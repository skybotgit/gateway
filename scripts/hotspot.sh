#!/usr/bin/env bash

DEPLOY_PATH=/opt/bin
sudo hotspotd stop >>/dev/null 2>&1
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9 >>/dev/null 2>&1
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9 >>/dev/null 2>&1
sudo rm -rf /etc/wpa_supplicant/wpa_supplicant.conf >>/dev/null 2>&1
Temp_File_Path=/tmp/wpa_supplicant.conf
Target_File_Path=/etc/wpa_supplicant/wpa_supplicant.conf
sudo rm $Temp_File_Path >>/dev/null 2>&1
sudo cp /opt/skybot/scripts/etc/wpa_supplicant/wpa_supplicant.conf.hotspot /tmp >>/dev/null 2>&1
cd /tmp
sudo mv wpa_supplicant.conf.hotspot wpa_supplicant.conf >>/dev/null 2>&1
sudo chown root:root $Temp_File_Path >>/dev/null 2>&1
sudo chmod 644 $Temp_File_Path >>/dev/null 2>&1
sudo cp -Rf $Temp_File_Path /etc/wpa_supplicant/ >>/dev/null 2>&1
sudo rm $Temp_File_Path >>/dev/null 2>&1
sudo ifdown wlan0 >>/dev/null 2>&1
sudo ifup wlan0 >>/dev/null 2>&1
sudo ifup wlan0 >>/dev/null 2>&1
sudo hotspotd start >>/dev/null 2>&1

sleep 15
sudo $DEPLOY_PATH/start_hotspot_server >>/dev/null 2>&1 &
sudo supervisorctl stop hotspot >>/dev/null 2>&1
sudo supervisorctl start hotspot >>/dev/null 2>&1
echo "True"