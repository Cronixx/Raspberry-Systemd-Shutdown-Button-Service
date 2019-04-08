#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi


# Read input until valid pin number was entered
repeat=1
while [[ $repeat -ne 0 ]] ; do
	echo "Which pin should be used by the shutdown button?"
	read pin
	echo "$pin" | egrep -q '^[0-9]{1,2}$'
	if [ $? -ne 0 ]; then
		echo "Please provide a valid pin number" 1>&2
	else
		repeat=0
		export SHUTDOWN_BUTTON_PIN=$pin
	fi
done


# Read input until 'y' or 'n' were entered
repeat=1
while [[ $repeat -ne 0 ]]; do
	echo "Enable console output? [y/n]"
	read yes_no
	echo $yes_no | egrep -q '^(y|n)$'
	if [[ $? -ne 0 ]]; then
		echo "Please choose [y] or [n]"
	else
		echo $yes_no | egrep -q '^y$'
		if [[ $? -eq 0 ]]; then
			export SHUTDOWN_BUTTON_PRINT="True"
			echo "Console print set to 'yes'"
		else
			export SHUTDOWN_BUTTON_PRINT="False"
			echo "Console print set to 'no'"
		fi
		repeat=0
	fi
done


# Copy python script to /usr/local/sbin
echo "Shutdown button is configured on GPIO$SHUTDOWN_BUTTON_PIN"
echo "Copying configured script to /usr/local/sbin"
cp $(realpath shutdown_button.py) /usr/local/sbin

# Copy systemd unit file to /etc/systemd/system
echo "Copying systemd-unit file to /etc/systemd/system"
cp $(realpath shutdown-button.service) /etc/systemd/system

# Create environment config for service in /etc/systemd/system/shutdown-button.service.d/env.conf
echo "Setting service environment variables"
mkdir -p /etc/systemd/system/shutdown-button.service.d
echo "[Service]
Environment="SHUTDOWN_BUTTON_PIN=$SHUTDOWN_BUTTON_PIN"
Environment="SHUTDOWN_BUTTON_PRINT=$SHUTDOWN_BUTTON_PRINT"
" > /etc/systemd/system/shutdown-button.service.d/env.conf

# Enable and start shutdown button service
systemctl enable shutdown-button.service
systemctl start shutdown-button.service
