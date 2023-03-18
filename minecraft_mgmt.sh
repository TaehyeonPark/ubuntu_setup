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
PAPERMC="https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/397/downloads/paper-1.19.3-397.jar"
VELOCITY="https://api.papermc.io/v2/projects/velocity/versions/3.2.0-SNAPSHOT/builds/225/downloads/velocity-3.2.0-SNAPSHOT-225.jar"
PORT=25565
MINECRAFT_SERVER_SCREEN="minecraft_server"
VELOCITY_SERVER_SCREEN="velocity_for_papermc"

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
5 : automaticaly stop server, detatch active screen, cleanup backups, backup the world, start server.
6 : reattach server.
7 : detatch server.
8 : start velocity.
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

setup() {
        # first parameter is setup-mode
        case $1 in
        "0")
                setup_all
                ;;
        "1") # jdk
                eval "apt update"
                eval "apt install $JDK"
                ;;
        "2") # screen
                eval "apt update"
                eval "apt install screen"
                ;;
        "3") # minecraft server
                eval "curl -LO $MINECRAFT_SERVER"
                ;;
        "4") # ufw portforwarding
                eval "ufw allow $PORT"
                ;;
        "5") # papermc
                eval "curl -LO $PAPERMC"
                ;;
        "6") # velocity
                eval "curl -LO $VELOCITY"
                ;;
        *)
                echo "invalid parameter."
                ;;
        esac

}

setup_all() {
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

download_file() {
        echo ">>>> download $1..."
        sudo curl -LO $1
        echo ">>>> download complete."
}


file_exist() {
        if [ -f "$1" ]; then
                return 0
        else
                return 1
        fi
}

directory_exist() {
        if [ -d "$1" ]; then
                return 0
        else
                return 1
        fi
}

dir_disk_size() {
        du_ret=$(du -sb "$1")
        spilt=($(echo "$du_ret" | tr " /" "\n"))
        size=$((${spilt[0]}))
        return $size
}

backup_server() {
        echo "[$(date +%Y%m%d-%H%M%S)] backuping..."
        if directory_exist "./backups"; then
                echo "./backups/ found."
        else
                mkdir "backups"
        fi
        tar -cvpzf ./backups/world-$(date +%F-%H-%M).tar.gz ./world/
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
        if file_exist "server.jar"; then
                echo "server.jar found."
        else
                echo "server.jar not found. download from[ $MINECRAFT_SERVER ]? (y/n)"
                read yn
                if [ "$yn" == "y" ]; then
                        download_file $MINECRAFT_SERVER
                else
                        echo "server.jar not found. exit."
                        exit
                fi
        fi

        echo ">>>> type memsize default(4G, MAX=4G)"
        read mem

        if [ -z "${mem}" ] || [ $(expr $mem) -gt 20 ] || [ $(expr $mem) -lt 1 ]; then
                mem=$default_mem
        fi

        echo "$((mem))G will be allocated"
        echo "start minecraft server."

        eval "screen -dmS $MINECRAFT_SERVER_SCREEN java -Xms1024M -Xmx${mem}G -jar server.jar nogui"
}

auto_start_server() {
        echo "auto start minecraft server."
        echo "java -Xms1024M -Xmx4G -jar server.jar nogui"
        eval "screen -dmS $MINECRAFT_SERVER_SCREEN java -Xms1024M -Xmx4G -jar server.jar nogui"
}

reattach_server() {
        # First parameter is screen name
        eval "screen -r $1"
}

detatch_server() {
        # First parameter is screen name
        eval "screen -S $1 -X quit"
}

stop_server() {
        echo "stop minecraft server."
        eval "screen -S $MINECRAFT_SERVER_SCREEN -X stuff 'stop^M'"
}

backup_server_and_restart() {
        echo "backup server and restart."
        stop_server
        detatch_server $MINECRAFT_SERVER_SCREEN
        cleanup_disk
        backup_server
        auto_start_server
}

start_velocity() {
        # file system check
        sub_dir="velocity"
        velocity_file_name="velocity*"
        velocity_file_extension="jar"

        if [ -d "$sub_dir" ]; then
                echo "velocity directory found."
        else
                echo "velocity directory not found."
                echo ">> 1. Create directory"
                echo ">> 2. Make symbolic link"
                read yn
                if [ "$yn" == "1" ]; then
                        echo ">> create directory"
                        mkdir $sub_dir
                elif [ "$yn" == "2" ]; then
                        echo ">> make symbolic link"
                        echo ">>>> symbolic link target: $sub_dir"
                        read -p ">>>> enter symbolic link target: " link_target
                        eval "ln -s $link_target $sub_dir"
                else
                        echo "invalid parameter. exit."
                        exit
                fi
        fi

        # if there is jar file in velocity directory, execute it.
        find $sub_dir -name "$velocity_file_name.$velocity_file_extension" -exec echo "velocity jar file found. execute it." \;
        if [ $? -eq 0 ]; then
                echo "velocity jar file found. execute it."
                comm="java -Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar $sub_dir/$velocity_file_name.$velocity_file_extension"
                eval "screen -dmS $VELOCITY_SERVER_SCREEN $comm"
        fi
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
                echo ">> select which to setup."
                echo ">> 0. all"
                echo ">> 1. jdk"
                echo ">> 2. screen"
                echo ">> 3. minecraft server"
                echo ">> 4. ufw"
                echo ">> 5. papermc"
                echo ">> 6. velocity"
                read SETUP
                if [ -z "${SETUP}" ] || [ $(expr $SETUP) -gt 6] || [$(expr $SETUP) -lt 0 ]; then
                        echo ">> invalid input. exit."
                fi
                setup $SETUP
                ;;
        "1")
                echo ">> start server as a background-PS through screen."
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
        "6")
                echo ">> reattach server."
                echo ">> screens available:"
                screen -ls
                read -p ">> enter screen name: " screen_name
                reattach_server $screen_name
                ;;
        "7")
                echo ">> detatch server."
                echo ">> screens available:"
                screen -ls
                if [ $? -eq 0 ]; then
                        echo ">> no screen available."
                        continue
                else
                        read -p ">> enter screen name: " screen_name
                        detatch_server $screen_name
                fi
                ;;
        "8")
                echo ">> start velocity."
                start_velocity
                ;;
        "clear")
                clear
                ;;
        *)
                echo ">> unknwon command."
                ;;
        esac
done

echo ">>>> mgmt.sh finished."
