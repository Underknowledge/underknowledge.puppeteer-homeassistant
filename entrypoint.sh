#!/usr/bin/env bash

while true;
do
    ./homeassistant.sh
    sleep ${SLEEP:=60}
done