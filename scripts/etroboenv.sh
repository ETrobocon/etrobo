#!/usr/bin/env bash
# etrobo environment core
#   etroboenv.sh 
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

if [ "$1" = "unset" ]; then
    . sim unset
    . download.sh unset
    . etrobopath.sh unset
    unset ETROBO_ENV
    unset ETROBO_ENV_VER
    unset ETROBO_SCRIPTS
    unset ETROBO_ATHRILL_GCC
    unset ETROBO_ATHRILL_TARGET
    unset ETROBO_HRP3_SDK
    unset ETROBO_HRP3_WORKSPACE
    unset ETROBO_ATHRILL_SDK
    unset ETROBO_ATHRILL_WORKSPACE
    unset ETROBO_SDCARD
    unset ETROBO_OS
    unset ETROBO_KERNEL
    unset ETROBO_KERNEL_POSTFIX
    unset ETROBO_USERPROFILE
    unset ETROBO_SIM_VER
    unset ETROBO_SIM_NAME
    unset ETROBO_EXE_POSTFIX
    unset ETROBO_LAUNCH_SIM
    unset ETROBO_LAUNCH_ASP
else
    if [ ! -f "$ETROBO_ROOT/disable" ]; then
        export ETROBO_ENV="available"
        export ETROBO_SCRIPTS="$ETROBO_ROOT/scripts"
        export ETROBO_ATHRILL_GCC="$ETROBO_ROOT/athrill-gcc-package/usr/local/athrill-gcc"
        export ETROBO_HRP3_SDK="$ETROBO_ROOT/hrp3/sdk"
        export ETROBO_HRP3_WORKSPACE="$ETROBO_HRP3_SDK/workspace"
        export ETROBO_ATHRILL_SDK="$ETROBO_ROOT/ev3rt-athrill-v850e2m/sdk"
        export ETROBO_ATHRILL_WORKSPACE="$ETROBO_ATHRILL_SDK/workspace"
        export ETROBO_SDCARD="$ETROBO_ROOT/ev3rt-1.0-release/sdcard"

        if [ `uname` == "Darwin" ]; then
            export ETROBO_OS="mac"
            export ETROBO_KERNEL="darwin"
            export ETROBO_KERNEL_POSTFIX="mac"
            export ETROBO_USERPROFILE="$HOME_ORG"
            export ETROBO_EXE_POSTFIX=".app"
        elif [ `uname -r | sed -E "s/^.*-(.*)$/\1/"` == "Microsoft" ]; then
            export ETROBO_OS="win"
            export ETROBO_KERNEL="debian"
            export ETROBO_KERNEL_POSTFIX="linux"
            export ETROBO_USERPROFILE="$(cmd.exe /c echo %USERPROFILE% | sed -r 's/^(.{1}):.*$/\/mnt\/\L&/' | sed -r 's/:|\r|\n//g' | sed -r 's/\\/\//g')"
            #export ETROBO_LAUNCH_SIM='cmd.exe /c "%USERPROFILE%\\etrobosim${ETROBO_SIM_VER}_${ETROBO_OS}\\${ETROBO_SIM_NAME}${ETROBO_EXE_POSTFIX}" &'
            export ETROBO_EXE_POSTFIX=".exe"
        elif [ "`ls /mnt/chromeos > /dev/null 2>&1; echo $?`" = "0" ]; then
            export ETROBO_OS="chrome"
            export ETROBO_KERNEL="debian"
            export ETROBO_KERNEL_POSTFIX="linux"
            export ETROBO_USERPROFILE="$HOME"
            export ETROBO_EXE_POSTFIX=".x86_64"
        elif [ `uname` == "Linux" ]; then
            export ETROBO_OS="linux"
            export ETROBO_KERNEL="debian"
            export ETROBO_KERNEL_POSTFIX="linux"
            export ETROBO_USERPROFILE="$HOME"
            export ETROBO_EXE_POSTFIX=".x86_64"
        fi

        export ETROBO_ATHRILL_TARGET="$ETROBO_ROOT/athrill-target-v850e2m/build_${ETROBO_KERNEL_POSTFIX}"

        . "$ETROBO_SCRIPTS/etrobopath.sh" unset
        export ETROBO_ENV_VER=`cd "$ETROBO_ROOT"; git show -s --date=short --format="%cd.%h"`
        . "$ETROBO_SCRIPTS/etrobopath.sh"

        # import module envs
        . "$ETROBO_SCRIPTS/sim" env
        . "$ETROBO_SCRIPTS/etrobopkg" env
        . "$ETROBO_SCRIPTS/etrobopath.sh"

        if [ "$BEERHALL_INVOKER" != "booting" ]; then
            echo
            echo "etrobo environment: Ready. (Ver.$ETROBO_ENV_VER)"
            echo
            echo 'to disable this environment, run `touch $ETROBO_ROOT/disable` and restart terminal'
            echo
        fi
    else
        echo
        echo "etrobo environment: Disabled."
        echo
        echo 'to re-enable this environment, run `rm $ETROBO_ROOT/disable` and restart terminal'
        echo
    fi
fi
