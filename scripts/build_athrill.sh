#!/usr/bin/env bash
# on-demand Athrill2 deployer for startetrobo
#   build_athril.sh 
# Author: jtFuruhata
# Copyright (c) 2020-2021 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

# Athrill2 environment for UnityETroboSim
# Powered by TOPPERS/ASP3 RTOS of Hakoniwa
# https://toppers.github.io/hakoniwa/
#
# See commits histories:
# https://github.com/toppers/athrill/commits/master
# https://github.com/toppers/athrill-target-v850e2m/commits/master
# https://github.com/toppers/ev3rt-athrill-v850e2m/commits/master
#
# the ETrobo official certified commit: Ver.2022.05.21a
ATHRILL_OFFICIAL_COMMIT="056a7aa761ef48f67f2c1f6effef104c66fa3b8c"
TARGET_OFFICIAL_COMMIT="2e0f02df5d0f55fc8ffff8f98cdc34f2f7db257e"
SAMPLE_OFFICIAL_COMMIT="eaa870b4e68413649d50e1b6d09d832b7de3af78"

# mruby environment for UnityETroboSim
# Powered by mruby Forum
# http://forum.mruby.org/
#
# See commits histories:
# https://github.com/mruby-Forum/mruby-ev3rt/commits/master
#
MRUBY_OFFICIAL_COMMIT="b0b3102f74ef1c57e0d99b9c056a6a9479d26226"

#
# the Athrill2 default repository
ATHRILL_AUTHOR="toppers"
ATHRILL_BRANCH="master"

#
# ETrobo dev-fork default repository
DEV_AUTHOR="ytoi"
DEV_BRANCH="master"

#
# show usage
if [ "$1" = "--help" ]; then
    echo "Usage:"
    echo "  build_athrill.sh show  ... show current author/branch/commit"
    echo
    echo "  build_athrill.sh [check|init] [official|pull|dev [<author>][/<branch>]]"
    echo
    echo "build the Athrill2 from specified sources into \$ETROBO_ATHRILL_WORKSPACE"
    echo
    echo "options:"
    echo "  show     ... show curent athrill status"
    echo "  check    ... do checkout or change author/branch(commit) only"
    echo "  init     ... initialize (means delete all of your athrill apps!) this workspace"
    echo "  official ... checkout from the ETrobo official certified commits"
    echo "  pull     ... pull from the TOPPERS/Hakoniwa repositories ('toppers/master'))"
    echo "  dev      ... pull from dev-forks repositories (default: 'ytoi/master')"
    echo "               option isn't implemented yet, default only"
    exit 0
fi

#
# ignore to use athrill on raspi
if [ ! "$ETROBO_ENV" = "available" ]; then
    . "$ETROBO_ROOT/scripts/etroboenv.sh" silent
fi
if [ "$ETROBO_OS" = "raspi" ]; then
    exit 0
fi

#
# change repositories and check installation
if [ -d "$ETROBO_ATHRILL_EV3RT" ]; then
    cd "$ETROBO_ATHRILL_EV3RT"
    CURRENT_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    CURRENT_BRANCH=`git branch | grep ^* | sed -E 's/^\* (.*)$/\1/'`
    if [ "$CURRENT_BRANCH" = "master" ]; then
        CURRENT_COMMIT="HEAD"
    else
        CURRENT_COMMIT=`echo "$CURRENT_BRANCH" | sed -E 's/^.*\(HEAD detached at (.*)\)$/\1/'`
        CURRENT_BRANCH="master"
    fi
    if [ -d "$ETROBO_MRUBY_EV3RT" ]; then
        cd "$ETROBO_MRUBY_EV3RT"
        MRUBY_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
        MRUBY_BRANCH=`git branch | grep ^* | sed -E 's/^\* (.*)$/\1/'`
        if [ "$MRUBY_BRANCH" = "master" ]; then
            MRUBY_COMMIT="HEAD"
        else
            MRUBY_COMMIT=`echo "$MRUBY_BRANCH" | sed -E 's/^.*\(HEAD detached at (.*)\)$/\1/'`
            MRUBY_BRANCH="master"
        fi
    else
        MRUBY_AUTHOR="NOT"
        MRUBY_COMMIT="INSTALLED"
        MRUBY_BRANCH="YET"
    fi
else
    CHECK="skip clean"
    unset CURRENT_AUTHOR
fi

unset ETROBO_ATHRILL_TARGET_ROOT
if [ -d "$ETROBO_ATHRILL_TARGET" ]; then
    ETROBO_ATHRILL_TARGET_ROOT="$(cd "$ETROBO_ATHRILL_TARGET/.."; pwd)"
fi

if [ -d "$ETROBO_ATHRILL_TARGET_ROOT" ]; then
    cd "$ETROBO_ATHRILL_TARGET/.."
    TARGET_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    TARGET_BRANCH=`git branch | grep ^* | sed -E 's/^\* (.*)$/\1/'`
    if [ "$TARGET_BRANCH" = "master" ]; then
        TARGET_COMMIT="HEAD"
    else
        TARGET_COMMIT=`echo "$TARGET_BRANCH" | sed -E 's/^.*\(HEAD detached at (.*)\)$/\1/'`
        TARGET_BRANCH="master"
    fi
else
    CHECK="skip clean"
    unset CURRENT_AUTHOR
fi
if [ -d "$ETROBO_ROOT/athrill" ]; then
    cd "$ETROBO_ROOT/athrill"
    ATH2_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    ATH2_BRANCH=`git branch | grep ^* | sed -E 's/^\* (.*)$/\1/'`
    if [ "$ATH2_BRANCH" = "master" ]; then
        ATH2_COMMIT="HEAD"
    else
        ATH2_COMMIT=`echo "$ATH2_BRANCH" | sed -E 's/^.*\(HEAD detached at (.*)\)$/\1/'`
        ATH2_BRANCH="master"
    fi
else
    CHECK="skip clean"
    unset CURRENT_AUTHOR
fi

#
# show status
if [ "$1" = "show" ]; then
    show_athrill="athrill"
    show_mruby="mruby"
    official_athrill="official"
    official_mruby="official"
    if [ "$2" = "mruby" ]; then
        unset show_athrill
    elif [ "$2" = "athrill" ]; then
        unset show_mruby
    fi
    echo "Current status of this Athrill-related repositories:"
    if [ -n "$show_athrill" ]; then
        echo "       athrill: $ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH"
        echo "athrill-target: $TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH"
        echo " ev3rt-athrill: $CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH"
        if [ "$ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH" = "$ATHRILL_AUTHOR/${ATHRILL_OFFICIAL_COMMIT:0:${#ATH2_COMMIT}}/$ATHRILL_BRANCH" ] \
        && [ "$TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH" = "$ATHRILL_AUTHOR/${TARGET_OFFICIAL_COMMIT:0:${#TARGET_COMMIT}}/$ATHRILL_BRANCH" ] \
        && [ "$CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH" = "$ATHRILL_AUTHOR/${SAMPLE_OFFICIAL_COMMIT:0:${#CURRENT_COMMIT}}/$ATHRILL_BRANCH" ]; then
            official_athrill="official"
        else
            unset official_athrill
        fi
    fi
    if [ -n "$show_mruby" ]; then
        echo "   mruby-ev3rt: $MRUBY_AUTHOR/$MRUBY_COMMIT/$MRUBY_BRANCH"
        if [ "$MRUBY_AUTHOR/$MRUBY_COMMIT/$MRUBY_BRANCH" = "mruby-Forum/${MRUBY_OFFICIAL_COMMIT:0:${#MRUBY_COMMIT}}/master" ]; then
            official_mruby="official"
        else
            unset official_mruby
        fi
    fi

    if [ -n "$official_mruby" ] && [ -n "$official_athrill" ]; then
        echo "the ETrobo official certified commit"
        exit 0
    else
        echo "unofficial commit detected."
        exit 1
    fi
fi

#
# set no build option
if [ "$1" = "check" ]; then
    CHECK="no build"
    shift
elif [ "$1" = "init" ]; then
    CHECK="skip clean"
    unset CURRENT_AUTHOR
    shift
fi

#
# make athrill clean
if [ -z "$CHECK" ]; then
    if [ -d "$ETROBO_ATHRILL_WORKSPACE" ]; then
        cd "$ETROBO_ATHRILL_WORKSPACE"
        echo make ASP3 workspace clean
        make clean > /dev/null 2>&1
        rm -f asp
        cd "$ETROBO_ATHRILL_TARGET"
        echo make Athrill clean
        make clean > /dev/null 2>&1
    fi
fi

cd "$ETROBO_ROOT"

#
# switch into dev repos
if [ "$1" = "dev" ]; then
    GIT_AUTHOR=$DEV_AUTHOR
else
    GIT_AUTHOR=$ATHRILL_AUTHOR
fi

#
# clone athrill repositories
if [ "$GIT_AUTHOR" != "$CURRENT_AUTHOR" ]; then
    echo "make Athrill repositories clean"
    rm -rf "$ETROBO_ROOT/athrill"
    rm -rf "$ETROBO_ATHRILL_TARGET_ROOT"
    rm -rf "$ETROBO_ATHRILL_EV3RT"
    git clone https://github.com/${GIT_AUTHOR}/athrill.git
    git clone --recursive https://github.com/${GIT_AUTHOR}/athrill-target-v850e2m.git
    git clone https://github.com/${GIT_AUTHOR}/ev3rt-athrill-v850e2m.git

    #
    # memory.txt hotfix
    #
    memory_txt="$ETROBO_ATHRILL_SDK/common/memory.txt"
    if [ -d "$ETROBO_ATHRILL_SDK" ] && [ ! -f "${memory_txt}.org" ]; then
        cp "$memory_txt" "${memory_txt}.org"
        cat "$memory_txt" | sed -E 's/^(R[OA]M, 0x00[02]00000,) 512$/\1 2048/' > "${memory_txt}.tmp"
        rm "$memory_txt"
        cp "${memory_txt}.tmp" "$memory_txt"
        rm "${memory_txt}.tmp"
    fi
fi

#
# clone and build mruby-ev3rt
cd "$ETROBO_ATHRILL_WORKSPACE"
if [ ! -d "$ETROBO_MRUBY_EV3RT" ]; then
    echo "Download mruby-ev3rt"
    git clone https://github.com/mruby-Forum/mruby-ev3rt.git
    rm -rf "$ETROBO_MRUBY_ROOT"
    cp -f "$ETROBO_ROOT/dist/$ETROBO_MRUBY_VER.tar.gz" ./
    tar xvf "$ETROBO_MRUBY_VER.tar.gz" >/dev/null 2>&1

    ##############
    # 2022 hofix #
    ##############
    #------------------------------------------------------------
    target="$ETROBO_MRUBY_ROOT/Rakefile"
    rm -f "$target.backup"
    cp -f "$target" "$target.backup"
    rm -f "$target"
    cat "$target.backup" | sed -E "s/^(  FileUtils.*)opts$/\1\*\*opts/" > "$target"
    #------------------------------------------------------------
fi

if [ "`build_athrill.sh show mruby > /dev/null; echo $?`" == "1" ]; then
    echo "Build mruby-ev3rt"
    cd "$ETROBO_MRUBY_EV3RT"
    cat build_config_ev3rt_sim.rb \
    | sed -E "s/^EV3RT_PATH\ =\ \"(.*)\"$/EV3RT_PATH = \"\$ETROBO_ATHRILL_EV3RT\"/" \
    | sed -E "s/^GNU_TOOL_PREFX\ =\ \"(.*)\"$/GNU_TOOL_PREFX = \"\$ETROBO_ATHRILL_GCC\/bin\/v850-elf-\"/" \
    > build_config_ev3rt_sim_etrobo.rb
    cd $ETROBO_MRUBY_ROOT
    rm -rf build
    MRUBY_CONFIG="$ETROBO_MRUBY_EV3RT/build_config_ev3rt_sim_etrobo.rb" rake
    if [ "$?" != "0" ]; then
        rm -rf "$ETROBO_MRUBY_EV3RT"
        rm -rf "$ETROBO_MRUBY_ROOT"
        echo
        echo ' *** FATAL ERROR *** mruby: build failed.  try `~/startetrobo update`'
        echo
    fi
fi

#
# checkout specific commits
if [ -n "$1" ]; then
    cd "$ETROBO_ROOT/athrill"
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ] || [ "$1" = "init" ]; then
        git checkout $ATHRILL_OFFICIAL_COMMIT
    fi
    cd ../athrill-target-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ] || [ "$1" = "init" ]; then
        git checkout $TARGET_OFFICIAL_COMMIT
        git submodule update --init --recursive
    fi
    cd ../ev3rt-athrill-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ] || [ "$1" = "init" ]; then
        git checkout $SAMPLE_OFFICIAL_COMMIT
    fi
    if [ -d sdk/workspace/mruby-ev3rt ]; then
        cd sdk/workspace/mruby-ev3rt
        git checkout .
        git checkout master
        git pull
        if [ "$1" = "official" ] || [ "$1" = "init" ]; then
            git checkout $MRUBY_OFFICIAL_COMMIT
        fi
    fi
fi

#########################
#   for 2022            #
#     Ruby 3.x hotfix   #
#########################
# -------------------------------------------------------------------------------------
target="$ETROBO_HRP3_SDK/../cfg/pass1.rb"
if [ -n "`cat \"$target\" | grep '{ skip_blanks:'`" ]; then
    cp -f "$target" "$target.backup"
    rm -f "$target"
    cat "$target.backup" \
    | sed -E "s/\{ (skip_blanks: true, skip_lines: \/\^\#\/ )\}/\1/" > "$target"
fi
target="$ETROBO_ATHRILL_SDK/../cfg/pass1.rb"
if [ -n "`cat \"$target\" | grep '{ skip_blanks:'`" ]; then
    cp -f "$target" "$target.backup"
    rm -f "$target"
    cat "$target.backup" \
    | sed -E "s/\{ (skip_blanks: true, skip_lines: \/\^\#\/ )\}/\1/" > "$target"
fi
if [ -f "$ETROBO_ROOT/dist/tecsgen-1.8.0.tgz" ]; then
    cd "$ETROBO_ATHRILL_SDK/../"
    cp "$ETROBO_ROOT/dist/tecsgen-1.8.0.tgz" ./
    rm -rf "tecsgen-1.8.0"
    tar xvf "tecsgen-1.8.0.tgz" > /dev/null
fi
if [ -d "$ETROBO_ATHRILL_SDK/../tecsgen-1.8.0" ]; then
    rm -rf "$ETROBO_ATHRILL_SDK/../tecsgen"
    cp -rf "$ETROBO_ATHRILL_SDK/../tecsgen-1.8.0/tecsgen" "$ETROBO_ATHRILL_SDK/../"
fi
# -------------------------------------------------------------------------------------

#
# modify Makefile.inc for mruby
cd "$ETROBO_ATHRILL_WORKSPACE/base_practice_1_mruby"
if [ -z "`cat Makefile.inc | grep ETROBO_MRUBY`" ]; then
    echo "modify \$ETROBO_ATHRILL_WORKSPACE/base_practice_1_mruby/Makefile.inc"
    cat Makefile.inc \
    | sed -E "s/^APPL_LIBS\ \+=\ (.*libmruby.a)(.*)$/APPL_LIBS += \$(ETROBO_MRUBY_LIB)\2/" \
    | sed -E "s/^INCLUDES\ \+=\ -I(.*\/mruby-$ETROBO_MRUBY_VER\/include\/)(.*)$/INCLUDES += -I\$(ETROBO_MRUBY_ROOT)\/include\/\2/" \
    > Makefile.inc.mod
    mv -f Makefile.inc.mod Makefile.inc
    cp -rf "$ETROBO_ATHRILL_WORKSPACE/base_practice_1_mruby" "$ETROBO_HRP3_WORKSPACE/"
fi

#
# build athrill
cd "$ETROBO_ATHRILL_TARGET"
if [ "$CHECK" != "no build" ]; then
    make etrobo_optimize=true
    rm -f "$ETROBO_ATHRILL_WORKSPACE/athrill2"
    cp ./athrill2 "$ETROBO_ATHRILL_WORKSPACE/"
fi
