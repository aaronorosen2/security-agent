#!/bin/bash

export TOKEN=abc
ansible-playbook -i hosts.ini -l agents csg_security_agent.yml -e "TOKEN=$TOKEN"

