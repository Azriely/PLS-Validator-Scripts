
Certainly! Here's a nicely formatted README description for the script that you can use in your GitHub repository:

PLS-Validator-Scripts
This repository contains a script to stop and check the status of Ethereum validator services, specifically geth, lighthouse-beacon, and lighthouse-validator. The script will also prompt the user to choose whether to shutdown, reboot, or cancel after the services have stopped.

Usage:

Clone the repository:
git clone https://github.com/Azriely/PLS-Validator-Scripts.git

Change to the repository directory:
cd PLS-Validator-Scripts

Make the script executable:
chmod +x stop_and_check_services.sh

Run the script:
./stop_and_check_services.sh

The script will then stop each of the services (geth, lighthouse-beacon, and lighthouse-validator) and confirm that they have stopped. 

Afterward, it will prompt the user to choose one of the following actions:
1. Shutdown
2. Reboot
3. Cancel
The user can enter the corresponding number to perform the desired action.