#!/bin/bash

setCrons(){
    crontmp=/tmp/cron.skybot
    echo "@reboot /opt/bin/init" >> $crontmp 2>&1
    echo "@reboot sudo python /opt/skybot/scripts/remove_older_logs.py" >> $crontmp 2>&1
    echo "0 0 1 * * ? sudo python /opt/skybot/scripts/remove_older_logs.py" >> $crontmp 2>&1
    echo "*/1 * * * * /opt/bin/scheduler" >> $crontmp
    if [ -f "/usr/bin/weavedstart.sh" ]; then
        echo "@reboot /usr/bin/weavedstart.sh" >> $crontmp
    fi
    sudo crontab $crontmp
    sudo rm $crontmp
}
setCrons
echo "Crons setup successfully"