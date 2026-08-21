# Function to check if there is a new version of ishare2 available
check_updates() {
    LATEST_VERSION=$(curl -sL https://raw.githubusercontent.com/ishare2-org/ishare2-cli/$CHANNEL/version)

    # Check if the version file could be fetched successfully
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${RED}[-] Failed to fetch the latest version information. Please check your internet connection.${NO_COLOR}"
        logger error "Failed to fetch the latest version information from: $LATEST_VERSION"
        return
    fi

    if [[ $LATEST_VERSION != $VERSION ]]; then
        # Make an array of messages
        messages=(
            "A newer version of ishare2 is available."
            "Current version: $VERSION"
            "Latest version: $LATEST_VERSION"
            "Run: ishare2 upgrade to update to the latest version."
            "See more methods to update on GitHub:"
            "https://github.com/ishare2-org/ishare2-cli"
        )
        print_box "${messages[@]}"
    fi
}

# Function to print a box-like component with adjusted width
print_box() {
    messages=("$@")

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
