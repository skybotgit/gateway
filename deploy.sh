#!/usr/bin/env bash
SAMPLE_COMMAND='`sh deploy.sh release 1.1`'
if [ "$#" -ne 2 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi

TYPE=$1
VERSION=$2

if [ "$TYPE" != 'debug' -a "$TYPE" != 'release' ]
then
    echo "Argument should be from 'debug', 'release'"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi

DIR=/opt/skybot
S3URL="https://s3-ap-south-1.amazonaws.com/skybot-binaries/${TYPE}/${VERSION}/build.tar.gz"
WORKPLACE=/opt/workplace
DEPLOY_PATH=/opt/bin

sudo rm -Rf $WORKPLACE
sudo mkdir -p $WORKPLACE
cd $WORKPLACE
sudo wget $S3URL
sudo tar -zxvf build.tar.gz ./
sudo rm build.tar.gz

cd $DIR
sudo supervisorctl stop all
sudo git reset --hard
sudo git pull origin
sudo git pull origin version/$VERSION
sudo rm -Rf /etc/supervisor/conf.d/*.conf
sudo cp -Rf $DIR/scripts/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
sudo rm -Rf $DEPLOY_PATH
sudo mkdir -p $DEPLOY_PATH
sudo cp -Rf $WORKPLACE/bin/* $DEPLOY_PATH
sudo cp -Rf $DIR/static $DEPLOY_PATH
sudo chown -Rf 0777 $DEPLOY_PATH
sudo chmod -Rf +x $DEPLOY_PATH
sudo rm -Rf $WORKPLACE
sudo hotspotd stop
sudo ps aux | grep -i $DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/offline | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/start_hotspot_server | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/heartbeat | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DIR/scripts/hotspot | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/s2r | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/r2s | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/init | awk {'print $2'} | sudo xargs kill -9

sleep 2
sudo supervisorctl reload
sleep 5
sudo supervisorctl status
sudo sh $DIR/scripts/crontab.sh
echo "SkyBot installed successfully"
echo "check logs with tail -f /opt/log/skybot"
sudo cp -Rf $DIR/scripts/upgrade.sh /opt
sudo chmod -Rf +x /opt/upgrade.sh
if [ "$TYPE" = 'debug' ]
then
    tail -f /opt/log/skybot
fi
