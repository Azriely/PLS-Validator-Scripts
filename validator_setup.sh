# Before running copy your validator keys created on another computer to your ~ directory
cd ~/blockchain
sudo cp -r ~/validator_keys .

# Remove validator keys from ~ directory after copying them to blockchain
cd ~
sudo rm -rf validator_keys

# Start Validator Docker container
sudo docker run -it -v /home/ubuntu/blockchain/validator_keys:/keys \
-v /home/ubuntu/blockchain/pw:/wallet \
--name validator \
registry.gitlab.com/pulsechaincom/prysm-pulse/validator \
accounts import --keys-dir=/keys --wallet-dir=/wallet \
--pulsechain-testnet-v4

sudo docker stop -t 180 validator

sudo docker container prune

sudo docker run -d --network=host -v /home/ubuntu/blockchain/validator_keys:/keys \
-v /home/ubuntu/blockchain/pw:/wallet \
--name validator \
registry.gitlab.com/pulsechaincom/prysm-pulse/validator --pulsechain-testnet-v4 \
--wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt \
--graffiti validators.azriel.io

# Configure container restart policy
sudo docker update --restart always geth
sudo docker update --restart always beacon
sudo docker update --restart always validator

# Change permissions of validator deposit
cd ~/blockchain/validator_keys
sudo chmod 777 deposit_data-1683359412.json