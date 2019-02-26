import logging
from logging.handlers import TimedRotatingFileHandler
import os
import traceback
import RPi.GPIO as GPIO
from time import sleep


def set_logger(name):
	import subprocess
	
	if os.path.isdir("/opt/log/") is False:
		subprocess.call(['sudo', 'mkdir', '-p', "/opt/log/"])
	
	logging.basicConfig(filename="/opt/log/skybot",
	                    level=logging.DEBUG,
	                    format='%(asctime)s - %(name)s - %(module)s - %(levelname)s - %(filename)s - %(lineno)d - %(funcName)s - %(message)s',
	                    datefmt='%Y-%m-%d %H:%M:%S')
	# create file handler which logs even debug messages
	handler = TimedRotatingFileHandler("/opt/log/skybot", when="midnight", backupCount=10)
	handler.setLevel(logging.DEBUG)
	
	logger = logging.getLogger(name)
	logger.setLevel(logging.DEBUG)
	
	logger.addHandler(handler)
	
	return logger


set_logger('reboot')

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
try:
	GPIO.setup(16, GPIO.OUT, initial=GPIO.HIGH)
	GPIO.setup(17, GPIO.OUT, initial=GPIO.HIGH)
	i = 1
	while i < 2:
		i += 1
		logging.debug("Gateway is restarting....")
		sleep(5)
		GPIO.output(17, GPIO.LOW)
		sleep(2)
		GPIO.output(16, GPIO.LOW)
		sleep(1)
except Exception as error:
	logging.debug("Error occurred")
	logging.error(traceback.format_exc())