import logging
from logging.handlers import TimedRotatingFileHandler
import os
import RPi.GPIO as GPIO
import time
import subprocess
import traceback


def set_logger(name):
	import subprocess
	
	if os.path.isdir("/opt/log/") is False:
		subprocess.call(['sudo', 'mkdir', '-p', "/opt/log/"])
	
	logging.basicConfig(filename="/opt/log/skybot.log",
	                    level=logging.DEBUG,
	                    format='%(asctime)s - %(name)s - %(module)s - %(levelname)s - %(filename)s - %(lineno)d - %(funcName)s - %(message)s',
	                    datefmt='%Y-%m-%d %H:%M:%S')
	# create file handler which logs even debug messages
	handler = TimedRotatingFileHandler("/opt/log/skybot.log", when="midnight", backupCount=10)
	handler.setLevel(logging.DEBUG)
	
	logger = logging.getLogger(name)
	logger.setLevel(logging.DEBUG)
	
	logger.addHandler(handler)
	
	return logger

set_logger('hotspot')

GPIO.setmode(GPIO.BOARD)

try:
	PIN = 35
	GPIO.setup(PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
	while True:
		GPIO.wait_for_edge(PIN, GPIO.FALLING)
		logging.debug("Hotspot Pin (" + str(PIN) + ") pressed.")
		start = time.time()
		time.sleep(0.2)
		
		while GPIO.input(PIN) == GPIO.LOW:
			time.sleep(0.02)
		
		length = time.time() - start
		logging.debug("Hotspot Pin (" + str(PIN) + ") pressed for " + str(length) + " seconds")
		
		if length > 3:
			logging.debug("Great! Starting Hotspot")
			output = subprocess.check_output(['bash', '/opt/skybot/scripts/hotspot.sh'])
			output = output.rstrip()
			logging.debug("Hotspot script output is : " + str(output))
			if output == "True":
				logging.debug("Starting hotspot flask server")
				subprocess.call(['/opt/bin/start_hotspot_server'])
			else:
				logging.debug("Invalid hotspot.sh output")
				subprocess.call(['/opt/bin/start_hotspot_server'])
		else:
			logging.debug("Short Press")

except Exception as error:
	logging.debug("Error occurred")
	logging.error(traceback.format_exc())
