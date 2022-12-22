#!/bin/bash
cd /home/minecraft
#URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.2-43.2.1/forge-1.19.2-43.2.1-installer.jar"
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar"
MODE="server"
FILENAME="forge_$MODE.jar"
echo "installer : saved as $FILENAME"
wget -O $FILENAME $URL
if [ $MODE=="server" ]; then
        echo "forge-$MODE will be installed."
        java -jar $FILENAME --installServer
elif [ $MODE=="client" ]; then
        echo "forge-$MODE will be installed."
        java -jar $FILENAME --installClient
else
        echo "$MODE : such mode dose not exist."
fi
