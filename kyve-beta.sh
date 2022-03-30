#!/bin/bash
echo -e ''
curl -s https://api.testnet.run/logo.sh | bash && sleep 3
echo -e ''

dependiences () {
    echo -e '\e[0;33mİnstalling Dependiences\e[0m'
    echo -e ''
    sudo apt update
    sudo apt install jq -y
    sudo apt install zip -y
    sudo apt install screen -y
}

variables (){
    echo export CHAIN_ID=kyve-beta >> $HOME/.profile
    echo export denom=tkyve >> $HOME/.profile
    source $HOME/.profile
}

binaries () {
    echo -e ''
    echo -e '\e[0;33mDownload Binaries\e[0m' && sleep 1
    echo -e ''
    echo -e "\033[1;34m"
    if [ ! $node_name ]; then
        read -p ' Enter your node name: ' node_name
        echo 'export node_name='$node_name >> $HOME/.bash_profile
    fi
    . $HOME/.bash_profile
    echo -e "\033[0m"
    mkdir kyvebinary && cd kyvebinary
    wget https://nc.breithecker.de/index.php/s/wKMRSZy3goxnaHT/download/kyve_beta-2022-03-30.zip
    unzip kyve_beta-2022-03-30
    tar -xvf  chain_linux_amd64.tar.gz
    sudo mv chaind kyved
    sudo mv kyved /usr/bin/
    kyved init $node_name
    mv genesis.json ~/.kyve/config/
    cd .. && rm -rf kyvebinary
    echo -e "\033[1;34m"
}

key_gen () {
    echo -e "\033[1;34m"
    echo -e ''
    echo -e '#######################################################################'
if [ ! $NODE_PASS ]; then
	read -p ' Enter your node password !!password must be at least 8 characters!!: ' NODE_PASS
    echo 'export node_pass='$NODE_PASS >> $HOME/.bash_profile
    source $HOME/.bash_profile
    source $HOME/.profile
fi
    source $HOME/.profile
    echo -e ""
    echo -e '\033[0mGenerating keys...\e[0m'
    sleep 2
    echo -e ''
    echo -e "\e[33mWait...\e[0m" && sleep 4
    (echo $NODE_PASS; echo $NODE_PASS) | kyved keys add validator --output json &>> $HOME/"$CHAIN_ID"_validator_info.json
    echo -e "You can find your mnemonic with the following command;"
    echo -e "\e[32mcat $HOME/kyve-beta_validator_info.json\e[39m"
    export KYVE_WALLET=`echo $NODE_PASS | kyved keys show validator -a`
    echo 'export KYVE_WALLET='${KYVE_WALLET} >> $HOME/.bash_profile
    . $HOME/.bash_profile
    echo -e '\n\e[44mHere is the your wallet address, save it!:' $KYVE_WALLET '\e[0m\n'
}

config_service () {
    wget https://raw.githubusercontent.com/Errorist79/seeds/main/seeds.txt -O $HOME/.kyve/config/seeds.txt
    sed -i.bak 's/seeds = \"\"/seeds = \"'$(cat $HOME/.kyve/config/seeds.txt)'\"/g' $HOME/.kyve/config/config.toml
    echo -e 'Creating system service...'
    sleep 2
sudo tee <<EOF >/dev/null /etc/systemd/system/kyved.service
[Unit]
Description=Kyved Cosmos daemon
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
cat /etc/systemd/system/kyved.service
sudo systemctl enable kyved
sudo systemctl daemon-reload
sudo systemctl restart kyved
sleep 2
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
}

create_validator () {
    if [ ! $faucet ]; then
        echo -e '\e[44mGo to Discord and in the \e[42mfaucet\e[0m channel use this command: \e[42m!faucet send' $KYVE_WALLET '\e[0m'
        echo -e "\033[1;34m"
        read -p 'Then press any key: '
        echo -e "\033[0m"
    fi
        echo -e "\033[1;34m"
    if [ ! $amount ]; then
        read -p ' Tell me, what is the amount you want to stake?
        remember, 1 KYVE=1000000000 : ' amount
        echo 'export amount='$amount >> $HOME/.bash_profile
    fi
    echo -e "\033[0m"
    source $HOME/.bash_profile
    sleep 2
    wget -q -O dms.sh https://api.testnet.run/dms.sh && chmod +x dms.sh
    sleep 2
    sudo screen -dmS validator ./dms.sh
}


done_process () {
    LOG_SEE="journalctl -u kyved.service -f -n 100"
    source $HOME/.profile
    echo -e '\n\e[41mDone! Now, please wait for your node to sync with the chain. This will take approximately 15 minutes. Use this command to see the logs:' $LOG_SEE '\e[0m\n'
}

PS3="What do you want?: "
select opt in İnstall Update Additional quit; 
do

  case $opt in
    İnstall)
    echo -e '\e[1;32mThe installation process begins...\e[0m'
    sleep 1
    dependiences
    variables
    binaries
    key_gen
    config_service
    create_validator
    done_process
    sleep 3
      break
      ;;
    Update)
    echo -e '\e[1;32mThe updating process begins...\e[0m'
    echo -e ''
    echo -e '\e[1;32mSoon...'
    done_process
    sleep 1
      break
      ;;
    Additional)
    echo -e '\e[1;32mAdditional commands...\e[0m'
    echo -e ''
    echo -e '\e[1;32mSoon...'
    sleep 1
      ;;
    quit)
    echo -e '\e[1;32mexit...\e[0m' && sleep 1
      break
      ;;
    *) 
      echo "Invalid $REPLY"
      ;;
  esac
done
