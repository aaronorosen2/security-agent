Security Agent Deployment code

The following code `aws-deploy.tf` deploys a ubuntu-20.04 LTS instance with ports 22 and 443 open and generates a hosts.ini inventory file populated with the instance's ipv4 addresses.

Before running this command you first need to setup `aws configure` and install terraform:

Next run the following commands to deploy the instance:
```
terraform init
terraform plan
terraform apply
```

Next we set the unique token used by the security agent in the TOKEN env variable

export TOKEN=CSG_$h4p3#7e

Run `csg_security_agent.yml` ansible script with the follow command:

ansible-playbook -i hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"


This configures /opt/csg_security_agent on the instance with the installer, configuration file and token.


See `install.sh` which runs all of these commands without interactive terminal prompts
