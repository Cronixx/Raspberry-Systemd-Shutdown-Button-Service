# Raspberry Pi Shutdown Button Service

This is a simple python script that initiates a shutdown command when it receives a trigger on a specific GPIO Pin.
It is wrapped by a systemd-service for autostarting and easy integrating into the system.
The installer script lets you specify on which pin to listen,
and sets up and configures the systemd unit.

Feel free to suggest changes, as it was my first take on shell scripting =)
