Host bastion
    HostName ${bastion_public_ip}
    User ec2-user
    IdentityFile ${ssh_key_path}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

%{ for index, ip in app_private_ips ~}
Host app-${index+1}
    HostName ${ip}
    ProxyJump bastion
    User ec2-user
    IdentityFile ${ssh_key_path}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
%{ endfor ~}


%{ for index, ip in db_private_ips ~}
Host db-${index+1}
    HostName ${ip}
    ProxyJump bastion
    User ec2-user
    IdentityFile ${ssh_key_path}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
%{ endfor ~}


