#!/usr/bin/env bash

SAMPLE_COMMAND='`sh upgrade.sh {s3_region} {s3_bucket} {environment} {mode} {version}`'
if [ "$#" -ne 5 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi
S3_REGION=$1
S3_BUCKET=$2
ENVIRONMENT=$3
MODE=$4
VERSION=$5
S3URL="https://s3-${S3_REGION}.amazonaws.com/${S3_BUCKET}/${ENVIRONMENT}/${MODE}/${VERSION}/build.tar.gz"
GITHUB_PATH='https://github.com/skybotgit/gateway.git'
WORKPLACE=/opt/workplace
DIR=/opt/skybot
BIN_DEPLOY_PATH=/opt/bin

sudo rm -Rf $WORKPLACE
sudo mkdir -p $WORKPLACE
cd $WORKPLACE
sudo wget -nv $S3URL
sudo tar -zxvf build.tar.gz ./
sudo rm build.tar.gz

cd /opt
sudo rm -Rf gateway

sudo git clone $GITHUB_PATH
cd gateway
sudo git checkout --quiet version/$VERSION

sudo supervisorctl stop all >> /dev/null
sudo rm -Rf /etc/supervisor/conf.d/*.conf
sudo cp -Rf /opt/gateway/scripts/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
sudo cp -Rf /opt/gateway/scripts/core.sh /opt
sudo rm -Rf $BIN_DEPLOY_PATH
sudo mkdir -p $BIN_DEPLOY_PATH
sudo cp -Rf $WORKPLACE/bin/* $BIN_DEPLOY_PATH
sudo cp -Rf /opt/gateway/static $BIN_DEPLOY_PATH
sudo chown -Rf 0777 $BIN_DEPLOY_PATH
sudo chmod -Rf +x $BIN_DEPLOY_PATH
sudo rm -Rf $WORKPLACE
sudo hotspotd stop >> /dev/null
sudo ps aux | grep -i $BIN_DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/heartbeat | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/hotspot | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/s2r | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/r2s | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $BIN_DEPLOY_PATH/init | awk {'print $2'} | sudo xargs kill -9

sleep 2
sudo supervisorctl start all >> /dev/null
sleep 5
sudo sh $DIR/scripts/crontab.sh >> /dev/null
sleep 5
sudo /opt/bin/init
sleep 5
echo "True"
sudo rm -Rf $DIR
sudo mv /opt/gateway $DIR
sudo chmod -Rf +x $DIR/scripts/upgrade.sh
sudo cp -Rf $DIR/scripts/upgrade.sh /opt
