#!/bin/bash

# Create the virtual environment
python3 -m venv create_layer

# Activate the virtual environment
source create_layer/bin/activate

# Install the required packages
pip install beautifulsoup4
pip install requests
pip install pymongo
pip install pymongo-auth-aws


# Create the python directory with lib structure
# AWS Lambda can find packages in python/lib/pythonX.Y/site-packages/
mkdir -p python/lib/python3.12/site-packages

# Copy the necessary library files to the correct directory structure for Lambda layers
cp -r create_layer/lib/python3.12/site-packages/* python/lib/python3.12/site-packages/

rm -rf create_layer/python3.12

# Zip the contents of the python directory
zip -9 -q -r scraper_layer_content.zip python

# Clean up
rm -rf python

# Deactivate the virtual environment
deactivate
