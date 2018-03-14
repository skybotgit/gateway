#!/usr/bin/env bash

replace_string() {
    FILE_PATH=$1
    SEARCH="{{$2}}"
    REPLACE="$3"
    if [[ "$OSTYPE" = "linux-gnu"* ]]
    then
        sudo sed -i "s/$SEARCH/$REPLACE/g" $FILE_PATH
    elif [[ "$OSTYPE" = "darwin"* ]]
    then
        sudo sed -i .bak "s/$SEARCH/$REPLACE/g" $FILE_PATH
    fi
}

SAMPLE_COMMAND='`sh wifi.sh {ssid} {psk}`'
#SAMPLE_COMMAND='`sh wifi.sh {ssid} {psk} {proto} {key_mgmt} {pairwise} {auth_alg}`'
if [ "$#" -ne 2 ]; then
#if [ "$#" -ne 6 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi

SSID=$1
PSK=$2
PROTO="RSN"
KEY_MGMT="WPA-PSK"
PAIRWISE="CCMP"
AUTH_ALG="OPEN"

#if [ "$PROTO" != 'RSN' -a "$PROTO" != 'WPA' ]
#then
#    echo "Proto should be from 'RSN', 'WPA'"
#    echo 'Sample Command :'$SAMPLE_COMMAND
#    exit
#fi

#if [ "$KEY_MGMT" != 'WPA-PSK' -a "$KEY_MGMT" != 'WPA-EAP' ]
#then
#    echo "Key_mgmt should be from 'WPA-PSK', 'WPA-EAP'"
#    echo 'Sample Command :'$SAMPLE_COMMAND
#    exit
#fi
#
#
#if [ "$PAIRWISE" != 'CCMP' -a "$PAIRWISE" != 'TKIP' ]
#then
#    echo "Pairwise should be from 'CCMP', 'TKIP'"
#    echo 'Sample Command :'$SAMPLE_COMMAND
#    exit
#fi
#
#if [ "$AUTH_ALG" != 'OPEN' -a "$AUTH_ALG" != 'LEAP' -a "$AUTH_ALG" != 'SHARED' ]
#then
#    echo "Pairwise should be from 'OPEN', 'LEAP', 'SHARED'"
#    echo 'Sample Command :'$SAMPLE_COMMAND
#    exit
#fi

sudo hotspotd stop >>/dev/null 2>&1
sleep 2
File_Path=/tmp/wpa_supplicant.conf
Target_File_Path=/etc/wpa_supplicant/wpa_supplicant.conf
sudo cp -Rf /opt/skybot/scripts$Target_File_Path /tmp
replace_string $File_Path "ssid" "${SSID}"
replace_string $File_Path "psk" "${PSK}"
replace_string $File_Path "key_mgmt" "${KEY_MGMT}"
replace_string $File_Path "proto" "${PROTO}"
replace_string $File_Path "pairwise" "${PAIRWISE}"
replace_string $File_Path "auth_alg" "${AUTH_ALG}"

sudo chown root:root $File_Path
sudo chmod 600 $File_Path
sudo cp -Rf $File_Path /etc/wpa_supplicant/
sudo rm $File_Path

sleep 2
sudo ifdown wlan0 >>/dev/null 2>&1
sleep 2
sudo ifup wlan0 >>/dev/null 2>&1

sleep 2
echo "True"