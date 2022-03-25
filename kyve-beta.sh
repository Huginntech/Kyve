#!/bin/bash
echo -e ''
curl -s https://api.testnet.run/logo.sh | bash && sleep 3
echo -e '\e[0;33mİnstalling Dependiences\e[0m'
echo -e ''
sudo apt update
sudo apt install jq -y
sudo apt install zip -y
echo -e "\033[1;34m"
if [ ! $node_name ]; then
	read -p ' Enter your node name: ' node_name
    echo 'export node_name='$node_name >> $HOME/.bash_profile
fi
echo -e "\033[0m"
echo -e '\e[0;33mDownload Binaries\e[0m' && sleep 1
echo -e ''
mkdir kyvebinary && cd kyvebinary
wget https://nc.breithecker.de/index.php/s/L8QoGPY5cJ2ze4T/download/kyve_beta-2022-03-23.zip && sleep 5
unzip kyve_beta-2022-03-23.zip
tar -xvf  chain_linux_amd64.tar.gz
sudo mv chaind kyved
sudo mv kyved /usr/bin/ && sleep 1
kyved init $node_name && sleep 1
mv genesis.json ~/.kyve/config/
cd .. && rm -rf kyvebinary
echo -e "\033[1;34m"
echo -e ''
echo -e '#######################################################################'
if [ ! $NODE_PASS ]; then
	read -p ' Enter your node password !!password must be at least 8 characters!!: ' NODE_PASS
    echo 'export node_pass='$NODE_PASS >> $HOME/.bash_profile
    echo 'export CHAIN_ID=kyve-beta' >> $HOME/.profile
    echo 'export denom=tkyve' >> $HOME/.profile
    source $HOME/.bash_profile
    source $HOME/.profile
fi
echo -e ""
echo -e '\033[0mGenerating keys...\e[0m' && sleep 2
echo -e ''
echo -e "\e[33mWait...\e[0m" && sleep 4
(echo $NODE_PASS; echo $NODE_PASS) | kyved keys add validator --output json &>> $HOME/"$CHAIN_ID"_validator_info.json
echo -e "You can find your mnemonic with the following command;"
echo -e "\e[32mcat $HOME/kyve-beta_validator_info.json\e[39m"
export KYVE_WALLET=`echo $NODE_PASS | kyved keys show validator -a`
echo 'export KYVE_WALLET='${KYVE_WALLET} >> $HOME/.bash_profile
. $HOME/.bash_profile
echo -e '\n\e[44mHere is the your wallet address!:' $KYVE_WALLET '\e[0m\n'
echo -e "\e[33mNeed some tokens!!\e[0m"
echo -e "\033[1;34m"
if [ ! $faucet ]; then
	read -p ' Go to discord for get some tokens, then press enter: '
fi
echo -e "\033[0m"
wget https://raw.githubusercontent.com/Errorist79/seeds/main/seeds.txt -O $HOME/.kyve/config/seeds.txt
sed -i.bak 's/seeds = \"\"/seeds = \"'$(cat $HOME/.kyve/config/seeds.txt)'\"/g' $HOME/.kyve/config/config.toml
echo -e '\e[0;33m###installing Service...###\e[0m'
echo -e ''
sudo tee <<EOF >/dev/null /etc/systemd/system/kyved.service
echo "[Unit]
Description=Kyved daemon
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/bin/kyved start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable kyved
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl restart kyved
echo -e 'Please wait for sync...'

check=0
while [ $check -le 1 ]
do
    tof=$(curl -s localhost:26657/status | jq '.result.sync_info.catching_up')
    if [ "$tof" = "false" ]; then
        echo -e '\e[32mDone!, we will create the validator shortly, just wait\e[0m'
        check=2
    else
        echo -e '\e[32mStill syncing, please wait...\e[0m'
    fi
sleep 80
done
echo -e "\033[1;34m"
if [ ! $amount ]; then
	read -p ' Tell me, what is the amount you want to stake?
    remember, 1 KYVE=1000000000 : ' amount
    echo 'export amount='$amount >> $HOME/.bash_profile
fi
echo -e "\033[0m"
(echo $NODE_PASS; echo $NODE_PASS) | kyved tx staking create-validator --yes --amount $amount$denom --moniker $node_name --commission-rate "0.10" --commission-max-rate "0.20" --commission-max-change-rate "0.01" --min-self-delegation "1" --pubkey "$(kyved tendermint show-validator)" --from validator --chain-id $CHAIN_ID
echo -e "\e[0;31mYou're fine! Here are the additional commands;\e[0m

\e[0;33mCheck logs:\e[0m journalctl -u kyved.service -f -n 100

\e[0;33mstop the node:\e[0m systemctl stop kyved

\e[0;33mStart the node:\e[0m systemctl start kyved

\e[0;33mCheck your balance:\e[0m kyved q bank balances {ADDRESS}

\e[0;33mLearn your valoper address:\e[0m kyved keys show validator -a --bech val

\e[0;33mDelegate additional stake:\e[0m kyved tx staking delegate {VALOPER_ADDRESS} {STAKE_AMOUNT}tkyve --from validator --chain-id kyve-beta

\e[0;33mUnjail:\e[0m kyved tx slashing unjail  --chain-id kyve-beta --from validator 
"
