#!/bin/bash
# For development
git config credential.helper cache
#
if [[ -f $HOME/.setup_done ]]
then
  echo "Setup is already comlete. "
  echo "If your lab environment is not working corrrectly, please ask for help."
  exit 0
fi

echo "Setting up the lab environment."
sudo yum makecache 2>&1 >> $HOME/setup.log
rpm -qi nano 2>&1 > /dev/null
if [[ $? -eq 1 ]]
then
  echo "Installing alternate text editor."
  sudo yum install nano -y 2>&1 >> $HOME/setup.log
  echo "export EDITOR=nano" >> $HOME/.bash_profile
fi
rpm -qi ansible > /dev/null 2>&1
ANSIBLE_PKG=$?
pip list 2>&1 | grep ansible > /dev/null 2>&1
ANSIBLE_PIP=$?

if [[ $ANSIBLE_PKG -eq 1 ]]
then
  echo "Upgrading Ansible."
  if [[ $ANSIBLE_PIP -eq 0 && $ANSIBLE_PKG -eq 1 ]]
  then
    echo "Removing pip ansible version."
    sudo pip uninstall --yes ansible  >> $HOME/setup.log 2>&1
  fi
  echo "Installing EPEL packaged version of ansible."
  sudo yum install ansible -y 2>&1 >> $HOME/setup.log
fi
grep csr1 /etc/hosts 2>&1 > /dev/null
if [[ $? -eq 1 ]]
then
  echo "Adding routers to /etc/hosts."
  cp /etc/hosts /tmp/hosts
  echo "198.18.134.11 csr1" >> /tmp/hosts
  echo "198.18.134.12 csr2" >> /tmp/hosts
  sudo mv /tmp/hosts /etc/hosts
  sudo chmod 644 /etc/hosts
fi
if [[ ! -d $HOME/.ssh ]]
then
  echo "Creating $HOME/.ssh"
  mkdir $HOME/.ssh
  chmod 700 $HOME/.ssh
fi
if [[ ! -f $HOME/.ssh/config ]]
then
  echo "Configuring host key checking for SSH in the demo environment."
  echo "Host *" > $HOME/.ssh/config
  echo "   StrictHostKeyChecking no" >> $HOME/.ssh/config
  chmod 600 $HOME/.ssh/config
fi
if [[ ! -f $HOME/.ssh/known_hosts ]]
then
  ssh-keyscan 198.18.134.11 >> $HOME/.ssh/known_hosts 2>/dev/null
  ssh-keyscan 198.18.134.12 >> $HOME/.ssh/known_hosts 2>/dev/null
  ssh-keyscan csr1 >> $HOME/.ssh/known_hosts 2>/dev/null
  ssh-keyscan csr2 >> $HOME/.ssh/known_hosts 2>/dev/null
  chmod 600 $HOME/.ssh/known_hosts
fi
touch $HOME/.setup_done
