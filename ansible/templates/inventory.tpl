[bastion]
bastion-primary ansible_host=${bastion_public_ip} ansible_user=${bastion_user}

[app]
%{ for index, ip in app_private_ips ~}
app-server-${index + 1} ansible_host=${ip} ansible_user=${app_db_user}
%{ endfor ~}

[db]
%{ for index, ip in db_private_ips ~}
db-server-${index + 1} ansible_host=${ip} ansible_user=${app_db_user}
%{ endfor ~}

[parent:children]
app
db

[all:vars]
ansible_ssh_private_key_file=${ssh_key_path}
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_connection=ssh

# Database configuration
db_host=${db_private_ips[0]}
db_name=crud_react_node
db_port=3306


[parent:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -i ${ssh_key_path} -o StrictHostKeyChecking=no ${bastion_user}@${bastion_public_ip}"'




# [app:vars]
# db_host=${db_private_ips[0]}
# ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J ${bastion_user}@${bastion_public_ip}'

# [db:vars]
# ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J ${bastion_user}@${bastion_public_ip}'
