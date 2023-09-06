#!/bin/bash

# Set installer TOKEN value
export TOKEN=CSG_$h4p3#7e

# To ignore host key checking prompt
export ANSIBLE_HOST_KEY_CHECKING=False
# retry ssh host could be still booting up.
export ANSIBLE_SSH_RETRIES=9


terraform init
terraform plan
terraform apply -auto-approve


# take the dns record from aws and look up ip_address
dns_ip=`tail -n 1 hosts.ini   | awk '{print $1;}' | xargs nslookup | grep Address | tail -n1 | awk '{print $2;}'`


# Check that our A record resolved to dns_ip before continuing on.
# NOTE: this is error prone as this value can be a previous configured while dns updates are being processed across all dns servers.
while : ; do
  echo "Waiting for dns security-agent.agentstat.net to resolve to ip $dns_ip"
  nslookup security-agent.agentstat.net | grep $dns_ip
  if [ $? -eq 0 ]
  then
    break
  fi
  sleep 4
done


ansible-playbook -i dns-hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"
