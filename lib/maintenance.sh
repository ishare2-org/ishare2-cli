# Function to fix permissions of the downloaded images
fix_permissions() {
    UNL_WRAPPER="/opt/unetlab/wrappers/unl_wrapper"
    if [[ -e $UNL_WRAPPER ]]; then
        print_info "Fixing permissions... "
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
        print_ok "Permissions fixed manually. "
    else
        print_error "Failed to fix permissions manually. "
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
    print_info "Running connection tests... "

    # Loop through the services and check their reachability
    for service in "${!SERVICES[@]}"; do
        print_info "Checking if $service is reachable... "
        if ping -q -c 5 -W 5 "${SERVICES[$service]}" >/dev/null; then
            print_success "$service is reachable. "
        else
            print_error "$service is not reachable. "
            all_services_reachable=false
        fi
    done

    # If any service is not reachable, attempt to fix DNS
    if [ "$all_services_reachable" = false ]; then
        print_question "Some services are not reachable. Do you want to attempt to fix DNS? [y/n] "
        read -r -n 1 -p "Choice: " choice
        echo
        case $choice in
        y | Y)
            fix_dns
            ;;
        n | N)
            print_info "DNS was not fixed. "
            ;;
        *)
            print_error "Invalid choice. DNS was not fixed. "
            ;;
        esac
    fi

    # Report the overall status
    if [ "$all_services_reachable" = true ]; then
        print_success "All services are reachable. "
        return 0
    else
        print_error "Some services are not reachable. "
        return 1
    fi
}

# Function to fix DNS (common issue with resolv.conf)
fix_dns() {
    print_info "Attempting to fix DNS... "

    if command -v systemctl >/dev/null 2>&1; then
        print_info "Running: systemctl restart systemd-resolved.service "
        systemctl restart systemd-resolved.service 2>/dev/null
    fi

    print_info "Attempting to fix DNS by setting nameserver to 8.8.8.8... "
    if echo "nameserver 8.8.8.8" >/etc/resolv.conf 2>/dev/null; then
        print_success "DNS fix applied successfully. "
    elif echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null 2>&1; then
        print_success "DNS fix applied successfully. "
    else
        print_error "Failed to update DNS settings. "
    fi
}
