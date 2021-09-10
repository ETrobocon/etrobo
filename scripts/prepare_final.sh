#!/usr/bin/env bash
#
# Postproduction utilities
#   prepare_final.sh
# Author: jtFuruhata
# Copyright (c) 2020-2021 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

#
# get/set value from/to JSON object
#
# json <envvar>.key.to.value [= <value>]
json () {
    argv="$1"
    op="$2"
    value="$3"
    envvar="`echo \"$argv\" | sed -E 's/^([^\.]*)\..*$/\1/'`"
    key="`echo \"$argv\" | sed -E 's/^[^\.]*(\..*)$/\1/'`"
    if [ -z "$op" ]; then
        eval "echo \$$envvar | jq -r $key"
    elif [ "$op" == "=" ]; then
        eval "$envvar=\"\`echo \$$envvar | jq -c \"$key|=\\\"$value\\\"\"\`\""
    fi
}
export -f json

if [ -n "`echo $1 | grep -E '^/'`" ]; then
    export relayFolder="$1"
    shift
fi
commonFolder="$relayFolder/common"

#
# stringifyMasters
#
# do JSON stringify master CSV files 
#
if [ "$1" == "stringifyMasters" ]; then
    # Teams
    fields=(ID classLetter divisionID LSlalom)
    mapper=""
    for ((i=0; i<${#fields[@]}; i++)); do
        if [ -n "$mapper" ];then
            mapper="$mapper,"
        fi
        mapper="${mapper}\"${fields[$i]}\":.[$i]"
    done
    cat "$commonFolder/Teams.csv" | sed -e 's/\r//g' \
     | jq -csR 'split("\n")|map(split(","))|map({'$mapper'})|del(.[][]|nulls)' \
     | sed -E 's/,\{\}//' | jq -c . \
     > "$commonFolder/Teams.json"

    # Divisions
    fields=(ID Name displayOrder blockLetter groupID)
    mapper=""
    for ((i=0; i<${#fields[@]}; i++)); do
        if [ -n "$mapper" ];then
            mapper="$mapper,"
        fi
        mapper="${mapper}\"${fields[$i]}\":.[$i]"
    done
    cat "$commonFolder/Divisions.csv" | sed -e 's/\r//g' \
     | jq -csR 'split("\n")|map(split(","))|map({'$mapper'})|del(.[][]|nulls)' \
     | sed -E 's/,\{\}//' | jq -c . \
     > "$commonFolder/Divisions.json"

    # Requests
    fields=(ID teamID courseLetter classLetter divisionID)
    mapper=""
    for ((i=0; i<${#fields[@]}; i++)); do
        if [ -n "$mapper" ];then
            mapper="$mapper,"
        fi
        mapper="${mapper}\"${fields[$i]}\":.[$i]"
    done
    cat "$commonFolder/Requests.csv" | sed -e 's/\r//g' \
     | jq -csR 'split("\n")|map(split(","))|map({'$mapper'})|del(.[][]|nulls)' \
     | sed -E 's/,\{\}//' | jq '.[].ID|=ascii_downcase' | jq -c . \
     > "$commonFolder/Requests.json"
fi

export Teams="`cat \"$commonFolder/Teams.json\"`"
export Divisions="`cat \"$commonFolder/Divisions.json\"`"
export Requests="`cat \"$commonFolder/Requests.json\"`"
export BlockPattern="`cat \"$commonFolder/BlockPattern.json\"`"

#
# request /path/to/BlobFolder [/path/to/Requests]
#
# expand zip files that there are in downloaded Blob strage folder into 'Requests' folder
#
if [ "$1" == "request" ]; then
    blobFolder="$2"
    requestsFolder="$relayFolder/Requests"
    if [ -n "$3" ]; then
        requestsFolder="$3"
    fi

    ls -1 "$blobFolder" | while read line; do
        teamID="$line"
        ls -1 "$blobFolder/$teamID" | while read line; do
            requestID="$line"
            record=$(echo "$Requests" | jq -r ".[]|select(.ID==\"$requestID\")")
            src="$blobFolder/$teamID/$requestID/req"
            src="$src/`ls -1 \"$src\"`"
            echo "$(json record.classLetter)_$requestID.zip"
            cp -f "$src" "$requestsFolder/$(json record.classLetter)_$requestID.zip"
        done
    done

#
# objectiveCheck [/path/to/Requests]
#
# objective check all request files in 'Requests' folder
#
elif [ "$1" == "objectiveCheck" ]; then
    requestsFolder="$relayFolder/Requests"
    if [ -n "$2" ]; then
        requestsFolder="$2"
    fi
    cd "$ETROBO_SIM_DIST"
    fileCounts=`ls -1 "$requestsFolder" | grep \.zip$ | wc -l`
    counter=0
    ls -tr "$requestsFolder" | grep \.zip$ \
    | while read target; do
        requestID=`echo $target | sed -E 's/^._(.*)\.zip$/\1/'`
        record=`echo "$Requests" | jq -r ".[]|select(.ID==\"$requestID\")"`
        teamID=$(printf "%03d" `json record.teamID`)
        courseLetter=`json record.courseLetter`
        classLetter=`json record.classLetter`
        rm -rf __race
        counter=$(($counter+1))
        echo -n "($counter/$fileCounts): $target = ${classLetter}${teamID}_${courseLetter} "
        cp "$requestsFolder/$target" "$ETROBO_SIM_DIST" > /dev/null 2>&1
        if [ "$?" != "0" ]; then
            echo ""
            echo "internal server error, can't access to this file."
            exit 1
        fi

        # check race zip file
        checker="`unzip -l $target | awk '{print $4}'`"
        if [ `echo "$checker" | grep -cE '^__race/$'` -eq 0 ]; then
            echo "isn't contain '__race' folder."
            checker="error"
        elif [ `echo "$checker" | grep -cE "^__race/${courseLetter,,}___race.asp$"` -eq 0 ]; then
            echo "isn't contain '${courseLetter,,}___race.asp' file."
            checker="error"
        elif [ `echo "$checker" | grep -cE '^__race/__ev3rtfs(_r)?/.{1,}'` -gt 256 ]; then
            echo "too many files in __ev3rtfs/_r"
            checker="error"
        fi

        if [ "$checker" != "error" ]; then
            # unzip race zip into simdist
            unzip -qqo $target
            unzip_error="$?"
            if [ "$unzip_error" != "0" ]; then
                echo "UNZIP ERROR"
                checker="error"
            fi
            rm "$ETROBO_SIM_DIST/$target"

            # calc md5sum
            unset sum
            if [ -f __race/__race.md5sum ]; then
                sum="`cat __race/__race.md5sum`"
                rm -f __race/__race.md5sum
            fi
            if [ "`(find __race -type f -exec md5sum -b {} \; && find __race) | env LC_ALL=C sort | md5sum -b`" != "$sum" ]; then
                echo "ERROR: mismatch md5sum"
                checker="error"
            fi
        fi

        if [ "$checker" != "error" ]; then
            echo "objective check: passed."
        fi
    done
fi
