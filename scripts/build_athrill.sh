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
# the ETrobo official certified commit: Ver.2021.03.21a
ATHRILL_OFFICIAL_COMMIT="aaec68572691c4e37d4f343f4b4af499c2a555c4"
TARGET_OFFICIAL_COMMIT="8268f73c32a632b979b6d4d808b64a3ec9f38e47"
SAMPLE_OFFICIAL_COMMIT="68cf8f2f897e3f9ed4d03e31a3067cdc98948cd5"

# mruby environment for UnityETroboSim
# Powered by mruby Forum
# http://forum.mruby.org/
#
# See commits histories:
# https://github.com/mruby-Forum/mruby-ev3rt/commits/master
#
MRUBY_OFFICIAL_COMMIT="e734fbd8a4189df5cdc7406fddaa5a8edf6e7bab"

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
    echo "  build_athrill.sh [check] [official|pull|dev [<author>][/<branch>]]"
    echo
    echo "build the Athrill2 from specified sources into \$ETROBO_ATHRILL_WORKSPACE"
    echo
    echo "options:"
    echo "  check    ... do checkout or change author/branch(commit) only"
    echo "  official ... checkout from the ETrobo official certified commits"
    echo "  pull     ... pull from the TOPPERS/Hakoniwa repositories ('toppers/master'))"
    echo "  dev      ... pull from dev-forks repositories (default: 'ytoi/master')"
    echo "               option isn't implemented yet, default only"
    exit 0
fi

#
# change repositories
if [ -d "$ETROBO_ATHRILL_EV3RT" ]; then
    cd "$ETROBO_ATHRILL_EV3RT"
    CURRENT_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    CURRENT_BRANCH=`git branch | grep ^* | sed -E 's/^\*\s(.*)$/\1/'`
    if [ "$CURRENT_BRANCH" = "master" ]; then
        CURRENT_COMMIT="HEAD"
    else
        CURRENT_COMMIT=`echo "$CURRENT_BRANCH" | sed -E 's/^\(HEAD detached at (.*)\)$/\1/'`
        CURRENT_BRANCH="master"
    fi
    if [ -d "$ETROBO_MRUBY_EV3RT" ]; then
        cd "$ETROBO_MRUBY_EV3RT"
        MRUBY_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
        MRUBY_BRANCH=`git branch | grep ^* | sed -E 's/^\*\s(.*)$/\1/'`
        if [ "$MRUBY_BRANCH" = "master" ]; then
            MRUBY_COMMIT="HEAD"
        else
            MRUBY_COMMIT=`echo "$MRUBY_BRANCH" | sed -E 's/^\(HEAD detached at (.*)\)$/\1/'`
            MRUBY_BRANCH="master"
        fi
    else
        MRUBY_AUTHOR="NOT"
        MRUBY_COMMIT="INSTALLED"
        MRUBY_BRANCH="YET"
    fi
    cd "$ETROBO_ATHRILL_TARGET"
    TARGET_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    TARGET_BRANCH=`git branch | grep ^* | sed -E 's/^\*\s(.*)$/\1/'`
    if [ "$TARGET_BRANCH" = "master" ]; then
        TARGET_COMMIT="HEAD"
    else
        TARGET_COMMIT=`echo "$TARGET_BRANCH" | sed -E 's/^\(HEAD detached at (.*)\)$/\1/'`
        TARGET_BRANCH="master"
    fi
    cd "$ETROBO_ROOT/athrill"
    ATH2_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    ATH2_BRANCH=`git branch | grep ^* | sed -E 's/^\*\s(.*)$/\1/'`
    if [ "$ATH2_BRANCH" = "master" ]; then
        ATH2_COMMIT="HEAD"
    else
        ATH2_COMMIT=`echo "$ATH2_BRANCH" | sed -E 's/^\(HEAD detached at (.*)\)$/\1/'`
        ATH2_BRANCH="master"
    fi
else
    unset CURRENT_AUTHOR
fi

#
# show status
if [ "$1" = "show" ]; then
    echo "Current status of this Athrill-related repositories:"
    echo "       athrill: $ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH"
    echo "athrill-target: $TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH"
    echo " ev3rt-athrill: $CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH"
    echo "   mruby-ev3rt: $MRUBY_AUTHOR/$MRUBY_COMMIT/$MRUBY_BRANCH"
    if [ "$ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH" = "$ATHRILL_AUTHOR/${ATHRILL_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ] \
    && [ "$TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH" = "$ATHRILL_AUTHOR/${TARGET_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ] \
    && [ "$MRUBY_AUTHOR/$MRUBY_COMMIT/$MRUBY_BRANCH" = "mruby-Forum/${TARGET_OFFICIAL_COMMIT:0:7}/master" ] \
    && [ "$CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH" = "$ATHRILL_AUTHOR/${SAMPLE_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ]; then
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
    rm -rf "$ETROBO_ROOT/athrill"
    rm -rf "$ETROBO_ATHRILL_TARGET"
    rm -rf "$ETROBO_ATHRILL_EV3RT"
    git clone https://github.com/${GIT_AUTHOR}/athrill.git
    git clone https://github.com/${GIT_AUTHOR}/athrill-target-v850e2m.git
    git clone https://github.com/${GIT_AUTHOR}/ev3rt-athrill-v850e2m.git
fi

#
# clone and build mruby-ev3rt
cd "$ETROBO_ATHRILL_WORKSPACE"
if [ ! -d "$ETROBO_MRUBY_EV3RT" ]; then
    echo "Download mruby-ev3rt"
    git clone https://github.com/mruby-Forum/mruby-ev3rt.git

    echo "Build mruby-ev3rt"
    cp "$ETROBO_ROOT/dist/$ETROBO_MRUBY_VER.tar.gz" ./
    tar xvf "$ETROBO_MRUBY_VER.tar.gz" >/dev/null 2>&1
    cd "$ETROBO_MRUBY_EV3RT"
    cat build_config_ev3rt_sim.rb \
    | sed -E "s/^EV3RT_PATH\ =\ \"(.*)\"$/EV3RT_PATH = \"\$ETROBO_ATHRILL_EV3RT\"/" \
    | sed -E "s/^GNU_TOOL_PREFX\ =\ \"(.*)\"$/GNU_TOOL_PREFX = \"\$ETROBO_ATHRILL_GCC\/bin\/v850-elf-\"/" \
    > build_config_ev3rt_sim_etrobo.rb
    cd $ETROBO_MRUBY_ROOT
    MRUBY_CONFIG="$ETROBO_MRUBY_EV3RT/build_config_ev3rt_sim_etrobo.rb" rake
    if [ "$?" != "0" ]; then
        rm -rf "$ETROBO_MRUBY_EV3RT"
        rm -rf "$ETROBO_MRUBY_ROOT"
        echo 'fatal error: mruby build: try `./startetrobo update`'
    fi
fi

#
# checkout specific commits
if [ -n "$1" ]; then
    cd "$ETROBO_ROOT/athrill"
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $ATHRILL_OFFICIAL_COMMIT
    fi
    cd ../athrill-target-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $TARGET_OFFICIAL_COMMIT
    fi
    cd ../ev3rt-athrill-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $SAMPLE_OFFICIAL_COMMIT
    fi
    cd sdk/workspace/mruby-ev3rt
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $MRUBY_OFFICIAL_COMMIT
    fi
fi

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
if [ -z "$CHECK" ]; then
    make etrobo_optimize=true
    rm -f "$ETROBO_ATHRILL_WORKSPACE/athrill2"
    cp ./athrill2 "$ETROBO_ATHRILL_WORKSPACE/"
fi
