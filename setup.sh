#!/bin/bash
DIR="/home/minecraft"
if [ -d "$DIR" ]; then
        echo "$DIR already exists"
else
        echo "Create $DIR"
        mkdir $DIR
fi
mkdir "$DIR/toold"
cd "$DIR/toold"

HELP="***Select possible download***
q : quit
h : help
0 : minecraft manager
1 : forge installer
2 : forge starter
3 : backup.sh
clear : clear all.
"

MCMANAGER="https://raw.githubusercontent.com/TaehyeonPark/ubuntu_setup/main/minecraft_mgmt.sh"
FORGE="https://raw.githubusercontent.com/TaehyeonPark/ubuntu_setup/main/forge_install.sh"
FORGESTART="https://raw.githubusercontent.com/TaehyeonPark/ubuntu_setup/main/forge_start.sh"
BACKUP="https://raw.githubusercontent.com/TaehyeonPark/ubuntu_setup/main/backup.sh"
helpme () { echo "$HELP"; }

while ! [ "$QUERY" == "q" ]
do
        read QUERY
        case $QUERY in
                "q")
                        echo ">> terminating mgmt.sh..."
                        ;;
                "h")
                        echo ">> help me!"
                        helpme
                        ;;
                "0")
                        echo ">> installing mincraft manager..."
                        wget $MCMANAGER
                        ;;
                "1")
                        echo ">> installing forge installer..."
                        wget $FORGE
                        ;;
                "2")
                        echo ">> installing forge starter..."
                        wget $FORGESTARTER
                        ;;
                "3")
                        echo ">> installing auto-backup script..."
                        wget $BACKUP
                        ;;
                "clear")
                        clear
                        ;;
                *)
                        echo ">> unknown command."
                        ;;
        esac
done
echo ">>>> setup.sh terminated."
