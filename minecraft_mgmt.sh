#!/bin/bash
OS_type="ubuntu
centos
"
OS_info='/etc/os-release'
OS_ID=$(cat $OS_info | grep "^ID=")
for ID in $OS_type #
do
        if [ "$OS_ID" == "ID=$ID" ]; then
                echo "start with $ID."
                OS_ID=$ID
        fi
done

### Config ###
JDK="openjdk-18-jdk"
MINECRAFT_SERVER="https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
PORT=25565
### ###### ###

HELP="*** help ***
q : quit
h : help
0 : setup minecraft server.
1 : start minecraft server as a background-PS through screen.
2 : backup script setting.
clear : clear
************
"
helpme () { echo "$HELP"; }
sudocheck () {
        echo "sudo cheking."
        echo "EUID=$EUID."
        if [ $EUID -ne 0 ]; then
                echo "please run as root"
                exit
        fi
}
sudocheck
helpme

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
                        echo ">> setup server..."
                        echo ">>>> apt update..."
                        sudo apt update
                        echo ">>>> apt updated."
                        echo ">>>> install $JDK..."
                        sudo apt install $JDK
                        echo ">>>> $JDK installation complete."
                        echo ">>>> install screen..."
                        sudo apt install screen
                        echo ">>>> screen installation complete."
                        echo ">>>> install minecraft server..."
                        echo ">>>> $MINECRAFT_SERVER"
                        sudo wget $MINECRAFT_SERVER
                        echo ">>>> minecraft server installation complete."

                        echo ">>>> ufw configuration..."
                        sudo ufw allow $PORT
                        echo ">>>> ufw configuration complete."
                        ;;
                "clear")
                        clear
                        ;;
                *)
                        echo ">> unknwon command."
                        ;;
        esac
done

echo ">>> mgmt.sh finished."

helpme () { echo "$HELP"; }
