#!/usr/bin/env bash
#
# Windows auto EV3 mounter/EV3 detector for EV3RT
#
# mount.sh
#
# for etrobo environment Ver 2.10a.200621
# Copyright (c) 2020 jtLab, Hokkaido Information University
# by TANAHASHI, Jiro(aka jtFuruhata) <jt@do-johodai.ac.jp>
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#

# MEMO:
# win: no auto mount, use /mnt/ev3 from here
# mac: /Volumes/{volume name}
# ubuntu: /media/{user name}/{volume name}

unset ready
unset physicalDrive
unset volumeName

if [ "$ETROBO_OS" = "win" ]; then
    mountPath="/mnt/ev3"
    Caption=""
    VolumeName=""
    tmpFile=$(mktemp)

    wmic.exe LogicalDisk get Caption,VolumeName > $tmpFile
    while read line; do
        if [ ${line:1:1} = ":"  ]; then
            if [ "${line:9:5}" = "EV3RT" ]; then
                Caption="${line:0:2}"
                physicalDrive=${Caption:0:1}
                volumeName=`echo ${line:9:-2}`
            fi
        fi
    done < $tmpFile
    rm $tmpFile

    if [ $Caption ]; then
        if [ -z "$1" ]; then
            echo "EV3 auto mounter needs permission as sudoers."
            echo "Please enter your login password if [sudo] ask you."
        fi
        if [ ! -d "$mountPath" ]; then
            sudo mkdir "$mountPath" 2> /dev/null
        fi
        sudo mount -t drvfs $Caption "$mountPath"
        if [ "$?" -eq 0 ]; then
            ready="ready"
        fi
    fi
else
    if [ "$ETROBO_OS" = "mac" ]; then
        physicalDrive="/Volumes"
    elif [ "$ETROBO_OS" = "chrome" ]; then
        physicalDrive="/mnt/chromeos/removable"
    elif [ "$ETROBO_KERNEL" = "debian" ]; then
        physicalDrive="/media/$(basename $ETROBO_USERPROFILE)"
    else
        physicalDrive="/mnt"
    fi
    volumeName=`ls -1 "$physicalDrive" | grep ^EV3RT | head -n 1`
    if [ -n "$volumeName" ]; then
        mountPath="$physicalDrive/$volumeName"
        ready="ready"
    fi
fi

if [ -n "$ready" ]; then
    if [ "$1" = "export" ]; then
        echo "export ETROBO_EV3RT_USB=\"$mountPath\""
    else
        echo "$physicalDrive $volumeName -> $mountPath"
        if [ -d "$mountPath/ev3rt/apps" ]; then
            ls "$mountPath/ev3rt/apps"
        fi
    fi
else
    exit 1
fi
