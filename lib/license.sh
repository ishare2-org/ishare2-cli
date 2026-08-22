# Function to update iptables and add them to startup script
block_cisco() {
    # Remove entries containing "cisco xml" from /etc/hosts
    sed -i '/cisco xml/d' /etc/hosts || {
        print_error "Failed to remove entries containing 'cisco xml' from /etc/hosts"
        logger error "Failed to remove entries containing 'cisco xml' from /etc/hosts"
        exit 1
    }

    # Add the iptables rule to block cisco xml requests to ovfstartup
    echo 'iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|xml|05|cisco|03|com" --algo bm -j DROP' >>/opt/ovf/ovfstartup || {
        print_error "Failed to add iptables rule to block cisco xml requests"
        logger error "Failed to add iptables rule to block cisco xml requests"
        exit 1
    }

    # Restart the ovfstartup service
    service ovfstartup restart || {
        print_error "Failed to restart ovfstartup service"
        logger error "Failed to restart ovfstartup service"
        exit 1
    }

    # If no errors occurred, show success message
    echo "${GREEN}[+] Successfully updated iptables and added them to the ovfstartup script${NO_COLOR}"
}

# Function to generate a new iourc license
generate_iourc_license() {
    BIN_PATH="/opt/unetlab/addons/iol/bin/"

    PYTHON_FILE=$BIN_PATH"CiscoIOUKeygen.py"
    PERL_FILE=$BIN_PATH"keepalive.pl"

    # Check if python2 is installed
    if ! command -v python &>/dev/null; then
        print_error "Python is not installed"
        logger error "Python is not installed"
        # Ask the user if they want to install python
        read -p "[?] Do you want to install python? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_package python
        else
            print_error "Python2 is required to generate the iourc license"
            exit 1
        fi
    fi

    # Block cisco xml requests
    block_cisco || {
        echo "${RED}[-] Failed to block cisco xml requests${NO_COLOR}"
        logger error "Failed to block cisco xml requests"
        exit 1
    }

    # Check if the CiscoIOUKeygen.py file exists in the bin directory
    if ! [[ -e $PYTHON_FILE ]]; then
        wget -O $PYTHON_FILE "$URL_CISCOIOUKEYGEN_PY" -q || {
            print_error "Error downloading CiscoIOUKeygen.py file"
            logger error "Error downloading CiscoIOUKeygen.py file"
            exit 1
        }
    fi

    print_warn "Executing CiscoIOUKeygen.py file... "
    python $PYTHON_FILE
    if [[ $? -ne 0 ]]; then
        print_error "Error running CiscoIOUKeygen.py file. "
        print_error "Please check your internet connection and try again. "
        exit 1
    fi

    if ! [[ -e $PERL_FILE ]]; then
        wget -O $PERL_FILE "$URL_KEEPALIVE_PL" -q
        if [[ $? -ne 0 ]]; then
            print_error "Error downloading keepalive.pl file. "
            print_error "Please check your internet connection and try again. "
            exit 1
        fi
    fi
    print_success "IOL license was generated successfully. "
}
