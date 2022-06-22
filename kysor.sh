#!/bin/bash
echo -e ''
curl -s https://api.testnet.run/logo.sh | bash && sleep 3
echo -e ''
GREEN="\e[32m"
NC="\e[0m"
RED='\033[0;31m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

dependencies () {
    echo -e '\e[0;33mİnstalling dependencies\e[0m'
    echo -e ''
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install wget unzip -y
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update
    sudo apt install yarn
    echo -e ''
    echo -e '\e[0;33mİnstalling Kysor...\e[0m'
    echo -e ''
    sleep 3
    git clone https://github.com/kyve-org/kysor.git
    cd kysor && mkdir secrets
    cp $HOME/arweave.json $HOME/kysor/secrets
    yarn install
    sleep 2
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1}
  msg "$msg"
  exit "$code"
}

stake_mnem () {
    echo -e "\e[0;32m"
if [ ! "$amount" ]; then
    echo "################################################################"
    echo -e ""
    read -p ' Tell me, what is the amount you want to stake?: ' amount
    echo 'export amount='$amount >> $HOME/.bash_profile
    echo -e ""
    echo "################################################################"
fi

sleep 3

if [ ! "$KEYS" ]; then
    echo "################################################################"
    echo -e ""
    read -p "Need your mnemonic, paste here: " KEYS
    echo  $KEYS >> $HOME/kysor/secrets/mnemonic.txt
    echo -e ""
    echo "################################################################"
fi

if [ ! "$SPACE" ]; then
    echo "################################################################"
    echo -e ""
    read -p "The maximum amount of bytes the node can use, 
    Attention! 1000000000 equals 1 GB, enter here: " SPACE
    echo 'export SPACE='$SPACE >> $HOME/.bash_profile
    echo -e ""
    echo "################################################################"
fi
    echo -e "\e[0m"
    source $HOME/.bash_profile
}

moonbeam () {
    VER=$( curl -s https://api.github.com/repos/kyve-org/evm/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="evm.zip https://github.com/kyve-org/evm/releases/download/$VER/kyve-linux.zip"
    echo export TAG="evm" >> $HOME/.bash_profile
    echo export BIN="evm" >> $HOME/.bash_profile
    echo export DAEMON="moonbeamd" >> $HOME/.bash_profile
    echo export ID="0" >> $HOME/.bash_profile
}

avalanche () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/evm/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="evm.zip https://github.com/kyve-org/evm/releases/download/$VER/kyve-linux.zip"
    echo export TAG="evm" >> $HOME/.bash_profile
    echo export BIN="evm" >> $HOME/.bash_profile
    echo export DAEMON="avalanched" >> $HOME/.bash_profile
    echo export ID="1" >> $HOME/.bash_profile
}

evmos () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/evm/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="evm.zip https://github.com/kyve-org/evm/releases/download/$VER/kyve-linux.zip"
    echo export TAG="evm" >> $HOME/.bash_profile
    echo export BIN="evm" >> $HOME/.bash_profile
    echo export DAEMON="evmosd" >> $HOME/.bash_profile
    echo export ID="8" >> $HOME/.bash_profile
}

bitcoin () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/bitcoin/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="bitcoin.zip https://github.com/kyve-org/bitcoin/releases/download/$VER/kyve-linux.zip"
    echo export TAG="bitcoin" >> $HOME/.bash_profile
    echo export BIN="bitcoind" >> $HOME/.bash_profile
    echo export DAEMON="bitcoind" >> $HOME/.bash_profile
    echo export ID="3" >> $HOME/.bash_profile
}

solana () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/solana/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="solana.zip https://github.com/kyve-org/solana/releases/download/$VER/kyve-linux.zip"
    echo export TAG="solana" >> $HOME/.bash_profile
    echo export BIN="solanad" >> $HOME/.bash_profile
    echo export DAEMON="solanad" >> $HOME/.bash_profile
    echo export ID="4" >> $HOME/.bash_profile
}

zilliqa () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/zilliqa/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="zilliqa.zip https://github.com/kyve-org/zilliqa/releases/download/$VER/kyve-linux.zip"
    echo export TAG="zilliqa" >> $HOME/.bash_profile
    echo export BIN="zilliqad" >> $HOME/.bash_profile
    echo export DAEMON="zilliqad" >> $HOME/.bash_profile
    echo export ID="5" >> $HOME/.bash_profile
}

near () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/near/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="near.zip https://github.com/kyve-org/near/releases/download/$VER/kyve-linux.zip"
    echo export TAG="near" >> $HOME/.bash_profile
    echo export BIN="neard" >> $HOME/.bash_profile
    echo export DAEMON="neard" >> $HOME/.bash_profile
    echo export ID="6" >> $HOME/.bash_profile
}

celo () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/celo/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="celo.zip https://github.com/kyve-org/celo/releases/download/$VER/kyve-linux.zip"
    echo export TAG="celo" >> $HOME/.bash_profile
    echo export BIN="celod" >> $HOME/.bash_profile
    echo export ID="7" >> $HOME/.bash_profile
}

injective () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="injectived" >> $HOME/.bash_profile
    echo export DAEMON="injectived" >> $HOME/.bash_profile
    echo export ID="10" >> $HOME/.bash_profile    
}

cosmos () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="cosmosd" >> $HOME/.bash_profile
    echo export DAEMON="cosmosd" >> $HOME/.bash_profile
    echo export ID="9" >> $HOME/.bash_profile    
}

evmoscosmos () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="evmosd" >> $HOME/.bash_profile
    echo export DAEMON="evmosd" >> $HOME/.bash_profile
    echo export ID="11" >> $HOME/.bash_profile   
}

axelar () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="axelard" >> $HOME/.bash_profile
    echo export DAEMON="axelard" >> $HOME/.bash_profile
    echo export ID="12" >> $HOME/.bash_profile    
}

aurora () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/evm/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="aurora.zip https://github.com/kyve-org/evm/releases/download/$VER/kyve-linux.zip"
    echo export TAG="aurora" >> $HOME/.bash_profile
    echo export BIN="aurorad" >> $HOME/.bash_profile
    echo export DAEMON="aurorad" >> $HOME/.bash_profile
    echo export ID="13" >> $HOME/.bash_profile    
}

cronos () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="cronosd" >> $HOME/.bash_profile
    echo export DAEMON="cronosd" >> $HOME/.bash_profile
    echo export ID="14" >> $HOME/.bash_profile    
}

terra () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="terrad" >> $HOME/.bash_profile
    echo export DAEMON="terrad" >> $HOME/.bash_profile
    echo export ID="15" >> $HOME/.bash_profile
}

umee () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/cosmos/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="cosmos.zip https://github.com/kyve-org/cosmos/releases/download/$VER/kyve-linux.zip"
    echo export TAG="cosmos" >> $HOME/.bash_profile
    echo export BIN="umeed" >> $HOME/.bash_profile
    echo export DAEMON="umeed" >> $HOME/.bash_profile
    echo export ID="16" >> $HOME/.bash_profile
}

polkadot () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/substrate/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="substrate.zip https://github.com/kyve-org/substrate/releases/download/$VER/kyve-linux.zip"
    echo export TAG="substrate" >> $HOME/.bash_profile
    echo export BIN="polkadotd" >> $HOME/.bash_profile
    echo export DAEMON="polkadotd" >> $HOME/.bash_profile
    echo export ID="17" >> $HOME/.bash_profile
}

kusama () {
    echo export VER=$( curl -s https://api.github.com/repos/kyve-org/substrate/releases/latest | grep tag_name | cut -d '"' -f 4)
    DIR="substrate.zip https://github.com/kyve-org/substrate/releases/download/$VER/kyve-linux.zip"
    echo export TAG="substrate" >> $HOME/.bash_profile
    echo export BIN="kusamad" >> $HOME/.bash_profile
    echo export DAEMON="kusamad" >> $HOME/.bash_profile
    echo export ID="18" >> $HOME/.bash_profile
}

help () {
echo -e ${GREEN}
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h]
Setup and download binaries via Kysor to run an kyve protocol node.
Available options:
-h,  --help                  Print this help and exit
-a,  --avalanche             Run Avalanche pool
-c,  --celo                  Run Celo pool
-m,  --moonbeam              Run Moonbeam pool
-e,  --evmos                 Run Evmos (evm) pool
-ax, --axelar                Run Axelar pool
-ec, --evmoscosmos           Run Evmos (cosmos) pool
-s,  --solana                Run Solana pool
-b,  --bitcoin               Run Bitcoin pool
-au, --aurora                Run Aurora pool
-co, --cosmos                Run Cosmos pool
-i,  --injective             Run İnjective pool
-n,  --near                  Run Near pool
-z,  --zilliqa               Run Zilliqa pool
-cr, --cronos                Run Cronos pool
-t,  --terra                 Run Terra pool
-u,  --umee                  Run Umee pool
-p,  --polkadot              Run Polkadot pool
-k,  --kusama                Run Kusama pool
-up, --upgrade               Upgrade the pool(s) | this option'll install Kysor and removes previous installations!
EOF
echo -e ${NC}
echo -e ${BLUE}"Usage of upgrade option:"${NC}
echo -e ${PURPLE}"-up pool_name or --upgrade pool_name"${NC}
echo -e ${CYAN}"For example: -up moonbeam"${NC}
}

pools () {
    source $HOME/.bash_profile
    FILE=/etc/systemd/system/"$DAEMON".service
if [ -f "$FILE" ]; then
    echo "$FILE exists, deleting..."
    systemctl stop "$DAEMON"
    systemctl disable "$DAEMON"
    rm /etc/systemd/system/"$DAEMON".service
    rm /usr/bin/"$DAEMON"
else 
    echo "Daemon not exist. all ok!"
fi
    dependencies
    stake_mnem
    sleep 2
    sed -i -e "s/poolId: 0/poolId: $ID/g; s/initialStake: 100/initialStake: $amount/g; s/space: 1000000000/space: $SPACE/g" $HOME/kysor/kysor.conf.ts
    yarn build
    echo -e ''
    echo -e ${GREEN}
    echo -e "Creating kysor daemon..."
    echo -e ${NC}
    echo -e ''
    sudo tee /etc/systemd/system/kysord.service > /dev/null <<EOF  
[Unit]
Description=Kysor Daemon
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/kysor
ExecStart=yarn start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sleep 2
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable kysord
sudo systemctl restart kysord
echo -e ""
	echo -e ${GREEN}"======================================================"
    echo -e "Check logs: journalctl -u kysord -f -o cat"
    echo -e "Stop the node: sudo systemctl stop kysord"
	echo -e "Restart the node: sudo systemctl restart kysord"
    echo -e "======================================================"${NC}
echo -e ""
}

upgrade () {

    echo -e ${GREEN}
    source $HOME/.profile
    source $HOME/.bash_profile
    FILE=/etc/systemd/system/"$DAEMON".service
if [ -f "$FILE" ]; then
    echo "$FILE exists, deleting..."
    systemctl stop "$DAEMON"
    systemctl disable "$DAEMON"
    rm /etc/systemd/system/"$DAEMON".service
else 
    echo "Daemon(s) not exist. all ok!"
fi
    echo -e ''
    sleep 2
    echo -e ${NC}
    stake_mnem
    source $HOME/.bash_profile
    git clone https://github.com/kyve-org/kysor.git
    cd kysor
    yarn install
    sleep 2
    mkdir secrets
    MEMO=$HOME/kysor/secrets/mnemonic.txt
if [ -f "$MEMO" ]; then
    echo "$MEMO exists, let's go!"
else
    echo -e ''
    echo "$MEMO not exists!"
    echo -e ''
    sleep 2
    echo "################################################################"
    echo -e ""
    read -p "Need your mnemonic, paste here: " MEMO
    echo  $MEMO >> $HOME/kysor/secrets/mnemonic.txt
    echo -e ""
    echo "################################################################"
fi
    sleep 1
    cp $HOME/arweave.json $HOME/kysor/secrets
    sed -i -e "s/poolId: 0/poolId: $ID/g; s/initialStake: 100/initialStake: $amount/g; s/space: 1000000000/space: $SPACE/g" $HOME/kysor/kysor.conf.ts
    yarn build
    sudo tee /etc/systemd/system/kysord.service > /dev/null <<EOF  
[Unit]
Description=Kysor Daemon
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/kysor
ExecStart=yarn start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sleep 2
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable kysord
sudo systemctl restart kysord
echo -e ""
	echo -e ${GREEN}"======================================================"
    echo -e "Check logs: journalctl -u kysord -f -o cat"
    echo -e "Stop the node: sudo systemctl stop kysord"
	echo -e "Restart the node: sudo systemctl restart kysord"
    echo -e "======================================================"${NC}
echo -e ""
}

set_params () {

    args=("$@")

    if [ "$upgrade" == "moonbeam" ]; then
        moonbeam
        upgrade
    elif [ "$upgrade" == "evmos" ]; then
        evmos
        upgrade
    elif [ "$upgrade" == "avalanche" ]; then
        avalanche
        upgrade
    elif [ "$upgrade" == "bitcoin" ]; then
        bitcoin
        upgrade
    elif [ "$upgrade" == "solana" ]; then
        solana
        upgrade
    elif [ "$upgrade" == "zilliqa" ]; then
        zilliqa
        upgrade
    elif [ "$upgrade" == "near" ]; then
        near
        upgrade
    elif [ "$upgrade" == "celo" ]; then
        celo
        upgrade
    elif [ "$upgrade" == "injective" ]; then
        injective
        upgrade
    elif [ "$upgrade" == "cosmos" ]; then
        cosmos
        upgrade
    elif [ "$upgrade" == "evmoscosmos" ]; then
        evmoscosmos
        upgrade
    elif [ "$upgrade" == "axelar" ]; then
        axelar
        upgrade
    elif [ "$upgrade" == "aurora" ]; then
        aurora
        upgrade
    elif [ "$upgrade" == "cronos" ]; then
        cronos
        upgrade
    elif [ "$upgrade" == "terra" ]; then
        terra
        upgrade
    elif [ "$upgrade" == "umee" ]; then
        umee
        upgrade
    elif [ "$upgrade" == "polkadot" ]; then
        polkadot
        upgrade
    fi
}

    while :; do
        case "${1-}" in
        -p | --polkadot)
            polkadot
            pools
            shift
            ;;
        -h | --help)
            help
            shift
            ;;
        -m | --moonbeam)
            moonbeam
            pools
            shift
            ;;
        -a | --avalanche)
            avalanche
            pools
            shift
            ;;
        -b | --bitcoin)
            bitcoin
            pools
            shift
            ;;
        -s | --solana)
            solana
            pools
            shift
            ;;
        -e | --evmos)
            evmos
            pools
            shift
            ;;
        -z | --zilliqa)
            zilliqa
            pools
            shift
            ;;
        -n | --near)
            near
            pools
            shift
            ;;
        -c | --celo)
            celo
            pools
            shift
            ;;
        -ax | --axelar)
            axelar
            pools
            shift
            ;;
        -ec | --evmoscosmos)
            evmoscosmos
            pools
            shift
            ;;
        -au | --aurora)
            aurora
            pools
            shift
            ;;
        -co | --cosmos)
            cosmos
            pools
            shift
            ;;
        -i | --injective)
            injective
            pools
            shift
            ;;
        -cr | --cronos)
            cronos
            pools
            shift
            ;;
        -t | --terra)
            terra
            pools
            shift
            ;;
        -u | --umee)
            umee
            pools
            shift
            ;;
        -ch | --chain)
            chain="${2-}"
            shift
            ;;
        -k | --kusama)
            kusama
            pools
            shift
            ;;
        -up | --upgrade)
            upgrade="${2-}"
            [[ -z "${upgrade-}" ]] && die "\033[0;31mMissing required parameter:\033[0m upgrade! Use these flag to see usage: \033[1;33m-h or --help\033[0m"
            shift
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done

set_params "$@"
