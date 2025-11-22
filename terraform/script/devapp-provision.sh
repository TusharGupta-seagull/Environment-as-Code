#!/usr/bin/env bash

set -eux
set -o pipefail

echo "Provision Dev App Instance"

# Create user
sudo useradd -m -s /bin/bash devuser

# Install JDK 21
echo "Installing JDK 21"
sudo yum install -y java-21-amazon-corretto-devel

# Install AWS CLI v2
echo "Installing AWS CLI v2"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install -y unzip
sudo unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install Tomcat 11
echo "Installing Tomcat 11"
TOMCAT_VERSION=11.0.22
sudo -u devuser bash << 'EOF'
cd /home/devuser
wget -q https://downloads.apache.org/tomcat/tomcat-11/v11.0.0-M15/bin/apache-tomcat-11.0.0-M15.tar.gz
tar -xzf apache-tomcat-11.0.0-M15.tar.gz
ln -s apache-tomcat-11.0.0-M15 tomcat
rm apache-tomcat-11.0.0-M15.tar.gz

# Create tomcat directories and set permissions
mkdir -p /home/devuser/tomcat/logs
chmod +x /home/devuser/tomcat/bin/*.sh
EOF

# Create systemd service for Tomcat
echo "Creating systemd service for Tomcat"
sudo tee /etc/systemd/system/tomcat.service > /dev/null << 'EOF'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=devuser
Group=devuser
Environment=JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
Environment=CATALINA_PID=/home/devuser/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/home/devuser/tomcat
Environment=CATALINA_BASE=/home/devuser/tomcat
ExecStart=/home/devuser/tomcat/bin/startup.sh
ExecStop=/home/devuser/tomcat/bin/shutdown.sh
Restart=on-failure
RestartSec=10s
WorkingDirectory=/home/devuser/tomcat

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Tomcat service
echo "Starting and enabling Tomcat service"
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat --no-pager

# Configure SSH agent
echo "Configuring SSH agent"
sudo yum install -y openssh-clients
sudo systemctl enable ssh-agent
sudo systemctl start ssh-agent
sudo systemctl status ssh-agent --no-pager

# Create S3 sync script for WAR files
echo "Creating S3 sync script..."
sudo tee /usr/local/bin/sync-war-files.sh > /dev/null << 'EOF'
#! /usr/bin/env bash
S3_BUCKET="your-app-bucket"
S3_FOLDER="webapps"
LOCAL_DIR="/home/devuser/tomcat/webapps"
TEMP_DIR="/tmp/war_sync"
LOG_FILE="/var/log/war-sync.log"
BACKUP_DIR="/home/devuser/tomcat/backups"

mkdir -p "$TEMP_DIR"
mkdir -p "$BACKUP_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

stop_tomcat(){
    log_message "STOP: Tomcat service"
    systemctl stop tomcat
}

start_tomcat(){
    log_message "START: Tomcat service"
    systemctl start tomcat
}

log_message "VALIDATE: S3 bucket and folder"
if ! aws s3 ls "s3://$S3_BUCKET/$S3_FOLDER/" > /dev/null 2>&1; then
    log_message "ERROR: S3 location s3://$S3_BUCKET/$S3_FOLDER/ not found or inaccessible"
    exit 1
else
    log_message "S3 location s3://$S3_BUCKET/$S3_FOLDER/ is accessible"
fi

BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
log_message "CREATE: Backup of current webapps"
tar -czf "$BACKUP_DIR/webapps_backup_$BACKUP_TIMESTAMP.tar.gz" -C "$LOCAL_DIR" . >> "$LOG_FILE" 2>&1

log_message "CHECK: Changes in S3 bucket"
CHANGES=$(aws s3 sync "s3://$S3_BUCKET/$S3_FOLDER/" "$TEMP_DIR" --delete --dryrun 2>&1)

if [ -n "$CHANGES" ]; then
    log_message "Changes detected:"
    echo "$CHANGES" >> "$LOG_FILE"
    
    # Perform actual sync
    log_message "SYNC: WAR files from S3"
    if aws s3 sync "s3://$S3_BUCKET/$S3_FOLDER/" "$TEMP_DIR" --delete >> "$LOG_FILE" 2>&1; then
        log_message "Sync completed successfully"
        
        # Count WAR files found
        WAR_COUNT=$(find "$TEMP_DIR" -name "*.war" | wc -l)
        log_message "Found $WAR_COUNT WAR file(s) in sync"
        
        if [ "$WAR_COUNT" -gt 0 ]; then
            find "$TEMP_DIR" -name "*.war" | while read -r war_file; do
                log_message "Processing: $(basename "$war_file")"
            done
            
            stop_tomcat
            
            log_message "Clearing existing webapps..."
            find "$LOCAL_DIR" -maxdepth 1 -name "*.war" -delete
            find "$LOCAL_DIR" -maxdepth 1 -type d ! -name "backups" ! -name "." -exec rm -rf {} + 2>/dev/null || true
            
            log_message "Copying new WAR files to webapps..."
            cp -r "$TEMP_DIR"/* "$LOCAL_DIR"/ 2>/dev/null || true
            
            chown -R devuser:devuser "$LOCAL_DIR"
            
            start_tomcat
            
            log_message "WAR files deployment completed successfully"
        else
            log_message "No WAR files found in S3 location after sync"
        fi
    else
        log_message "ERROR: S3 sync failed"
        exit 1
    fi
else
    log_message "No changes detected in S3 bucket"
fi

find "$TEMP_DIR" -type f -mtime +1 -delete >> "$LOG_FILE" 2>&1

ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm >> "$LOG_FILE" 2>&1

log_message "Sync process completed"
EOF

sudo chmod +x /usr/local/bin/sync-war-files.sh

# Create system wide cron job
echo "Setting up cron job for WAR file sync"
sudo tee /etc/cron.d/war-sync > /dev/null << EOF
*/5 * * * * root /usr/local/bin/sync-war-files.sh >> /var/log/war-sync.log 2>&1
EOF

sudo touch /var/long/war-sync.log
sudo chmod 644 /var/log/war-sync.log

# set environment variable
sudo tee /etc/profile.d/tomcat-env.sh > /dev/null << EOF
export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
export CATALINA_HOME=/home/devuser/tomcat
export PATH=$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH
EOF

sudo chmod +x /etc/profile.d/tomcat-env.sh

sudo chown -R devuser:devuser /home/devuser

# Install SSM agent
echo "Installing SSM Agent"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent --no-pager
