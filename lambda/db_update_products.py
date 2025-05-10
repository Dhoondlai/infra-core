import pymongo
from datetime import datetime
import json
from groq import Groq
import os
import boto3

if os.environ.get("IS_LOCAL"):
    print("Using local key and local mongodb.")
    groq_api_key = os.environ.get("GROQ_API_KEY")
    client = pymongo.MongoClient("mongodb://localhost:27017/")
else:

    # fetch from parameter store
    ssm = boto3.client('ssm', region_name='us-east-1')
    response = ssm.get_parameter(Name='groq-api-key', WithDecryption=True)
    mongodb_uri = ssm.get_parameter(Name='mongo-uri', WithDecryption=True)
    groq_api_key = response['Parameter']['Value']
    uri = mongodb_uri['Parameter']['Value']
    client = pymongo.MongoClient(uri)

# Rename the Groq client to avoid variable name collision
groq_client = Groq(
    api_key=groq_api_key,
)


def run(event, context):
    # Connect to MongoDB
    db = client.dhoondlai
    products = db.products

    # Get the category from the event
    category = event.get('category')
    if not category:
        return {
            'statusCode': 400,
            'body': 'Category parameter is required'
        }

    # Fetch all products in the category
    all_products = list(products.find({"category": category}))
    if not all_products:
        return {
            'statusCode': 404,
            'body': f'No products found for category: {category}'
        }
    print(f"\nFound {len(all_products)} products in category '{category}'\n")

    # Process products in batches to avoid overloading
    batch_size = 15
    updated_count = 0
    skipped_count = 0

    for i in range(0, len(all_products), batch_size):
        batch = all_products[i:i+batch_size]

        # Filter out products without names
        valid_products = [p for p in batch if p.get('name', '')]

        if not valid_products:
            continue

        # Create a combined prompt for standardizing multiple product names
        product_list_text = "\n".join(
            [f"{idx+1}. \"{p['name']}\"" for idx, p in enumerate(valid_products)])

        prompt = f"""
        Extract the standard base model names from these PC parts. Numbered list format:

        {product_list_text}
        
        Rules:
        1. Remove marketing phrases like "Buy", "Desktop Processor", "Processor", "Motherboard" etc.
        2. Keep the core product identifiers (e.g., "AMD Ryzen 5 2600")
        3. Remove packaging info like "Tray", "Used"
        4. Remove parentheses and their contents
        5. You can change the order of words if needed (e.g, Intel Core 12th Gen i3 12100F -> Intel Core i3 12100F)
        
        Return your answer in this exact format with one standardized name per line:
        1. [standardized name 1]
        2. [standardized name 2]
        ... and so on
        
        Include ONLY the numbered list, nothing else.
        """

        try:
            response = groq_client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {"role": "system",
                        "content": "You are a product name standardization assistant."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=500,
                temperature=0.1
            )

            standard_names_text = response.choices[0].message.content.strip()

            # Parse the response to extract standardized names
            standard_names = []
            for line in standard_names_text.split('\n'):
                line = line.strip()
                if line and line[0].isdigit() and '. ' in line:
                    standard_name = line.split('. ', 1)[1].strip()
                    if standard_name.startswith('[') and standard_name.endswith(']'):
                        standard_name = standard_name[1:-1].strip()
                    standard_names.append(standard_name)

            # Ensure we have the same number of standardized names as products
            if len(standard_names) == len(valid_products):
                bulk_updates = []

                # Prepare bulk updates
                for product, standard_name in zip(valid_products, standard_names):
                    print(
                        f"Standardizing: '{product['name']}' → '{standard_name}'")
                    bulk_updates.append(
                        pymongo.UpdateOne(
                            {"_id": product["_id"]},
                            {"$set": {
                                "standard_name": standard_name,
                                "updated_at": datetime.now()
                            }}
                        )
                    )

                # Execute bulk update
                if bulk_updates:
                    result = products.bulk_write(bulk_updates)
                    updated_count += result.modified_count
                    print(
                        f"Updated {result.modified_count} products in this batch")
            else:
                print(
                    f"Error: Received {len(standard_names)} standard names for {len(valid_products)} products")
                skipped_count += len(valid_products)

        except Exception as e:
            print(f"Error processing batch: {str(e)}")
            skipped_count += len(valid_products)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'category': category,
            'total_products': len(all_products),
            'updated': updated_count,
            'skipped': skipped_count
        })
    }
