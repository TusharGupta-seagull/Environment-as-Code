Host bastion
    HostName ${bastion_public_ip}
    User ${bastion_user}
    IdentityFile ${ssh_key_path}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 30
    ServerAliveCountMax 3


# Match all private IPs in 10.0.x.x range
Host 10.0.*
    User ${app_db_user}
    IdentityFile ${ssh_key_path}
    ProxyJump bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 30
    ServerAliveCountMax 3

# Specific app servers
%{ for index, ip in app_private_ips ~}
Host app-server-${index + 1}
    HostName ${ip}
    User ${app_db_user}
    IdentityFile ${ssh_key_path}
    ProxyJump bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 30
    ServerAliveCountMax 3

%{ endfor ~}

# Specific db servers
%{ for index, ip in db_private_ips ~}
Host db-server-${index + 1}
    HostName ${ip}
    User ${app_db_user}
    IdentityFile ${ssh_key_path}
    ProxyJump bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 30
    ServerAliveCountMax 3
%{ endfor ~}
