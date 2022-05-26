#!/usr/bin/env bash

while true;
do
    ./homeassistant.sh
    sleep ${SLEEP:=1m}
done