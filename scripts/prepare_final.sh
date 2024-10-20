#!/usr/bin/env bash
#
# Postproduction utilities
#   prepare_final.sh
# Author: jtFuruhata
# Copyright (c) 2020-2023 ETロボコン実行委員会, Released under the MIT license
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
        eval "echo \$$envvar | jq -r $key | grep -v ^null$"
    elif [ "$op" == "=" ]; then
        eval "$envvar=\"\`echo \$$envvar | jq -c \"$key|=\\\"$value\\\"\"\`\""
    fi
}
export -f json

target="$ETROBO_ROOT/dist/simvm.sh"
if [ -f "$target" ]; then
    source "$target"
fi
export relayFolder="$ETROBO_RELAY"

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
    fields=(ID classLetter divisionID LSlalom year bibID)
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
    fields=(ID courseLetter teamID classLetter divisionID)
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
#export BlockPattern="`cat \"$commonFolder/BlockPattern.json\"`"

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

#
# overlayPNG
#
# overlay MatchMaker result PNG over filter.png
#
elif [ "$1" == "overlayPNG" ]; then
    srcdir="$commonFolder/matchmaker/results"
    destdir="$commonFolder/raceserv/results"
    ls -1 "$srcdir" \
    | while read combinedID; do
        echo "converting... $combinedID"
        convert -transparent black "$srcdir/$combinedID/${combinedID}_リザルト.png" "$destdir/$combinedID.png"
        convert "$ETROBO_ROOT/dist/filter.png" "$destdir/$combinedID.png" -compose over -composite "$destdir/$combinedID.png"
    done

#
# mmmux
#
# MatchMaker movie muxing
#
elif [ "$1" == "mmmux" ]; then
    srcDir="$commonFolder/matchmaker/results"
    destDir="$commonFolder/raceserv"
    if [ ! -d "$destDir/results" ]; then
        mkdir -p "$destDir/results"
    fi
#    ls -1 "$srcDir" \
    combinedIDs=(`ls -1 "$srcDir" | grep '.mp4$' | sed -E 's/^(E[0-9]{3})_.*$/ \1/'`)
    for combinedID in ${combinedIDs[@]}; do
        echo "muxing... $combinedID"
        ffutil mmmux 2 $destDir/${combinedID}_L.mp4 info
        ffutil mmmux 2 $destDir/${combinedID}_R.mp4 info
        ffutil encode multiplex 2 $destDir/${combinedID}_L.mp4 $destDir/results/${combinedID}_L.mp4 info
        ffutil encode multiplex 2 $destDir/${combinedID}_R.mp4 $destDir/results/${combinedID}_R.mp4 info
    done

#
# distribute results|all|<divisionID> [/path/to/commonFolder]
#
# divide result movies by divisionID
#
elif [ "$1" == "distribute" ]; then
    shift
    divisions=(1 2 4 5 6 8 9 11 12 13)
    if [ "$1" == "results" ]; then
        divisions="results"
    elif [ "$1" != "all" ]; then
        divisions=($1)
    fi
    shift

    common="$commonFolder"
    if [ -n "$1" ]; then
        common="$1"
    fi

    tmpFolder="$common/tmp"
    rm -rf "$tmpFolder"

    if [ "$divisions" == "results" ]; then
        ls -1 "$common/matchmaker/results" \
        | while read combinedID; do
            class="`echo $combinedID | sed -E 's/^([EPA]{1})([0-9]{3})$/\1/'`"
            teamID="`echo $combinedID | sed -E 's/^([EPA]{1})([0-9]{3})$/\2/' | sed -E 's/^0*([1-9]{1}[0-9]*)$/\1/'`"
            divisionID="`echo $Teams | jq -cr \".[]|select(.ID==\\\"$teamID\\\")|.divisionID\"`"
            groupID=$(printf "%02d" $(echo "$Divisions" | jq -cr ".[]|select(.ID==\"$divisionID\")|.groupID"))
            
            if [ ! -d "$tmpFolder/$groupID" ]; then
                mkdir -p "$tmpFolder/$groupID"
            fi

            asset="$tmpFolder/asset/$groupID/$combinedID"
            mkdir -p "$asset"
            echo "division group:$groupID    combinedID:$combinedID"
            cp "$common/raceserv/results_org/${combinedID}"*.* $tmpFolder/$groupID
            cp "$common/raceserv/${combinedID}"*.* $asset
            cp "$common/matchmaker/results_org/$combinedID/"*.* $asset
        done
    else
        for divisionID in ${divisions[@]}; do
            groupID=$(printf "%02d" $(echo "$Divisions" | jq -cr ".[]|select(.ID==\"$divisionID\")|.groupID"))
            
            if [ ! -d "$tmpFolder/$groupID" ]; then
                mkdir -p "$tmpFolder/$groupID"
            fi

            echo $Teams | jq -c ".[]|select(.divisionID==\"$divisionID\")" \
            | while read record; do
                class=`json record.classLetter`
                teamID=$(printf "%03d" $(json record.ID))
                combinedID=${class}${teamID}
                asset="$tmpFolder/asset/$groupID/$combinedID"
                mkdir -p "$asset"
                echo "division group:$groupID    combinedID:$combinedID"
                cp "$common/raceserv/results_org/${combinedID}"*.* $tmpFolder/$groupID
                cp "$common/raceserv/${combinedID}"*.* $asset
                cp "$common/matchmaker/results_org/$combinedID/"*.* $asset
            done
        done
    fi
#
# getNew [sync /path/to/relayFolder_remote] [YYMMDD.HHmm] [/path/to/relayFolder]
#
# sync and get MatchMaker CSV and result files from remote and copy into local common folder
#
elif [ "$1" == "getNew" ]; then
    shift

    unset remoteFolder
    if [ "$1" == "sync" ]; then
        remoteFolder="$2"
        shift 2
    fi

    unset lastupdate
    if [ -n "`echo $1 | grep -E '^[0-9]{2}[0-9]{2}[0-9]{2}\.[0-9]{2}[0-9]{2}$'`" ]; then
        lastupdate="`echo $1 | sed -E 's/^([0-9]{2})([0-9]{2})([0-9]{2})\.([0-9]{2})([0-9]{2})$/20\1-\2-\3 \4:\5:00/'`"
        shift
    fi

    if [ -z "$relayFolder" ]; then
        if [ -n "$1" ]; then
            relayFolder="$1"
        else
            echo 'you should run `. preparefinal.sh /path/to/relayFolder` or specify relay folder.'
            exit 1
        fi
    fi

    mmFolder="$relayFolder/common/matchmaker"
    rm -rf "$mmFolder/results/"*

    if [ -z "$lastupdate" ]; then
        if [ -f "$mmFolder/lastupdate" ]; then
            lastupdate="`date \"+%F %T\" -r \"$mmFolder/lastupdate\"`"
        else
            lastupdate="1970-01-01 00:00:00"
        fi
    fi
    touch -d "$lastupdate" "$mmFolder/lastupdate"


    if [ -n "$remoteFolder" ]; then
        remoteFolder="$remoteFolder/common/matchmaker"

        echo "preparing to sync with $remoteFolder ..."
        ls -1 "$remoteFolder/results" \
        | while read combinedID; do
            unset loop
            ls -1 "$remoteFolder/results/$combinedID" \
            | while read file; do
                if [ ! -d "$mmFolder/results_org/$combinedID" ]; then
                    mkdir "$mmFolder/results_org/$combinedID"
                fi
                if [ ! -f "$mmFolder/results_org/$combinedID/$file" ] || [ "$remoteFolder/results/$combinedID/$file" -nt "$mmFolder/results_org/$combinedID/$file" ]; then
                    if [ -z "$loop" ]; then
                        loop="loop"
                        if [ ! -f "$mmFolder/csv/${combinedID}_L.csv" ] || [ "$remoteFolder/csv/${combinedID}_L.csv" -nt "$mmFolder/csv/${combinedID}_L.csv" ]; then
                            echo "update: ${combinedID}_L.csv"
                            cp "$remoteFolder/csv/${combinedID}_L.csv" "$mmFolder/csv/${combinedID}_L.csv"
                        fi
                        if [ ! -f "$mmFolder/csv/${combinedID}_L.json" ] || [ "$remoteFolder/csv/${combinedID}_L.json" -nt "$mmFolder/csv/${combinedID}_L.json" ]; then
                            echo "update: ${combinedID}_L.json"
                            cp "$remoteFolder/csv/${combinedID}_L.json" "$mmFolder/csv/${combinedID}_L.json"
                        fi
                        if [ ! -f "$mmFolder/csv/${combinedID}_R.csv" ] || [ "$remoteFolder/csv/${combinedID}_R.csv" -nt "$mmFolder/csv/${combinedID}_R.csv" ]; then
                            echo "update: ${combinedID}_R.csv"
                            cp "$remoteFolder/csv/${combinedID}_R.csv" "$mmFolder/csv/${combinedID}_R.csv"
                        fi
                        if [ ! -f "$mmFolder/csv/${combinedID}_R.json" ] || [ "$remoteFolder/csv/${combinedID}_R.json" -nt "$mmFolder/csv/${combinedID}_R.json" ]; then
                            echo "update: ${combinedID}_R.json"
                            cp "$remoteFolder/csv/${combinedID}_R.json" "$mmFolder/csv/${combinedID}_R.json"
                        fi
                    fi
                    echo "update: $file"
                    cp "$remoteFolder/results/$combinedID/$file" "$mmFolder/results_org/$combinedID/$file"
                fi
            done
        done
        echo "finish syncing"
    fi

    ls -1 "$mmFolder/results_org" \
    | while read combinedID; do
        ls -1 "$mmFolder/results_org/$combinedID" \
        | while read file; do
            if [ "$mmFolder/results_org/$combinedID/$file" -nt "$mmFolder/lastupdate" ]; then
                if [ ! -d "$mmFolder/results/$combinedID" ]; then
                    mkdir "$mmFolder/results/$combinedID"
                fi
                echo "newer: $combinedID/$file"
                cp "$mmFolder/results_org/$combinedID/$file" "$mmFolder/results/$combinedID/"
            fi
        done
    done
    touch -d "`date \"+%F %T\"`" "$mmFolder/lastupdate"

#
# updateDivisionName
#
# update division name
#
elif [ "$1" == "updateDivisionName" ]; then
    resultsPath="$relayFolder/common/matchmaker/results_org"
#    ls -1 $relayFolder/common/raceserv/*.png | grep -E '.*\/[EP]{1}[0-9]{3}.*\.png$' \
#    ls -1 $relayFolder/common/raceserv/results_org/*.png | grep -E '.*\/[EP]{1}[0-9]{3}\.png$' \
    ls -1 $resultsPath | grep -E '[EP]{1}[0-9]{3}$' \
    | while read file; do
        file="$resultsPath/$file/$(ls -1 $resultsPath/$file | grep "\.png$")"
        teamID=`echo "$file" | sed -E 's/.*\/[EP]{1}([0-9]{3}).*\.png$/\1/'`
        teamNo=`echo $teamID | sed -E 's/^00([1-9]{1})$/\1/' | sed -E 's/^0([1-9]{1}[0-9]{1})$/\1/'`
        divisionID=`echo "$Teams" | jq -r ".[]|select(.ID==\"$(awk "BEGIN { print $teamNo }")\")|.divisionID"`
        if [ "$divisionID" == "4" ]; then
            echo "Tokyo : $file"
            convert "$file" "$relayFolder/common/matchmaker/04.png" -gravity northwest -compose over -composite "$file"
        elif [ "$divisionID" == "8" ]; then
            echo "Kansai: $file"
            convert "$file" "$relayFolder/common/matchmaker/08.png" -gravity northwest -compose over -composite "$file"
        fi
    done

#
# rerun
#
# do postproduction with matchmaker/results re-run files
#
elif [ "$1" == "rerun" ]; then
    ls -1 "$relayFolder/common/matchmaker/results" \
    | while read combinedID; do
        echo "generate images: $combinedID"
        sourceFolder="$relayFolder/common/matchmaker/results/$combinedID"
        ffutil generateResultImages "$sourceFolder/${combinedID}_リザルト.png"
        cp "$sourceFolder/${combinedID}.png" "$relayFolder/common/raceserv/results/"
        cp "$sourceFolder/${combinedID}_L_check.png" "$relayFolder/common/raceserv/"
        cp "$sourceFolder/${combinedID}_L_result.png" "$relayFolder/common/raceserv/"
        cp "$sourceFolder/${combinedID}_R_check.png" "$relayFolder/common/raceserv/"
        cp "$sourceFolder/${combinedID}_R_result.png" "$relayFolder/common/raceserv/"
        rm "$sourceFolder/${combinedID}.png"
        rm "$sourceFolder/${combinedID}_L_check.png"
        rm "$sourceFolder/${combinedID}_L_result.png"
        rm "$sourceFolder/${combinedID}_R_check.png"
        rm "$sourceFolder/${combinedID}_R_result.png"
    done

    echo "move files into results_org"
    mv "$relayFolder/common/raceserv/results/"* "$relayFolder/common/raceserv/results_org/"

#
# replaceMovies [all|division|id] [id]
#
# replace to mmmuxed movies into result files which in 'Results_org' and store to Results folder
#
elif [ "$1" == "replaceMovies" ]; then
    sourceFolder="$relayFolder/Results_org"
    destinationFolder="$relayFolder/Results"

    mode="all"
    unset id
    groups=(1 2 4 5 6 8 9 12 11 14 A B C CS)
    unset teamID
    unset divisionID
    unset classLetter
    unset targetID
    if [ "$2" == "all" ] || [ "$2" == "division" ] || [ "$2" == "id" ]; then
        mode="$2"
        id="$3"
        if [ "$mode" == "division" ]; then
            groups=($id)
        elif [ "$mode" == "id" ]; then
            teamID="$id"
            record=`echo $Teams | jq -cr ".[]|select(.ID==\"$teamID\")"`
            divisionID=$(json record.divisionID)
            classLetter=$(json record.classLetter)
            record=`echo $Divisions | jq -cr ".[]|select(.ID==\"$divisionID\")"`
            if [ "$classLetter" == "A" ]; then
                targetID=$(json record.blockLetter)
            else
                targetID=$(json record.groupID)
            fi
            if [ "$divisionID" == "0" ]; then
                targetID="0"
            fi
        fi
    fi

    ls -1 "$sourceFolder" | sed -E 's/^[EAP]_(.*)\.zip/\1/' \
    | while read requestID; do
        echo "debug: $requestID"
        skip="skip"
        record=`echo "$Requests" | jq -cr ".[]|select(.ID==\"$requestID\")"`
        if [ "$mode" == "id" ]; then
            if [ "$teamID" == "$(json record.teamID)" ]; then
                courseLetter=$(json record.courseLetter)
                unset skip
            fi
        else
            teamID=$(json record.teamID)
            divisionID=$(json record.divisionID)
            classLetter=$(json record.classLetter)
            courseLetter=$(json record.courseLetter)
            record=`echo "$Divisions" | jq -cr ".[]|select(.ID==\"$divisionID\")"`
            if [ "$classLetter" == "A" ]; then
                targetID=$(json record.blockLetter)
            else
                targetID=$(json record.groupID)
            fi
            if [ "$divisionID" == "0" ]; then
                targetID="0"
            fi
            for group in ${groups[@]}; do
                if [ "$group" == "$targetID" ] || [ "$targetID" == "0" ]; then
#                    echo "divisionID: $divisionID  targetID=$targetID  group=$group"
                    unset skip
                fi
            done
        fi

        if [ -z "$skip" ]; then
            combinedID="${classLetter}$(printf "%03d" $teamID)"
            raceID="${combinedID}_${courseLetter}"
            target="${classLetter}_${requestID}.zip"

            echo "$requestID -> $raceID @ $targetID"
            mkdir -p "${destinationFolder}_${targetID}_${classLetter}"
            cp "$sourceFolder/$target" "${destinationFolder}_${targetID}_${classLetter}/"
            target="${destinationFolder}_${targetID}_${classLetter}/$target"
            innerFolder=`unzip -Z1 "$target" | head -n 1 | sed -E 's/^(.*)\/$/\1/'`
            cd "${destinationFolder}_${targetID}_${classLetter}"
            mkdir "$innerFolder"
            echo "replace: $raceID"
            cp "$relayFolder/common/matchmaker/results/${combinedID}_リザルト.png" "${innerFolder}/"
            cp "$relayFolder/common/raceserv/results/$raceID.mp4" "${innerFolder}/"
            cp "$relayFolder/common/matchmaker/csv/$raceID.csv" "${innerFolder}/"
            zip "$target" -d $innerFolder/$innerFolder.csv $innerFolder/$innerFolder.mp4 $innerFolder/result.json
            zip "$target" -r $innerFolder
            rm -rf $innerFolder
        fi
    done

#
# catResults /path/to/Results_divisionID_[EP]
#
# show requestID and raceID
#
elif [ "$1" == "catResults" ]; then
    sourceFolder="$2"

    ls -1 "$sourceFolder" \
    | while read requestFile; do
        requestID=`echo $requestFile | sed -E 's/^[EAP]_(.*)\.zip/\1/'`
        record=`echo $Requests | jq -cr ".[]|select(.ID==\"$requestID\")"`
        teamID=$(json record.teamID)
        classLetter=$(json record.classLetter)
        courseLetter=$(json record.courseLetter)
        combinedID="${classLetter}$(printf "%03d" $teamID)"
        raceID="${combinedID}_${courseLetter}"
        echo "$requestFile,$raceID"
    done

#
# assignResults /path/to/Results_divisionID_[EP]
#
# assign a division's Results folder to half1 and half2
# need hardcode combinedID array of half1 as H1
#
elif [ "$1" == "assignResults" ]; then
    H1=(P079 P147 P098 P131 P082 P102 P048 P146 P052 P087 P092 P123 P046 P164 P112 P095 P091)
    sourceFolder="$2"

    mkdir -p "${sourceFolder}_H1"
    mkdir -p "${sourceFolder}_H2"

    prepare_final.sh catResults "$sourceFolder" \
    | while read result; do
        requestFile=`echo $result | sed -E 's/^(.*),([EP]{1}[0-9]{3})\_[LR]{1}$/\1/'`
        combinedID=`echo $result | sed -E 's/^(.*),([EP]{1}[0-9]{3})\_[LR]{1}$/\2/'`
        unset found
        for attempt in ${H1[@]}; do
            if [ "$combinedID" == "$attempt" ]; then
                found="found"
            fi
        done
        if [ $found ]; then
            echo "$requestFile ($combinedID) -> H1"
            cp "$sourceFolder/$requestFile" "${sourceFolder}_H1/"
        else
            echo "$requestFile ($combinedID) -> H2"
            cp "$sourceFolder/$requestFile" "${sourceFolder}_H2/"
        fi
    done

#
# joinResults
#
# join all result files on /path/to/Results_divisionID_[EP] into /path/to/Results_E
#
elif [ "$1" == "joinResults" ]; then
    mkdir -p "$relayFolder/Results_E"
    ls -1 "$relayFolder" | grep ^Results_.*_E$ \
    | while read line; do
        ls -1 "$relayFolder/$line" \
        | while read file; do
            cp -f "$relayFolder/$line/$file" "$relayFolder/Results_E/"
        done
    done

#
# returnResults [bib] /path/to/Results_divisionID_[EPA] <teamID|bibID>
#
# return a teamID's or a bibID's Results file from /path/to/Results_divisionID_[EPA]
# /path/to/Results_divisionID_[EPA] have to contain the actual relayFolder at sim/ope-vm
#
elif [ "$1" == "returnResults" ]; then
    unset bibMode
    if [ "$2" == "bib" ]; then
        bibMode="$2"
        shift 1
    fi
    sourceFolder="$2"
    unset teamID
    if [ -n "$bibMode" ]; then
        teamID=`echo "$Teams" | jq -cr ".[]|select(.bibID==\"$3\").ID"`
    else
        teamID="$3"
    fi
    echo "$Requests" | jq -cr ".[]|select(.teamID==\"$teamID\")" \
    | while read record; do
        classLetter=$(json record.classLetter)
        courseLetter=$(json record.courseLetter)
        requestID=$(json record.ID)
        file="${classLetter}_${requestID}.zip"
        if [ -f "$sourceFolder/$file" ]; then
            echo "${classLetter}$(printf "%03d" $teamID)_$courseLetter = $file"
            mv "$sourceFolder/$file" "$(dirname $sourceFolder)/Results/"
        else
            echo "${classLetter}$(printf "%03d" $teamID)_$courseLetter is already moved"
        fi
    done
    ETroboSimRunner.Relay.sh return "$relayFolder"

#
# oneMoreChance [finalChance]
#
# re-race the retired teams that be determined from results.csv
# oneMoreChance re-race all retired races
# finalChance re-race the teams which both L and R were retired
#
elif [ "$1" == "oneMoreChance" ]; then
    unset chanceType
    if [ "$2" == "finalChance" ]; then
        chanceType="$2"
    else
        chanceType="$1"
    fi

    # backup files
    workFolder="$commonFolder/work"
    chanceFolder="$workFolder/$chanceType"
    if [ ! -d "$chanceFolder" ]; then
        mkdir -p "$chanceFolder/Results_old"
        mkdir -p "$chanceFolder/common/csv_old"
        mkdir -p "$chanceFolder/common/matchmaker/csv_old"
        mkdir -p "$chanceFolder/common/raceserv_old"
        mkdir -p "$chanceFolder/common/work_old"

        resultsFile_src="$chanceFolder/common/work_old/results.csv"
        mv "$workFolder/results.csv" "$resultsFile_src"
    else
        echo "aborted: no more chance."
    fi

    resultsFile_tmp="$commonFolder/work/results_tmp.csv"
    unset resultsFile_dst
    if [ -z "$finalChance" ]; then
        echo "** One More Chance **"
        resultsFile_dst="$commonFolder/work/results_org.csv"
        if [ -f "$resultsFile_dst" ]; then
            echo "aborted: no more chance."
            unset resultsFile_dst
        else
            cp -f "$resultsFile_src" "$resultsFile_dst"
            resultsFile_src="$resultsFile_dst"
            resultsFile_dst="$commonFolder/work/results_oneMoreChance.csv"
        fi
    else
        echo "** Final Chance **"
        resultsFile_dst="$commonFolder/work/results_oneMoreChance_org.csv"
        if [ -f "$resultsFile_dst" ]; then
            echo "aborted: no more chance."
            unset resultsFile_dst
        else
            cp -f "$resultsFile_src" "$resultsFile_dst"
            resultsFile_src="$resultsFile_dst"
            resultsFile_dst="$commonFolder/work/results_finalChance.csv"
        fi
    fi

    # determine the teams
    if [ -n "$resultFile_dst" ]; then
        while read line; do
            echo $line;
        done
    fi
elif [ "$1" == "doit" ]; then
    workFolder="$commonFolder/work"
    chanceFolder="$workFolder/oneMoreChance"
    results_old="$chanceFolder/Results_old"
    csv_old="$chanceFolder/common/csv_old"
    matchmaker_csv_old="$chanceFolder/common/matchmaker/csv_old"
    raceserv_old="$chanceFolder/common/raceserv_old"
    work_old="$chanceFolder/common/work_old"
    results_src="$relayFolder/Results"
    csv_src="$relayFolder/common/csv"
    matchmaker_csv_src="$relayFolder/common/matchmaker/csv"
    raceserv_src="$relayFolder/common/raceserv"
    work_src="$chanceFolder/common/work"
    requestIDs=() # input requestIDs
    teamIDs=() # input teamIDs
    courses=() # input courses
    for ((i=0; i<${#requestIDs[@]}; i++)); do
        echo "${requestIDs[$i]} - ${teamIDs[$i]}${courses[$1]}"
        mv "$results_src/E_${requestIDs[$i]}.zip" "$results_old/"
        mv "$csv_src/E_${requestIDs[$i]}.csv" "$csv_old/"
        mv "$matchmaker_csv_src/E${teamIDs[$i]}_${courses[$i]}.csv" "$matchmaker_csv_old/"
        mv "$raceserv_src/E${teamIDs[$i]}_${courses[$i]}.mp4" "$raceserv_old/"
        mv "$raceserv_src/E${teamIDs[$i]}_${courses[$i]}_1.mp4" "$raceserv_old/"
        mv "$raceserv_src/E${teamIDs[$i]}_${courses[$i]}_2.mp4" "$raceserv_old/"
        mv "$raceserv_src/E${teamIDs[$i]}_${courses[$i]}_3.mp4" "$raceserv_old/"
        mv "$raceserv_src/E${teamIDs[$i]}_${courses[$i]}_4.mp4" "$raceserv_old/"
        cp "$relayFolder/Requests_org/E_${requestIDs[$i]}.zip" "$relayFolder/Requests/"
    done

#
# quickConv <combinedID|bibID> [isCombinedID]
#
# convert combinedID to bibID or bibID to combinedID
# if isCombinedID is specified, return true if the first argument is combinedID or empty string if isn't it
#
elif [ "$1" == "quickConv" ]; then
    if [ -n "`echo $2 | grep -E '^[EP]{1}[0-9]{3}$'`" ]; then
        combinedID="$2"
        teamID=`echo "$combinedID" | sed -E 's/^[EP]{1}0*([1-9]*).*$/\1/'`
        bibID=`echo "$Teams" | jq -cr ".[]|select(.ID==\"$teamID\").bibID"`
        if [ "$3" == "isCombinedID" ]; then
            echo "true"
        else
            echo "$bibID"
        fi
    elif [ -n "`echo $2 | grep -E '^[EW]{1}-[0-9]{2}$'`" ]; then
        bibID="$2"
        teamID=`echo "$Teams" | jq -cr ".[]|select(.bibID==\"$bibID\").ID"`
        combinedID="`echo "$Teams" | jq -cr ".[]|select(.ID==\"$teamID\").classLetter"`$(printf "E%03d" $teamID)"
        if [ "$3" == "isCombinedID" ]; then
            echo ""
        else
            echo "$combinedID"
        fi
    fi

#
# filenamesInto <combinedID|bibID> /path/to/folder
#
# convert all filenames into combinedID or bibID
#
elif [ "$1" == "filenamesInto" ]; then
    ls -1 "$3" | \
    while read line; do
        id=`echo $line | sed -E 's/^(.{4}).*$/\1/'`
        footer=`echo $line | sed -E 's/^(.{4})(.*)$/\2/'`
        isCombinedID=`prepare_final.sh quickConv $id isCombinedID`
        if [ -n "$isCombinedID" ] && [ "$2" == "bibID" ]; then
            id=`prepare_final.sh quickConv $id`
            mv "$3/$line" "$3/${id}${footer}"
        elif [ -z "$isCombinedID" ] && [ "$2" == "combinedID" ]; then
            id=`prepare_final.sh quickConv $id`
            mv "$3/$line" "$3/${id}${footer}"
        fi
        echo "$line -> $id$footer"
    done
fi
