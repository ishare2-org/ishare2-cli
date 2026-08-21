# Function to fix permissions of the downloaded images
fix_permissions() {
    UNL_WRAPPER="/opt/unetlab/wrappers/unl_wrapper"
    if [[ -e $UNL_WRAPPER ]]; then
        echo -e "${YELLOW}[-] Fixing permissions... ${NO_COLOR}"
        chmod +x $UNL_WRAPPER
        $UNL_WRAPPER -a fixpermissions

        if [ $? -ne 0 ]; then
            echo -e "\n${RED}[-] Failed to fix permissions ${NO_COLOR}"
            exit 1
        fi

        echo -e "\n${GREEN}[+] Fix permissions command has been executed correctly ${NO_COLOR}"
        return
    fi

    # unl_wrapper not present: fix permissions manually
    logger info "unl_wrapper not found. Fixing permissions manually."
    if chmod 755 -R /opt/unetlab/addons; then
        echo -e "${GREEN}[✓] Permissions fixed manually. ${NO_COLOR}"
    else
        echo -e "${RED}[-] Failed to fix permissions manually. ${NO_COLOR}"
    fi
}

# Function to run Internet connection tests
connection_tests() {
    # Define an associative array with service names and their respective IP addresses or domains
    declare -A SERVICES=(
        ["GitHub"]="github.com"
        ["GitHub Raw Files"]="raw.githubusercontent.com"
        ["LabHub (Onedrive backend)"]="labhub.eu.org"
        ["LabHub (Google Drive backend)"]="drive.labhub.eu.org"
        ["Google DNS"]="8.8.8.8"
    )

    # Initialize a flag to track if all services are reachable
    local all_services_reachable=true

    # Header
    echo -e "${YELLOW}[-] Running connection tests... ${NO_COLOR}"

    # Loop through the services and check their reachability
    for service in "${!SERVICES[@]}"; do
        echo -e "${YELLOW}[-] Checking if $service is reachable... ${NO_COLOR}"
        if ping -q -c 5 -W 5 "${SERVICES[$service]}" >/dev/null; then
            echo -e "${GREEN}[+] $service is reachable. ${NO_COLOR}"
        else
            echo -e "${RED}[-] $service is not reachable. ${NO_COLOR}"
            all_services_reachable=false
        fi
    done

    # If any service is not reachable, attempt to fix DNS
    if [ "$all_services_reachable" = false ]; then
        echo -e "${YELLOW}[?] Some services are not reachable. Do you want to attempt to fix DNS? [y/n] ${NO_COLOR}"
        read -r -n 1 -p "Choice: " choice
        echo
        case $choice in
        y | Y)
            fix_dns
            ;;
        n | N)
            echo -e "${YELLOW}[-] DNS was not fixed. ${NO_COLOR}"
            ;;
        *)
            echo -e "${RED}[-] Invalid choice. DNS was not fixed. ${NO_COLOR}"
            ;;
        esac
    fi

    # Report the overall status
    if [ "$all_services_reachable" = true ]; then
        echo -e "${GREEN}[+] All services are reachable. ${NO_COLOR}"
        return 0
    else
        echo -e "${RED}[-] Some services are not reachable. ${NO_COLOR}"
        return 1
    fi
}

# Function to fix DNS (common issue with resolv.conf)
fix_dns() {
    echo -e "${YELLOW}[-] Attempting to fix DNS... ${NO_COLOR}"
    echo -e "${YELLOW}[-] Running: systemctl restart systemd-resolved.service ${NO_COLOR}"
    systemctl restart systemd-resolved.service
    echo -e "${YELLOW}[-] Attempting to fix DNS by setting nameserver to 8.8.8.8... ${NO_COLOR}"
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] DNS fix applied successfully. ${NO_COLOR}"
    else
        echo -e "${RED}[-] Failed to update DNS settings. ${NO_COLOR}"
    fi
}
