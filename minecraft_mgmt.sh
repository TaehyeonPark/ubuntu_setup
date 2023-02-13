#!/bin/bash
OS_type="ubuntu
centos
"
OS_info='/etc/os-release'
OS_ID=$(cat $OS_info | grep "^ID=")
for ID in $OS_type; do #
        if [ "$OS_ID" == "ID=$ID" ]; then
                echo "start with $ID."
                OS_ID=$ID
        fi
done

### Config ###
JDK="openjdk-18-jdk"
MINECRAFT_SERVER="https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar"
PORT=25565
SCREEN_NAME="minecraft_server"

dir="/backups"
pattern="world-*"
threshold_mem_size=5368709120

default_mem="4"

HELP="*** help ***
q : quit
h : help
0 : setup minecraft server.
1 : start minecraft server as a background-PS through screen.
2 : stop minecraft server. (detatch active screen)
3 : backup the world. (./world/.)
4 : cleanup automaticaly obsolete one.
5 : backup server and restart.
clear : clear command lines.
************
"
### ###### ###

sudocheck() {
        echo "sudo cheking."
        echo "EUID=$EUID."
        if [ $EUID -ne 0 ]; then
                echo "please run as root"
                exit
        fi
}

setup_setup() {
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
        sudo curl -LO $MINECRAFT_SERVER
        echo ">>>> minecraft server installation complete."

        echo ">>>> ufw configuration..."
        sudo ufw allow $PORT
        echo ">>>> ufw configuration complete."
}


dir_disk_size() {
        du_ret=$(du -sb "$1")
        spilt=($(echo "$du_ret" | tr " /" "\n"))
        size=$((${spilt[0]}))
        return $size
}

backup_server() {
        echo "[$(date +%Y%m%d-%H%M%S)] backuping..."
        tar -cvpzf /backups/world-$(date +%F-%H-%M).tar.gz ./world/
        echo "[$(date +%Y%m%d-%H%M%S)] backuped."
}

remove_latest() {
        echo "[$(find $dir -name "$pattern" -printf '%T+ %p\n' | sort | head -n 1)] will be deleted."
        rm -rf $(find $dir -name "$pattern" -printf '%T+ %p\n' | sort | head -n 1)
        echo "Removing success."
}

cleanup_disk() {
        dir_disk_size $dir
        ret=$size
        #if [ `expr $ret > $threshold_mem_size` ]; then
        if (($ret > $threshold_mem_size)); then
                echo "out of memory [$ret]"
                echo "freeing up space..."
                remove_latest
        else
                echo "enough memory left [$ret]"
        fi
}

start_server() {
        read mem
        if [ -z "${mem}" ] || [ $(expr $mem) -gt 20 ] || [ $(expr $mem) -lt 1 ]; then
                mem=$default_mem
        fi
        echo "$((mem))G will be allocated"
        echo "start minecraft server."
        echo "java -Xms1024M -Xmx${mem}G -jar server.jar nogui"
        eval "screen -dmS $SCREEN_NAME java -Xms1024M -Xmx${mem}G -jar server.jar nogui"
}

auto_start_server() {
        echo "auto start minecraft server."
        echo "java -Xms1024M -Xmx4G -jar server.jar nogui"
        eval "screen -dmS $SCREEN_NAME java -Xms1024M -Xmx4G -jar server.jar nogui"
}

reattach_server() {
        echo "reattach minecraft server."
        eval "screen -r $SCREEN_NAME"
}

detatch_server() {
        echo "detatch minecraft server."
        eval "screen -d $SCREEN_NAME"
}

stop_server() {
        echo "stop minecraft server."
        eval "screen -S $SCREEN_NAME -X stuff 'stop^M'"
}

backup_server_and_restart() {
        echo "backup server and restart."
        stop_server
        cleanup_disk
        backup_server
        auto_start_server
}

helpme() { echo "$HELP"; }

sudocheck
helpme

while ! [ "$QUERY" == "q" ]; do
        read QUERY
        case $QUERY in
        "q")
                echo ">> terminating mgmt.sh..."
                ;;
        "h")
                echo ">> help()"
                helpme
                ;;
        "0")
                echo ">> setup server..."
                setup_setup
                ;;
        "1")
                echo ">> start server as a background-PS through screen."
                echo ">>>> type memsize default(4G, MAX=4G)"
                start_server
                ;;
        "2")
                echo ">> stop server."
                stop_server
                ;;
        "3")
                echo ">> backup the world."
                backup_server
                echo ">> backuped."
                ;;
        "4")
                echo ">>>> cleanup backups."
                cleanup_disk
                echo ">>>> cleanup finished."
                ;;
        "5")
                echo ">> backup server and restart."
                backup_server_and_restart
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
