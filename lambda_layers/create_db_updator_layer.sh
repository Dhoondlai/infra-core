#!/bin/bash

# Create the virtual environment
python3 -m venv create_db_updator_layer

# Activate the virtual environment
source create_db_updator_layer/bin/activate

# Install the pylcs package
pip install groq
pip install pymongo
pip install pymongo-auth-aws

# Create the python directory
mkdir -p python/lib/python3.12/site-packages

# Copy the necessary library files to the correct directory structure for Lambda layers
cp -r create_db_updator_layer/lib/python3.12/site-packages/* python/lib/python3.12/site-packages/

# Zip the contents of the python directory
zip -9 -q -r db_updator_layer_content.zip python

rm -rf python

# Deactivate the virtual environment
deactivate
