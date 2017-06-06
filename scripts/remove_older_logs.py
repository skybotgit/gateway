#!/usr/bin/python

# run by crontab
# removes any files in /opt/log/ older than 3 days

import os, time

now = time.time()
cutoff = now - (3 * 86400)

files = os.listdir("/opt/log")
for xfile in files:
	if os.path.isfile("/opt/log/" + xfile):
		t = os.stat("/opt/log/" + xfile)
		c = t.st_ctime
		
		# delete file if older than cutoff
		if c < cutoff:
			os.remove("/opt/log/" + xfile)

print "Remove old log files job executed successfully."
