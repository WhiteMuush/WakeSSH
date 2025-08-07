#!/bin/bash

# Create necessary files if they don't exist
# Check if we can write in current directory
if ! touch test_write 2>/dev/null; then
    echo -e "${RED}Error: No write permissions in current directory $(pwd)${RESET}"
    echo -e "${RED}Please run this script from a directory where you have write permissions${RESET}"
    echo -e "${RED}Example: cd ~ && ./$(basename $0)${RESET}"
    exit 1
fi
rm -f test_write

# Create data files
touch servers.txt serversSSH.txt serversWOL.txt
chmod 644 servers.txt serversSSH.txt serversWOL.txt 2>/dev/null

ORANGE='\033[38;5;208m'       
DARK_ORANGE='\033[38;5;166m'  
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'
BG_BLACK='\033[40m'
RED='\033[31m'
RESET_COLOR='\033[0m'

display_welcome() {
    clear
    echo -e "${DARK_ORANGE}"
    cat << "EOF"
    ██╗    ██╗ █████╗ ██╗  ██╗███████╗███████╗███████╗██╗  ██╗
    ██║    ██║██╔══██╗██║ ██╔╝██╔════╝██╔════╝██╔════╝██║  ██║
    ██║ █╗ ██║███████║█████╔╝ █████╗  ███████╗███████╗███████║
    ██║███╗██║██╔══██║██╔═██╗ ██╔══╝  ╚════██║╚════██║██╔══██║
    ╚███╔███╔╝██║  ██║██║  ██╗███████╗███████║███████║██║  ██║
     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝                                                        
EOF

    echo -e ${RESET_COLOR}
    echo ""
    echo -e "${ORANGE}Welcome Boss ${RESET}${BOLD}$(whoami)${RESET}${ORANGE} !${RESET}\n"
    echo -e "${DARK_ORANGE}This is your personal Servers Management System.${RESET}\n"

}
display_menu() {
    display_welcome
    echo ""
    echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET}${BOLD}        Please choose what you want to do:${RESET}${ORANGE}          ║${RESET} "
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [1] Connect to a server in ${BOLD}SSH${RESET}                     ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [2] ${BOLD}Wake on LAN${RESET} one of your server                 ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [3] Edit Servers List                              ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [4] Exit                                           ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

display_ssh_menu() {
    display_welcome
    echo ""
    echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║${RESET}${BOLD}               SSH Connection Menu                  ${RESET}${ORANGE}║${RESET}"
    echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
    echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
    echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║${RESET} Please select a server to connect to via ${BOLD}SSH${RESET}       ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
    echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
    
    if [ ! -s serversSSH.txt ]; then
        echo ""
        echo -e "${RED}No SSH servers found. Please add a server first.${RESET}"
        echo -e "${RED}Press enter to return to the menu...${RESET}"
        read
        clear
        display_menu
        choice_menu
        return
    fi
    
    echo ""
    cat -n serversSSH.txt
    echo ""
    read -p "Enter the number of the server (or 'q' to exit): " server_num
    if [[ "$server_num" == "q" ]]; then
        echo "Exiting SSH connection menu..."
        clear
        display_menu
        choice_menu
        return
    fi
    selected_server=$(sed -n "${server_num}p" serversSSH.txt)
    if [ -z "$selected_server" ]; then
        echo "Invalid server number."
        echo "Press enter to continue..."
        read
        clear
        display_ssh_menu
        return
    fi

    # Make selected_server available globally
    export selected_server
}

display_wol_menu() {
    display_welcome
    echo ""
    echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET}${BOLD}                  Wake on LAN Menu${RESET}                  ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET}         Please select a server to wake up:         ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
    
    if [ ! -s serversWOL.txt ]; then
        echo ""
        echo -e "${RED}No WOL servers found. Please add a server first.${RESET}"
        echo -e "${RED}Press enter to continue...${RESET}"
        read
        clear
        display_menu
        choice_menu
        return
    fi

    echo ""
    cat -n serversWOL.txt
    echo ""
    read -p "Enter the number of the server (or 'q' to exit): " server_num
    if [[ "$server_num" == "q" ]]; then
        echo "Exiting WOL menu..."
        clear
        display_menu
        choice_menu
        return
    fi
    selected_server=$(sed -n "${server_num}p" serversWOL.txt)
    if [ -z "$selected_server" ]; then
        echo "Invalid server number."
        echo "Press enter to continue..."
        read
        clear
        display_wol_menu
        return
    fi

    export selected_server
}

server_list_menu() {
    display_welcome
    echo ""
    echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET}             ${BOLD}Edit Servers List Menu${RESET}                 ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"    
    echo -e "${ORANGE}║${RESET} [1] Add a new server                               ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET} [2] Remove a server                                ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET} [3] View current servers                           ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET} [4] Back to main menu                              ${ORANGE}║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
    read -p "Enter your choice boss: " choicelistmenu
    case $choicelistmenu in
        1)
            echo -e "\nEnter the server name to add:"
            read server_name
            # Validate server name
            if [ -z "$server_name" ]; then
                echo "Server name cannot be empty."
                echo "Press enter to continue..."
                read
                server_list_menu
                return
            fi
            
            echo "$server_name" >> servers.txt
            echo ""
            echo "Is it for SSH or WOL? (ssh/wol)"
            read server_type
            if [[ "$server_type" == "ssh" ]]; then
                # SSH server details
                echo -e "\nEnter the server IP address:"
                read server_ip
                if [ -z "$server_ip" ]; then
                    echo "IP address cannot be empty."
                    # Remove from servers.txt since we're canceling
                    sed -i "/$server_name/d" servers.txt
                    echo "Press enter to continue..."
                    read
                    server_list_menu
                    return
                fi
                
                echo -e "\nEnter the server port (default is 22):"
                read server_port
                if [ -z "$server_port" ]; then
                    server_port=22
                fi
                
                echo -e "\nEnter the SSH username:"
                read server_username
                if [ -z "$server_username" ]; then
                    echo "Username cannot be empty."
                    # Remove from servers.txt since we're canceling
                    sed -i "/$server_name/d" servers.txt
                    echo "Press enter to continue..."
                    read
                    server_list_menu
                    return
                fi
                
                # Add server details to serversSSH.txt 
                echo "$server_name - $server_ip:$server_port - $server_username" >> serversSSH.txt
                echo -e "\nSSH Server '$server_name' added successfully."
                echo "Details: $server_ip:$server_port with user '$server_username'"
                
            elif [[ "$server_type" == "wol" ]]; then
                # WOL server details
                echo -e "\nEnter the server MAC address:"
                read server_mac
                if [ -z "$server_mac" ]; then
                    echo "MAC address cannot be empty."
                    # Remove from servers.txt since we're canceling
                    sed -i "/$server_name/d" servers.txt
                    echo "Press enter to continue..."
                    read
                    server_list_menu
                    return
                fi
                
                echo -e "\nEnter the server IP address:"
                read server_ip
                if [ -z "$server_ip" ]; then
                    echo "IP address cannot be empty."
                    # Remove from servers.txt since we're canceling
                    sed -i "/$server_name/d" servers.txt
                    echo "Press enter to continue..."
                    read
                    server_list_menu
                    return
                fi
                
                echo -e "\nEnter the server hostname:"
                read server_hostname
                if [ -z "$server_hostname" ]; then
                    echo "Hostname cannot be empty."
                    # Remove from servers.txt since we're canceling
                    sed -i "/$server_name/d" servers.txt
                    echo "Press enter to continue..."
                    read
                    server_list_menu
                    return
                fi
                
                # Add server details to serversWOL.txt
                echo "$server_name - $server_mac - $server_ip - $server_hostname" >> serversWOL.txt
                echo -e "\nWOL Server '$server_name' added successfully."
                echo "Details: MAC=$server_mac, IP=$server_ip, Host=$server_hostname"
                
            else
                echo "Invalid server type. Please enter 'ssh' or 'wol'."
                # Remove from servers.txt since we're canceling
                sed -i "/$server_name/d" servers.txt
                echo "Press enter to continue..."
                read
                server_list_menu
                return
            fi
            echo "Press enter to continue..."
            read
            server_list_menu
            ;;
        2)
            echo -e "List of current servers:"
            if [ -s servers.txt ]; then
                cat -n servers.txt
            else
                echo "No servers found."
                echo "Press enter to continue..."
                read
                server_list_menu
                return
            fi
            echo ""
            read -p "Enter the number of the server to remove: " server_num
            
            # Get the server name from the line number
            server_name=$(sed -n "${server_num}p" servers.txt)
            
            if [ -z "$server_name" ]; then
                echo "Invalid server number."
                echo "Press enter to continue..."
                read
                server_list_menu
                return
            fi
            
            # Remove from all files
            sed -i "${server_num}d" servers.txt
            
            # Also remove from specific server files (using grep to match the server name)
            if grep -q "$server_name" serversSSH.txt 2>/dev/null; then
                sed -i "/$server_name/d" serversSSH.txt
                echo "Removed from SSH servers list."
            fi
            if grep -q "$server_name" serversWOL.txt 2>/dev/null; then
                sed -i "/$server_name/d" serversWOL.txt
                echo "Removed from WOL servers list."
            fi
            
            echo "Server '$server_name' removed successfully."
            echo "Press enter to continue..."
            read
            server_list_menu
            ;;
        3)
            clear
            display_welcome
            echo ""
            echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
            echo -e "${ORANGE}║${RESET}                ${BOLD}Current Servers List${RESET}                ${ORANGE}║${RESET}"
            echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}ALL Servers:${RESET}"
            if [ -s servers.txt ]; then
                while IFS= read -r line; do
                    echo -e "${ORANGE}║${RESET} $line"
                done < servers.txt
            else
                echo -e "${ORANGE}║${RESET} No servers found."
            fi
            echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}SSH Servers:${RESET}"
            if [ -s serversSSH.txt ]; then
                while IFS= read -r line; do
                    echo -e "${ORANGE}║${RESET} $line"
                done < serversSSH.txt
            else          
                echo -e "${ORANGE}║${RESET} No SSH servers found."
            fi
            echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}WOL Servers:${RESET}"
            if [ -s serversWOL.txt ]; then
                while IFS= read -r line; do
                    echo -e "${ORANGE}║${RESET} $line"
                done < serversWOL.txt
            else
                echo -e "${ORANGE}║${RESET} No WOL servers found."
            fi
            echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
            echo ""
            echo "Press enter to return to the Server List Menu..."
            read
            server_list_menu
            ;;
        4)
            echo "Returning to main menu..."
            clear 
            display_menu
            choice_menu
            ;;
        *)
            echo "Invalid option. Please try again."
            echo "Press enter to continue..."
            read
            server_list_menu
            ;;
    esac
}

choice_menu() {
    echo ""
    echo -n "Enter your choice: "
    read choice
    case $choice in 
        1)
            clear
            display_ssh_menu
            # Only proceed if a server was selected
            if [ -n "$selected_server" ]; then
                ssh_connect
            fi
            ;;
        2)
            clear
            display_wol_menu
            # Only proceed if a server was selected
            if [ -n "$selected_server" ]; then
                wol_wake
            fi
            ;;
        3)  
            clear
            server_list_menu
            ;;
        4)
            echo "Thank you for using the Home Server Management System!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            echo "Press enter to continue..."
            read
            clear
            display_menu
            choice_menu
            ;;
    esac
}

ssh_connect() {
    # The selected_server variable should be set by display_ssh_menu
    if [ -z "$selected_server" ]; then
        echo "No server selected."
        echo "Press enter to continue..."
        read
        clear
        display_menu
        choice_menu
        return
    fi
    
    # Extract server details
    # Format: "server_name - ip:port - username"
    server_name=$(echo "$selected_server" | cut -d '-' -f 1 | sed 's/^ *//;s/ *$//')
    connection_info=$(echo "$selected_server" | cut -d '-' -f 2 | sed 's/^ *//;s/ *$//')
    server_ip=$(echo "$connection_info" | cut -d ':' -f 1)
    server_port=$(echo "$connection_info" | cut -d ':' -f 2)
    server_username=$(echo "$selected_server" | cut -d '-' -f 3 | sed 's/^ *//;s/ *$//')
    
    echo "Connecting to $server_name ($server_ip) on port $server_port as $server_username..."
    ssh -p "$server_port" "$server_username@$server_ip"
    
    echo "SSH session ended."
    echo "Press enter to continue..."
    read
    clear
    display_menu
    choice_menu
}

wol_wake() {
    # The selected_server variable should be set by display_wol_menu
    if [ -z "$selected_server" ]; then
        echo "No server selected."
        echo "Press enter to continue..."
        read
        clear
        display_menu
        choice_menu
        return
    fi
    
    # Extract server details
    # Format: "server_name - MAC - ip - hostname"
    server_name=$(echo "$selected_server" | cut -d '-' -f 1 | sed 's/^ *//;s/ *$//')
    server_mac=$(echo "$selected_server" | cut -d '-' -f 2 | sed 's/^ *//;s/ *$//')
    server_ip=$(echo "$selected_server" | cut -d '-' -f 3 | sed 's/^ *//;s/ *$//')
    
    echo "Waking up $server_name with MAC address $server_mac..."
    
    # Check if wakeonlan is installed
    if ! command -v wakeonlan &> /dev/null; then
        echo "wakeonlan command not found. Please install it first."
        echo "You can install it with: sudo apt-get install wakeonlan"
    else
        wakeonlan "$server_mac"
        echo "Wake-on-LAN packet sent to $server_name ($server_ip)."
    fi
    
    echo "Press enter to continue..."
    read
    clear
    display_menu
    choice_menu
}

# Ensure files exist and start the program
touch servers.txt serversSSH.txt serversWOL.txt
display_menu
choice_menu