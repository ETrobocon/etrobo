#!/usr/bin/env bash
# etrobo all-in-one package installer/updater
#   setup.sh 
# Author: jtFuruhata
# Copyright (c) 2020-2025 ETロボコン実行委員会, Released under the MIT license
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

unset update
if [ "$1" = "update" ]; then
    update="$1"
    option="$2"
    option2="$3"
    if [ "$option" = "repair" ]; then
        update="$option"
        option="$option2"
        if [ "$option" = "mruby" ]; then
            echo "delete mruby installation"
            rm -f "$ETROBO_CACHE/$ETROBO_MRUBY_VER."*
            rm -f "dist/$ETROBO_MRUBY_VER."*
            rm -f "$ETROBO_MRUBY_ROOT/../$ETROBO_MRUBY_VER."*
            rm -rf "$ETROBO_MRUBY_EV3RT"
            rm -rf "$ETROBO_MRUBY_ROOT/"
        fi
    fi
fi

if [ -n "$update" ]; then
    cd "$ETROBO_ROOT"
    rm -f ~/startetrobo
    cp -f scripts/startetrobo ~/
    if [ "$ETROBO_OS" = "mac" ]; then
        cp -f scripts/startetrobo_mac.command "$BEERHALL/../"
    elif [ "$ETROBO_OS" = "raspi" ]; then
        cp -f scripts/hackspi ~
    fi
    scripts="$ETROBO_SCRIPTS"
    . "$scripts/etroboenv.sh" unset
    . "$scripts/etroboenv.sh" silent

    unset simselect
    if [ "$option" = "sim" ]; then
        ls "$ETROBO_CACHE"/*etrobosim*.tar.gz | grep -v "$ETROBO_PUBLIC_VER" | while read line; do
            rm -f "$line"
            rm -f "$line.manifest"
        done
        ls "$ETROBO_ROOT"/dist/*etrobosim*.tar.gz | grep -v "$ETROBO_PUBLIC_VER" | while read line; do
            rm -f "$line"
            rm -f "$line.manifest"
        done
        if [ "$option2" = "beta" ]; then
            sim_select="sim_beta"
        elif [ "$option2" = "public" ]; then
            sim_select="sim_public"
        fi
    fi
    etrobopkg $sim_select
    . "$scripts/sim" env
fi

if [ "$update" = "repair" ] && [ "$option" = "mruby" ]; then
    echo "repair mruby installation"
    "$ETROBO_SCRIPTS/build_athrill.sh" official
fi

if [ ! -f "$ETROBO_ATHRILL_WORKSPACE/athrill2" ]; then
    installProcess="athrill"
    option="athrill"
else
    "$ETROBO_SCRIPTS/build_athrill.sh" show
    if [ "$?" = "1" ] && [ "$update" = "update" ] && [ "$athrill" != "skip" ]; then
        option="athrill"
    fi
fi

if [ "$option" = "athrill" ] && [ "$ETROBO_OS" != "raspi" ] && [ "$ETROBO_ENV_MODE" != "NXT" ]; then
    echo
    echo "Build Athrill2 with the ETrobo official certified commit"
    "$ETROBO_SCRIPTS/build_athrill.sh" official
    rm -f "$ETROBO_ATHRILL_SDK/common/library/libcpp-ev3/libcpp-ev3-standalone.a"
    installProcess="${installProcess}athrill "
fi

#
# distribute etroboc_common
if [ "$ETROBO_ENV_MODE" != "NXT" ]; then
    src="$ETROBO_ROOT/dist/etroboc_common"
    dst="$ETROBO_HRP3_WORKSPACE/etroboc_common"
    if [ ! -d "$dst" ]; then
        echo
        echo "Install etroboc_common to workspace"
        cp -rf "$src" "$ETROBO_HRP3_WORKSPACE/"
    elif [ "$src/etroboc_ext.h" -nt "$dst/etroboc_ext.h" ]; then
        echo
        echo "Update etroboc_ext.h"
        rm -f "$dst/etroboc_ext.h"
        cp -f "$src/etroboc_ext.h" "$dst/"
    fi
fi

#
# add include path to etroboc_common into Makefile.img
if [ "$ETROBO_ENV_MODE" == "SPIKE" ] \
&& [ -f "$ETROBO_ATHRILL_SDK/common/Makefile.img" ] \
&& [ -z "`cat \"$ETROBO_ATHRILL_SDK/common/Makefile.img\" | grep 'etroboc_common'`" ]; then
    mv -f "$ETROBO_ATHRILL_SDK/common/Makefile.img" "$ETROBO_ATHRILL_SDK/common/Makefile.img.org"
    cat "$ETROBO_ATHRILL_SDK/common/Makefile.img.org" \
    | sed -E 's/^\t-I\$\(LIBRASPIKE-ART_DIR\)\/include$/\t-I\$(LIBRASPIKE-ART_DIR)\/include \\\n\t-I\$(ETROBO_ATHRILL_WORKSPACE)\/etroboc_common/' \
    > "$ETROBO_ATHRILL_SDK/common/Makefile.img"
fi

# prepare device_config_r.txt
if [ -f "${ETROBO_ATHRILL_DEVICE_CONFIG}.txt" ]; then
    if [ ! -f "${ETROBO_ATHRILL_DEVICE_CONFIG}_r.txt" ]; then
        echo
        echo "Prepare ${ETROBO_ATHRILL_DEVICE_CONFIG}_r.txt"
        cat "${ETROBO_ATHRILL_DEVICE_CONFIG}.txt" \
        | sed -E "s/^DEVICE_CONFIG_UART_BASENAME(.*)$/DEVICE_CONFIG_UART_BASENAME\1_r/" \
        | sed -E "s/^DEVICE_CONFIG_BT_BASENAME(.*)$/DEVICE_CONFIG_BT_BASENAME\1_r/" \
        | sed -E "s/^DEBUG_FUNC_VDEV_TX_PORTNO\ *([0-9]*)$/DEBUG_FUNC_VDEV_TX_PORTNO\ \ \ 54003/" \
        | sed -E "s/^DEBUG_FUNC_VDEV_RX_PORTNO\ *([0-9]*)$/DEBUG_FUNC_VDEV_RX_PORTNO\ \ \ 54004/" \
        > "${ETROBO_ATHRILL_DEVICE_CONFIG}_r.txt"
    fi
fi

#
# distribute UnityETroboSim
if [ "$ETROBO_OS" != "raspi" ] && [ "$ETROBO_ENV_MODE" != "NXT" ]; then
    cd "$ETROBO_ROOT/dist"
    . sim env
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
        if [ "$?" = "0" ]; then
            mv -f "$targetSrc" "$targetDist/"
            if [ "$ETROBO_OS" == "linux" ]; then
                chmod +x "$targetDist/$targetSrc/etrobosim.x86_64"
            fi
        else
            echo "unpacking error: ${targetName}.tar.gz"
            exit 1
        fi
    fi
fi

if [ "$ETROBO_ENV_MODE" == "EV3" ]; then
    if [ ! -d "$ETROBO_HRP3_WORKSPACE/sample_c4" ]; then
        installProcess="${installProcess}sample_c4 "
        echo
        echo "Install workspace/sample_c4:"
        git checkout .
        cp -rf "$ETROBO_ROOT/dist/sample_c4" "$ETROBO_HRP3_WORKSPACE/"
    fi

    if [ ! -d "$ETROBO_HRP3_WORKSPACE/sample_mruby" ]; then
        installProcess="${installProcess}sample_mruby "
        echo
        echo "Install workspace/sample_mruby:"
        git checkout .
        cp -rf "$ETROBO_ROOT/dist/sample_mruby" "$ETROBO_HRP3_WORKSPACE/"
    fi
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
