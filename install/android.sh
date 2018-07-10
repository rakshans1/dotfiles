"Install Java"

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -qq update > /dev/null 2>&1 
sudo apt-get install oracle-java8-installer > /dev/null 2>&1 

"Install Android"

wget https://dl.google.com/dl/android/studio/ide-zips/3.1.3.0/android-studio-ide-173.4819257-linux.zip
sudo unzip android-studio-ide-173.4819257-linux.zip -d /opt

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec="/opt/android-studio/bin/studio.sh" %f
Icon=/opt/android-studio/bin/studio.png
Categories=Development;IDE;
Terminal=false
StartupNotify=true
StartupWMClass=android-studio" >> ~/.local/share/applications/androidstudio.desktop

