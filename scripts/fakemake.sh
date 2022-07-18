#!/usr/bin/env bash
#
# fakemake, integrated build and launch system among HRP3/EV3 and ASP3/Athrill
#   fakemake.sh 
# Author: jtFuruhata, mhikichi1769, yurie
# Copyright (c) 2020-2021 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

cd "$ETROBO_HRP3_WORKSPACE"

# no-fake invoke on `make upload`
if [ "$1" = "upload" ]; then
    make $@
    exit $?
fi

# `make skiphrp3` skips building for HRP3
unset skiphrp3
if [ "$1" = "skiphrp3" ]; then
    skiphrp3="$1"
    shift
fi

# `make strip` strips symbols
unset strip
if [ "$1" = "strip" ]; then
    strip="$1"
    shift
fi

# `make import` imports from UnityETroboSim preferences to settings.json
import=""
export=""
if [ "$1" = "import" ]; then
    import="import"
    export="export"
    shift
fi

# select course
courseSelect=""
copts=""
app_prefix=""
arg_app_prefix=""
if [ "$1" = "l" ] || [ "$1" = "left" ]; then
    shift
    courseSelect="left"
    copts="-DMAKE_LEFT"
    app_prefix="l_"
elif [ "$1" = "r" ] || [ "$1" = "right" ]; then
    shift
    courseSelect="right"
    copts="-DMAKE_RIGHT"
    app_prefix="r_"
fi

if [ -n "$app_prefix" ]; then
    arg_app_prefix="app_prefix=$app_prefix"
fi

# manual launch control
manual_launch=""
if [ "$1" = "manual" ]; then
    manual_launch="manual"
    shift
fi

# `make unprefs` doesn't set preference to UnityETroboSim preferences
unprefs=""
if [ "$1" = "unprefs" ] || [ "$1" = "noset" ]; then
    unprefs="unprefs"
    shift
fi

# `sim btcat` outputs Virtual BT into bt.log
unset btcat
if [ "$1" = "btcat" ]; then
    shift
    btcat="btcat"
fi

# sugar command for noobs
if [ "$1" = "sample" ]; then
    if [ "$2" = "tr" ]; then
        cd "$ETROBO_ROOT"
        make $skiphrp3 $strip $import $courseSelect $manual_launch $unprefs $btcat app="etrobo_tr" sim up
    elif [ "$2" = "mruby" ]; then
        cd "$ETROBO_ROOT"
        make $skiphrp3 $strip $import $courseSelect $manual_launch $unprefs $btcat app="sample_mruby" sim up
    else
        cd "$ETROBO_ROOT"
        make $skiphrp3 $strip $import $courseSelect $manual_launch $unprefs $btcat app="sample_c4" sim up
    fi
    exit 0
fi

# transparent to make for Athrill
if [ "$1" = "debug" ]; then
    cd "$ETROBO_ATHRILL_WORKSPACE"
    make debug
    exit 0
fi

if [ "$1" = "start" ]; then
    if [ "$2" = "up" ]; then
        sim $export $courseSelect $manual_launch $unprefs $btcat launch
    else
        sim $export $courseSelect $manual_launch $unprefs $btcat only launch
    fi
    exit 0
fi

if [ "$1" = "stop" ]; then
    sim stop $2
    exit 0
fi

# parse options and get project name
unset build_asp3
unset simopt
args="$@"
for arg in "$@"; do
    prepare=`echo "$arg" | grep -e app= -e img= | sed -E "s/^app=|img=(.*)$/\1/"`
    if [ -n "$prepare" ]; then
        proj="$prepare"
    fi
    if [ "$arg" == "sim" ]; then
        build_asp3="sim"
    elif [ "$arg" == "start" ]; then
        simopt="start"
    elif [ "$arg" == "up" ]; then
        simopt="up"
    fi
done
# prepare current app
if [ -z "$proj" ] && [ -f currentapp ]; then
    currentapp=`head -n 1 currentapp`
    args="$args $currentapp"
    proj=`echo $currentapp | sed -E "s/^app=|img=(.*)$/\1/"`
fi

# transparent COPTS through Makefile.inc
incFile="$proj/Makefile.inc"
if [ -f "${incFile}.org" ]; then
    rm -f "${incFile}.base"
    mv -f "${incFile}.org" "$incFile"
fi
if [ -f "$incFile" ]; then
    touch "$incFile"
fi
cp -f "$incFile" "${incFile}.org"
if [ -n "$copts" ]; then
    echo >> "$incFile"
    echo "COPTS += $copts" >> "$incFile"
fi
cp -f "$incFile" "${incFile}.base"

# build to mruby bytecode
if [ -n "`cat \"$incFile\" | grep ETROBO_MRUBY`" ]; then
    echo "Build to mruby bytecode"
    cd "$proj"
    ruby "generate_bytecode.rb"
    skiphrp3="mruby"
    cd ..
fi

# invoke make for HRP3/EV3
echo invoke: make $arg_app_prefix $args
echo >> "$incFile"
echo "COPTS += -DMAKE_EV3" >> "$incFile"
if [ -z "$skiphrp3" ]; then
    make $arg_app_prefix $args
    makeResult=$?
    cp -f "${incFile}.org" "$incFile"
    if [ $makeResult -eq 0 ]; then
        echo fakemake on `echo "$ETROBO_EV3RT_KERNEL" | sed -E "s/(.*)/\U\1/"`: build succeed: ${app_prefix}${proj}
        currentapp=`head -n 1 currentapp`
        simopt=`tail -n 1 currentapp`
    else
        echo fakemake on `echo "$ETROBO_EV3RT_KERNEL" | sed -E "s/(.*)/\U\1/"`: make failed ... `cat currentapp`
        cd "$ETROBO_HRP3_WORKSPACE"
        rm -f "${incFile}.org"
        rm -f "${incFile}.base"
        exit 1
    fi
else
    cd "$ETROBO_HRP3_WORKSPACE"
    echo "app=$proj" > currentapp
fi

if [ -n "$build_asp3" ]; then
    if [ "$proj" = "athrillsample" ]; then
        echo fakemake on ASP3: \"athrillsample\" can\'t be integrated on this system.
        echo please make on \$ETROBO_ATHRILL_WORKSPACE... I can\'t remember there absolute path...
        exit 1
    fi

    # invoke make for ASP3/Athrill
    rm -rf "$ETROBO_ATHRILL_WORKSPACE/$proj"
    mv -f "${incFile}.base" "${incFile}"
    cp -rH "$ETROBO_HRP3_WORKSPACE/$proj" "$ETROBO_ATHRILL_WORKSPACE/"  # Issue #30: thx to @Amakuchisan
    mv -f "${incFile}.org" "$incFile"

    cd "$ETROBO_ATHRILL_WORKSPACE"
    echo >> "$incFile"
    echo "COPTS += -DSYSLOG_IMPLEMENT_AS_PRINTF -DMAKE_SIM" >> "$incFile"
    make img="$proj"
    if [ $? -eq 0 ]; then
        mv -f "${incFile}.org" "$incFile"
        if [ -n "$strip" ]; then
            echo fakemake on ASP3: strip debug symbols
            v850-elf-strip --keep-symbol=_athrill_device_func_call --keep-symbol=_athrill_device_raise_interrupt asp
        fi
        echo fakemake on ASP3: build succeed: ${app_prefix}${proj}.asp
        cp -f asp "${app_prefix}${proj}.asp"
        echo "${app_prefix}${proj}.asp" > currentasp

        #
        # prepare simdist folder
        #
        # the directory structure for new launch simdist procedure:
        # `sim` launches athrill apps from under the `workspace/simdist/[projName]` folder.
        #
        # $ETROBO_ATHRILL_WORKSPACE
        #   |- athrill2
        # $ETROBO_HRP3_WORKSPACE
        #   |- [simdist]
        #       |- [projName]
        #           |- log.txt
        #           |- l_projName.asp
        #           |- r_projName.asp
        #           |- settings.json
        #           |- __ev3rt_bt_in
        #           |- __ev3rt_bt_out
        #           |- [__ev3rtfs]
        #
        simdist="$ETROBO_SIM_DIST/$proj"
        if [ ! -d "$simdist" ]; then
            mkdir -p "$simdist"
        fi
        cp -f "${app_prefix}${proj}.asp" "$simdist/"

        if [ "$simopt" = "up" ]; then
            echo "launch sim"
            sim $export $courseSelect $manual_launch $unprefs $btcat launch $proj
        elif [ "$simopt" = "start" ]; then
            sim $export $courseSelect $manual_launch $unprefs $btcat only launch $proj
        fi
    else
        echo fakemake on ASP3: one or more error occured while build for $proj
        exit 1
    fi
fi
rm -f "${incFile}.org"
rm -f "${incFile}.base"
