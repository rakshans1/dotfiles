"Install Java"

echo "Installing Java"
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq install oracle-java8-installer > /dev/null 2>&1

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

echo "Installing Android Dependencies"
sudo apt-get -qq install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 > /dev/null 2>&1

echo "Installing Android Sdk"
cd ~/
mkdir Android && cd Android
mkdir Sdk && cd Sdk
wget -O tools.zip https://dl.google.com/android/repository/tools_r25.2.5-linux.zip
unzip tools.zip && rm tools.zip

echo "y" | android update sdk -a -u -t platform-tools,android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26,build-tools-27.0.0
