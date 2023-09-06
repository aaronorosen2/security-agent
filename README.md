# Security Agent Deployment Automation

The terraform script `aws-deploy.tf` deploys ubuntu-20.04 LTS instances with a security group that has ports 22 and 443 accessible. It generates a hosts.ini and dns-host.ini ansible inventory file populated with the instance's aws dns and dns addresses deployed via terraform. The script creates a DNS A record of `security-agent-#.agentstat.net` for each instance it deploys.

Before running this command you first need to setup `aws configure` and install terraform

Run the following commands to deploy the terraform script:
```
terraform init
terraform plan
terraform apply
```

The next part of the process installs the `csg security agent` which requires a unique token used by the security agent which is set in the TOKEN env variable

`export TOKEN=CSG_$h4p3#7e`

Run `csg_security_agent.yml` ansible script with the follow command:

`ansible-playbook -i hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"`

This configures /opt/csg_security_agent on the instance with the installer, configuration file and token.

To run all of these commands without interactive terminal prompts see `install.sh`

NOTE: install.sh uses the dns_hosts.ini inventory file where the install.sh script makes perodic calls using `nslookup` to confirm dns has been populated with correct records which can take on the order of 15 minutes to update and also does not guarantee the agent to be installed on the correct host as DNS can return previous DNS records previously configured on the domain name entry so it is best to use the host.ini file directly like is shown in the given ansible-playbook command above.
