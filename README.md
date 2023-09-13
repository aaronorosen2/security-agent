# Security Agent Deployment Automation

## Setup

In order to perform the deployment one must install terraform and ansible. Follow this guide which outlines the install process for terraform `https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli`. This guide outlines the install process for ansible `https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html`.

This guide has been tested using: `Terraform v1.5.7` and `ansible [core 2.14.2]` on Ubuntu 23.04.

If you are using ubuntu this should be achievable with: `sudo apt-get install ansible terraform`

## Terraform Configuration

The terraform logic is located in the `terraform` directory of this project and creates resources such as instances, ssh-key, security-group, hostzone and A records that are required to deply the security agent. In order to run the terraform script you must export your aws credential.

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

Now, take time to review the `variables.tf` file, here is where you will update parameters that you might need to change for your setup requirements. The parameters you can change are:

`aws_region` aws region to use, default is `us-west-2`.<br>
`ssh_key` path to public ssh-key, default is `~/.ssh/id_rsa.pub`.<br>
`instance_count` number of security agent instances to deploy, default is `1`.<br>
`instance_type` type of instances to deploy, default is `t2.micro`<br>
`domain_name` the domain name used to create route53 records for the security agents, default is `agentstat.net`.<br>
`record_name` the record name to use for A records, default is `security-agent`.<br>

<b>NOTE:</b> if you do not have this domain_name  or a domain_name to use in your aws account this script will still execute successfully though the DNS A records created will not resolve correctly, you will need to use a different ansible inventory file explained later.

## Running Terraform

The terraform script `instance.tf` deploys ubuntu-20.04 LTS instances with a security group that has ports 22 and 443 accessible see `security-group.tf`. The terraform generates a hosts.ini and dns-host.ini ansible inventory file in the top level ansbile folder populated with the instance's aws dns and dns addresses deployed via terraform . The script creates a DNS A record of `record_name`-#.`domain_name` for each instance it deploys where # is the instance number for example 1,2,3 etc..by default there will be one A record named `security-agent-1.agentstat.net` see `dns.tf`.

Run the following commands to deploy the terraform script:
```
terraform init
terraform plan
terraform apply
```

At this point you should have all the resources deployed in your aws account.

<b>Important!!!</b> We need to check the nameservers in the domain_name hostzone match the nameservers configured on the domain name and manually update these if they are not matching. To do this navigate to route53 and click `Registered domains` on the left sidebar and click on `agentstat.net` (domain_name). Now, note down the name servers defined on the domain that is displayed. Click on `Hosted zones` and select agentstat.net or whatever domain name you are using and find the NS record enties. Make sure these entires match the ones configured on the domain that you noted.

Unfortinately these values are outside of what terraform can configure and need to be handled manually at this time, see for more information: https://www.reddit.com/r/Terraform/comments/q8xych/noob_question_matching_nameservers_on_route53/, https://stackoverflow.com/questions/44609348/how-can-i-specify-the-dns-servers-when-terrafrorm-uses-aws-route53-zone.


## Ansible

The next part of the process installs the `csg security agent` This logic is located in the ansible folder cd to this folder now.

`cd ansible`

The csa security agent requires a token that is used by the security agent. To run the ansible script which configures the csg security agent use the following command:

`ansible-playbook -i dns_hosts.ini main_playbook.yml -e "TOKEN=<PUT TOKEN VALUE HERE>"`

If you are working with a setup that does not have a domain_name in the aws account use the hosts.ini file instead like:

`ansible-playbook -i hosts.ini main_playbook.yml -e "TOKEN=<PUT TOKEN VALUE HERE>"`

The ansible script configures `/opt/csg_security_agent` on the instance with it's own csa user and group containing the installer, configuration file, token and outputs the output of the installer script.

It's a good idea to inspect the hosts to ensure everything configured correctly. Ssh to each host in the host.ini file with `ssh ubuntu@<ip-address>` and inspect with `ls -lrt /opt/` you should see:<br>
`ls -lrt /opt`<br>
`total 4`<br>
`drwxrwx--- 2 csa csa 4096 Sep 13 20:52 csg_security_agent`<br>

You can check the csg_security_agent configuration file field unique_token is configured with the `TOKEN` specified: <br>
`sudo cat csg_security_agent/security_agent_config.conf`

If this is the case the csa security agent should be configured and installed correctly. 
