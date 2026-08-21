check_image_hash() {
    local image_path=$1
    local image_name=$2
    local expected_hash=$3
    local hash_type=${4,,} # Convert to lowercase (e.g., "SHA1" → "sha1")

    logger info "${YELLOW}[+] Checking ${hash_type^^} hash for ${image_name}${NO_COLOR}"

    if [[ -z "$expected_hash" ]]; then
        logger info "${YELLOW}[!] No ${hash_type^^} hash provided in the index. Skipping check.${NO_COLOR}"
        return
    fi

    if [ ! -f "$image_path/$image_name" ]; then
        logger error "${RED}[-] File not found: $image_path/$image_name${NO_COLOR}"
        return 1
    fi

    local actual_hash
    case "$hash_type" in
    sha1)
        actual_hash=$(sha1sum "$image_path/$image_name" | awk '{print $1}')
        ;;
    md5)
        actual_hash=$(md5sum "$image_path/$image_name" | awk '{print $1}')
        ;;
    *)
        echo -e "${RED}[-] Unsupported hash type: $hash_type${NO_COLOR}"
        return 1
        ;;
    esac

    if [[ "$actual_hash" != "$expected_hash" ]]; then
        echo -e "${RED}[-] ${hash_type^^} mismatch for $image_name${NO_COLOR}"
        echo -e "${YELLOW} Expected: $expected_hash${NO_COLOR}"
        echo -e "${YELLOW} Actual  : $actual_hash${NO_COLOR}"
        return 1
    fi

    echo -e "${GREEN}[✓] ${hash_type^^} hash is valid.${NO_COLOR}"
}

# Function to check image size against the downloaded image
check_image_size() {
    local image_path=$1
    local image_name=$2
    local image_size_from_json=$3

    # Check if the image file exists
    if [ ! -f "$image_path/$image_name" ]; then
        echo -e "${RED}[-] Error: The image file was not found at $image_path/$image_name while checking its size.${NO_COLOR}"
        logger error "The image file was not found: $image_path/$image_name"
        return 1
    fi

    local image_size
    image_size=$(stat -c%s "$image_path/$image_name" 2>/dev/null)

    # Validate image_size is numeric
    if [[ -z "$image_size" || ! "$image_size" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[-] Error: Unable to determine image size for $image_path/$image_name.${NO_COLOR}"
        logger error "Invalid or missing image size for: $image_path/$image_name"
        return 1
    fi

    # Check if the image size is less than 20KB
    if [ $image_size -lt 20000 ]; then
        echo -e "${RED}[-] Error: The image file size is too small. The file may be corrupted.${NO_COLOR}"
        logger error "The image file size is too small: $image_path/$image_name. Expected size: $image_size_from_json. Actual size: $image_size"
        return 1
    fi

    # Check if the image size matches the size from the JSON file
    if [[ -z "$image_size_from_json" || ! "$image_size_from_json" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[-] Error: Invalid or missing expected size from JSON for $image_name.${NO_COLOR}"
        logger error "Missing or non-numeric image_size_from_json: $image_size_from_json"
    fi

    if [ "$image_size" -ne "$image_size_from_json" ]; then
        echo -e "${RED}[-] Error: The image file size does not match the size expected by the index.${NO_COLOR}"
        echo -e "${RED}[!] Debug information:${NO_COLOR}"
        echo -e "${YELLOW} Expected size: $image_size_from_json${NO_COLOR}"
        echo -e "${YELLOW} Actual size: $image_size${NO_COLOR}"
        echo -e "${YELLOW} JSON file URL: $JSON_URL${NO_COLOR}"
        logger error "Mismatch: expected $image_size_from_json, got $image_size ($image_path/$image_name)"
    fi

    echo -e "${GREEN}[✓] The downloaded image is the expected size.${NO_COLOR}"
}

fetch_json() {
    check_installed "jq"

    # Constants
    REPO_URL="https://api.github.com/repos/ishare2-org/mirrors/releases/latest"

    logger info "Fetching the latest release information from: $REPO_URL"

    # Fetch release metadata quietly
    response=$(curl -sL "$REPO_URL") || {
        logger error "Failed to fetch release metadata from: $REPO_URL"
        exit 1
    }

    # Extract labhub.json URL
    labhub_url=$(echo "$response" | jq -r '.assets[] | select(.name == "labhub.json") | .browser_download_url')

    if [[ -z "$labhub_url" ]]; then
        logger error "labhub.json not found in release metadata from: $REPO_URL"
        echo -e "${RED}[-] Error: Failed to get image index URL from the LabHub repository.${NO_COLOR}"
        exit 1
    fi

    logger info "Downloading labhub.json from: $labhub_url"
    if curl -sSL -o "$TEMP_JSON" "$labhub_url"; then
        logger info "labhub.json downloaded successfully."
    else
        logger error "Failed to download labhub.json from: $labhub_url"
        echo -e "${RED}[-] Failed to download the JSON index file. Check your internet connection.${NO_COLOR}"
        echo -e "${YELLOW}[!] Running connection test...${NO_COLOR}"

        connection_tests
        local connection_test_result=$?

        if [[ $connection_test_result -eq 0 ]]; then
            echo -e "${GREEN}[+] Internet connection is working.${NO_COLOR}"
            echo -e "${YELLOW}[?] Do you want to reconfigure ishare2?${NO_COLOR}"
            read -p "[?] (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}[+] Reconfiguring ishare2...${NO_COLOR}"
                create_config
            else
                echo -e "${RED}[-] Check the log file for more information.${NO_COLOR}"
                echo -e "${YELLOW}[!] Log file: $LOG_FILE${NO_COLOR}"
            fi
        else
            echo -e "${RED}[-] Connection test failed. Please check your internet connection.${NO_COLOR}"
        fi
        exit 1
    fi

    # Validate downloaded JSON
    if ! jq -e . <"$TEMP_JSON" >/dev/null 2>&1; then
        logger error "Invalid JSON structure in: $TEMP_JSON"
        echo -e "${RED}[-] Error: Invalid JSON index file.${NO_COLOR}"
        logger info "Debug information: The downloaded JSON file is not valid. Please check the file at: $TEMP_JSON"
        exit 1
    else
        logger info "Valid JSON file confirmed: $TEMP_JSON"
    fi
}

# Function to download a file using wget or aria2c
download_file() {
    local url="$1"
    local output="$2"
    local options="$3"
    USE_ARIA2C=$(grep "USE_ARIA2C" $ISHARE2_CONF_FILE | cut -d "=" -f2)
    logger info "Downloading file from $url to $output with options: $options"

    if [[ $USE_ARIA2C == "true" ]]; then
        # Check if aria2c is installed
        if ! command -v aria2c &>/dev/null; then
            echo -e "${RED}[-] Error: aria2c is not installed. Attempting to install it...${NO_COLOR}"
            install_package "aria2" >/dev/null
            # Check if aria2c is installed
            if ! command -v aria2c &>/dev/null; then
                echo -e "${RED}[-] Error: aria2c is not installed. Please install it manually and try again.${NO_COLOR}"
                exit 1
            else # aria2c is installed
                echo -e "${GREEN}[+] aria2c has been installed successfully.${NO_COLOR}"
            fi
        fi
    fi

    if command -v aria2c &>/dev/null && [[ $USE_ARIA2C == "true" ]]; then
        download_file_aria2 "$url" "$output" "$options"
    else
        download_file_wget "$url" "$output"
    fi
}

# Function to download a file using aria2c
download_file_aria2() {
    local url="$1"
    local output_dir="$2"
    local output_name="$3"

    logger info "Downloading file from $url..."
    rm -f error.log
    if [ "$SSL_CHECK" = true ]; then
        aria2c --console-log-level=warn -j 2 -c --split=4 --min-split-size=20M --max-connection-per-server=4 --download-result=hide --allow-overwrite=true --dir="$output_dir" --out="$output_name" --log="error.log" "$url"
    else
        aria2c --console-log-level=warn -j 2 -c --split=4 --min-split-size=20M --max-connection-per-server=4 --download-result=hide --check-certificate=false --allow-overwrite=true --dir="$output_dir" --out="$output_name" --log="error.log" "$url"
    fi

    if [ $? -eq 0 ]; then
        # line break
        echo
        echo -e "${YELLOW}[+] ${GREEN}The file has been downloaded successfully to $output_dir$output_name ${NO_COLOR}"
        rm -f error.log
    else
        echo -e "${RED}[-] Error: Unable to download the file. Check the error.log file for more information.${NO_COLOR}"
        exit 1
    fi
    # Check if file size is less than 20KB and its extension is not excluded
    local excluded_extensions=("html" "txt" "php" "yml" "md" "json" "sh" "yaml" "txt")

    if [ -f "$output_dir$output_name" ] && [ $(stat -c%s "$output_dir$output_name") -lt 20000 ]; then
        is_excluded=false
        for ext in "${excluded_extensions[@]}"; do
            if [ "${output_name##*.}" = "$ext" ]; then
                is_excluded=true
                break
            fi
        done

        if [ "$is_excluded" = false ]; then
            echo -e "${RED}[-] The file size is too small. The file may be corrupted.${NO_COLOR}"
            # Check if html file is downloaded instead of the actual file, key words: "DOCTYPE", "<html>", Bhadoo
            if grep -q "DOCTYPE" "$output_dir$output_name" || grep -q "<html>" "$output_dir$output_name" || grep -q "Bhadoo" "$output_dir$output_name"; then
                echo -e "${RED}[-] The file may be corrupted. The file may be an HTML file instead of the actual file.${NO_COLOR}"
            fi
            # Show troubleshooting steps
            echo -e "${YELLOW}[!] Troubleshooting:${NO_COLOR}"
            echo -e "${YELLOW}[!] 1) Switch mirrors, if you have mirrors rotation enabled then run the command again using the --overwrite flag.${NO_COLOR}"
            echo -e "${YELLOW}[!] 2) If the issue persists, visit the live repository through your web browser and download the file manually.${NO_COLOR}"
            echo -e "${YELLOW}[!] 3) If the issue persists, report the issue to the ishare2 team on Telegram.${NO_COLOR}"
        fi
    fi

}

# Function to download a file using curl
download_file_curl() { # $1 = url, $2 = output
    # Create the directory if it does not exist
    mkdir -p $ISHARE2_DIR/tmp
    # Create the file if it does not exist
    touch $ISHARE2_DIR/tmp/curl_error
    local url="$1"
    local output="$2"
    logger info "Downloading file from $url..."
    if [ "$SSL_CHECK" = true ]; then
        curl -s -o "$output" "$url" 2>$ISHARE2_DIR/tmp/curl_error
    else
        curl -s --insecure -o "$output" "$url" 2>$ISHARE2_DIR/tmp/curl_error
    fi

    if [ $? -eq 0 ]; then
        logger info "The file has been downloaded successfully to $output."
        rm -f $ISHARE2_DIR/tmp/curl_error
    else
        echo -e "${RED}[-] Error: Unable to download the file. ${NO_COLOR}"
        # Read the error message from the curl_error file
        ERROR_MESSAGE=$(cat $ISHARE2_DIR/tmp/curl_error)
        # Print the error message
        echo -e "${RED}[-] Logs:\n $ERROR_MESSAGE ${NO_COLOR}"
        exit 1
    fi
}

# Function to download a file using wget
download_file_wget() {
    # Create the directory if it does not exist
    mkdir -p $ISHARE2_DIR/tmp
    # Create the file if it does not exist
    touch $ISHARE2_DIR/tmp/wget_error
    local url="$1"
    local output_dir="$2"
    local output_name="$3"
    if [[ -z "$output_name" ]]; then
        # if output name is not provided, use the basename of the URL
        output_name=$(basename "$url")
    fi
    local output="$output_dir/$output_name"
    logger info "Downloading file from $url..."

    if [ "$SSL_CHECK" = true ]; then
        wget -O "$output" "$url" -q --show-progress --content-disposition -T 300
    else
        wget -O "$output" "$url" -q --show-progress --content-disposition --no-check-certificate -T 300
    fi

    # Check if wget command failed
    if [ $? -eq 0 ]; then
        logger info "The file has been downloaded successfully to $output."
        rm -f $ISHARE2_DIR/tmp/wget_error
    else
        echo -e "${RED}[-] Error: Unable to download the file. ${NO_COLOR}"
        # Read the error message from the wget_error file
        ERROR_MESSAGE=$(cat $ISHARE2_DIR/tmp/wget_error)
        # Print the error message
        echo -e "${RED}[-] Read the logs above for more information. ${NO_COLOR}"
        logger error "Failed to download the file. Error: $ERROR_MESSAGE"
        exit 1
    fi
}
