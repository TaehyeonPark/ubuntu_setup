#!/bin/sh

### config ###
VELOCITY_SERVER_SCREEN="velocity_for_papermc"
HELP="*** help ***
q : quit
h : help
1 : Start velocity server as a background-PS through screen.
2 : Stop velocity server. (detatch active screen)
3 : reattach server.
4 : detatch server.
clear : clear command lines.
************
"
##############

stop_server() {
        if [ -z "$(screen -ls | grep $VELOCITY_SERVER_SCREEN)" ]; then
                echo ">> velocity server is not running."
        else
                echo ">> stopping velocity server..."
                screen -S $VELOCITY_SERVER_SCREEN -X stuff "stop^M"
        fi
}

reattach_server() {
        # First parameter is screen name
        eval "screen -r $1"
}

detatch_server() {
        # First parameter is screen name
        eval "screen -S $1 -X quit"
}

start_server() {
        if [ -z "$(screen -ls | grep $VELOCITY_SERVER_SCREEN)" ]; then
                echo ">> starting velocity server..."
                commd="java -Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity*.jar"
                eval "screen -dmS $VELOCITY_SERVER_SCREEN $commd"
        else
                echo ">> velocity server is already running."
        fi
}
helpme() { echo "$HELP"; }

helpme
while ! [ "$QUERY" == "q" ]; do
        read QUERY
        case $QUERY in
        "q")
                echo ">> terminating velocity.sh..."
                ;;
        "h")
                echo ">> help()"
                helpme
                ;;
        "1")
                echo ">> Start velocity server."
                start_server
                ;;
        "2")
                echo ">> Stop velocity server."
                stop_server
                detatch_server $VELOCITY_SERVER_SCREEN
                ;;
        "3")
                echo ">> reattach server."
                reattach_server $VELOCITY_SERVER_SCREEN
                ;;
        "4")
                echo ">> detatch server."
                detatch_server $VELOCITY_SERVER_SCREEN
                ;;
        "clear")
                clear
                ;;
        *)
                echo ">> unknwon command."
                ;;
        esac
done
