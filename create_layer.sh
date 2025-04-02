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
pip install pylcs

# Create the python directory
mkdir python

# Copy the necessary library files to your python directory
cp -r create_layer/lib/python* python/

# Zip the contents of the python directory
zip -9 -q -r scraper_layer_content.zip python

rm -rf python

# Deactivate the virtual environment
deactivate
