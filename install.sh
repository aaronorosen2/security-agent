#!/bin/bash


export TOKEN=CSG_$h4p3#7e
terraform init
terraform plan
terraform apply -auto-approve


# To ignore host key checking prompt
export ANSIBLE_HOST_KEY_CHECKING=False

# retry ssh host could be still booting up.
export ANSIBLE_SSH_RETRIES=9
ansible-playbook -i hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"
