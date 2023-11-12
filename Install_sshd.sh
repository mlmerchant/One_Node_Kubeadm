#!/bin/bash

sudo apt-get -y install ssh
sudo systemctl enable sshd
sudo systemctl start sshd
