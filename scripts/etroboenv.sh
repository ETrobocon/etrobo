#!/usr/bin/env bash
# etrobo environment core
#   etroboenv.sh 
# Author: jtFuruhata
# Copyright (c) 2020-2026 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

currentDir="`pwd`"

# against VSCode bug on WSL2
if [ "$ETROBO_OS_SUBSYSTEM" == "WSL2" ] || [ -n "`uname -r | grep WSL2`" ]; then
    for process in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${process}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${process}_interop
        fi
    done
fi

# recognize target devenv
if [ -z "$ETROBO_ENV_MODE" ]; then
    if [ -f "$ETROBO_ROOT/NXT" ]; then
        export ETROBO_ENV_MODE="NXT"
        export ETROBO_ENV_TARGET="physical"
    elif [ -f "$ETROBO_ROOT/EV3" ]; then
        export ETROBO_ENV_MODE="EV3"
        export ETROBO_ENV_TARGET="simulator"
    elif [ -f "$ETROBO_ROOT/SPIKE_RT" ]; then
        export ETROBO_ENV_MODE="SPIKE-RT"
        export ETROBO_ENV_TARGET="physical"
    elif [ -f "$ETROBO_ROOT/SPIKE" ]; then
        export ETROBO_ENV_MODE="SPIKE"
        export ETROBO_ENV_TARGET="simulator"
    else
        export ETROBO_ENV_MODE="SPIKE"
        export ETROBO_ENV_TARGET="simulator"
    fi
fi

# switch workspace
if [ "$ETROBO_ENV_MODE" = "EV3" ]; then
    # select EV3RT kernel version
    ver=`ls -1 "$ETROBO_ROOT" | grep "^ev3rt-.*-release" | grep -v beta | tail -n 1 | sed -E "s/^ev3rt-(.*)-release$/\1/"`
    file="$ETROBO_ROOT/select_kernel_version"
    if [ -f "$file" ]; then
        ver=`cat "$file"`
    fi
    if [ -z "$ver" ]; then
        ver="1.1"
    fi
    kernel="hrp3"
    if [ -n "`echo $ver | grep beta`" ]; then
        kernel="hrp2"
    fi
elif [ "$ETROBO_ENV_MODE" = "SPIKE" ]; then
    kernel="raspike-athrill-v850e2m"
elif [ "$ETROBO_ENV_MODE" = "SPIKE-RT" ]; then
    kernel="spike-rt"
fi
if [ "$ETROBO_ENV_MODE" = "NXT" ]; then
    targetSDK="$ETROBO_ROOT/nxtOSEK"
else
    targetSDK="$ETROBO_ROOT/$kernel/sdk"
fi
targetWorkspace="$targetSDK/workspace"

currentWorkspace="`ls -la "$ETROBO_ROOT" | grep 'workspace ->' | sed -E 's/.* workspace -> (.*)$/\1/'`"
if [ "$targetWorkspace" != "$currentWorkspace" ] && [ -d "$targetWorkspace" ]; then
    rm -f "$ETROBO_ROOT/workspace"
    ln -s "$targetWorkspace" "$ETROBO_ROOT/workspace"
fi

if [ "$1" = "unset" ]; then
    . sim unset
    . etrobopkg unset
    . spike unset
    . etrobopath.sh unset
    unset ETROBO_ENV
    unset ETROBO_ENV_MODE
    unset ETROBO_ENV_TARGET
    unset ETROBO_ENV_VER
    unset ETROBO_SCRIPTS
    unset ETROBO_TARGET_GCC
    unset ETROBO_TARGET_GCC_VER
    unset ETROBO_ATHRILL_GCC
    unset ETROBO_ATHRILL_TARGET
    unset ETROBO_HRP3_SDK       # ToDo: rename to ETROBO_TARGET_SDK
    unset ETROBO_HRP3_WORKSPACE # ToDo: rename to ETROBO_TARGET_WORKSPACE
    unset ETROBO_ATHRILL_EV3RT
    unset ETROBO_ATHRILL_RASPIKE
    unset ETROBO_ATHRILL_SDK
    unset ETROBO_ATHRILL_WORKSPACE
    unset ETROBO_ATHRILL_DEVICE_CONFIG
    unset ETROBO_SDCARD
    unset ETROBO_OS
    unset ETROBO_OS_SUBSYSTEM
    unset ETROBO_KERNEL
    unset ETROBO_KERNEL_POSTFIX
    unset ETROBO_PLATFORM
    unset ETROBO_USERPROFILE
    unset ETROBO_MODE_CUI
    unset ETROBO_SIM_VER
    unset ETROBO_SIM_NAME
    unset ETROBO_EXE_POSTFIX
    unset ETROBO_LAUNCH_SIM
    unset ETROBO_LAUNCH_ASP
else
    if [ "$1" = "silent" ]; then
        quit="no message mode"
    fi
    if [ "$ETROBO_ENV" != "available" ]; then
        if [ ! -f "$ETROBO_ROOT/disable" ]; then
            export ETROBO_ENV="available"
            export ETROBO_SCRIPTS="$ETROBO_ROOT/scripts"
            export ETROBO_ATHRILL_GCC="$ETROBO_ROOT/athrill-gcc-package/usr/local/athrill-gcc"
            export ETROBO_EV3RT_VER=$ver
            export ETROBO_EV3RT_KERNEL="$kernel"
            export ETROBO_HRP3_SDK="$targetSDK"             # ToDo: rename to ETROBO_TARGET_SDK
            export ETROBO_HRP3_WORKSPACE="$targetWorkspace" # ToDo: rename to ETROBO_TARGET_WORKSPACE
            export ETROBO_ATHRILL_EV3RT="$ETROBO_ROOT/ev3rt-athrill-v850e2m"
            export ETROBO_ATHRILL_RASPIKE="$ETROBO_ROOT/raspike-athrill-v850e2m"
            if [ "$ETROBO_ENV_MODE" == "EV3" ]; then
                export ETROBO_ATHRILL_SDK="$ETROBO_ATHRILL_EV3RT/sdk"
                export ETROBO_ATHRILL_DEVICE_CONFIG="$ETROBO_HRP3_WORKSPACE/etroboc_common/device_config"
            else
                export ETROBO_ATHRILL_SDK="$ETROBO_ATHRILL_RASPIKE/sdk"
                export ETROBO_ATHRILL_DEVICE_CONFIG="$ETROBO_ATHRILL_SDK/workspace/etroboc_common/device_config"
            fi
            export ETROBO_ATHRILL_WORKSPACE="$ETROBO_ATHRILL_SDK/workspace"
            export ETROBO_MRUBY_EV3RT="$ETROBO_ATHRILL_WORKSPACE/mruby-ev3rt"
            export ETROBO_MRUBY_VER="2.0.1"
            export ETROBO_MRUBY_ROOT="$ETROBO_ATHRILL_WORKSPACE/mruby-$ETROBO_MRUBY_VER"
            export ETROBO_MRUBY_LIB="$ETROBO_MRUBY_ROOT/build/EV3RT-sim/lib/libmruby.a"
            export ETROBO_SDCARD="$ETROBO_ROOT/ev3rt-$ETROBO_EV3RT_VER-release/sdcard"

            export ETROBO_PLATFORM="`uname -m`"

            os=`"$ETROBO_SCRIPTS/detect_host_os"`
            export ETROBO_OS="`echo $os | awk '{print $1}'`"
            if [ "$ETROBO_OS" == "mac" ]; then
                export ETROBO_KERNEL="darwin"
                export ETROBO_KERNEL_POSTFIX="mac"
                export ETROBO_USERPROFILE="$HOME_ORG"
                export ETROBO_EXE_POSTFIX=".app"
            elif [ "$ETROBO_OS" == "win" ]; then
                export ETROBO_OS_SUBSYSTEM="`echo $os | awk '{print $2}'`"
                export ETROBO_KERNEL="debian"
                export ETROBO_KERNEL_POSTFIX="linux"
                comspec="`which cmd.exe`"
                if [ -z "$comspec" ]; then
                    comspec="/mnt/c/Windows/System32/cmd.exe"
                    export ETROBO_MODE_CUI="true"
                fi
                mntc="/mnt/$($comspec /c echo %USERPROFILE% 2>/dev/null | sed -E 's/.*/\L&/' | sed -E 's/^(.{1}).*$/\1/')"
                uppath="$($comspec /c echo %USERPROFILE% 2>/dev/null | sed -r 's/^(.{1}):(.*)$/\2/' | sed -r 's/:|\r|\n//g' | sed -r 's/\\/\//g')"
                export ETROBO_USERPROFILE="$mntc$uppath"
                if [ -z "$uppath" ]; then
                    export ETROBO_USERPROFILE="/mnt/c/Users/`whoami`"
                fi
                export ETROBO_EXE_POSTFIX=".exe"
            elif [ "$ETROBO_OS" == "chrome" ]; then
                export ETROBO_KERNEL="debian"
                export ETROBO_KERNEL_POSTFIX="linux"
                export ETROBO_USERPROFILE="$HOME"
                export ETROBO_EXE_POSTFIX=".$ETROBO_PLATFORM"
            elif [ "$ETROBO_OS" == "linux" ] || [ "$ETROBO_OS" == "raspi" ]; then
                export ETROBO_KERNEL="debian"
                export ETROBO_KERNEL_POSTFIX="linux"
                export ETROBO_USERPROFILE="$HOME"
                export ETROBO_EXE_POSTFIX=".$ETROBO_PLATFORM"
            fi

            if [ "$ETROBO_ENV_MODE" == "NXT" ] || [ "$ETROBO_ENV_MODE" == "EV3" ]; then
                export ETROBO_TARGET_GCC_VER="6_1-2017q1"
                export ETROBO_TARGET_GCC="$ETROBO_ROOT/gcc-arm-none-eabi-6-2017-q1-update"
            else
                export ETROBO_TARGET_GCC_VER="10.3-2021.10"
                export ETROBO_TARGET_GCC="$ETROBO_ROOT/gcc-arm-none-eabi-10.3-2021.10"
            fi

            export ETROBO_ATHRILL_TARGET="$ETROBO_ROOT/athrill-target-v850e2m/build_${ETROBO_KERNEL_POSTFIX}"

            . "$ETROBO_SCRIPTS/etrobopath.sh" unset
            export ETROBO_ENV_VER=`cd "$ETROBO_ROOT"; git show -s --date=short --format="%cd.%h"`

            # import module envs
            . "$ETROBO_SCRIPTS/sim" env
            . "$ETROBO_SCRIPTS/etrobopkg" env
            . "$ETROBO_SCRIPTS/spike" env
            . "$ETROBO_SCRIPTS/etrobopath.sh"

            if [ "$BEERHALL_INVOKER" != "booting" ] && [ -z "$quit" ]; then
                echo
                echo "etrobo environment for $ETROBO_ENV_MODE: Ready. (Ver.$ETROBO_ENV_VER)"
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
    elif [ -z "$quit" ]; then
        if [ "$PATH" == "$ETROBO_PATH_ORG" ]; then
            . "$ETROBO_SCRIPTS/sim" env
            . "$ETROBO_SCRIPTS/etrobopkg" env
            . "$ETROBO_SCRIPTS/etrobopath.sh"
        fi
        echo "etrobo environment for $ETROBO_ENV_MODE: Ready. (Ver.$ETROBO_ENV_VER)"
    fi
fi

cd "$currentDir"
