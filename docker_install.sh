#!/bin/bash

# Docker Installation Script by Rezawojdani

# Trap Ctrl+C to exit cleanly
trap 'echo -e "\nExiting..."; exit 0' INT

# Function to check if user has root privileges
check_root() {
    if ! sudo -n true 2>/dev/null; then
        echo "Error: This script requires root privileges."
        echo "Please run with 'sudo ./docker_install.sh' or as the root user (e.g., 'sudo -i')."
        exit 1
    fi
}

# Function to check if the system is Ubuntu
check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "Error: This script only supports Ubuntu systems."
            exit 1
        fi
    else
        echo "Error: Cannot determine the operating system. This script only supports Ubuntu."
        exit 1
    fi
}

# Function to display the menu
display_menu() {
    clear
    echo "====================================="
    echo " Docker Management Script"
    echo " Created by: Rezawojdani"
    echo "====================================="
    echo "1. Update Server"
    echo "2. Configure Network (Shecan DNS + Disable IPv6)"
    echo "3. Install Docker and Docker Compose"
    echo "4. Remove Docker"
    echo "5. Reboot Server"
    echo "6. Exit"
    echo "====================================="
    echo -n "Please select an option [1-6]: "
}

# Function to update server
update_server() {
    check_ubuntu
    echo "Updating server..."
    sudo apt update && sudo apt upgrade -y
    echo "Server update completed."
    read -r -p "Press Enter to continue..." < /dev/tty
}

# Function to configure Shecan DNS
configure_dns() {
    echo "Configuring Shecan DNS..."
    # Backup resolv.conf
    sudo cp /etc/resolv.conf /etc/resolv.conf.bak
    # Create temporary file to build new resolv.conf
    tmpfile=$(mktemp)
    # Filter out Shecan DNS entries, comment out other nameservers, keep other lines
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^nameserver (185.51.200.2|178.22.122.100)$" || echo "$line" | grep -qE "^#nameserver (185.51.200.2|178.22.122.100)$"; then
            continue
        elif echo "$line" | grep -q "^nameserver"; then
            echo "#$line"
        else
            echo "$line"
        fi
    done < /etc/resolv.conf > "$tmpfile"
    # Add Shecan DNS
    echo "nameserver 185.51.200.2" >> "$tmpfile"
    echo "nameserver 178.22.122.100" >> "$tmpfile"
    # Replace resolv.conf with new content
    sudo mv "$tmpfile" /etc/resolv.conf
    sudo chmod 644 /etc/resolv.conf
    echo "Shecan DNS (185.51.200.2, 178.22.122.100) configured."
    # Verify DNS configuration
    if grep -q "nameserver 185.51.200.2" /etc/resolv.conf && grep -q "nameserver 178.22.122.100" /etc/resolv.conf && grep -q "#nameserver 127.0.0.53" /etc/resolv.conf; then
        echo "DNS configuration verified."
    else
        echo "Error: DNS configuration failed."
        exit 1
    fi
}

# Function to disable IPv6 temporarily
disable_ipv6() {
    echo "Disabling IPv6 temporarily..."
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
    echo "IPv6 disabled."
}

# Function to configure network (DNS + IPv6)
configure_network() {
    check_ubuntu
    configure_dns
    disable_ipv6
    echo "Network configuration completed."
    read -r -p "Press Enter to continue..." < /dev/tty
}

# Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
        read -r -p "Press Enter to continue..." < /dev/tty
        return 1
    fi
    return 0
}

# Function to install Docker
install_docker() {
    check_ubuntu
    if check_docker; then
        echo "Installing Docker and Docker Compose..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo "Docker and Docker Compose installed successfully."
    fi
    read -r -p "Press Enter to continue..." < /dev/tty
}

# Function to remove Docker
remove_docker() {
    echo "WARNING: This will completely remove Docker and all its data."
    echo "This includes all containers, images, and volumes."
    read -r -p "Are you sure you want to proceed? (y/N): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Removing Docker..."
        sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        sudo rm /etc/apt/sources.list.d/docker.list
        sudo rm /etc/apt/keyrings/docker.asc
        echo "Docker removed successfully."
    else
        echo "Docker removal cancelled."
    fi
    read -r -p "Press Enter to continue..." < /dev/tty
}

# Function to reboot server
reboot_server() {
    echo "WARNING: This will reboot the server immediately."
    read -r -p "Are you sure you want to proceed? (y/N): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Rebooting server..."
        sudo reboot
    else
        echo "Server reboot cancelled."
    fi
    read -r -p "Press Enter to continue..." < /dev/tty
}

# Main script
check_root

while true; do
    display_menu
    read -r choice < /dev/tty
    case $choice in
        1)
            update_server
            ;;
        2)
            configure_network
            ;;
        3)
            install_docker
            ;;
        4)
            remove_docker
            ;;
        5)
            reboot_server
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1, 2, 3, 4, 5, or 6."
            read -r -p "Press Enter to continue..." < /dev/tty
            ;;
    esac
done
