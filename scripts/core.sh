#!/usr/bin/env bash

SAMPLE_COMMAND='`sh core.sh`'

DIR=/opt/skybot

cd $DIR

sudo git reset --quiet --hard

status=$(sudo git pull origin --quiet)
if [ "$status" == error:* ]; then
    echo $status
    exit
fi

sudo rm -Rf /opt/upgrade.sh
sudo cp -Rf $DIR/scripts/upgrade.sh /opt

echo "True"