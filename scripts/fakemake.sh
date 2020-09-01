#!/usr/bin/env bash
#
# fakemake, integrated build and launch system among HRP3/EV3 and ASP3/Athrill
#   fakemake.sh 
# Author: jtFuruhata, mhikichi1769
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

cd "$ETROBO_HRP3_WORKSPACE"

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

# sugar command for noobs
if [ "$1" = "sample" ]; then
    if [ "$2" = "tr" ]; then
        cd "$ETROBO_ROOT"
        make $courseSelect app="etrobo_tr" sim up
    else
        cd "$ETROBO_ROOT"
        make $courseSelect app="sample_c4" sim up
#        cd "$ETROBO_ATHRILL_WORKSPACE"
#        make $courseSelect img=athrillsample
#        if [ $? -eq 0 ]; then
#            sim wait launch
#        fi
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
        sim $courseSelect wait launchDist
    else
        sim $courseSelect only launchDist
    fi
    exit 0
fi

# prepare current app and get project name
args="$@"
for arg in "$@"; do
    prepare=`echo "$arg" | grep -e app= -e img= | sed -E "s/^app=|img=(.*)$/\1/"`
    if [ -n "$prepare" ]; then
        proj="$prepare"
    fi
done
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

# invoke make for HRP3/EV3
echo >> "$incFile"
echo "COPTS += -DMAKE_EV3" >> "$incFile"
echo invoker make $arg_app_prefix $args
make $arg_app_prefix $args
makeResult=$?
cp -f "${incFile}.org" "$incFile"
if [ $makeResult -eq 0 ]; then
    echo fakemake on HRP3: build succseed: ${app_prefix}${proj}
    currentapp=`head -n 1 currentapp`
    simopt=`tail -n 1 currentapp`

    if [ "$currentapp" != "$simopt" ]; then
        if [ "$proj" = "athrillsample" ]; then
            echo fakemake on ASP3: \"athrillsample\" can\'t be integrated on this system.
            echo please make on \$ETROBO_ATHRILL_WORKSPACE... I can\'t remember there absolute path...
            exit 1
        fi

        # invoke make for ASP3/Athrill
        rm -rf "$ETROBO_HRP3_WORKSPACE/$proj/simdist"   # ToDo: this line will be removed in next year
        rm -rf "$ETROBO_ATHRILL_WORKSPACE/$proj"
        mv -f "${incFile}.base" "${incFile}"
        cp -r "$ETROBO_HRP3_WORKSPACE/$proj" "$ETROBO_ATHRILL_WORKSPACE/"
        mv -f "${incFile}.org" "$incFile"

        cd "$ETROBO_ATHRILL_WORKSPACE"
        echo >> "$incFile"
        echo "COPTS += -DMAKE_SIM" >> "$incFile"
        make img="$proj"
        if [ $? -eq 0 ]; then
            mv -f "${incFile}.org" "$incFile"
            echo fakemake on ASP3: build succseed: ${app_prefix}${proj}.asp
            cp -f asp "${app_prefix}${proj}.asp"
            echo "${app_prefix}${proj}.asp" > currentasp

            #
            # prepare simdist folder
            #
            # the directory structure for new launchDist procedure:
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
            simdist="$ETROBO_HRP3_WORKSPACE/simdist/$proj"
            if [ ! -d "$simdist" ]; then
                mkdir -p "$simdist"
            fi
            cp -f "${app_prefix}${proj}.asp" "$simdist/"

            if [ "$simopt" = "up" ]; then
                echo launch sim
#            	sim $courseSelect wait launch "${app_prefix}${proj}.asp"
            	sim $courseSelect wait launchDist $proj
            elif [ "$simopt" = "start" ]; then
#            	sim $courseSelect only launch "${app_prefix}${proj}.asp"
            	sim $courseSelect only launchDist $proj
            fi
        else
            echo fakemake on ASP3: one or more error occured while build for $proj
            exit 1
        fi
    fi
    rm -f "${incFile}.org"
    rm -f "${incFile}.base"
else
    echo fakemake on HRP3: make failed ... `cat currentapp`
    cd "$ETROBO_HRP3_WORKSPACE"
    rm -f "${incFile}.org"
    rm -f "${incFile}.base"
fi
