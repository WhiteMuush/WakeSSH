#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Colors
ORANGE='\033[38;5;208m'
DARK_ORANGE='\033[38;5;166m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'
BG_BLACK='\033[40m'
RED='\033[31m'

# Paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SERVERS_ALL="$SCRIPT_DIR/servers.txt"
SERVERS_SSH="$SCRIPT_DIR/serversSSH.txt"
SERVERS_WOL="$SCRIPT_DIR/serversWOL.txt"

# Globals
SELECTED_LINE=""

pause() { read -r -p "Press enter to continue..." _; }
ask() { # ask "Prompt: " varname
    local __prompt="$1"; local __var="$2"; read -r -p "$__prompt" "$__var"
}
is_number() { [[ "$1" =~ ^[0-9]+$ ]]; }
line_count() { wc -l < "$1" | tr -d ' '; }
safe_grep_q() { grep -Fq -- "$1" "$2"; }
escape_sed_re() { printf '%s' "$1" | sed -e 's/[.[\*^$()+?{}|]/\\&/g'; }

ensure_writable() {
    if ! touch "$SCRIPT_DIR/.writetest.$$" 2>/dev/null; then
        printf "%bError: No write permissions in directory %s%b\n" "$RED" "$SCRIPT_DIR" "$RESET"
        printf "%bPlease run this script from a directory where you have write permissions%b\n" "$RED" "$RESET"
        exit 1
    fi
    rm -f "$SCRIPT_DIR/.writetest.$$"
}

init_files() {
    touch "$SERVERS_ALL" "$SERVERS_SSH" "$SERVERS_WOL" 2>/dev/null || true
    chmod 644 "$SERVERS_ALL" "$SERVERS_SSH" "$SERVERS_WOL" 2>/dev/null || true
}

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
    echo -e "${RESET}\n"
    echo -e "${ORANGE}Welcome Boss ${RESET}${BOLD}$(whoami)${RESET}${ORANGE} !${RESET}\n"
    echo -e "${DARK_ORANGE}This is your personal Servers Management System.${RESET}\n"
}

display_menu() {
    display_welcome
    echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET}${BOLD}        Please choose what you want to do:${RESET}${ORANGE}          ║${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
    echo -e "${ORANGE}║                                                    ║${RESET}"
    echo -e "${ORANGE}║${RESET} [1] Connect to a server in ${BOLD}SSH${RESET}                     ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [2] ${BOLD}Wake on LAN${RESET} one of your server                 ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [3] Edit Servers List                              ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}║${RESET} [4] Exit                                           ${ORANGE}║"
    echo -e "${ORANGE}║                                                    ║"
    echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}"
}

display_ssh_menu() {
    while true; do
        display_welcome
        echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
        echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
        echo -e "${ORANGE}║${RESET}${BOLD}               SSH Connection Menu                  ${RESET}${ORANGE}║${RESET}"
        echo -e "${ORANGE}║${RESET}                                                    ${ORANGE}║${RESET}"
        echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
        echo -e "${ORANGE}║${RESET} Please select a server to connect to via ${BOLD}SSH${RESET}       ${ORANGE}║${RESET}"
        echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}\n"

        if [ ! -s "$SERVERS_SSH" ]; then
            echo -e "${RED}No SSH servers found. Please add a server first.${RESET}"
            pause; return
        fi

        nl -ba "$SERVERS_SSH"; echo
        read -r -p "Enter the number (or 'q' to exit): " server_num
        [[ "$server_num" == "q" ]] && return
        if ! is_number "$server_num"; then
            echo "Please enter a valid number."; pause; continue
        fi
        total=$(line_count "$SERVERS_SSH")
        if (( server_num < 1 || server_num > total )); then
            echo "Invalid server number."; pause; continue
        fi
        SELECTED_LINE="$(sed -n "${server_num}p" "$SERVERS_SSH")"
        return
    done
}

display_wol_menu() {
    while true; do
        display_welcome
        echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
        echo -e "${ORANGE}║${RESET}${BOLD}                  Wake on LAN Menu${RESET}                  ${ORANGE}║${RESET}"
        echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}\n"

        if [ ! -s "$SERVERS_WOL" ]; then
            echo -e "${RED}No WOL servers found. Please add a server first.${RESET}"
            pause; return
        fi

        nl -ba "$SERVERS_WOL"; echo
        read -r -p "Enter the number (or 'q' to exit): " server_num
        [[ "$server_num" == "q" ]] && return
        if ! is_number "$server_num"; then
            echo "Please enter a valid number."; pause; continue
        fi
        total=$(line_count "$SERVERS_WOL")
        if (( server_num < 1 || server_num > total )); then
            echo "Invalid server number."; pause; continue
        fi
        SELECTED_LINE="$(sed -n "${server_num}p" "$SERVERS_WOL")"
        return
    done
}

server_list_menu() {
    while true; do
        display_welcome
        echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
        echo -e "${ORANGE}║${RESET}             ${BOLD}Edit Servers List Menu${RESET}                 ${ORANGE}║${RESET}"
        echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
        echo -e "${ORANGE}║${RESET} [1] Add a new server                               ${ORANGE}║${RESET}"
        echo -e "${ORANGE}║${RESET} [2] Remove a server                                ${ORANGE}║${RESET}"
        echo -e "${ORANGE}║${RESET} [3] View current servers                           ${ORANGE}║${RESET}"
        echo -e "${ORANGE}║${RESET} [4] Back to main menu                              ${ORANGE}║${RESET}"
        echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}\n"
        read -r -p "Enter your choice boss: " choicelistmenu
        case "$choicelistmenu" in
            1)
                echo; ask "Enter the server name to add: " server_name
                if [ -z "${server_name:-}" ]; then echo "Server name cannot be empty."; pause; continue; fi
                echo "$server_name" >> "$SERVERS_ALL"

                read -r -p "Is it for SSH or WOL? (ssh/wol): " server_type
                case "${server_type,,}" in
                    ssh)
                        ask "Enter the server IP address: " server_ip
                        if [ -z "${server_ip:-}" ]; then
                            echo "IP address cannot be empty."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        ask "Enter the server port (default 22): " server_port
                        server_port="${server_port:-22}"
                        if ! is_number "$server_port"; then
                            echo "Port must be a number."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        ask "Enter the SSH username: " server_username
                        if [ -z "${server_username:-}" ]; then
                            echo "Username cannot be empty."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        echo "$server_name - $server_ip:$server_port - $server_username" >> "$SERVERS_SSH"
                        echo "SSH Server '$server_name' added successfully."
                        ;;
                    wol)
                        ask "Enter the server MAC address: " server_mac
                        if [ -z "${server_mac:-}" ]; then
                            echo "MAC address cannot be empty."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        ask "Enter the server IP address: " server_ip
                        if [ -z "${server_ip:-}" ]; then
                            echo "IP address cannot be empty."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        ask "Enter the server hostname: " server_hostname
                        if [ -z "${server_hostname:-}" ]; then
                            echo "Hostname cannot be empty."; sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"; pause; continue
                        fi
                        echo "$server_name - $server_mac - $server_ip - $server_hostname" >> "$SERVERS_WOL"
                        echo "WOL Server '$server_name' added successfully."
                        ;;
                    *)
                        echo "Invalid server type. Please enter 'ssh' or 'wol'."
                        sed -i "/^$(escape_sed_re "$server_name")$/d" "$SERVERS_ALL"
                        ;;
                esac
                pause
                ;;
            2)
                echo -e "List of current servers:"
                if [ ! -s "$SERVERS_ALL" ]; then echo "No servers found."; pause; continue; fi
                nl -ba "$SERVERS_ALL"; echo
                read -r -p "Enter the number of the server to remove: " server_num
                if ! is_number "$server_num"; then echo "Invalid number."; pause; continue; fi
                total=$(line_count "$SERVERS_ALL")
                if (( server_num < 1 || server_num > total )); then echo "Invalid server number."; pause; continue; fi

                server_name="$(sed -n "${server_num}p" "$SERVERS_ALL")"
                sed -i "${server_num}d" "$SERVERS_ALL"

                esc_name="$(escape_sed_re "$server_name")"
                if [ -s "$SERVERS_SSH" ]; then
                    if safe_grep_q "$server_name" "$SERVERS_SSH"; then
                        sed -i "/^${esc_name} - /d" "$SERVERS_SSH"
                        echo "Removed from SSH servers list."
                    fi
                fi
                if [ -s "$SERVERS_WOL" ]; then
                    if safe_grep_q "$server_name" "$SERVERS_WOL"; then
                        sed -i "/^${esc_name} - /d" "$SERVERS_WOL"
                        echo "Removed from WOL servers list."
                    fi
                fi
                echo "Server '$server_name' removed successfully."
                pause
                ;;
            3)
                display_welcome
                echo -e "${ORANGE}╔════════════════════════════════════════════════════╗${RESET}"
                echo -e "${ORANGE}║${RESET}                ${BOLD}Current Servers List${RESET}                ${ORANGE}║${RESET}"
                echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
                echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}ALL Servers:${RESET}"
                if [ -s "$SERVERS_ALL" ]; then while IFS= read -r line; do echo -e "${ORANGE}║${RESET} $line"; done < "$SERVERS_ALL"; else echo -e "${ORANGE}║${RESET} No servers found."; fi
                echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
                echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}SSH Servers:${RESET}"
                if [ -s "$SERVERS_SSH" ]; then while IFS= read -r line; do echo -e "${ORANGE}║${RESET} $line"; done < "$SERVERS_SSH"; else echo -e "${ORANGE}║${RESET} No SSH servers found."; fi
                echo -e "${ORANGE}╠════════════════════════════════════════════════════╣${RESET}"
                echo -e "${ORANGE}║${RESET} ${DARK_ORANGE}WOL Servers:${RESET}"
                if [ -s "$SERVERS_WOL" ]; then while IFS= read -r line; do echo -e "${ORANGE}║${RESET} $line"; done < "$SERVERS_WOL"; else echo -e "${ORANGE}║${RESET} No WOL servers found."; fi
                echo -e "${ORANGE}╚════════════════════════════════════════════════════╝${RESET}\n"
                pause
                ;;
            4) return ;;
            *) echo "Invalid option."; pause ;;
        esac
    done
}

ssh_connect() {
    if [ -z "${SELECTED_LINE:-}" ]; then echo "No server selected."; pause; return; fi
    # Format: "server_name - ip:port - username"
    server_name="$(awk -F ' - ' '{print $1}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"
    connection_info="$(awk -F ' - ' '{print $2}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"
    server_username="$(awk -F ' - ' '{print $3}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"
    server_ip="${connection_info%%:*}"
    server_port="${connection_info##*:}"
    [[ "$server_port" == "$connection_info" ]] && server_port=22

    echo "Connecting to $server_name ($server_ip) on port $server_port as $server_username..."
    ssh -p "$server_port" "$server_username@$server_ip" || true
    echo "SSH session ended."
    pause
}

wol_wake() {
    if [ -z "${SELECTED_LINE:-}" ]; then echo "No server selected."; pause; return; fi
    # Format: "server_name - MAC - ip - hostname"
    server_name="$(awk -F ' - ' '{print $1}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"
    server_mac="$(awk -F ' - ' '{print $2}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"
    server_ip="$(awk -F ' - ' '{print $3}' <<<"$SELECTED_LINE" | sed 's/^ *//;s/ *$//')"

    echo "Waking up $server_name with MAC address $server_mac..."
    if command -v wakeonlan >/dev/null 2>&1; then
        wakeonlan "$server_mac"
        echo "Wake-on-LAN packet sent to $server_name ($server_ip)."
    else
        echo "wakeonlan not found. Install: sudo apt-get install wakeonlan"
    fi
    pause
}

main() {
    ensure_writable
    init_files
    while true; do
        display_menu
        echo
        read -r -p "Enter your choice: " choice
        case "$choice" in
            1) SELECTED_LINE=""; display_ssh_menu; [ -n "${SELECTED_LINE:-}" ] && ssh_connect ;;
            2) SELECTED_LINE=""; display_wol_menu; [ -n "${SELECTED_LINE:-}" ] && wol_wake ;;
            3) server_list_menu ;;
            4) echo "Thank you for using the Home Server Management System!"; exit 0 ;;
            *) echo "Invalid option."; pause ;;
        esac
    done
}

main "$@"
