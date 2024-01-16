#!/usr/bin/env bash
# ETroboSimRunner.Relay task scheduler
#   ETroboSimRunner.Relay.sh
# Author: jtFuruhata
# Copyright (c) 2020-2021 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

# interval time that each method is called by task scheduler
GET_INTERVAL=10  # sec.
PUT_INTERVAL=300 # sec.

if [ "$1" == "usage" ] || [ "$1" == "--help" ]; then
    echo "usage:"
    echo "  ETroboSimRunner.Relay.sh [serv|both|get|put|lookup|return] [/path/to/raceFolder] /path/to/relayFolder [<requestID>]"
    echo "    ... 'lookup' option returns 'Team:<teamID>' or 'Error:<errorMessage>'"
    exit 0
fi

mode="both"
if [ "$1" == "serv" ] || [ "$1" == "both" ] || [ "$1" == "get" ] || [ "$1" == "put" ] || [ "$1" == "lookup" ] || [ "$1" == "return" ]; then
    mode="$1"
    shift
fi

raceFolder="$1"
relayFolder="$2"
if [ -z "$relayFolder" ] || [ "$mode" == "lookup" ]; then
    relayFolder="$raceFolder"
fi
cd "$raceFolder" >/dev/null 2>&1
if [ "$?" == "0" ]; then
    # 
    # task scheduler
    #
    if [ "$mode" == "serv" ] || [ "$mode" == "lookup" ] || [ "$mode" == "return" ]; then
        # prepare simRunner
        simRunner=`cd "$relayFolder/../ETroboSimRunner.Relay" >/dev/null 2>&1; if [ "$?" == "0" ]; then pwd; fi`
        if [ -n "$simRunner" ]; then
            echo -n "ETroboSimRunner.Relay.exe /p" > "$simRunner/put.cmd"
            echo -n "ETroboSimRunner.Relay.exe /g" > "$simRunner/get.cmd"
            echo -n "ETroboSimRunner.Relay.exe /t %1" > "$simRunner/lookup.cmd"
            simRunner="`echo \"$simRunner\" | sed -E 's/^\/mnt\///' | sed -E 's/^(.{1})/\U&:/' | sed -E 's/\//\\\\\\\\/g'`"
        else
            echo "ETroboSimRunner.Relay not found."
            exit 1
        fi
    fi

    if [ "$mode" == "serv" ]; then
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
                cmd.exe /C "cd /D ${simRunner}&put.cmd" > /dev/null 2>&1
                rm put
            fi
            # request get via ETroboSimRunner.Relay
            if [ -f get ]; then
                cmd.exe /C "cd /D ${simRunner}&get.cmd" > /dev/null 2>&1
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

    #
    # lookup from requestID to teamID
    # 
    if [ "$mode" == "lookup" ]; then
        response=`cmd.exe /C "cd /D ${simRunner}&lookup.cmd $2" 2>&1`
        result="`echo \"$response\" | tail -n 1 | grep '^Team:'`"
        if [ -z "$result" ]; then
            echo "$response" | tail -n 1
            exit 1
        else
            echo "$result" | sed -E 's/[^0-9]//g'
        fi
    fi

    #
    # return Results files immediately
    # 
    if [ "$mode" == "return" ]; then
        cmd.exe /C "cd /D ${simRunner}&put.cmd" > /dev/null 2>&1
    fi
else
    echo "$raceFolder: no such directory"
    exit 1
fi
