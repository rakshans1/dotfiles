#!/bin/sh

# Chrome Driver
BASE_URL=https://chromedriver.storage.googleapis.com
VERSION=$(curl -sL "$BASE_URL/LATEST_RELEASE")
curl -sL "$BASE_URL/$VERSION/chromedriver_linux64.zip" -o  /tmp/driver.zip
unzip /tmp/driver.zip
chmod 755 chromedriver
sudo mv chromedriver /usr/bin/chromedriver
