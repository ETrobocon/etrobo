#!/usr/bin/env bash
# ETroboSimRunner.Relay task scheduler
#   ETroboSimRunner.Relay.sh
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

# interval time that each method is called by task scheduler
GET_INTERVAL=10  # sec.
PUT_INTERVAL=300 # sec.

if [ "$1" == "usage" ] || [ "$1" == "--help" ]; then
    echo "usage: ETroboSimRunner.Relay.sh [serv|both|get|put] /path/to/raceFolder /path/to/relayFolder"
    exit 0
fi

mode="both"
if [ "$1" == "serv" ] || [ "$1" == "both" ] || [ "$1" == "get" ] || [ "$1" == "put" ]; then
    mode="$1"
    shift
fi

raceFolder="$1"
relayFolder="$2"
cd "$raceFolder" >/dev/null 2>&1
if [ "$?" == "0" ]; then
    # 
    # task scheduler
    #
    if [ "$mode" == "serv" ]; then
        # prepare simRunner
        simRunner=`cd "$relayFolder/../ETroboSimRunner.Relay" >/dev/null 2>&1; if [ "$?" == "0" ]; then pwd; fi`
        if [ -n "$simRunner" ]; then
            simRunner="`echo \"$simRunner\" | sed -E 's/^\/mnt\///' | sed -E 's/^(.{1})/\U&:/' | sed -E 's/\//\\\\\\\\/g'`"
        else
            echo "ETroboSimRunner.Relay not found."
            exit 1
        fi

        # task scheduler main loop
        get_time=0
        put_time=0
        while [ ! -f stop_relay ];do
            # invokers
            get_time=$(($get_time + 1))
            if [ $get_time -gt $GET_INTERVAL ]; then
                touch get
                get_time=0
            fi
            put_time=$(($put_time + 1))
            if [ $get_time -gt $GET_INTERVAL ]; then
                touch put
                put_time=0
            fi

            # request put via ETroboSimRunner.Relay
            if [ -f put ]; then
                cmd.exe /C "cd /D ${simRunner}&ETroboSimRunner.Relay.exe" > /dev/null 2>&1
                rm put
            fi
            # request get via ETroboSimRunner.Relay
            if [ -f get ]; then
                cmd.exe /C "cd /D ${simRunner}&ETroboSimRunner.Relay.exe" > /dev/null 2>&1
                rm get
            fi
            sleep 1
        done
        rm stop_relay
    fi
    #
    # send get or post request to myself
    # 
    if [ "$mode" == "both" ] || [ "$mode" == "get" ]; then
        touch get
    fi
    if [ "$mode" == "both" ] || [ "$mode" == "put" ]; then
        touch put
    fi
else
    echo "$raceFolder: no such directory"
    exit 1
fi
