#!/bin/bash

# Define the services to stop
services=("geth" "lighthouse-beacon" "lighthouse-validator")

# Stop the services
for service in "${services[@]}"; do
    echo "Stopping $service..."
    sudo systemctl stop "$service"
done

# Check the status of the services
for service in "${services[@]}"; do
    echo "Checking status of $service..."
    sudo systemctl status "$service"
    echo "--------------------------------"
done

# Prompt the user to shut down or reboot the server
read -p "Do you want to (s)hut down, (r)eboot, or (c)ancel? " choice

case "$choice" in
    s|S) echo "Shutting down the server..."
         sudo shutdown -h now ;;
    r|R) echo "Rebooting the server..."
         sudo reboot ;;
    c|C) echo "Cancelled. No action taken." ;;
    *) echo "Invalid choice. No action taken." ;;
esac
