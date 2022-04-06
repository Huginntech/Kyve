#!/bin/bash
dependient () {
    sudo apt update
    sudo apt install zip -y
    sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu nload -y < "/dev/null"
    echo -e ''
    echo -e "Go..."
    wget -O go1.17.1.linux-amd64.tar.gz https://golang.org/dl/go1.17.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz && rm go1.17.1.linux-amd64.tar.gz
    echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
    echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
    echo 'export GO111MODULE=on' >> $HOME/.bash_profile
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
    . $HOME/.bash_profile
    go version
}

select_dist () {
    source $HOME/.profile && sleep 2
    VAR=$(cat $HOME/distro.txt)
    source $HOME/.profile
    if [ $VAR = "Darwin" ]; then
     echo -e "installing cosmovisor for MacOS.." && sleep 3
     wget -q -O "$HOME"/cosmovisor https://nc.breithecker.de/index.php/s/7o7q26WXciQbFnR/download/cosmovisor_mac
else
     echo -e "installing cosmovisor for Linux.." && sleep 3
     wget -q -O "$HOME"/cosmovisor https://nc.breithecker.de/index.php/s/6PccY4zznJN4H4L/download/cosmovisor_linux
fi
}

cosmovisor () {
    echo -e ''
    echo -e "Cosmovisor..." && sleep 2
    git clone https://github.com/cosmos/cosmos-sdk
    cd cosmos-sdk
    git checkout v0.44.3
    make cosmovisor
    mkdir ~/go/bin
    cp cosmovisor/cosmovisor $GOPATH/bin/cosmovisor
    cd $HOME
}


create_bin () {
    wget -q -O /usr/bin/kyved https://free.files.cnow.at/index.php/s/Y828KHtSgbg5PYe/download/chaind && chmod +x /usr/bin/kyved
    mkdir -p ~/.kyve/cosmovisor/genesis/bin/
    echo "{}" > ~/.kyve/cosmovisor/genesis/upgrade-info.json
    cp /usr/bin/kyved ~/.kyve/cosmovisor/genesis/bin/
    export DAEMON_HOME="$HOME/.kyve" >> $HOME/.profile
    export DAEMON_NAME="kyved" >> $HOME/.profile
    # optional on whether auto-download should be enabled
    export DAEMON_ALLOW_DOWNLOAD_BINARIES="true" >> $HOME/.profile
    source ~/.profile
    sleep 2
    kyved config chain-id kyve-beta
    wget -q -O ~/.kyve/config/genesis.json https://raw.githubusercontent.com/Errorist79/Kyve/main/genesis.json
    wget https://raw.githubusercontent.com/Errorist79/seeds/main/seeds.txt -O $HOME/.kyve/config/seeds.txt
    sed -i.bak 's/seeds = \"\"/seeds = \"'$(cat $HOME/.kyve/config/seeds.txt)'\"/g' $HOME/.kyve/config/config.toml
}

services () {
sudo tee /etc/systemd/system/kyved.service > /dev/null <<EOF  
[Unit]
Description=Kyve Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=$HOME/.kyve"
Environment="DAEMON_NAME=kyved"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"

[Install]
WantedBy=multi-user.target
EOF
sudo -S systemctl daemon-reload
sudo -S systemctl enable kyved
sudo -S systemctl start kyved
systemctl status kyved
}

PS3="What do you want?: "
select opt in İnstall Update Additional quit; 
do

case $opt in
    İnstall)   
    echo -e '\e[1;32mThe installation process begins...\e[0m'
    uname >> $HOME/distro.txt
    export VAR=$(cat $HOME/distro.txt)
    source $HOME/.profile
    sleep 1
    #select_dist
    dependient
    cosmovisor
    create_bin
    services
    sleep 3
      break
      ;;
    Update)
    echo -e '\e[1;32mThe updating process begins...\e[0m'
    echo -e ''
    echo -e '\e[1;32mSoon...'
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
