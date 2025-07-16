#!/bin/bash

# Create necessary files if they don't exist
touch servers.txt
touch serversSSH.txt
touch serversWOL.txt

ORANGE='\033[38;5;208m'       
DARK_ORANGE='\033[38;5;166m'  
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'
BG_BLACK='\033[40m'
RED='\033[31m'


display_welcome() {
    clear
    echo -e 
    cat << "EOF"
 ____                                                      
/\  _`\                                                    
\ \,\L\_\     __   _ __   __  __     __   _ __   ____      
 \/_\__ \   /'__`\/\`'__\/\ \/\ \  /'__`\/\`'__\/',__\     
   /\ \L\ \/\  __/\ \ \/ \ \ \_/ |/\  __/\ \ \//\__, `\    
   \ `\____\ \____\\ \_\  \ \___/ \ \____\\ \_\\/\____/    
    \/_____/\/____/ \/_/   \/__/   \/____/ \/_/ \/___/     
                                                           
                                                           
                                                           
 /'\_/`\                                                   
/\      \     __      ___      __       __      __   _ __  
\ \ \__\ \  /'__`\  /' _ `\  /'__`\   /'_ `\  /'__`\/\`'__\
 \ \ \_/\ \/\ \L\.\_/\ \/\ \/\ \L\.\_/\ \L\ \/\  __/\ \ \/ 
  \ \_\\ \_\ \__/.\_\ \_\ \_\ \__/.\_\ \____ \ \____\\ \_\ 
   \/_/ \/_/\/__/\/_/\/_/\/_/\/__/\/_/\/___L\ \/____/ \/_/ 
                                        /\____/            
                                        \_/__/             
EOF
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
        display_menu
        choice_menu
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
    read -p "Enter the number of the server: " server_num
    selected_server=$(sed -n "${server_num}p" serversWOL.txt)
    if [ -z "$selected_server" ]; then
        echo "Invalid server number."
        echo "Press enter to continue..."
        read
        clear
        display_menu
        choice_menu
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
            read -p "Enter the server name to add: " server_name
            echo "$server_name" >> servers.txt
            echo "Is it for SSH or WOL? (ssh/wol)"
            read server_type
            if [[ "$server_type" == "ssh" ]]; then
                # SSH server details
                echo "Enter the server IP address (ip a):"
                read server_ip
                echo "Enter the server port (default is 22):"
                read server_port
                echo "Enter the SSH username:"
                read server_username
                # Add server details to serversSSH.txt 
                echo "$server_name - $server_ip:$server_port - $server_username" >> serversSSH.txt
                echo "Server added successfully."
                echo "Press enter to continue..."
                read
                clear
                display_menu
            elif [[ "$server_type" == "wol" ]]; then
                # WOL server details
                echo -e "\nEnter the server name (for identification):"
                read server_name
                echo -e "\nEnter the server MAC address (ip a):"
                read server_mac
                echo -e "\nEnter the server IP address (ip a):"
                read server_ip
                echo -e "\nEnter the server hostname (whoami):"
                read server_hostname
                # Add server details to serversWOL.txt
                echo "$server_name - $server_mac - $server_ip - $server_hostname" >> serversWOL.txt
                echo "Server added successfully."
                echo "Press enter to continue..."
                read
                clear
                display_menu
            else
                echo "Invalid server type. Please enter 'ssh' or 'wol'."
                echo "Press enter to continue..."
                read
                clear
                server_list_menu
            fi
            ;;
        2)
            echo -e "List of current servers:"
            if [ -s servers.txt ]; then
                cat servers.txt
            else
                echo "No servers found."
            fi
            echo ""
            read -p "Enter the server name to remove: " server_name
            if grep -q "$server_name" servers.txt; then
                sed -i "/$server_name/d" servers.txt
                # Also remove from specific server files
                if grep -q "$server_name" serversSSH.txt 2>/dev/null; then
                    sed -i "/$server_name/d" serversSSH.txt
                fi
                if grep -q "$server_name" serversWOL.txt 2>/dev/null; then
                    sed -i "/$server_name/d" serversWOL.txt
                fi
                echo "Server $server_name removed successfully."
            else
                echo "Server $server_name not found."
            fi
            echo ""
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
            echo -e "${ORANGE}╠════════════════════════════════════════════════════╝${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}ALL Servers:${RESET}"
            if [ -s servers.txt ]; then
            while IFS= read -r line; do
                echo -e "${ORANGE}║${RESET} $line"
            done < servers.txt
            else
            echo -e "${ORANGE}║${RESET} No servers found."
            fi
            echo -e "${ORANGE}╠════════════════════════════════════════════════════${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}SSH Servers:${RESET}"
            if [ -s serversSSH.txt ]; then
            while IFS= read -r line; do
                echo -e "${ORANGE}║${RESET} $line"
            done < serversSSH.txt
            else
            echo -e "${ORANGE}║${RESET}"           
            echo -e "${ORANGE}║${RESET} No SSH servers found."
            fi
            echo -e "${ORANGE}╠════════════════════════════════════════════════════${RESET}"
            echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}WOL Servers:${RESET}"
            if [ -s serversWOL.txt ]; then
            while IFS= read -r line; do
                echo -e "${ORANGE}║${RESET} $line"
            done < serversWOL.txt
            else
            echo -e "${ORANGE}║${RESET}"
            echo -e "${ORANGE}║${RESET} No WOL servers found."
            fi
            echo -e "${ORANGE}╚═════════════════════════════════════════════════════${RESET}"
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
            # The selected_server variable is now set by display_ssh_menu
            ssh_connect
            ;;
        2)
            clear
            display_wol_menu
            # The selected_server variable is now set by display_wol_menu
            wol_wake
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
    fi
    
    # Extract server details
    # Format: "server_name - ip:port - username@hostname"
    server_name=$(echo "$selected_server" | cut -d '-' -f 1 | tr -d ' ')
    connection_info=$(echo "$selected_server" | cut -d '-' -f 2 | tr -d ' ')
    server_ip=$(echo "$connection_info" | cut -d ':' -f 1)
    server_port=$(echo "$connection_info" | cut -d ':' -f 2)
    server_user_host=$(echo "$selected_server" | cut -d '-' -f 3 | tr -d ' ')
    
    echo "Connecting to $server_name ($server_ip) on port $server_port as $server_user_host..."
    ssh -p "$server_port" "$server_user_host@$server_ip"
    
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
    fi
    
    # Extract server details
    # Format: "server_name - MAC - ip - username@hostname"
    server_name=$(echo "$selected_server" | cut -d '-' -f 1 | tr -d ' ')
    server_mac=$(echo "$selected_server" | cut -d '-' -f 2 | tr -d ' ')
    server_ip=$(echo "$selected_server" | cut -d '-' -f 3 | tr -d ' ')
    
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

display_menu
choice_menu