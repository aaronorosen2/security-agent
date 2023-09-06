#!/bin/bash


export TOKEN=CSG_$h4p3#7e
terraform init
terraform plan
terraform apply -auto-approve


dns_ip=`tail -n 1 hosts.ini   | awk '{print $1;}'`



# Here we check for dns to resolve correctly before continuing on.
# NOTE: this is still error prone and we should use public_ip instead.
while : ; do
  echo "Checking if dns resolves to intended ip"
  nslookup security-agent.agentstat.net | grep $dns_ip
  if [ $? -eq 0 ]
  then
    break
  fi
  sleep 4
done


# To ignore host key checking prompt
export ANSIBLE_HOST_KEY_CHECKING=False

# retry ssh host could be still booting up.
export ANSIBLE_SSH_RETRIES=9
ansible-playbook -i dns-hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"
