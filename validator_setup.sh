#!/bin/bash

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y && sudo apt autoremove -y

# Install necessary packages
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  git \
  ufw \
  openssl \
  lsb-release -y

# Configure firewall
sudo ufw allow 30303
sudo ufw allow 12000
sudo ufw allow 13000
sudo ufw allow 3000
sudo ufw allow 9090

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# Create directory and password file
mkdir blockchain
sudo chmod 777 blockchain
cd blockchain
mkdir pw
sudo chmod 777 pw
cd pw
nano pw.txt
# Enter your Prysm wallet password, hit CRTL+X, hit y, hit enter
cd ~

# Generate JWT secret
openssl rand -hex 32 | sudo tee blockchain/jwt.hex > /dev/null

# Start Geth Docker container
sudo docker run -d --name geth --network=host -p 30303:30303 -p 8545:8545 \
-v /home/admxn/blockchain:/blockchain \
registry.gitlab.com/pulsechaincom/go-pulse:v2.1.1 \
--pulsechain-testnet-v4 \
--authrpc.jwtsecret=/blockchain/jwt.hex \
--datadir=/blockchain

# Start Beacon Chain Docker container
sudo docker run -d --name beacon --network=host -p 4000:4000/tcp -p 12000:12000/udp -p 13000:13000/tcp -v /home/admxn/blockchain:/blockchain registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain \
--pulsechain-testnet-v4 --jwt-secret=/blockchain/jwt.hex --datadir=/blockchain \
--checkpoint-sync-url=https://checkpoint.v4.testnet.pulsechain.com --genesis-beacon-api-url=https://checkpoint.v4.testnet.pulsechain.com \
--suggested-fee-recipient=0xeCEDe74770c7371134b203572F7926fce235AB16 \
--min-sync-peers=1 \
--p2p-host-ip=$(curl -s https://checkip.amazonaws.com) 

# Start Validator Docker container
sudo docker run -d --network=host -v /home/admxn/blockchain/validator_keys:/keys \
-v /home/admxn/blockchain/pw:/wallet \
--name validator \
registry.gitlab.com/pulsechaincom/prysm-pulse/validator \
--pulsechain-testnet-v4 \
accounts import --keys-dir=/keys --wallet-dir=/wallet \
--password-file=/wallet/pw.txt

# Configure container restart policy
sudo docker update --restart always geth
sudo docker update --restart always beacon
sudo docker update --restart always validator

# Monitor syncing
while :
do
# Check if Geth is synced
# Start Geth and Beacon Chain Docker containers
sudo docker-compose up -d

# Wait for both containers to fully sync
while true; do
  geth_sync=$(sudo docker logs geth 2>&1 | grep "Imported new chain segment" | tail -n 1 | awk '{print $11}' | tr -d ',')
  beacon_sync=$(sudo docker logs beacon 2>&1 | grep "Successfully updated latest finalized block" | tail -n 1 | awk '{print $11}' | tr -d ',')
  if [ -n "$geth_sync" ] && [ -n "$beacon_sync" ]; then
    echo "Geth and Beacon Chain are fully synced."
    break
  fi
  echo "Geth syncing at block height $geth_sync."
  echo "Beacon Chain syncing at block height $beacon_sync."
  sleep 300
done

# Wait for validator keys to be available in blockchain directory
while [ ! -f "/home/$USER/blockchain/validator_keys/deposit_data-*.json" ]; do
  echo "Waiting for validator keys to be available in /home/$USER/blockchain/validator_keys directory."
  sleep 300
done

# Start Validator Docker container
sudo docker run -d --network=host -v /home/$USER/blockchain/validator_keys:/keys \
-v /home/$USER/blockchain/pw:/wallet \
--name validator \
registry.gitlab.com/pulsechaincom/prysm-pulse/validator \
--pulsechain-testnet-v4 \
accounts import --keys-dir=/keys --wallet-dir=/wallet \
--password-file=/wallet/pw.txt

# Configure container restart policy
sudo docker update --restart always geth
sudo docker update --restart always beacon
sudo docker update --restart always validator

# Change permissions of validator deposit
sudo chmod 777 /home/$USER/blockchain/validator_keys/deposit_data-*.json

echo "Validator container is now running."
