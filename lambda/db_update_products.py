import pymongo
from datetime import datetime
import pylcs


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

    print(f"Found {len(all_products)} products in category '{category}'")

    # For each product, find its longest common substring with other products
    product_scores = []

    # for i in range(len(all_products)):
    for i in range(0, 1):
        longest_substring_length = 0
        longest_substring = ""
        compared_product = ""

        for j in range(len(all_products)):
            # compare product i with j+1 and so on
            # find the longest common substring
            # update the product[i] with the longest common substring

            if i != j:  # Don't compare product with itself
                str1 = all_products[i]['name']
                str2 = all_products[j]['name']

                indices = pylcs.lcs_string_idx(str1, str2)
                lcs = ''.join([str2[i] for i in indices if i != -1])

                print("Comparing: \n", str1, "\n", str2)
                print("LCS: ", lcs)
                print("Length: ", len(lcs))

                if len(lcs) > longest_substring_length:
                    longest_substring = lcs
                    longest_substring_length = len(lcs)
                    compared_product = all_products[j]['name']

        print("\n+++++++++++++++++++++++++++++\n")
        print("Compared with: ", compared_product)

        print("Longest common substring for product: ",
              all_products[i]['name'])
        print("Longest common substring: ", longest_substring)
        print("Length: ", longest_substring_length)

    # for i, product1 in enumerate(all_products):
    #     total_common_length = 0
    #     best_substring = ""
    #     best_substring_length = 0

    #     for j, product2 in enumerate(all_products):
    #         if i != j:  # Don't compare product with itself
    #             # Use pylcs to find the longest common substring
    #             str1 = product1['name'].lower()
    #             str2 = product2['name'].lower()

    #             # Get indices from the longest common substring
    #             indices = pylcs.lcs_string_idx(str1, str2)

    #             # Construct the substring using the indices
    #             lcs = ''.join([str2[i] for i in indices if i != -1])

    #             if lcs and len(lcs) > 3:  # Require at least 4 chars
    #                 if len(lcs) > best_substring_length:
    #                     best_substring = lcs
    #                     best_substring_length = len(lcs)
    #                     total_common_length += len(lcs)

    #     if best_substring:
    #         product_scores.append({
    #             'product_id': product1['_id'],
    #             'original_name': product1['name'],
    #             'best_substring': best_substring,
    #             'total_common_length': total_common_length
    #         })

    # if not product_scores:
    #     return {
    #         'statusCode': 404,
    #         'body': 'No significant common substrings found between products'
    #     }

    # # Find the product with the highest total common substring length
    # winner = max(product_scores, key=lambda x: x['total_common_length'])

    # # Update the winning product with its best common substring
    # result = products.update_one(
    #     {"_id": winner['product_id']},
    #     {"$set": {
    #         "name": winner['best_substring'],
    #         "updated_at": datetime.now()
    #     }}
    # )

    # return {
    #     'statusCode': 200,
    #     'body': f"Updated product from '{winner['original_name']}' to '{winner['best_substring']}'. Modified: {result.modified_count}"
    # }
