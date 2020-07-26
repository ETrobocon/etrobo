#!/usr/bin/env bash
# etrobo all-in-one package installer/updater
#   setup.sh 
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

#
# ** CAUTION **:
#   This module will be duplicated.
#   installation process is already moved into `etrobopkg`.
#

if [ -z "$ETROBO_ROOT" ]; then
    echo "run startetrobo first."
    exit 1
elif [ ! "$ETROBO_ENV" = "available" ]; then
    if [ "$ETROBO_KERNEL" = "darwin" ] && [ -z "$BEERHALL" ]; then
        echo "run startetrobo_mac.command first."
        exit 1
    fi
    . "$ETROBO_ROOT/scripts/etroboenv.sh" silent
fi
cd "$ETROBO_ROOT"

if [ "$1" = "update" ]; then
    update="update"
    athrill="$2"
    cd "$ETROBO_ROOT"
    #echo "update etrobo package:"
    #git pull --ff-only
    rm -f ~/startetrobo
    cp -f scripts/startetrobo ~/
    if [ "$ETROBO_OS" = "mac" ]; then
        rm -f "$BEERHALL/../startetrobo_mac.command"
        cp -f scripts/startetrobo_mac.command "$BEERHALL/../"
    fi
    scripts="$ETROBO_SCRIPTS"
    . "$scripts/etroboenv.sh" unset
    . "$scripts/etroboenv.sh" silent
fi

 if [ ! -f "$ETROBO_ATHRILL_WORKSPACE/athrill2" ]; then
    installProcess="athrill"
    athrill="athrill"
 fi

if [ "$athrill" = "athrill" ]; then
    echo
    echo "Build Athrill2 with the ETrobo official certified commit"
    "$ETROBO_SCRIPTS/build_athrill.sh" official
    rm -f "$ETROBO_ATHRILL_SDK/common/library/libcpp-ev3/libcpp-ev3-standalone.a"
    installProcess="${installProcess}athrill "
fi

#
# distribute etroboc_common
src="$ETROBO_ROOT/dist/etroboc_common"
dst="$ETROBO_HRP3_WORKSPACE/etroboc_common"
if [ ! -d "$dst" ]; then
    echo
    echo "Install etroboc_common to workspace"
    cp -rf "$src" "$ETROBO_HRP3_WORKSPACE/"
elif [ "$src/etrobo_ext.h" -nt "$dst/etrobo_ext.h" ]; then
    echo
    echo "Update etrobo_ext.h"
    rm -f "$dst/etrobo_ext.h"
    cp -f "$src/etrobo_ext.h" "$dst/"
fi

device_config="$ETROBO_HRP3_WORKSPACE/etroboc_common/device_config"
if [ ! -f "${device_config}_r.txt" ]; then
    echo
    echo "Prepare ${device_config}_r.txt"
    cat "${device_config}.txt" \
    | sed -E "s/^DEBUG_FUNC_VDEV_TX_PORTNO\ *([0-9]*)$/DEBUG_FUNC_VDEV_TX_PORTNO\ \ \ 54003/" \
    | sed -E "s/^DEBUG_FUNC_VDEV_RX_PORTNO\ *([0-9]*)$/DEBUG_FUNC_VDEV_RX_PORTNO\ \ \ 54004/" \
    > "${device_config}_r.txt"
fi

#
# distribute UnityETroboSim
cd "$ETROBO_ROOT/dist"
echo "Bundled Simulator: $ETROBO_SIM_VER"
if [ "$ETROBO_OS" = "chrome" ]; then
    os="linux"
else
    os="$ETROBO_OS"
fi
targetName="etrobosim${ETROBO_SIM_VER}_${os}"
if [ "$ETROBO_KERNEL" = "darwin" ]; then
    targetSrc="${targetName}${ETROBO_EXE_POSTFIX}"
    targetDist="/Applications/etrobosim"
else
    targetSrc="${targetName}"
    targetDist="$ETROBO_USERPROFILE/etrobosim"
fi

if [ ! -d "$targetDist/$targetSrc" ]; then
    installProcess="${installProcess}sim "
    echo
    echo "Install ETrobocon Simulator"
    if [ ! -d "$targetDist" ]; then
        mkdir "$targetDist"
    fi

    tar xvf "${targetName}.tar.gz" > /dev/null 2>&1
    mv -f "$targetSrc" "$targetDist/"
fi

if [ ! -d "$ETROBO_HRP3_WORKSPACE/sample_c4" ]; then
    installProcess="${installProcess}sample "
    echo
    echo "Install workspace/sample_c4:"
    git checkout .
    cp -rf "$ETROBO_ROOT/dist/sample_c4" "$ETROBO_HRP3_WORKSPACE/"
fi

if [ -n "$update" ]; then
    echo
    echo "Update: finish"
    echo
elif [ -n "$installProcess" ]; then
    echo
    echo "Install etrobo Environment: finish"
    echo
fi
