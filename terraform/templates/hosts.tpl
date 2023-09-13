[agents]
%{ for ip in agents ~}
${ip} ansible_ssh_user=ubuntu
%{ endfor ~}
