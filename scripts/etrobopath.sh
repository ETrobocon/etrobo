#!/usr/bin/env bash
if [ -n "$BEERHALL_PATH" ]; then
    export PATH="$BEERHALL_PATH"
elif [ -n "$ETROBO_PATH_ORG" ]; then
    export PATH="$ETROBO_PATH_ORG"
fi
if [ -n "$ETROBO_LD_LIBRARY_PATH_ORG" ]; then
    unset LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH="$ETROBO_LD_LIBRARY_PATH_ORG"
fi
if [ "$1" = "unset" ]; then
    unset ETROBO_PATH
    unset ETROBO_PATH_ORG
    unset ETROBO_LD_LIBRARY_PATH_ORG
else
    if [ -f "$ETROBO_ROOT/ldlibpath" ]; then
        if [ -z "$LD_LIBRARY_PATH" ]; then
            export LD_LIBRARY_PATH="$ETROBO_ATHRILL_GCC:$ETROBO_ATHRILL_GCC/lib"
        else
            export ETROBO_LD_LIBRARY_PATH_ORG="$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="$ETROBO_ATHRILL_GCC:$ETROBO_ATHRILL_GCC/lib:$LD_LIBRARY_PATH"
        fi
    fi
    
    export ETROBO_PATH_ORG="$PATH"
    export PATH=".:$ETROBO_SCRIPTS:$ETROBO_ATHRILL_GCC/bin:$ETROBO_ROOT/gcc-arm-none-eabi-$ETROBO_HRP3_GCC_VER/bin:$PATH"
    export ETROBO_PATH="available"
fi
