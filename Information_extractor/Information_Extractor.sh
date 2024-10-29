#!/bin/bash

# Color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color


get_public_ip() {
    curl -s ifconfig.me | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
}

get_private_ip() {
    ip addr show | head -n 3 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
}

get_mac_address() {
    ip link | grep link/ether | awk '{print $2}' | sed 's/..$/XX:XX/'
}

get_default_gateway() {
    ip route show default | awk '/default/ {print $3}'
}

get_top_processes() {
    top -b -n 1 | sed -n '8,12p' | awk '{printf "%-8s %-20s %s%%\n", $1, $12, $9}'
}

get_memory_usage() {
    free -m | awk 'NR==2{printf "Total Memory: %s MB\nAvailable Memory: %s MB\n", $2, $7}'
}

get_active_services() {
    systemctl list-units --type=service --state=active | head -n 11
}

get_largest_files() {
    find /home -type f -exec du -ah {} + | sort -rh | head -n 10 | awk '{print $1, $2}' | awk -F'/' '{print $1, $(NF)}'
}


public_ip=$(get_public_ip)
private_ip=$(get_private_ip)
mac_address=$(get_mac_address)
default_gateway=$(get_default_gateway)
memory_usage=$(get_memory_usage)
active_services=$(get_active_services)
largest_files=$(get_largest_files)

display_results() {
    echo -e "${GREEN}1. Public IP: $public_ip (Default Gateway: $default_gateway)${NC}"
    echo -e "${GREEN}2. Private IP: $private_ip${NC}"
    echo -e "${GREEN}3. Masked MAC Address: $mac_address${NC}"
    echo -e "${GREEN}4. Top 5 CPU Processes: \n$(get_top_processes)${NC}"
    echo -e "${GREEN}5. Memory Usage: \n$memory_usage${NC}"
    echo -e "${GREEN}6. Top 10 Active System Services: \n$active_services${NC}"
    echo -e "${GREEN}7. Top 10 Largest Files in /home: \n$largest_files${NC}"
}

while true; do
    echo "Choose an option:"
    echo "1. Display Public IP and Default Gateway"
    echo "2. Display Private IP"
    echo "3. Display Masked MAC Address"
    echo "4. Monitor Top 5 CPU Processes"
    echo "5. Display Memory Usage"
    echo "6. Display Top 10 System Services"
    echo "7. Display Top 10 Largest Files in /home"
    echo "8. Display All Options"
    echo "E. Exit"
    read -p "Enter choice: " choice

    clear
    case $choice in
        1) echo -e "${GREEN}Public IP: $public_ip (Default Gateway: $default_gateway)${NC}" ;;
        2) echo -e "${GREEN}Private IP: $private_ip${NC}" ;;
        3) echo -e "${GREEN}Masked MAC Address: $mac_address${NC}" ;;
        4) while true; do
               echo -e "${GREEN}Top 5 CPU Processes:${NC}"
               echo -e "${GREEN}$(get_top_processes)${NC}"
               echo -e "${NC}Press 'e' to exit this view.${NC}"
               read -t 10 -n 1 -s input
               if [[ $input == "e" ]]; then
                   break
               fi
               clear
           done
           ;;
        5) echo -e "${GREEN}Memory Usage:${NC}"
           echo -e "${GREEN}$memory_usage${NC}"
           ;;
        6) echo -e "${GREEN}Top 10 Active System Services:${NC}"
           echo -e "${GREEN}$active_services${NC}"
           ;;
        7) echo -e "${GREEN}Top 10 Largest Files in /home:${NC}"
           echo -e "${GREEN}$largest_files${NC}"
           ;;
        8) display_results ;;
        [Ee]) echo "Exiting program."
           exit 0
           ;;
        *) echo "Invalid option." ;;
    esac
    echo
    read -p "Press any key to continue..." -n 1 -r
    clear
done

