# Kysor Setup Guide -  Step by Step

* [1. Overview](#1-overview)
* [2. Build Guide](#2-build-guide)
    * [2.1 Requirements](#21-requirements)
    * [2.2 Installation](#22-installation)


## 1. Overview

KYVE has a broad ecosystem of projects archiving their data with KYVE. To standardize different data from different projects KYVE created special runtimes for standards like `@kyve/evm` for all EVM based chains. This has great benefits but also has downsides for protocol node runners in terms of user experience.

Without KYSOR for every pool the node runner has to get the binaries manually. If you want to run on another pool which has a different runtime you again have to manually obtain the binaries. Furthermore, if a pool ever upgrades to a newer protocol node version, you have the same procedure like before. Even worse, you might miss the update and receive a timeout slash for being offline

**Running nodes with KYSOR has the following benefits:**

- Only use **one** program to run on **every** pool
- Not installing and compiling protocol binaries **manually** for every pool
- Getting the new upgrade binaries during a pool upgrade **automatically** and therefore **don't risk timeout slashes**
- Make running protocol nodes **standardized** and **easier**

## 2. Build Guide

### 2.1 Requirements

The following are **minimum** requirements to run an protocol node:
 - **CPU**: 1vCPU
 - **RAM**: 4GB RAM
 - **Storage**: 1vCPU

### 2.2 Installation

Start by installing Yarn

```
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install wget unzip curl git -y
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install yarn
```

Next, cloning the Kysor Github repositor and move into the Kysor directory:

```
cd $HOME
git clone https://github.com/kyve-org/kysor.git
cd kysor
```

Now, run this command:

```
yarn install
```

Create secrets folder
> This directory where your secrets are stored like arweave.json and mnemonic.txt
```
mkdir secrets
```
There are some other requirements required for Kysor to work.
- Mnemonic 
> The **mnemonic.txt** (we'll create this in the next step) file which contains your mnemonic of your validator account. This one mnemonic will be used for all of your protocol nodes. 
You need to add this to the secrets directory.
- Initial Stake
> the amount of $KYVE you want to stake
- Pool Id
> the ID of the pool you want to join as a validator, an overview of all pools [can be found here.](https://app.kyve.network)
- Disk Space
> the amount of bytes the node can use at max to cache data, **1000000000 equals 1 GB** which is usually enough
- Arweave Key File
> this is the arweave keyfile you need to provide in order to run protocol nodes. This one keyfile will be used for all of your protocol nodes


#### Set environment variables

You can set the above requirements as follows:

##### 1. Mnemonic

Replace `PUT_YOUR_MNEMONIC_HERE` with the mnemonics of the wallet where your've tokens.

```
MNEMONIC="PUT_YOUR_MNEMONİC_HERE"
echo "$MNEMONIC" >> $HOME/kysor/secrets/mnemonic.txt
```

##### 2. Initial Stake
Replace `PUT_THE_AMOUNT_OF_$KYVE_YOU_WANT_TO_STAKE_HERE` with the mnemonics of the wallet where your've tokens.
```
AMOUNT="PUT_THE_AMOUNT_OF_$KYVE_YOU_WANT_TO_STAKE_HERE"
echo export AMOUNT=$AMOUNT >> $HOME/.profile
```

##### 3. Pool Id

Replace `PUT_ID_HERE` with the ID of the pool you want to join as a validator.
```
ID="PUT_ID_HERE"
echo export ID=$ID >> $HOME/.profile
```

##### 4. Disk Space

Replace `PUT_SPACE_HERE` with the amount of bytes the node can use at max to cache data

```
SPACE="PUT_SPACE_HERE"
echo export SPACE=$SPACE >> $HOME/.profile
```

Now, run this command:
```
sed -i -e "s/poolId: 0/poolId: $ID/g; s/initialStake: 100/initialStake: $amount/g; s/space: 1000000000/space: $SPACE/g" $HOME/kysor/kysor.conf.ts
```

##### 5. Arweave Key File

Here we need to upload manually. 
Now, we need to rename our Arweave key file to `arweave.json`. after that, we need to upload this file to our node.
We have a few alternatives to upload the file. Let's see;


<details>
  <summary>Winscp for Windows users:</summary>
  
  *  [Download Winscp](https://winscp.net/eng/index.php) 
  *  Upload your arweave.json file to the $HOME/kysor/secrets directory. type `echo $HOME` on the command line (aka terminal) and then you can see your home directory. (Do it on the server)
  *  Here is a step-by-step guide on [how to use winscp.](https://www.youtube.com/watch?v=MMZ7YZHslRc)
    
  
</details>

<details>
  <summary>CyberDuck for Mac users:</summary>
  
  *  [Download CyberDuck](https://cyberduck.io/) 
  *  Upload your arweave.json file to the $HOME/kysor/secrets directory. type `echo $HOME` on the command line (aka terminal) and then you can see your home directory. (Do it on the server)
  *  Here is a step-by-step guide on [how to use winscp.](https://www.youtube.com/watch?v=7c8SYE2ALRc)
    
  
</details>

<details>
  <summary>Via SCP - Secure Copy with SSH:</summary>
  
  *   Replace `path/to/arwave/file` with the directory where you have your `arweave.json` file.
  *   Replace `username` with the username you use on the server.
  *   Replace `ip` with your server ip.
  *   And replace `/path/to/kysor/secrets` with the full path to the `kysor/secrets` directory.
  *  type `echo $HOME` on the command line (aka terminal) and then you can see your home directory. (Do it on the server.)
  
  ```
  scp path/to/arwave/file username@ip:/path/to/kysor/secrets
  ```
   Example:
  ```
  scp C:\Users\Errorist\Desktop\arweave.json root@135.181.157.37:/root/kysor/secrets
  ```
  
</details>


### Final Touches

This command should be run again every time the config file is edited, let's do it:

```
yarn build
```

With the `yarn start` command you are ready to start node! But, wait.

There is a better way. will create a daemon. It runs these processes in the background and provides a better usability.

```
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
```

Start service
                                                              
```                                                            
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable kysord
sudo systemctl start kysord
```


### Additional Commands

Check Logs

```
journalctl -u kysord -fo cat
```

Stop the Kysor

```
systemctl stop kysord
```

Restart Kysor

```
systemctl restart kysord
```
