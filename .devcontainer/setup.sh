#!/bin/bash
set -e

# Flutter
git clone https://github.com/flutter/flutter.git ~/flutter --depth 1 -b stable
echo 'export PATH=$PATH:$HOME/flutter/bin' >> ~/.bashrc

# Android SDK
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip
unzip -q tools.zip && mv cmdline-tools latest && rm tools.zip

echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

~/flutter/bin/flutter config --android-sdk ~/android-sdk
~/flutter/bin/flutter precache --android
