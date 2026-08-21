# Function to check if PNetLab is installed
is_pnetlab_installed() {
    # Check if pnetlab is installed
    data=$(mysql -uroot -ppnetlab -D pnetlab_db -e "SELECT control_value FROM control WHERE control_value>1;" 2>/dev/null)
    data_array=("$data")
    pnetlab_version=${data_array[1]}
    if [[ -z $pnetlab_version ]]; then
        echo -e "${YELLOW}[!] WARN: PNetLab was not found.${NO_COLOR}"
        echo -e "${YELLOW}[!]${NO_COLOR} This script has only been tested on PNetLab. If you are not using PNetLab, you may encounter issues."
        logger warn "PNetLab is not installed."
        return 1
    fi
    return 0
}

# Function to initialize the ishare2 directory checks
check_ishare2_dir() {
    # check if ishare2 directory exists otherwise create it
    if [[ ! -d $ISHARE2_DIR ]]; then
        create_ishare2_dir
    fi
}

# Set max log file lines to 1000
set_max_log_lines() {
    if [[ -f $LOG_FILE ]]; then
        if [[ $(wc -l <"$LOG_FILE") -gt 1000 ]]; then
            tail -n 1000 $LOG_FILE >$ISHARE2_DIR/tmp.txt
            mv $ISHARE2_DIR/tmp.txt $LOG_FILE
        fi
    fi
}
create_default_conf() {
    install_dependencies
    # If the --init argument is passed, display a message to the user
    messages=(
        "The default configuration will be used. Feel free to modify it later"
        "by running: ishare2 config"
        "Press Enter to continue."
    )
    print_box "${messages[@]}"
    read -n 1

    # Write the default configuration to the configuration file
    echo "USE_ARIA2C=false" >$ISHARE2_CONF_FILE
    echo "SSL_CHECK=true" >>$ISHARE2_CONF_FILE
    echo "CHANNEL=$CHANNEL" >>$ISHARE2_CONF_FILE
    echo "ROTATE=true" >>$ISHARE2_CONF_FILE
    echo "JSON_URL=${MIRRORS[0]}" >>$ISHARE2_CONF_FILE

    # Display values used
    messages=(
        "Configuration values:"
        "USE_ARIA2C: false"
        "SSL_CHECK: true"
        "CHANNEL: $CHANNEL"
        "ROTATE: true"
    )
    print_box "${messages[@]}"
}

# Function to check if the configuration file exists, and validate it
check_config() {
    # get first argument
    local first_arg=$1
    if [[ $first_arg == "--init" ]]; then
        # check if ishare2 directory exists otherwise create it
        check_ishare2_dir
        # create default configuration
        create_default_conf
        return
    fi

    # check if config file exists
    if [[ ! -f $ISHARE2_CONF_FILE ]]; then
        create_config
    fi
    # check if config file is empty
    if [[ ! -s $ISHARE2_CONF_FILE ]]; then
        echo -e "${RED}[!] Configuration file is empty. Please configure ishare2.${NO_COLOR}"
        create_config
    fi
    # check if config file is valid
    validate_conf_file
}

get_available_mirrors() {
    # Ensure we have the latest index file
    fetch_json || {
        logger error "Failed to fetch index while getting mirrors"
        return 1
    }

    # Extract mirror names from the JSON structure
    local mirrors=()
    while IFS= read -r mirror_name; do
        mirrors+=("$mirror_name")
    done < <(jq -r '.url_properties.hostnames | keys[]' "$TEMP_JSON" 2>/dev/null)

    # Return default mirrors if none found
    if [ ${#mirrors[@]} -eq 0 ]; then
        logger error "No mirrors found in index."
        exit 1
    else
        echo "${mirrors[@]}"
    fi
}

# Function to create the configuration file
create_config() {
    clear
    messages=(
        "Welcome to ishare2!"
        "This script will guide you through the initial configuration process."
        "First, let's ensure all required dependencies are installed."
    )
    print_box "${messages[@]}"
    sleep 3

    is_pnetlab_installed

    if [[ -z $pnetlab_version ]]; then
        logger warn "PNetLab is not installed."
    else
        echo -e "${GREEN}[✓] Detected PNetLab version: $pnetlab_version${NO_COLOR}"
        fix_repositories
        check_pnetlab_sources
    fi

    echo -e "${BLUE}[i] Installing iShare2 dependencies...${NO_COLOR}"
    MAX_RETRIES=3
    retry_counter=0

    while [[ $retry_counter -lt $MAX_RETRIES ]]; do
        if install_dependencies; then
            break
        fi
        echo -e "${RED}[✗] Dependency installation failed. Retrying... (${retry_counter}/${MAX_RETRIES})${NO_COLOR}"
        logger error "Failed to install dependencies. Retrying..."
        retry_counter=$((retry_counter + 1))
        sleep 5
    done

    if [[ $retry_counter -eq $MAX_RETRIES ]]; then
        MAX_RETRIES=3
        retry_counter=0
        while [[ $retry_counter -lt $MAX_RETRIES ]]; do
            if check_pnetlab_sources; then
                break
            fi
            echo -e "${RED}[✗] Could not update PNetLab sources. Retrying... (${retry_counter}/${MAX_RETRIES})${NO_COLOR}"
            logger error "Failed to replace PNetLab sources. Retrying..."
            retry_counter=$((retry_counter + 1))
            sleep 5
        done
    fi

    logger info "Launching configuration wizard..."
    clear
    messages=(
        "ishare2 Configuration Wizard"
        "- This wizard will guide you through essential setup steps."
        "- Press Enter to accept default values when applicable."
        "- To reconfigure later, run: ishare2 config"
        "- Press Ctrl+C at any time to cancel."
    )
    print_box "${messages[@]}"
    sleep 3

    echo -e "${YELLOW}[?] Enable aria2c for accelerated downloads? (default: no)${NO_COLOR}"
    read -p "[y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[!] aria2c can improve download speeds, but may cause issues for some users."
        echo "To disable later, run: ishare2 config and answer no to this question.${NO_COLOR}"
        echo "USE_ARIA2C=true" >"$ISHARE2_CONF_FILE"
        install_package "aria2"
        read -n 1
    else
        echo "USE_ARIA2C=false" >"$ISHARE2_CONF_FILE"
    fi

    echo -e "${YELLOW}[?] Perform SSL certificate validation for downloads? (default: yes)${NO_COLOR}"
    read -p "[y/N]: " -r
    case $REPLY in
    [Nn]) SSL_CHECK=false ;;
    *) SSL_CHECK=true ;;
    esac
    echo "SSL_CHECK=\"$SSL_CHECK\"" >>"$ISHARE2_CONF_FILE"

    echo -e "${YELLOW}[?] Select update channel (branch).${NO_COLOR}"
    mapfile -t branches < <(curl -sL https://api.github.com/repos/ishare2-org/ishare2-cli/branches | jq -r '.[].name')
    for ((i = 0; i < ${#branches[@]}; i++)); do
        echo " $((i + 1))) ${branches[i]}"
    done

    local current_channel=$CHANNEL
    read -p "[*] Enter the number of the desired branch (default: $CHANNEL): " -r

    if [[ -z $REPLY ]]; then
        echo -e "${YELLOW}[i] Default branch selected: $CHANNEL${NO_COLOR}"
    elif ! [[ $REPLY =~ ^[0-9]+$ ]] || ((REPLY < 1 || REPLY > ${#branches[@]})); then
        echo -e "${RED}[✗] Invalid input. Falling back to default branch: $CHANNEL${NO_COLOR}"
    else
        CHANNEL=${branches[REPLY - 1]}
        echo -e "${GREEN}[✓] Branch selected: $CHANNEL${NO_COLOR}"
        echo -e "${BLUE}[i] Running 'ishare2 upgrade' to switch to this branch.${NO_COLOR}"
    fi
    echo "CHANNEL=\"$CHANNEL\"" >>"$ISHARE2_CONF_FILE"

    local available_mirrors=($(get_available_mirrors))
    [[ ${#available_mirrors[@]} -eq 0 ]] && available_mirrors=("drive" "main")

    declare -A mirror_descriptions=(
        ["drive"]="Google Drive mirror"
        ["main"]="OneDrive mirror"
        ["backup"]="Backup server"
        ["cdn"]="Content Delivery Network"
    )

    echo -e "\n${YELLOW}[!] Mirror Selection${NO_COLOR}"
    echo "iShare2 can download files from multiple mirror sources."
    echo
    echo " 1) Automatically rotate mirrors for reliability"

    local counter=2
    declare -A mirror_options
    for mirror in "${available_mirrors[@]}"; do
        local desc="${mirror_descriptions[$mirror]:-$mirror mirror}"
        echo " $counter) Always use: $desc"
        mirror_options[$counter]=$mirror
        ((counter++))
    done

    echo
    read -p "[?] Enter your choice (default: 1): " -r choice
    choice=${choice:-1}

    case $choice in
    1)
        echo -e "${GREEN}[✓] Mirror rotation enabled (${#available_mirrors[@]} sources).${NO_COLOR}"
        echo "ROTATE=true" >>"$ISHARE2_CONF_FILE"
        ;;
    *)
        if [[ -n "${mirror_options[$choice]}" ]]; then
            local selected_mirror="${mirror_options[$choice]}"
            local selected_desc="${mirror_descriptions[$selected_mirror]:-$selected_mirror mirror}"
            echo -e "${GREEN}[✓] Mirror locked to: $selected_desc${NO_COLOR}"
            echo "ROTATE=false" >>"$ISHARE2_CONF_FILE"
            echo "MIRROR=\"$selected_mirror\"" >>"$ISHARE2_CONF_FILE"
        else
            echo -e "${RED}[✗] Invalid choice. Mirror rotation will be used.${NO_COLOR}"
            echo "ROTATE=true" >>"$ISHARE2_CONF_FILE"
        fi
        ;;
    esac

    echo >>"$ISHARE2_CONF_FILE"

    if [[ ! -f "$ISHARE2_CONF_FILE" ]]; then
        echo -e "${RED}[✗] Failed to create configuration file.${NO_COLOR}"
        logger error "Configuration file creation failed."
        exit 1
    fi

    remove_duplicates
    validate_conf_file

    messages=(
        "Configuration completed successfully."
        "You can now start using ishare2."
        "[!] IMPORTANT:"
        "- ishare2 is a free, open-source tool. If someone charged you for it, you've been scammed."
        "- Avoid unofficial sources. They may contain malicious code."
    )
    print_box "${messages[@]}"

    if [[ $current_channel != $CHANNEL ]]; then
        echo -e "${YELLOW}[i] Updating ishare2 to the selected '$CHANNEL' branch...${NO_COLOR}"
        curl -sL "https://raw.githubusercontent.com/ishare2-org/ishare2-cli/$CHANNEL/ishare2" >/usr/sbin/ishare2
        chmod +x /usr/sbin/ishare2
        echo -e "${GREEN}[✓] iShare2 has been updated to the latest version from the '$CHANNEL' branch.${NO_COLOR}"
    fi
}

# Function to remove duplicate lines from the configuration file
remove_duplicates() {
    local config_file="$ISHARE2_CONF_FILE"

    # Check if the configuration file exists
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}[!] Configuration file does not exist.${NO_COLOR}"
        logger error "Configuration file does not exist."
        return
    fi

    # Remove duplicate lines from the configuration file
    awk '!seen[$0]++' "$config_file" >"$config_file.tmp" && mv "$config_file.tmp" "$config_file"

    logger info "Removed duplicate lines from the configuration file."
}

# Function to validate the configuration file
validate_conf_file() {

    # Check if the configuration file exists
    if [ ! -f "$ISHARE2_CONF_FILE" ]; then
        echo -e "${RED}[!] Configuration file does not exist.${NO_COLOR}"
        logger error "Configuration file does not exist."
        return 1
    fi

    # Array of allowed variables
    local allowed_vars=("USE_ARIA2C" "CHANNEL" "SSL_CHECK" "ROTATE" "MOTD")

    # Read the configuration file line by line and filter out invalid variables
    local filtered_content=""
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" == \#* ]]; then
            continue
        fi

        # Extract variable name by trimming leading and trailing whitespaces
        local var_name="$(echo "$line" | awk -F '=' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')"

        # Check if the variable is allowed
        is_allowed=false
        for allowed_var in "${allowed_vars[@]}"; do
            if [[ "$allowed_var" == "$var_name" ]]; then
                is_allowed=true
                break
            fi
        done

        if $is_allowed || [[ "$line" != *=* ]]; then
            filtered_content+="$line"$'\n'
        else
            logger warn "Removed invalid variable \"$var_name\" from the configuration file."
        fi
    done <"$ISHARE2_CONF_FILE"

    # Write the filtered content back to the configuration file
    echo "$filtered_content" >"$ISHARE2_CONF_FILE"

    logger info "Validated the configuration file."
    # shellcheck source=/opt/ishare2/cli/ishare2.conf
    source "$ISHARE2_CONF_FILE"
    return 0
}

# Function to remove i-share.top apt sources.list
remove_ishare_sources() {
    # Remove i-share.top line from sources.list
    sed -i '/i-share.top/d' /etc/apt/sources.list
}

# Function to install dependencies required for ishare2
install_dependencies() {
    remove_ishare_sources
    echo -e "${YELLOW}[+] ishare2 needs to install some dependencies to work properly.${NO_COLOR}"
    local packages=("curl" "wget" "jq" "unrar" "tree" "unzip")
    echo -e "${YELLOW}[+] List of packages to be installed: ${NO_COLOR}"
    for package in "${packages[@]}"; do
        echo -e "${YELLOW} -${NO_COLOR} $package"
    done
    echo -e "${YELLOW}[+] Starting to install dependencies in 5 seconds... This may take a while. Press Ctrl+C to cancel.${NO_COLOR}"
    sleep 5

    for package in "${packages[@]}"; do
        install_package "$package"
    done
}

# Function to check if a package is installed and install it if it's not
check_installed() {
    PACKAGE=$1
    # Check if package is installed
    if ! command -v "$PACKAGE" &>/dev/null; then
        echo -e "${YELLOW}[!] WARN: $PACKAGE is not installed.${NO_COLOR}"
        install_package "$PACKAGE"
        # Check success of package installation
        if ! command -v "$PACKAGE" &>/dev/null; then
            echo -e "${RED}[-] Error: Failed to install $PACKAGE.${NO_COLOR}"
            logger error "Failed to install $PACKAGE."
            exit 1
        else # package is installed
            echo -e "${GREEN}[+] $PACKAGE has been installed successfully.${NO_COLOR}"
        fi
    fi
}

# Function to check if a site is accessible
is_site_accessible() {
    local url=$1
    if ! curl -s --head --request GET "$url" | grep "200 OK\|301 Moved Permanently" >/dev/null; then
        return 1 # Site is not accessible
    else
        return 0 # Site is accessible
    fi
}

# Function to check if the sources.list file is using the correct sources
fix_repositories() {
    # Immediately check for http://repo.pnetlab.com and replace it with https if found
    if grep -q "deb \[trusted=yes\] http://repo.pnetlab.com ./" /etc/apt/sources.list; then
        echo -e "${YELLOW}[+] Found http://repo.pnetlab.com in sources.list, replacing with https...${NO_COLOR}"
        sed -i 's|deb \[trusted=yes\] http://repo.pnetlab.com ./|deb [trusted=yes] https://repo.pnetlab.com ./|g' /etc/apt/sources.list
    fi

    # Check if https://repo.pnetlab.com is accessible
    if ! is_site_accessible "https://repo.pnetlab.com"; then
        echo -e "${YELLOW}[!] repo.pnetlab.com is not accessible.${NO_COLOR}"
        echo -e "${YELLOW}[!] Checking alternative...${NO_COLOR}"
        # The script previously modified any http to https if necessary, so just check for https existence now
        if grep -q "deb \[trusted=yes\] https://repo.pnetlab.com ./" /etc/apt/sources.list; then
            echo -e "${YELLOW}[!] Your sources.list is already using https for repo.pnetlab.com.${NO_COLOR}"
        fi
        # Check if https://pnetlab.labhub.eu.org is accessible
        if ! is_site_accessible "https://pnetlab.labhub.eu.org"; then
            echo -e "${RED}[-] Both repo.pnetlab.com and the alternative pnetlab.labhub.eu.org are inaccessible.${NO_COLOR}"
            echo -e "${YELLOW}[!] Please check your internet connection and try again.${NO_COLOR}"
            # Ask the user if they want to continue anyway
            echo -e "${YELLOW}[?] Do you want to continue anyway?${NO_COLOR}"
            read -p "[?] (y/n): " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        # Ask the user if they want to replace the sources
        echo -e "${YELLOW}[!] The official pnetlab.com repository is not accessible.${NO_COLOR}"
        echo -e "${YELLOW}[?] Do you want to replace the pnetlab sources with the LabHub mirror?${NO_COLOR}"
        read -p "[?] (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Comment out "deb [trusted=yes] https://repo.pnetlab.com ./" and add "deb [trusted=yes] https://pnetlab.labhub.eu.org ./"
            echo -e "${YELLOW}[+] Replacing pnetlab sources with labhub mirror...${NO_COLOR}"
            sed -i 's|deb \[trusted=yes\] https://repo.pnetlab.com ./|#deb \[trusted=yes\] https://repo.pnetlab.com ./|g' /etc/apt/sources.list
            echo "deb [trusted=yes] https://pnetlab.labhub.eu.org ./" >>/etc/apt/sources.list
        fi
    else
        echo -e "${GREEN}[+] repo.pnetlab.com is accessible.${NO_COLOR}"
        # No further action needed if the site is accessible, assuming the earlier check already ensured https is used
    fi
}

# Function to run apt-get update
apt_get_update() {
    echo -e "${YELLOW}[+] Updating package lists...${NO_COLOR}"
    if ! apt-get update -y -qq; then
        return 1
    fi
}

# Function to install a package
install_package() {
    local package_name=$1
    # check if $package_name is installed otherwise install it
    if ! command -v "$package_name" &>/dev/null; then
        echo -e "${YELLOW}[+] $package_name is not installed.${NO_COLOR}"
        if ! apt_get_update; then
            echo -e "${RED}[-] Failed to update package lists.${NO_COLOR}"
            echo -e "${YELLOW}[!] Please check your internet connection and try again or fix your repositories.${NO_COLOR}"
            logger error "Failed to update package lists."
        fi

        echo -e "${YELLOW}[+] Installing $package_name...${NO_COLOR}"
        if ! apt-get install -qq -y "$package_name"; then
            echo -e "${RED}[-] Failed to install $package_name. Please install it manually or you will likely encounter issues in the future.${NO_COLOR}"
            echo -e "${YELLOW}[!] Run: apt-get install -y $package_name${NO_COLOR}"
            logger error "Failed to install $package_name."
            exit 1
        fi
    else
        echo -e "${GREEN}[+] $package_name is already installed.${NO_COLOR}"
        logger info "Package $package_name is already installed."
        logger info "Updating $package_name..."
        if ! apt-get install --only-upgrade -qq "$package_name"; then
            logger error "Failed to update $package_name."
            exit 1
        fi
    fi
}

# Function to check if APT or dpkg is running and unlock dpkg
unlock_dpkg() {
    # Check if APT or dpkg is running
    if pgrep -f '^[/]usr[/]bin[/](apt|dpkg)' >/dev/null 2>&1; then
        echo "APT or dpkg seems to be running in the background."
        echo -e "${YELLOW}[?] Do you want to unlock dpkg?${NO_COLOR}"

        # Confirm with the user
        echo -e "${YELLOW}[!] Warning: Unlocking dpkg while APT or dpkg processes are active can lead to a broken system.${NO_COLOR}"
        echo "Proceed with caution. It's recommended to try this only if you're sure that no APT or dpkg processes are running."
        echo "Proceed? (y/n)"
        read -r answer

        if [[ $answer != "y" && $answer != "Y" ]]; then
            echo "Operation cancelled by the user."
        fi

        # Attempt to remove lock files
        echo "Attempting to remove lock files..."
        local lock_files=(
            "/var/lib/dpkg/lock"
            "/var/cache/apt/archives/lock"
            "/var/lib/apt/lists/lock"
            "/var/lib/dpkg/lock-frontend"
        )

        for file in "${lock_files[@]}"; do
            if [ -f "$file" ]; then
                sudo rm "$file" >/dev/null 2>&1
                echo "Removed $file"
            else
                echo "$file does not exist or has already been removed."
            fi
        done

        # Attempt to reconfigure dpkg
        echo "Reconfiguring dpkg..."
        sudo dpkg --configure -a

        echo "Operation completed. Please try running your APT or dpkg command again."
    fi
}

# Function to create the ishare2 directory
create_ishare2_dir() {
    echo -e "${YELLOW}[!] Creating ishare2 directory...${NO_COLOR}"
    if ! mkdir -p $ISHARE2_DIR 2>/dev/null; then
        error_message=$(mkdir -p $ISHARE2_DIR 2>&1 >/dev/null)
        if [[ $error_message == *"Permission denied"* ]]; then
            echo -e "${RED}[-] Failed to create ishare2 directory: Permission denied.${NO_COLOR}"
        else
            echo -e "${RED}[-] Failed to create ishare2 directory. Error: $error_message${NO_COLOR}"
        fi
        exit 1
    fi
    logger info "ishare2 directory created successfully."
}

