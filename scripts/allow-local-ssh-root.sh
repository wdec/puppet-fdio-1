#!/bin/bash -xe

echo "" | sudo tee -a /etc/ssh/sshd_config
echo "Match address 127.0.0.1" | sudo tee -a /etc/ssh/sshd_config
echo "    PermitRootLogin without-password" | sudo tee -a /etc/ssh/sshd_config
echo "" | sudo tee -a /etc/ssh/sshd_config
echo "Match address ::1" | sudo tee -a /etc/ssh/sshd_config
echo "    PermitRootLogin without-password" | sudo tee -a /etc/ssh/sshd_config
if [ ! -f ~/.ssh/id_rsa.pub ]; then
if [ -f ~/.ssh/id_rsa ]; then
  ssh-keygen -y -f ~/.ssh/id_rsa -b 2048 -P "" > ~/.ssh/id_rsa.pub
else
  ssh-keygen -f ~/.ssh/id_rsa -b 2048 -P ""
fi
fi
sudo mkdir -p /root/.ssh
sudo chmod 700 /root/.ssh
sudo rm -f /root/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub | sudo tee -a /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo restorecon /root/.ssh/authorized_keys
if [ -f /usr/bin/yum ]; then
  sudo systemctl restart sshd
elif [ -f /usr/bin/apt-get ]; then
  sudo service ssh restart
fi
sudo cat /root/.ssh/authorized_keys
