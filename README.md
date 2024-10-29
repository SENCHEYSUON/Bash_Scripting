# Shell Scripting Repository

This repository aims to build a solid foundation for shell scripting. Through exploring project samples on various platforms, I have curated and implemented essential commands. The repository is structured around three main topics: Information and System Condition Extractor, Sender Policy Framework (SPF), and Basic Automated Backup with cron jobs.

## 1. Information and System Condition Extractor

### Purpose
This folder contains a Bash script designed to capture and display various system metrics for a Linux operating system. The script provides details about the Linux version, network information including private and public IP addresses, and the default gateway. It also retrieves disk statistics such as total size, free space, and used space, highlights the five largest directories, and monitors CPU usage. The script updates these statistics every ten seconds to reflect the real-time state of the system.

### Usage
- `bash script_name`
- `./script_name` (use `chmod` if you encounter permission issues)
- `sh script_name`

## 2. Sender Policy Framework (SPF)

### What is SPF?
Sender Policy Framework (SPF) is an email authentication method that helps to prevent sender address forgery during the delivery of emails. SPF allows domain owners to specify which mail servers are authorized to send emails on behalf of their domain.

### Why Implement SPF?
Implementing SPF is crucial for several reasons:
- Reducing spam and phishing attacks
- Improving email deliverability
- Protecting the domain's reputation

### Usage
- `./scriptname <domain>`
- `bash`
- `shell`

## 3. Basic Automated Backup with Cron Job

### Purpose
Creating automated backup scripts is essential for data management at personal, business, and organizational levels. Here are some reasons why automated backups are crucial:
- Data protection
- Consistency and reliability
- Efficiency and scalability
- Version control
- Remote management and monitoring

### Usage
1. Modify the path in the configuration and shell script files.
2. Adjust the number of backups to retain.
3. Execute the shell script.
4. Set up a cron job for automatic execution.
   - `crontab -e`: To edit crontab, add `00 00 * * * sudo /path/to/automated_backup.sh` to schedule a backup every midnight.
   - `crontab -l`: To verify the scheduled jobs.

Feel free to explore the scripts and utilize them in enhancing your system's functionality and security!
