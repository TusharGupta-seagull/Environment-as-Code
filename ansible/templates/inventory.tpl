[bastion]
bastion-primary ansible_host=${bastion_public_ip} ansible_user=ec2-user

[app]
%{ for index, ip in app_private_ips ~}
app-server-${index + 1} ansible_host=${ip} ansible_user=ec2-user
%{ endfor ~}

[db]
%{ for index, ip in db_private_ips ~}
db-server-${index + 1} ansible_host=${ip} ansible_user=ec2-user
%{ endfor ~}

[parent:children]
app
db


[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q -o StrictHostKeyChecking=no ec2-user@${bastion_public_ip}"'
ansible_ssh_private_key_file=${ssh_key_path}

