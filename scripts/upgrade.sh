#!/usr/bin/env bash

SAMPLE_COMMAND='`sh upgrade.sh {api_version} {s3url - https://s3-ap-south-1.amazonaws.com/skybot-binaries/debug/1.1/build.tar.gz }`'
if [ "$#" -ne 2 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi
API_VERSION=$1
S3URL=$2
GITHUB_PATH='https://github.com/skybotgit/gateway.git'
WORKPLACE=/opt/workplace
DIR=/opt/skybot
DEPLOY_PATH=/opt/bin
UPGRADE='false'
TYPE='release'

sudo rm -Rf $WORKPLACE
sudo mkdir -p $WORKPLACE
cd $WORKPLACE
sudo wget $S3URL
sudo tar -zxvf build.tar.gz ./
sudo rm build.tar.gz

cd $DIR

sudo git reset --hard

status=$(sudo git pull origin)
if [ "$status" == error:* ]; then
    echo $status
    exit
fi

current_branch=$(sudo git branch | grep \* | cut -d ' ' -f2)
if [ "$current_branch" != "version/$API_VERSION" ]; then
    status=$(sudo git checkout --quiet version/$API_VERSION)
    if [ "$status" == error:* ]; then
        echo $status
        exit
    fi
fi

status=$(sudo git pull origin version/$API_VERSION)
if [ "$status" == error:* ]; then
    echo $status
    exit
fi

sudo supervisorctl stop all >> /dev/null
sudo rm -Rf /etc/supervisor/conf.d/*.conf
sudo cp -Rf $DIR/scripts/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
sudo rm -Rf $DEPLOY_PATH
sudo mkdir -p $DEPLOY_PATH
sudo cp -Rf $WORKPLACE/bin/* $DEPLOY_PATH
sudo cp -Rf $DIR/static $DEPLOY_PATH
sudo chown -Rf 0777 $DEPLOY_PATH
sudo chmod -Rf +x $DEPLOY_PATH
sudo rm -Rf $WORKPLACE
sudo hotspotd stop >> /dev/null
sudo ps aux | grep -i $DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/heartbeat | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/hotspot | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/s2r | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/r2s | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/init | awk {'print $2'} | sudo xargs kill -9

sleep 2
sudo supervisorctl reload >> /dev/null
sleep 5
sudo sh $DIR/scripts/crontab.sh >> /dev/null
sleep 5
echo "True"
sudo chmod -Rf +x $DIR/scripts/upgrade.sh
sudo cp -Rf $DIR/scripts/upgrade.sh /opt
