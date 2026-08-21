# Function to check if there is a new version of ishare2 available
check_updates() {
    local last_check_file="$ISHARE2_DIR/last_update_check"

    # Check for updates at most once per day
    if [[ -f "$last_check_file" ]] && [[ -z "$(find "$last_check_file" -mtime +1 -print 2>/dev/null)" ]]; then
        return
    fi
    touch "$last_check_file"

    local latest_version
    latest_version=$(curl -fsSL "$URL_VERSION") || {
        logger warn "Failed to fetch the latest version information from: $URL_VERSION"
        return
    }

    # Check if the version file could be fetched successfully
    if [[ -z "$latest_version" ]]; then
        logger error "The latest version file from $URL_VERSION is empty."
        return
    fi

    if [[ $latest_version != "$VERSION" ]]; then
        # Make an array of messages
        messages=(
            "A newer version of ishare2 is available."
            "Current version: $VERSION"
            "Latest version: $latest_version"
            "Run: ishare2 upgrade to update to the latest version."
            "See more methods to update on GitHub:"
            "https://github.com/ishare2-org/ishare2-cli"
        )
        print_box "${messages[@]}"
    fi
}

# Function to print a box-like component with adjusted width
print_box() {
    local messages=("$@")

    # Split messages on line breaks and find the length of the longest line
    max_length=0
    IFS=$'\n'    # Internal Field Separator set to newline for splitting
    all_lines=() # Array to hold all lines of all messages
    for message in "${messages[@]}"; do
        # Split message into lines
        readarray -t lines <<<"$message"
        for line in "${lines[@]}"; do
            all_lines+=("$line")
            length=${#line}
            if ((length > max_length)); then
                max_length=$length
            fi
        done
    done
    IFS=$' \t\n' # Reset IFS to default

    # Display information in a box-like component with adjusted width
    echo -e "${YELLOW}┌$(printf '─%.0s' $(seq 1 $((max_length + 4))))┐${NO_COLOR}"
    for line in "${all_lines[@]}"; do
        printf "${YELLOW}│${NO_COLOR} %-$(($max_length + 2))s ${YELLOW}│${NO_COLOR}\n" "$line"
    done
    echo -e "${YELLOW}└$(printf '─%.0s' $(seq 1 $((max_length + 4))))┘${NO_COLOR}"
}

# Function to print a separator with a title
print_separator() {
    local TITLE=$1
    local WIDTH=${#TITLE}
    local SEPARATOR=""

    # Calculate the required number of '=' characters to create the separator
    for ((i = 0; i < WIDTH + 8; i++)); do
        SEPARATOR+="="
    done

    echo -e "${BLUE}$SEPARATOR${NO_COLOR}"
    echo -e "\033[1;33m    ${TITLE}    \033[0m"
    echo -e "${BLUE}$SEPARATOR${NO_COLOR}"
}
