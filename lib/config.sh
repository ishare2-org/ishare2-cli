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
    echo "AUTO_FIX_PERMISSIONS=false" >>$ISHARE2_CONF_FILE
    mkdir -p "$ISHARE2_CONF_DIR"

    # Display values used
    messages=(
        "Configuration values:"
        "USE_ARIA2C: false"
        "SSL_CHECK: true"
        "CHANNEL: $CHANNEL"
        "ROTATE: true"
        "AUTO_FIX_PERMISSIONS: false"
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
        return 1
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
        install_package "aria2" "aria2c"
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

    echo -e "${YELLOW}[?] Automatically fix image permissions after downloading? (default: no)${NO_COLOR}"
    echo -e "${YELLOW}[!] When disabled, you can still run: ishare2 fix permissions${NO_COLOR}"
    read -p "[y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "AUTO_FIX_PERMISSIONS=true" >>"$ISHARE2_CONF_FILE"
    else
        echo "AUTO_FIX_PERMISSIONS=false" >>"$ISHARE2_CONF_FILE"
    fi

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

    mkdir -p "$ISHARE2_CONF_DIR"

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
    local allowed_vars=("USE_ARIA2C" "CHANNEL" "SSL_CHECK" "ROTATE" "MOTD" "AUTO_FIX_PERMISSIONS" "MIRROR" "JSON_URL")

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
    # shellcheck source=/etc/ishare2.conf
    source "$ISHARE2_CONF_FILE"

    # Source any drop-in configuration files from the drop-in directory
    if [[ -d "$ISHARE2_CONF_DIR" ]]; then
        for dropin in "$ISHARE2_CONF_DIR"/*.conf; do
            [[ -f "$dropin" ]] || continue
            # shellcheck source=/dev/null
            source "$dropin"
        done
    fi

    return 0
}

# Detect the available package manager for the current distribution
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
    elif command -v apk >/dev/null 2>&1; then
        PKG_MANAGER="apk"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MANAGER="zypper"
    else
        PKG_MANAGER=""
    fi
}

# Refresh package lists using the detected package manager
pkg_update() {
    [[ -n "${PKG_MANAGER:-}" ]] || detect_package_manager
    case "$PKG_MANAGER" in
    apt) apt-get update -y -qq ;;
    dnf) dnf makecache -y -q ;;
    yum) yum makecache -y -q ;;
    apk) apk update ;;
    pacman) pacman -Sy --noconfirm ;;
    zypper) zypper --non-interactive refresh ;;
    *) return 1 ;;
    esac
}

# Install a package using the detected package manager
pkg_install() {
    local package=$1
    [[ -n "${PKG_MANAGER:-}" ]] || detect_package_manager
    case "$PKG_MANAGER" in
    apt) apt-get install -qq -y "$package" ;;
    dnf) dnf install -y -q "$package" ;;
    yum) yum install -y -q "$package" ;;
    apk) apk add "$package" ;;
    pacman) pacman -S --noconfirm --needed "$package" ;;
    zypper) zypper --non-interactive install "$package" ;;
    *) return 1 ;;
    esac
}

# Function to remove i-share.top apt sources.list (apt-based systems only)
remove_ishare_sources() {
    [[ -n "${PKG_MANAGER:-}" ]] || detect_package_manager
    [[ "$PKG_MANAGER" == "apt" ]] || return 0
    [[ -f /etc/apt/sources.list ]] || return 0
    # Remove i-share.top line from sources.list
    sed -i '/i-share.top/d' /etc/apt/sources.list
}

# Function to install dependencies required for ishare2
install_dependencies() {
    remove_ishare_sources
    echo -e "${YELLOW}[+] ishare2 needs to install some dependencies to work properly.${NO_COLOR}"
    local required=("curl" "wget" "jq" "unzip" "tree")
    local suggested=("unrar")
    echo -e "${YELLOW}[+] Required packages: ${NO_COLOR}${required[*]}"
    echo -e "${YELLOW}[+] Suggested packages: ${NO_COLOR}${suggested[*]}"
    echo -e "${YELLOW}[+] Starting to install dependencies in 5 seconds... This may take a while. Press Ctrl+C to cancel.${NO_COLOR}"
    sleep 5

    for package in "${required[@]}"; do
        install_package "$package"
    done
    for package in "${suggested[@]}"; do
        install_suggested_package "$package"
    done
}

# Function to check if a package is installed and install it if it's not
check_installed() {
    PACKAGE=$1
    # Check if package is installed
    if ! command -v "$PACKAGE" &>/dev/null; then
        echo -e "${YELLOW}[!] WARN: $PACKAGE is not installed.${NO_COLOR}"
        install_package "$PACKAGE"
        echo -e "${GREEN}[+] $PACKAGE has been installed successfully.${NO_COLOR}"
    fi
}

# Install a required package (no prompt); exits on failure.
install_package() {
    local package_name=$1
    local command_name=${2:-$package_name}

    if command -v "$command_name" &>/dev/null; then
        echo -e "${GREEN}[+] $package_name is already installed.${NO_COLOR}"
        logger info "Package $package_name is already installed."
        return 0
    fi

    [[ -n "${PKG_MANAGER:-}" ]] || detect_package_manager
    if [[ -z "$PKG_MANAGER" ]]; then
        echo -e "${RED}[-] No supported package manager found. Please install '$package_name' manually.${NO_COLOR}"
        logger error "No supported package manager found to install $package_name."
        exit 1
    fi

    echo -e "${YELLOW}[+] Installing $package_name...${NO_COLOR}"
    pkg_update || {
        echo -e "${RED}[-] Failed to update package lists.${NO_COLOR}"
        echo -e "${YELLOW}[!] Please check your internet connection and try again or fix your repositories.${NO_COLOR}"
        logger error "Failed to update package lists."
    }

    if ! pkg_install "$package_name"; then
        echo -e "${RED}[-] Failed to install $package_name. Please install it manually or you will likely encounter issues.${NO_COLOR}"
        logger error "Failed to install $package_name."
        exit 1
    fi
}

# Install a suggested (optional) package, prompting first and allowing skip.
install_suggested_package() {
    local package_name=$1
    local command_name=${2:-$package_name}

    if command -v "$command_name" &>/dev/null; then
        return 0
    fi

    echo -e "${YELLOW}[?] ishare2 suggests installing the optional package: $package_name${NO_COLOR}"
    read -p "[?] Install it now? [y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_package "$package_name" "$command_name"
    else
        echo -e "${YELLOW}[!] Skipped $package_name. Some features may not work, but ishare2 will do its best.${NO_COLOR}"
        logger warn "Skipped installing suggested package $package_name."
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

