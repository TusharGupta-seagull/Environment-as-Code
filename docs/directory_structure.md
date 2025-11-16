# Proposed Directory Structure

```text
Directory structure for V2

/EAC
    --ansible
        --inventories
            --dev
                --group_vars
                -inventory.ini
        --roles
            --common
            --app-server
            --database-server
            --jenkins-master
            --jenkins-agent(optional)
        --templates
            --app
            --nginx
            --jenkins
        -main.yml
        -ssh_config
        -ansible.cfg
        
    --configs
    
    --docs
    
    --jenkins
        --pipelines
            -pipeline1.groovy
            -pipeline2.groovy
            
    --terraform
        --modules
            --compute
                --auto-scaling
                --ec2-instance
                --elb
            --network
                --route53
                --security_group
                --vpc
            --database
                --rds
        --vars
            -dev.tfvars
            -staging.tfvars
        --network
            -vpc.tf
            -sg.tf
            -route53.tf
            -variable.tf
            -output.tf
        --application
            -instances.tf (application related)
            -alb.tf
            -asg.tf
            -variable.tf
            -output.tf
        --config-mgmt
            -ansible.tf
            -variable.tf
            -output.tf
        --cd-cd
            -jenkins.tf
            -variable.tf
            -output.tf
        -main.tf
        -provider.tf
        -variable.tf
        -output.tf
```