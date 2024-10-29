#!/bin/bash

# Configuration file path
CONFIG_FILE="/home/senchey/Desktop/Publish_Project/cron_job_backup/config.conf"

# Load configuration or exit with an error if the configuration file is not found
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found!"
    exit 1
fi

# Create a timestamp for the backup
BACKUP_DATE=$(date +%Y%m%d%H%M%S)

# Define backup and log file names
BACKUP_FILENAME="backup_of_$BACKUP_DATE.tar.gz"
LOG_FILE="$BACKUP_DST/backup_$BACKUP_DATE/backup_of_$BACKUP_DATE.log"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DST/backup_$BACKUP_DATE"

# Redirect all output to the log file
exec >> >(tee -a "$LOG_FILE") 2>&1

# Perform the backup with tar command
tar -czf "$BACKUP_DST/backup_$BACKUP_DATE/$BACKUP_FILENAME" -C "$BACKUP_SRC" .

# Check the success of the backup operation
if [ $? -eq 0 ]; then
    echo "Backup successful!: $BACKUP_FILENAME"
else
    echo "Backup unsuccessful!"
    exit 1
fi

# Set the number of backups to retain
NUM_BACKUPS_TO_KEEP=2

# Delete old backups beyond the number to keep
cd "$BACKUP_DST"
find . -maxdepth 1 -name "backup_*" -type d | sort -r | sed -e "1,${NUM_BACKUPS_TO_KEEP}d" | xargs rm -rf
find . -maxdepth 1 -name "backup_*.log" | sort -r | sed -e "1,${NUM_BACKUPS_TO_KEEP}d" | xargs rm -rf

echo "Backup script completed successfully"
exit 0

