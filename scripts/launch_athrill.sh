#!/usr/bin/env bash
#
# Athrill2 application launcher
#   launch_athrill.sh
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#
if [ "$1" == "usage" ] || [ "$1" == "--help" ]; then
    echo "usage: launch_athrill.sh [left|right] <projName>"
    exit 0
fi

# unset/env option for etrobo env core
if [ "$1" == "unset" ]; then
    unset ETROBO_ATHRILL_CONFIG
    exit 0
elif [ "$1" == "env" ]; then
    mode_env="env"
    shift
else
    unset mode_env
fi

# default filenames for launcher
simdist="$ETROBO_HRP3_WORKSPACE/simdist"
athrill2="$ETROBO_ATHRILL_WORKSPACE/athrill2"
memory_txt="$ETROBO_ATHRILL_SDK/common/memory.txt"
device_config_path="$ETROBO_ATHRILL_SDK/common"
target="$ETROBO_ATHRILL_WORKSPACE/asp"

#
# memory.txt hotfix
#
# @todo: this process has to move into build_athrill.sh
if [ -d "$ETROBO_ATHRILL_SDK" ] && [ ! -f "${memory_txt}.org" ]; then
    cp "$memory_txt" "${memory_txt}.org"
    cat $ETROBO_ATHRILL_SDK/common/memory.txt | sed -E 's/^(R[OA]M, 0x00[02]00000,) 512$/\1 2048/' > "${memory_txt}.tmp"
    rm "$memory_txt"
    cp "${memory_txt}.tmp" "$memory_txt"
    rm "${memory_txt}.tmp"
fi

# search & select a path to device_config.txt
# select priority: 
# 1. $ETROBO_HRP3_WORKSPACE/etroboc_common
# 2. $ETROBO_ATHRILL_WORKSPACE/etroboc_common
# 3. $ETROBO_ATHRILL_SDK/common
if [ -f "$ETROBO_HRP3_WORKSPACE/etroboc_common/device_config.txt" ]; then
    device_config_path="$ETROBO_HRP3_WORKSPACE/etroboc_common"
elif [ -f "$ETROBO_ATHRILL_WORKSPACE/etroboc_common/device_config.txt" ]; then
    device_config_path="$ETROBO_ATHRILL_WORKSPACE/etroboc_common"
fi
device_config_txt="$device_config_path/device_config.txt"

# course select
app_prefix=""
app_select="l_app"
sim_select="left"
if [ "$1" = "l" ] || [ "$1" = "left" ]; then
    app_prefix="l_"
    shift
elif [ "$1" = "r" ] || [ "$1" = "right" ]; then
    app_prefix="r_"
    app_select="r_app"
    sim_select="right"
    device_config_txt="$device_config_path/device_config_r.txt"
    shift
fi

# export the path to device_config.txt
export ETROBO_ATHRILL_CONFIG="$device_config_txt"

# invoke launcher
if [ -z "$mode_env" ]; then
    ${athrill2} -c1 -m ${memory_txt} -d ${device_config_txt} -t -1 "$target" &
else
    exit 1
fi

