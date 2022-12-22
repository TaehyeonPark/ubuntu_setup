#!/usr/bin/env sh
# Edit the user_jvm_args.txt for more configuration.
# Add custom program arguments {such as nogui} to this file in the next line before the "$@" or
#  pass them to this script directly
MODE="nogui"
MEM=20
cd /home/minecraft
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.19.2-43.2.1/unix_args.txt $MODE
#java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.19.2-43.2.1/unix_args.txt "$@"
