#!/usr/bin/env bash
KINDLE_IP="${KINDLE_IP:=10.0.3.192}" 
KINDLE_PASSWORD="${KINDLE_PASSWORD:=kindle}" 
HOMEASSISTANT_URL="${HOMEASSISTANT_URL:=http://10.0.0.27:8123/vr-welcome/kindle?kiosk}" 
# Screaming case for docker
export login_page="${HOMEASSISTANT_URL}"
export login_username="${HOMEASSISTANT_LOGIN_USER:=kindle}" 
export login_password="${HOMEASSISTANT_LOGIN_PASS:=kindle}" 

if nc -z -w 1 ${KINDLE_IP} 22 ; then
  # Decide if we want to sleep a little
  brightness=$(sshpass -p "${KINDLE_PASSWORD}" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no 'bash -c "cat /sys/devices/system/fl_tps6116x/fl_tps6116x0/fl_intensity"' 2>/dev/null | grep -o -e '[0-9]' |  tr -d "\n")
  if [ "$brightness" -gt 240 ]; then
      echo "You probably want to read something... Sleeping for $READING_DURATION"
      sleep ${READING_DURATION} || sleep 7200
  fi
  # Run pupeteer
  node home_assistant.js
  # Convert to a nice grayscale, while theoreticaly the kindle could work this out byhimself, it looks ugly
  convert home_assistant.png -depth 4 -colorspace gray -define png:color-type=0 -define png:bit-depth=8 home_assistant_8bit.png

  TIME=$(date +"%M")
  # Clear the display every 10 minutes https://superuser.com/a/49786
  if [ $(( $TIME % 10 )) -eq 0 ]
  then 
    sshpass -p "${KINDLE_PASSWORD}" ssh root@${KINDLE_IP} 'eips -c; eips -c'
  else
    # echo "$(date +"%M") is not divisible by 10, No screen clear"
    true
  fi
  # Copy the picture
  sshpass -p "${KINDLE_PASSWORD}" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no home_assistant_8bit.png root@${KINDLE_IP}:/mnt/us/documents/ && echo copyed || echo "issue copying to kindle"
  # Set the picture 
  sshpass -p "${KINDLE_PASSWORD}" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${KINDLE_IP} 'eips -g /mnt/us/documents/home_assistant_8bit.png' > /dev/null 2>&1
else
  echo "Kindle not connected to the Network, or it has now another IP"
  exit 0
fi