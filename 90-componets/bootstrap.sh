#!/bin/bash
env=$1
component=$2
dnf install ansible -y
ansible-pull -U https://github.com/gsurendhar/ansible-roboshop-by-roles-env.git  -e env=$1 -e component=$2 main.yaml