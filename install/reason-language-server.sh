#!/bin/bash
set -e

OS="$(uname -s)"

case $OS in
    "Linux")
        PLATFORM="linux"
    ;;
    "Darwin")
        PLATFORM="macos"
    ;;
esac

VERSION="$(curl -s "https://api.github.com/repos/jaredly/reason-language-server/releases/latest" | jq -r .tag_name | sed 's/v//')" 

PACKAGE_NAME="rls-$PLATFORM.zip"
TEMP_DIRECTORY=$(mktemp -d)

echo "Downloading $PACKAGE_NAME ..."
wget -q --show-progress https://github.com/jaredly/reason-language-server/releases/download/$VERSION/$PACKAGE_NAME -O "$TEMP_DIRECTORY/rls.zip"

if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi

echo "Extracting File..."
unzip "$TEMP_DIRECTORY/rls.zip" -d $TEMP_DIRECTORY/
sudo mv "$TEMP_DIRECTORY/rls-$PLATFORM/reason-language-server" /usr/local/bin/
