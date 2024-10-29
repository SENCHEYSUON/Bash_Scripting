#!/bin/bash

# Variables
S="************************************"
D="-------------------------------------"
COLOR="y"
MOUNT=$(mount | egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs" | grep -v "loop" | sort -u -t' ' -k1,2)
FS_USAGE=$(df -PThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs | awk '!seen[$1]++' | sort -k6n | tail -n +2)
IUSAGE=$(df -iPThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs | awk '!seen[$1]++' | sort -k6n | tail -n +2)

# Colors based on usage thresholds
setup_colors() {
  if [ $COLOR == "y" ]; then
    GCOLOR="\e[47;32m ------ SAFE  \e[0m"
    WCOLOR="\e[43;31m ------ WARNING! \e[0m"
    CCOLOR="\e[47;31m ------ CRITICAL! \e[0m"
  else
    GCOLOR=" ------ SAFE "
    WCOLOR=" ------ WARNING! "
    CCOLOR=" ------ CRITICAL! "
  fi
}

# System Header
print_header() {
  echo -e "$S"
  echo -e "\tSystem Health Status"
  echo -e "$S"
}

# Operating System Details
os_details() {
  echo -e "\nOperating System Details"
  hostname -f &>/dev/null && printf "Hostname : $(hostname -f)" || printf "Hostname : $(hostname -s)"
  echo -en "\nOperating System : "
  [ -f /etc/os-release ] && echo $(egrep -w "NAME|VERSION" /etc/os-release | awk -F= '{ print $2 }' | sed 's/"//g') || cat /etc/system-release
  echo -e "Kernel Version :" $(uname -r)
  printf "OS Architecture :"$(arch | grep x86_64 &>/dev/null) && printf " 64 Bit OS\n" || printf " 32 Bit OS\n"
}

# System Uptime and Date
system_uptime_and_date() {
  echo -en "System Uptime : " $(uptime -p)
  echo -e "\nCurrent System Date & Time : "$(date +%c)
}

# Check for Read-only Filesystems
check_read_only_fs() {
  echo -e "\nChecking For Read-only File System[s]"
  echo -e "$D"
  echo "$MOUNT" | grep -w ro && echo -e "\n.....Read Only file system[s] found" || echo -e ".....No read-only file system[s] found. "
}

# Mounted Filesystems
check_mounted_fs() {
  echo -e "\n\nChecking For Currently Mounted File System[s]"
  echo -e "$D$D"
  echo "$MOUNT" | column -t
}

# Disk Usage on Mounted Filesystems
check_disk_usage() {
  echo -e "\n\nChecking For Disk Usage On Mounted File System[s]"
  echo -e "$D$D"
  echo -e "( 0-85% = SAFE,  85-95% = WARNING,  95-100% = CRITICAL )"
  echo -e "$D$D"
  echo -e "Mounted File System[s] Utilization (Percentage Used):\n"

  COL1=$(echo "$FS_USAGE" | awk '{print $1 " "$7}')
  COL2=$(echo "$FS_USAGE" | awk '{print $6}' | sed -e 's/%//g')

  for i in $(echo "$COL2"); do
    if [ $i -ge 95 ]; then
      COL3="$(echo -e $i"% $CCOLOR\n$COL3")"
    elif [[ $i -ge 85 && $i -lt 95 ]]; then
      COL3="$(echo -e $i"% $WCOLOR\n$COL3")"
    else
      COL3="$(echo -e $i"% $GCOLOR\n$COL3")"
    fi
  done
  COL3=$(echo "$COL3" | sort -k1n)
  paste <(echo "$COL1") <(echo "$COL3") -d' ' | column -t
}

# Zombie Processes Checking
check_zombie_processes() {
  echo -e "\n\nChecking For Zombie Processes"
  echo -e "$D"
  ps -eo stat | grep -w Z 1>&2 >/dev/null
  if [ $? == 0 ]; then
    echo -e "Number of zombie processes on the system: " $(ps -eo stat | grep -w Z | wc -l)
    echo -e "\n  Details of each zombie process found"
    echo -e "  $D"
    ZPROC=$(ps -eo stat,pid | grep -w Z | awk '{print $2}')
    for i in $(echo "$ZPROC"); do
      ps -o pid,ppid,user,stat,args -p $i
    done
  else
    echo -e "No zombie processes found on the system."
  fi
}

# Check Inode Usage
check_inode_usage() {
  echo -e "\n\nChecking For INode Usage"
  echo -e "$D$D"
  echo -e "( 0-85% = OK/HEALTHY,  85-95% = WARNING,  95-100% = CRITICAL )"
  echo -e "$D$D"
  echo -e "INode Utilization (Percentage Used):\n"

  COL11=$(echo "$IUSAGE" | awk '{print $1" "$7}')
  COL22=$(echo "$IUSAGE" | awk '{print $6}' | sed -e 's/%//g')

  for i in $(echo "$COL22"); do
    if [[ $i = *[[:digit:]]* ]]; then
      if [ $i -ge 95 ]; then
        COL33="$(echo -e $i"% $CCOLOR\n$COL33")"
      elif [[ $i -ge 85 && $i -lt 95 ]]; then
        COL33="$(echo -e $i"% $WCOLOR\n$COL33")"
      else
        COL33="$(echo -e $i"% $GCOLOR\n$COL33")"
      fi
    else
      COL33="$(echo -e $i"% (Inode Percentage details not available)\n$COL33")"
    fi
  done
  COL33=$(echo "$COL33" | sort -k1n)
  paste <(echo "$COL11") <(echo "$COL33") -d' ' | column -t
}

# Swap Utilization
check_swap_usage() {
  echo -e "\n\nChecking SWAP Details"
  echo -e "$D"
  echo -e "Total Swap Memory in MiB : "$(grep -w SwapTotal /proc/meminfo | awk '{print $2/1024}')", in GiB : "$(grep -w SwapTotal /proc/meminfo | awk '{print $2/1024/1024}')
  echo -e "Swap Free Memory in MiB : "$(grep -w SwapFree /proc/meminfo | awk '{print $2/1024}')", in GiB : "$(grep -w SwapFree /proc/meminfo | awk '{print $2/1024/1024}')
}

# Main function to call all other functions
main() {
  setup_colors
  print_header
  os_details
  system_uptime_and_date
  check_read_only_fs
  check_mounted_fs
  check_disk_usage
  check_zombie_processes
  check_inode_usage
  check_swap_usage
}

# Run the main function
main

