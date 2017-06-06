#!/bin/bash

setCrons(){
    crontmp=/tmp/cron.skybot
    echo "@reboot /opt/bin/init >>/dev/null 2>&1" >> $crontmp
    echo "*/1 * * * * /opt/bin/scheduler" >> $crontmp
    if [ -f "/usr/bin/weavedstart.sh" ]; then
        echo "@reboot /usr/bin/weavedstart.sh" >> $crontmp
    fi
    sudo crontab $crontmp
    sudo rm $crontmp
}
setCrons
echo "Crons setup successfully"