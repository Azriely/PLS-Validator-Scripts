cd ~
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
sudo chmod 777 deposit_data-1683359412.json