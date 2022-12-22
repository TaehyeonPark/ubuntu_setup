#!/bin/bash
cd /home/minecraft
#URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.2.1/forge-1.19.2-43.2.1-installer.jar"
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar"
MODE="server"
FILENAME="forge_$MODE.jar"
echo "save file as $FILENAME"
wget -O $FILENAME $URL
java -jar $FILENAME --installServer
