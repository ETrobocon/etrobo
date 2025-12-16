#!/usr/bin/env bash

raceCSV="/mnt/f/_race/capture/R.csv"

fields=(`cat "$raceCSV" | head -n 1 | sed -E 's/[,\r\n]/\ /g'`)
mapper=""
for ((i=0; i<${#fields[@]}; i++)); do
    if [ -n "$mapper" ];then
        mapper="$mapper,"
    fi
    mapper="${mapper}\"${fields[$i]}\":.[$i]"
done

raceJson=`cat "$raceCSV" | tail -n 1 | sed -E 's/\r//g' \
        | jq -csR 'split("\n")|map(split(","))|map({'$mapper'})|del(.[][]|nulls)' \
        | sed -E 's/,\{\}//' | jq -c .`

resultJson="{}"
reassembleFields=( \
    TIME \
    MEASUREMENT_TIME \
    RUN_TIME \
    GATE1 \
    GATE2 \
    GOAL \
    GARAGE_STOP \
    GARAGE_TIME \
    SLALOM \
    PETBOTTLE \
    BLOCK_IN_GARAGE \
    BLOCK_YUKOIDO \
    CARD_NUMBER_CIRCLE \
    BLOCK_NUMBER_CIRCLE \
    BLOCK_BINGO \
    ENTRY_BONUS \
    BLOCK_YUKOIDOP \
    BLOCK_YUKOIDOC \
    BLOCK_BINGOP \
    LAP_POLE_TOUCHED \
    CARRY_BLOCK_MOVE \
    SMART_CARRY \
    GOAL_AREA_STOP \
)
course="left"
for ((i=0; i<${#reassembleFields[@]}; i++)); do
    resultJson="$(echo "$resultJson" | jq ".${course}Measurement.${reassembleFields[i]}|=\"$(echo "$raceJson" | jq -r ".[0].${reassembleFields[i]}")\"")"
done

echo "$resultJson"