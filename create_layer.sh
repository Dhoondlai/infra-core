python3 -m venv create_layer
source create_layer/bin/activate
pip install beautifulsoup4
pip install requests
pip install pymongo
mkdir python
cp -r create_layer/lib python/
zip -r scraper_layer_content.zip python
rm -rf create_layer
rm -rf python
deactivate