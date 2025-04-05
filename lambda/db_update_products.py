import pymongo
from datetime import datetime
import json
from groq import Groq
import os
import boto3

if os.environ.get("IS_LOCAL"):
    print("Using local key.")
    groq_api_key = os.environ.get("GROQ_API_KEY")
else:

    # fetch from parameter store
    ssm = boto3.client('ssm', region_name='us-east-1')
    response = ssm.get_parameter(Name='groq-api-key', WithDecryption=True)
    groq_api_key = response['Parameter']['Value']

# Rename the Groq client to avoid variable name collision
groq_client = Groq(
    api_key=groq_api_key,
)


def run(event, context):
    # Connect to MongoDB
    client = pymongo.MongoClient("mongodb://localhost:27017/")
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
    batch_size = 20
    updated_count = 0
    skipped_count = 0

    # Process all products
    # for i in range(0, len(all_products), batch_size):
    for i in range(0, 1):
        batch = all_products[i:i+batch_size]
        for product in batch:
            original_name = product.get('name', '')
            if not original_name:
                skipped_count += 1
                continue

            # Create a prompt for standardizing the product name
            prompt = f"""
            Extract the standard base model name from this PC part:
            "{original_name}"
            
            Rules:
            1. Remove marketing phrases like "Buy", "Desktop Processor", "Processor", "Motherboard" etc.
            2. Keep the core product identifiers (e.g., "AMD Ryzen 5 2600")
            3. Remove packaging info like "Tray", "Used"
            4. Remove parentheses and their contents
            5. You can change the order of words if needed (e.g, Intel Core 12th Gen i3 12100F -> Intel Core i3 12100F)
            
            Return ONLY the standardized name, nothing else.
            """

            try:
                response = groq_client.chat.completions.create(
                    model="qwen-2.5-32b",
                    messages=[
                        {"role": "system",
                            "content": "You are a product name standardization assistant."},
                        {"role": "user", "content": prompt}
                    ],
                    max_tokens=50,
                    temperature=0.1
                )

                standard_name = response.choices[0].message.content.strip()

                # Update the product in the database
                result = products.update_one(
                    {"_id": product["_id"]},
                    {"$set": {
                        "standard_name": standard_name,
                        "updated_at": datetime.now()
                    }}
                )

                if result.modified_count > 0:
                    updated_count += 1
                    print(f"Updated: '{original_name}' → '{standard_name}'")
                else:
                    skipped_count += 1

            except Exception as e:
                print(f"Error processing {original_name}: {str(e)}")
                skipped_count += 1

    return {
        'statusCode': 200,
        'body': json.dumps({
            'category': category,
            'total_products': len(all_products),
            'updated': updated_count,
            'skipped': skipped_count
        })
    }
