#!/usr/bin/python3
import os
from subprocess import call
import RPi.GPIO as GPIO

"""
Install by running 'install.sh' from same directory as this script.
That will copy this script to /usr/local/bin,
and create, configure and start a systemd service
for automatic startup and management of this script.

PIN 2/3 shouldnt be used as they got hardwired resistors.
"""

# config section
input_pin_number = int(os.environ["SHUTDOWN_BUTTON_PIN"])
should_print_to_console = bool(os.environ["SHUTDOWN_BUTTON_PRINT"])

# initialization
GPIO.setmode(GPIO.BCM)
GPIO.setup(input_pin_number, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# confirm config
if should_print_to_console:
    print("Shutdown Button listening on pin {}".format(input_pin_number))

# block until rise in voltage is detected
GPIO.wait_for_edge(input_pin_number, GPIO.RISING)
if should_print_to_console:
    print('Shutdown initiated ...')
call("systemctl poweroff", shell=True)
