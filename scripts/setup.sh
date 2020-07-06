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
    . "$BEERHALL/etc/profile.d/etrobo.sh"
fi
cd "$ETROBO_ROOT"

if [ "$1" = "update" ]; then
    update="update"
    dist="$2"
    cd "$ETROBO_ROOT"
    echo "update etrobo package:"
    git pull
    rm -f ~/startetrobo
    cp -f scripts/startetrobo ~/
    if [ "$ETROBO_OS" = "mac" ]; then
        rm -f "$BEERHALL/../startetrobo_mac.command"
        cp -f scripts/startetrobo_mac.command "$BEERHALL/../"
    fi
    cd "$ETROBO_SCRIPTS"
    . "etroboenv.sh" unset
    . "etroboenv.sh"
fi

if [ "$dist" != "dist" ]; then
    echo
    echo "Build Athrill2 with the ETrobo official certified commit"
    "$ETROBO_SCRIPTS/build_athrill.sh" official
    rm -f "$ETROBO_ATHRILL_SDK/common/library/libcpp-ev3/libcpp-ev3-standalone.a"
fi

#
# distrubute etrobo_tr samples
#echo "update distributions"
#echo 
#sampleProj="sample_c4"
#echo "distribute $sampleProj project"
#cd "$ETROBO_HRP3_WORKSPACE"
#rm -rf "$sampleProj"
#mkdir "$sampleProj"
cd "$ETROBO_ROOT/dist"
#cp -f "${sampleProj}/"* "$ETROBO_HRP3_WORKSPACE/${sampleProj}"
#rm -rf "$sampleProj"

#
# distribute UnityETroboSim
echo "Bundled Simulator: $ETROBO_SIM_VER"
targetSrc="etrobosim${ETROBO_SIM_VER}_${ETROBO_OS}"
tar xvf "${targetSrc}.tar.gz" > /dev/null 2>&1

if [ "$ETROBO_KERNEL" = "darwin" ]; then
    targetSrc="${targetSrc}${ETROBO_EXE_POSTFIX}"
    targetDist="/Applications/etrobosim"
else
    targetDist="$ETROBO_USERPROFILE/etrobosim"
fi

if [ -d "$targetDist" ]; then
    rm -rf "$targetDist/$targetSrc"
else
    mkdir "$targetDist"
fi
mv -f "$targetSrc" "$targetDist/"

if [ -z "$update" ]; then
    echo
    echo "Update: finish"
    echo
else
    echo
    echo "Install etrobo Environment: finish"
    echo
fi
