#!/bin/bash

services=("geth" "lighthouse-beacon" "lighthouse-validator")

# Stop services and check their status
for service in "${services[@]}"; do
  echo "Stopping $service..."
  sudo systemctl stop "$service"

  status=$(sudo systemctl is-active "$service")

  if [ "$status" = "inactive" ]; then
    echo "$service has stopped."
  else
    echo "Failed to stop $service."
  fi
  echo "-----------------------"
done

# Prompt for shutdown or reboot
echo "What would you like to do?"
echo "1. Shutdown"
echo "2. Reboot"
echo "3. Cancel"
read -r option

case $option in
  1)
    echo "Shutting down..."
    sudo shutdown -h now
    ;;
  2)
    echo "Rebooting..."
    sudo reboot
    ;;
  3)
    echo "Canceled."
    ;;
  *)
    echo "Invalid option."
    ;;
esac
