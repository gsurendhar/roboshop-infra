#!/bin/bash
component=$2
env=$1
dnf install ansible -y
ansible-pull -U https://github.com/gsurendhar/ansible-roboshop-by-roles-env.git -e component=$2 -e env=$1 main.yaml