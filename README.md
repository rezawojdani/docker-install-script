# Docker Installation Script

     A Bash script for managing Docker on Ubuntu servers.

     ## Features
     - Update server packages (`apt update && apt upgrade`) on Ubuntu systems only.
     - Configure network with Shecan DNS (185.51.200.2, 178.22.122.100) and disable IPv6 temporarily.
     - Install Docker and Docker Compose.
     - Remove Docker and all associated data with user confirmation.
     - Reboot server with user confirmation.
     
     ## Usage
     1. Download the script:
     
        wget https://raw.githubusercontent.com/Rezawojdani/docker-install-script/main/docker_install.sh
       
     2. Make it executable:
        
        chmod +x docker_install.sh
     
     3. Run with sudo or as root:
      
        ./docker_install.sh
     
     ## Requirements
     - Ubuntu-based system
     - Root privileges (via `sudo` or root user)

     ## Notes
     - The script checks if the system is Ubuntu before performing updates, network configuration, or Docker installation.
     - The network configuration option modifies `/etc/resolv.conf` to use Shecan DNS, comments out existing nameservers (e.g., 127.0.0.53), and prevents duplicate DNS entries. A backup is created at `/etc/resolv.conf.bak`.
     - Docker removal deletes all containers, images, and volumes. Use with caution.
     - IPv6 is disabled temporarily during network configuration.
     - Press Ctrl+C to exit the script cleanly.

     ## License
     This project is licensed under the MIT License - see the [LICENSE] file for details.
    
