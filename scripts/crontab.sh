#!/bin/bash

setCrons(){
    crontmp=/tmp/cron.skybot
    echo "@reboot sudo /opt/bin/init" >> $crontmp 2>&1
    echo "@reboot sudo python /opt/skybot/scripts/remove_older_logs.py" >> $crontmp 2>&1
    echo "5 */12 * * * sudo python /opt/skybot/scripts/remove_older_logs.py" >> $crontmp 2>&1
    echo "15 */3 * * * sudo python /opt/skybot/scripts/reboot.py" >> $crontmp 2>&1
    if [ -f "/usr/bin/weavedstart.sh" ]; then
        echo "@reboot /usr/bin/weavedstart.sh" >> $crontmp
    fi
    echo "@daily sudo supervisorctl reload" >> $crontmp 2>&1
    sudo crontab $crontmp
    sudo rm $crontmp
}
setCrons
echo "Crons setup successfully"