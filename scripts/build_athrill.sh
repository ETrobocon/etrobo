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
# the ETrobo official certified commit: Ver.2021.03.07a
ATHRILL_OFFICIAL_COMMIT="33ef12ab9740e4707d6b642c750584fc02af07fb"
TARGET_OFFICIAL_COMMIT="eff0dbc0628975f1294447245f1538bac7b70a7f"
SAMPLE_OFFICIAL_COMMIT="1d850948e0dccab7d405043e231a000c3a805247"
#ATHRILL_HOTFIX_COMMIT=""
#ATHRILL_HOTFIX_PATH=""
#TARGET_HOTFIX_COMMIT=""
#TARGET_HOTFIX_PATH=""
#SAMPLE_HOTFIX_COMMIT=""
#SAMPLE_HOTFIX_PATH=""

#
# the Athrill2 default repository
ATHRILL_AUTHOR="toppers"
ATHRILL_BRANCH="master"

#
# ETrobo dev-fork default repository
DEV_AUTHOR="ytoi"
DEV_BRANCH="master"

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

if [ -d "$ETROBO_ROOT/ev3rt-athrill-v850e2m" ]; then
    cd "$ETROBO_ROOT/ev3rt-athrill-v850e2m"
    CURRENT_AUTHOR=`git remote -v | head -n 1 | sed -E "s/^.*github.com\/(.*)\/.*$/\1/"`
    CURRENT_BRANCH=`git branch | grep ^* | sed -E 's/^\*\s(.*)$/\1/'`
    if [ "$CURRENT_BRANCH" = "master" ]; then
        CURRENT_COMMIT="HEAD"
    else
        CURRENT_COMMIT=`echo "$CURRENT_BRANCH" | sed -E 's/^\(HEAD detached at (.*)\)$/\1/'`
        CURRENT_BRANCH="master"
    fi
    cd "$ETROBO_ROOT/athrill-target-v850e2m"
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

if [ "$1" = "show" ]; then
    echo "Current status of this Athrill-related repositories:"
    echo "       athrill: $ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH"
    echo "athrill-target: $TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH"
    echo " ev3rt-athrill: $CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH"
    if [ "$ATH2_AUTHOR/$ATH2_COMMIT/$ATH2_BRANCH" = "$ATHRILL_AUTHOR/${ATHRILL_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ] \
    && [ "$TARGET_AUTHOR/$TARGET_COMMIT/$TARGET_BRANCH" = "$ATHRILL_AUTHOR/${TARGET_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ] \
    && [ "$CURRENT_AUTHOR/$CURRENT_COMMIT/$CURRENT_BRANCH" = "$ATHRILL_AUTHOR/${SAMPLE_OFFICIAL_COMMIT:0:7}/$ATHRILL_BRANCH" ]; then
        echo "the ETrobo official certified commit"
        exit 0
    else
        echo "unofficial commit detected."
        exit 1
    fi
fi

if [ "$1" = "check" ]; then
    CHECK="no build"
    shift
fi

if [ -z "$CHECK" ]; then
    if [ -d "$ETROBO_ATHRIL_WORKSPACE" ]; then
        cd "$ETROBO_ATHRIL_WORKSPACE"
        echo make ASP3 workspace clean
        make clean > /dev/null 2>&1
        rm -f asp
        cd "$ETROBO_ATHRILL_TARGET"
        echo make Athrill clean
        make timer32=true clean > /dev/null 2>&1
    fi
fi

cd "$ETROBO_ROOT"

if [ "$1" = "dev" ]; then
    GIT_AUTHOR=$DEV_AUTHOR
else
    GIT_AUTHOR=$ATHRILL_AUTHOR
fi

if [ "$GIT_AUTHOR" != "$CURRENT_AUTHOR" ]; then
    rm -rf "$ETROBO_ROOT/athrill"
    rm -rf "$ETROBO_ROOT/athrill-target-v850e2m"
    rm -rf "$ETROBO_ROOT/ev3rt-athrill-v850e2m"
    git clone https://github.com/${GIT_AUTHOR}/athrill.git
    git clone https://github.com/${GIT_AUTHOR}/athrill-target-v850e2m.git
    git clone https://github.com/${GIT_AUTHOR}/ev3rt-athrill-v850e2m.git
fi

if [ -n "$1" ]; then
    cd "$ETROBO_ROOT/athrill"
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $ATHRILL_OFFICIAL_COMMIT
        if [ -n "$ATHRILL_HOTFIX_COMMIT" ]; then
            wget "https://github.com/$ATHRILL_AUTHOR/athrill/raw/$ATHRILL_HOTFIX_COMMIT/$ATHRILL_HOTFIX_PATH" -O $ATHRILL_HOTFIX_PATH
        fi
    fi
    cd ../athrill-target-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $TARGET_OFFICIAL_COMMIT
        if [ -n "$TARGET_HOTFIX_COMMIT" ]; then
            wget "https://github.com/$ATHRILL_AUTHOR/athrill-target-v850e2m/raw/$TARGET_HOTFIX_COMMIT/$TARGET_HOTFIX_PATH" -O $TARGET_HOTFIX_PATH
        fi
    fi
    cd ../ev3rt-athrill-v850e2m
    git checkout .
    git checkout master
    git pull
    if [ "$1" = "official" ]; then
        git checkout $SAMPLE_OFFICIAL_COMMIT
        if [ -n "$SAMPLE_HOTFIX_COMMIT" ]; then
            wget "https://github.com/$ATHRILL_AUTHOR/ev3rt-athrill-v850e2m/raw/$SAMPLE_HOTFIX_COMMIT/$SAMPLE_HOTFIX_PATH" -O $SAMPLE_HOTFIX_PATH
        fi
    fi
fi

cd "$ETROBO_ATHRILL_TARGET"
if [ -z "$CHECK" ]; then
    make timer32=true
    rm -f "$ETROBO_ATHRILL_WORKSPACE/athrill2"
    cp ./athrill2 "$ETROBO_ATHRILL_WORKSPACE/"
fi
