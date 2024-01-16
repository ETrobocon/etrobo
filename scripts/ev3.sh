#!/usr/bin/env bash
#
# EV3 utility for EV3RT
#
# ev3.sh
#
# for etrobo environment Ver 3.10a.220531
# Copyright (c) 2020-2022 jtLab, Hokkaido Information University
# by TANAHASHI, Jiro(aka jtFuruhata) <jt@do-johodai.ac.jp>
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#

# please change this IP address if you have changed from default value
BTPAN_IP="10.0.10.1"

# `ev3 cp` copies app via Bluetooth PAN if connected
if [ "$1" = "cp" ]; then
    ping -c 1 -W 1 $BTPAN_IP > /dev/null
    if [ $? -eq 0 ]; then
        curl -m 1 $BTPAN_IP > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            name="$2"
            if [ -z "$name" ]; then
                name="app"
            fi
            make upload ip=$BTPAN_IP from=$ETROBO_HRP3_WORKSPACE/app to=$name
            exit $?
        fi
    fi
fi

mountInfo=`$ETROBO_SCRIPTS/mount.sh export`
if [ $? -eq 0 ]; then
    eval $mountInfo;
    case "$1" in
    "ls" )
        ls "$ETROBO_EV3RT_USB/ev3rt/apps"
        ;;
    "cp" )
        name=app
        if [ -n "$2" ]; then
            name=$2
        fi
        rm -f "$ETROBO_EV3RT_USB/ev3rt/apps/"$name
        cp "$ETROBO_HRP3_WORKSPACE/app" "$ETROBO_EV3RT_USB/ev3rt/apps/$name"
        echo "'$name' is copied into EV3."
        ;;
    "rm" )
        if [ -z "$2" ]; then
            name=app
        elif [ "$2" = "all" ]; then
            name=*
        else
            name=$2
        fi
        rm -f "$ETROBO_EV3RT_USB/ev3rt/apps/"$name
        echo "'$name' is removed from EV3."
        ;;
    "install" )
        if [ "$2" = "clean" ]; then
            echo "erase all files"
            rm -rf "$ETROBO_EV3RT_USB/uImage" 2> /dev/null
            rm -rf "$ETROBO_EV3RT_USB/ev3rt" 2> /dev/null
        fi
        rm -rf "$ETROBO_EV3RT_USB/uImage" 2> /dev/null
        if [ "$2" = "img" ]; then
            cp "$ETROBO_HRP3_WORKSPACE/uImage" "$ETROBO_EV3RT_USB/"
        else
            cp "$ETROBO_SDCARD/uImage" "$ETROBO_EV3RT_USB/"
            if [ ! -d "$ETROBO_EV3RT_USB/ev3rt" ]; then
                rm -f "$ETROBO_EV3RT_USB/ev3rt" 2> /dev/null
                mkdir "$ETROBO_EV3RT_USB/ev3rt"
            fi
            if [ ! -d "$ETROBO_EV3RT_USB/ev3rt/apps" ]; then
                rm -f "$ETROBO_EV3RT_USB/ev3rt/apps" 2> /dev/null
                mkdir "$ETROBO_EV3RT_USB/ev3rt/apps"
            fi
            if [ ! -d "$ETROBO_EV3RT_USB/ev3rt/res" ]; then
                rm -f "$ETROBO_EV3RT_USB/ev3rt/res" 2> /dev/null
                mkdir "$ETROBO_EV3RT_USB/ev3rt/res"
            fi
            if [ ! -d "$ETROBO_EV3RT_USB/ev3rt/etc" ]; then
                rm -f "$ETROBO_EV3RT_USB/ev3rt/etc" 2> /dev/null
                mkdir "$ETROBO_EV3RT_USB/ev3rt/etc"
            fi
            if [ ! -f "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" ]; then
                rm -rf "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" 2> /dev/null
                cp "$ETROBO_SDCARD/ev3rt/etc/rc.conf.ini" "$ETROBO_EV3RT_USB/ev3rt/etc/"
            fi
        fi
        echo "install EV3RT successed. please reboot this EV3 to apply."
        ;;
    "name" )
        name=`cat "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" | grep ^LocalName | sed -e 's/\(.*\)=\(.*\)/\2/g'`
        if [ -z "$2" ]; then
            echo $name
        else
            shift 1
            newName="$@"
            tmpFile=`mktemp`
            while read line; do
                if [ -z "`echo $line | grep ^LocalName`" ]; then
                    echo "$line" >> $tmpFile
                else
                    shift 1
                    echo "LocalName=$newName" >> $tmpFile
                fi
            done < "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini"
            rm -f "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" > /dev/null 2>&1
            mv -f $tmpFile "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" > /dev/null 2>&1
            echo "please reboot this EV3 to change LocalName to '`ev3.sh name`'"
        fi
        ;;
    "pin" )
        pin=`cat "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" | grep ^PinCode | sed -e 's/\(.*\)=\(.*\)/\2/g'`
        if [ -z "$2" ]; then
            echo $pin
        else
            newPin=$2
            tmpFile=`mktemp`
            while read line; do
                if [ -z "`echo $line | grep ^PinCode`" ]; then
                    echo "$line" >> $tmpFile
                else
                    shift 1
                    echo "PinCode=$newPin" >> $tmpFile
                fi
            done < "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini"
            rm -f "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" > /dev/null 2>&1
            mv -f $tmpFile "$ETROBO_EV3RT_USB/ev3rt/etc/rc.conf.ini" > /dev/null 2>&1
            echo "please reboot this EV3 to change PinCode to '`ev3.sh pin`'"
        fi
        ;;
    * )
        echo "Usage: ev3 [<command> [<params>]]"
        echo
        echo "   ls                 show file list in EV3 apps directory"
        echo "   cp [<name>]        copy app into EV3 apps as specified name"
        echo "   rm [<name>]        remove app from EV3 apps directory"
        echo "   rm all             remove all apps from EV3 apps directory"
        echo
        echo "   install            install the EV3RT dynamic-loader uImage and folders"
        echo "   install img        install a uImage in the workspace folder"
        echo "   install clear      remove uImage and folders before install"
        echo
        echo "   name               show current [Bluetooth]LocalName"
        echo "   name <newName>     set [Bluetooth]LocalName to <newName>"
        echo
        echo "   pin                show current [Bluetooth]PinCode"
        echo "   pin <newPinCode>   set [Bluetooth]PinCode to <newPinCode>"
        echo
        echo "'name' and 'pin' will be change after rebooting EV3"
        ;;
    esac
else
    echo
    echo "EV3 control: operation failed: EV3RT device is disconnected."
    echo
    exit 1
fi
