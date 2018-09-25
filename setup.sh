#!/bin/bash

if [[ -f $HOME/.setup_done ]]
then
  echo "Setup is already comlete. "
  echo "If your lab environment is not working corrrectly, please ask for help."
  exit 0
fi

echo "Setting up the lab environment."
echo "Installing alternate text editor."
sudo yum install nano -y 2>&1 >> $HOME/setup.log
echo "export EDITOR=nano" >> .bash_profile
echo "Upgrading Ansible."
sudo pip uninstall --yes ansible 2>&1 >> $HOME/setup.log
sudo yum makecache 2>&1 >> $HOME/setup.log
sudo yum install ansible -y 2>&1 >> $HOME/setup.log
echo "Adding routers to /etc/hosts."
cp /etc/hosts /tmp/hosts
echo "198.18.134.11 csr1" >> /tmp/hosts
echo "198.18.134.12 csr2" >> /tmp/hosts
sudo mv /tmp/hosts /etc/hosts
sudo chmod 644 /etc/hosts
echo "Configuring host key checking for SSH in the demo environment."
echo "Host *" > $HOME/.ssh/config
echo "   StrictHostKeyChecking no" >> $HOME/.ssh/config
chmod 400 $HOME/.ssh/config
touch $HOME/.setup_done
