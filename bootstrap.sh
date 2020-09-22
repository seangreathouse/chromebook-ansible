#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## bootstrap minimum requirements to run Ansible setup
## put the contents into a file called 'bootstrap.sh'
## and call as 'bash ./bootstrap.sh'
##
## or run the following:
# curl -q -o ./bootstrap.sh https://raw.githubusercontent.com/seangreathouse/chromebook-ansible/master/bootstrap.sh && bash ./bootstrap.sh
## Note:  raw.githubusercontent.com has a 5 minute edge cache


DEFAULT_CLONE_URL="git@github.com:seangreathouse/chromebook-ansible.git"
DEFAULT_HTTPS_CLONE_URL="https://github.com/seangreathouse/chromebook-ansible.git"
GIT_PATH="git"
DIVIDER="+++++++++++++++++++++++++++++++++++++++++++++++++++"

###################################
## Support development branches
GIT_ANSIBLE_BRANCH="master"
GIT_CONFIG_BRANCH="master"
while [[ $# -ge 1 ]]; do
    i="$1"
    case $i in
        --ab) ## Set the code repo branch
            if [ -z "$2" ]; then
                fail "\"$1\" argument needs a value."
            fi
            GIT_ANSIBLE_BRANCH=$2
            echo "GIT_ANSIBLE_BRANCH=$GIT_ANSIBLE_BRANCH"
            shift
            ;;
        --cb) ## Set the config repo branch
            if [ -z "$2" ]; then
                fail "\"$1\" argument needs a value."
            fi
            GIT_CONFIG_BRANCH=$2
            echo "GIT_CONFIG_BRANCH=$GIT_CONFIG_BRANCH"
            shift
            ;;

        *)
            echo "Unrecognized option $1."
            exit 1
            ;;
    esac
    shift
done

echo $'\n\n'$DIVIDER
echo "Welcome to chromebook-ansible"
echo $DIVIDER

echo "Quick Start will run without user interaction"
echo "See README.md for details on Full Setup: https://github.com/seangreathouse/chromebook-ansible/blob/master/README.md"
echo "You can run a Full Setup after a Quick Start without deleting your Linux container."
echo "So, go for it."
echo
PS3='Choose the deployment type: '
DEPLOYMENT_CHOICE=("Quick Start" "Full Setup")
select MY_CHOICE in "${DEPLOYMENT_CHOICE[@]}"; do
    case $MY_CHOICE in
        "Quick Start")
            DEPLOYMENT_CHOICE="QUICK_START"
            echo "You have chosen a Quick Start deployment."
            break
            ;;
        "Full Setup")
            DEPLOYMENT_CHOICE="FULL_SETUP"
            echo "You have chosen a Full Setup deployment."
	        break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
read -e -p "Hit <enter> to continue or 'ctrl c' to exit." KEY_PRESS
 

if [ $DEPLOYMENT_CHOICE == "QUICK_START" ]
    then
        GIT_CLONE_URL=$DEFAULT_HTTPS_CLONE_URL
        GIT_PROJECT_NAME=`echo $GIT_CLONE_URL | awk -F '/' '{print $5}' |awk -F '.' '{print $1}'`
        GIT_CONFIG_CLONE_URL=$GIT_CLONE_URL
        GIT_CONFIG_PROJECT_NAME=`echo $GIT_CONFIG_CLONE_URL | awk -F '/' '{print $5}' |awk -F '.' '{print $1}'`
        HOST_NAME="localhost"
fi

if [ $DEPLOYMENT_CHOICE == "FULL_SETUP" ]
    then
        echo $DIVIDER
        echo "Hostname to reference this host in Ansible"
        echo "For example if hosts.yml contains 'work_chromebook.local'"
        echo "If you are only managing a single device, hit <enter> for 'localhost'"
        read -e -p "hostname [localhost]: " HOST_NAME
        HOST_NAME=${HOST_NAME:-localhost}
        echo $'\n'$DIVIDER
        echo "Github repository url"
        echo "hit <enter> for default: '$DEFAULT_CLONE_URL'"
        read -e -p "git clone url: " GIT_CLONE_URL
        GIT_CLONE_URL=${GIT_CLONE_URL:-$DEFAULT_CLONE_URL}
        GIT_PROJECT_NAME=`echo $GIT_CLONE_URL | awk -F '/' '{print $2}' |awk -F '.' '{print $1}'`

        echo $'\n'$DIVIDER
        echo "Github config repository url"
        echo "ssh format required: 'git@github.com....'"
        read -e -p "git config clone url: " GIT_CONFIG_CLONE_URL
        GIT_CONFIG_PROJECT_NAME=`echo $GIT_CONFIG_CLONE_URL | awk -F '/' '{print $2}' |awk -F '.' '{print $1}'`

        echo $'\n'$DIVIDER
        read -e -p "Ansible Vault key: " VAULT_KEY

        echo $'\n'$DIVIDER
        PRIVATE_KEY=""
        while [ "$PRIVATE_KEY" == "" ]
        do
            echo "Paste PRIVATE ssh key, hit enter, then ctrl-d when done (required)"
            echo "(Paste command is ctrl-shift-v in this terminal)"
            echo "Key type will be auto-recognized RSA/ECDSA/ed25519"
            PRIVATE_KEY=$(cat)
        done
        echo $'\n'$DIVIDER
        PUBLIC_KEY=""
        while [ "$PUBLIC_KEY" == "" ]
        do
            echo "Paste PUBLIC ssh key, hit enter, then ctrl-d when done (required)"
            echo "(Paste command is ctrl-shift-v in this terminal)"
            PUBLIC_KEY=$(cat)
        done
        echo $'\n'$
        echo "Ready to begin bootstrap...."
        read -e -p "Hit <enter> to continue or 'ctrl c' to exit." KEY_PRESS

        ## Create SSH Keys
        mkdir -p $HOME/.ssh
        chmod 700 $HOME/.ssh
        touch $HOME/.ssh/id_temp
        touch $HOME/.ssh/id_temp.pub
        chmod 600 $HOME/.ssh/*
        echo "$PRIVATE_KEY" > $HOME/.ssh/id_temp
        echo "$PUBLIC_KEY" > $HOME/.ssh/id_temp.pub
        ## Check for key type
        ssh-keygen -l -f $HOME/.ssh/id_temp
        KEY_TYPE=`ssh-keygen -l -f $HOME/.ssh/id_temp |awk -F '(' '{print $2}'|awk -F ')' '{print tolower ($1)}'`
        mv $HOME/.ssh/id_temp $HOME/.ssh/id_$KEY_TYPE 
        mv $HOME/.ssh/id_temp.pub $HOME/.ssh/id_$KEY_TYPE.pub
        echo $'\n'$DIVIDER
        echo "$KEY_TYPE key detected, id_$KEY_TYPE & id_$KEY_TYPE.pub written to  $HOME/.ssh"
        echo $'\n'$DIVIDER
        sleep 2

        ## Add github to known hosts to allow non-interactive git clone
        /usr/bin/ssh-keyscan -H -t rsa github.com >> $HOME/.ssh/known_hosts

        ## Add hosts file entry if it does not already exist
        sudo grep $HOST_NAME /etc/hosts || echo -e "127.0.0.1\t$HOST_NAME" | sudo tee -a /etc/hosts

        mkdir -p $HOME/.config/ansible/
        if [ ! $VAULT_KEY == "" ]
        then
            touch $HOME/.config/ansible/vault-pw.txt
            chmod 600  $HOME/.config/ansible/vault-pw.txt
            echo "$VAULT_KEY" > $HOME/.config/ansible/vault-pw.txt
        fi
fi

mkdir -p $HOME/$GIT_PATH
cd $HOME/$GIT_PATH
git clone --branch $GIT_CONFIG_BRANCH $GIT_CONFIG_CLONE_URL

ANSIBLE_CONFIG_PATH="$HOME/$GIT_PATH/$GIT_CONFIG_PROJECT_NAME/"

## Install dependencies
sudo apt-get update
sudo apt-get install -y apt-utils git gnupg python3 python3-apt

mkdir -p $HOME/$GIT_PATH
cd $HOME/$GIT_PATH
git clone --branch $GIT_ANSIBLE_BRANCH $GIT_CLONE_URL

sudo grep 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' /etc/apt/sources.list || \
    echo 'echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list' | sudo -s 
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update
sudo apt-get install -y ansible
sudo apt-get autoremove -y

echo "creating bash alias 'chromebook-ansible-playbook' in .bashrc"
echo "this allows you to run the playbook without having to pass the hostname variable to ansible"

ANSIBLE_ALIAS=$(cat <<EOF
alias chromebook-ansible-playbook='export ANSIBLE_CONFIG=$ANSIBLE_CONFIG_PATH &&
cd $HOME/$GIT_PATH/$GIT_PROJECT_NAME && 
ansible-playbook ./chromebook_setup.yml --extra-vars "cb_localhost=$HOST_NAME" &&
unset ANSIBLE_CONFIG'
EOF
)

if  [ -f $HOME/.bashrc ] && grep 'alias chromebook-ansible-playbook' $HOME/.bashrc 1> /dev/null
    then
        sed -i "s/^alias\ chromebook\-ansible\-playbook.*//" $HOME/.bashrc
        echo $ANSIBLE_ALIAS >> $HOME/.bashrc
    else
        echo $ANSIBLE_ALIAS >> $HOME/.bashrc
fi

echo $'\n\n'$DIVIDER
echo -e "bootstrap.sh is done. \n"
echo -e 'Run: \nsource $HOME/.bashrc \nThen run: \nchromebook-ansible-playbook'



