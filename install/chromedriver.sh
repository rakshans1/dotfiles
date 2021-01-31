#!/bin/sh
set -e
# Chrome Driver

OS="$(uname -s)"

case $OS in
    "Linux")
        PLATFORM="linux64"
    ;;
    "Darwin")
        PLATFORM="mac64"
    ;;
esac

BASE_URL=https://chromedriver.storage.googleapis.com
VERSION=$(curl -sL "$BASE_URL/LATEST_RELEASE")
TEMP_DIRECTORY=$(mktemp -d)

echo "Downloading $VERSION ..."
wget -q --show-progress "$BASE_URL/$VERSION/chromedriver_$PLATFORM.zip" -O  "$TEMP_DIRECTORY/chromedriver.zip"

if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting File..."
unzip "$TEMP_DIRECTORY/chromedriver.zip" -d $TEMP_DIRECTORY/
sudo mv "$TEMP_DIRECTORY/chromedriver" /usr/local/bin/
