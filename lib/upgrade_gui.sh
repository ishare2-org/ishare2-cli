# Function to get the version of ishare2
ishare2_version() {
    printf '%s\n' "$VERSION" >"$ISHARE2_DIR/ishare2_version"
    if [[ $1 == "show" ]]; then
        echo -e "ishare2 version: $VERSION"
        echo -e "Latest version: $(curl -fsSL "$URL_VERSION")"
    fi
}

# Function to upgrade ishare2
upgrade_ishare2() {
    LOCAL_VALUE=$VERSION
    UPSTREAM_VERSION=$(curl -fsSL "$URL_VERSION") || {
        echo -e "${RED}[-] Failed to fetch the latest version information.${NO_COLOR}"
        return 1
    }

    if [[ $LOCAL_VALUE == "$UPSTREAM_VERSION" ]]; then
        echo -e "${YELLOW}[+] ishare2 $UPSTREAM_VERSION is already in the newest version available. ${NO_COLOR}"
        echo -e "${YELLOW}[+] Do you want to reinstall it? (y/n) ${NO_COLOR}"
        read -r answer
        if [[ $answer == "y" || $answer == "Y" ]]; then
            echo -e "${YELLOW}[+] Reinstalling ishare2... ${NO_COLOR}"
        else
            exit 0
        fi
    fi

    rm /usr/sbin/ishare2
    download_file_wget "$URL_ISHARE2" /usr/sbin/ "ishare2"

    mkdir -p "$ISHARE2_DIR/lib"
    local module_base_url="${URL_ISHARE2%/*}/lib"
    for module in "${ISHARE2_MODULES[@]}"; do
        download_file_wget "$module_base_url/$module" "$ISHARE2_DIR/lib" "$module"
    done
    printf '%s\n' "$UPSTREAM_VERSION" >"$ISHARE2_DIR/ishare2_version"

    echo -e "${GREEN}[+] Successfully downloaded the latest version of ishare2!${NO_COLOR}"
    # Make ishare2 executable
    echo -e "${YELLOW}[+] Setting ishare2 permissions${NO_COLOR}"
    chmod +x /usr/sbin/ishare2
    # Show success message
    echo -e "${GREEN}[+] ishare2 was upgraded from $LOCAL_VALUE to $UPSTREAM_VERSION ${NO_COLOR}"
}

# Function to show the ishare2 upgrade menu
menu_ishare2_upgrade_pnetlab() {
    # Define the menu options
    options=(
        "Upgrade PNETLab v5 STABLE"
        "Upgrade PNETLab v5 BETA"
        "Upgrade PNETLab v6 BETA"
    )

    # Set the prompt for the select menu
    PS3="Please, select an option: "

    # Print the menu and wait for user input
    select opt in "${options[@]}" "Exit"; do
        case "$REPLY" in
        1)
            # Upgrade PNETLab v5
            bash -c "$(curl -sL --insecure "$URL_PNETLAB_V5")"
            ;;
        2)
            # Upgrade PNETLab v5 Beta
            bash -c "$(curl -sL --insecure "$URL_PNETLAB_V5_BETA")"
            ;;
        3)
            # Upgrade PNETLab v6
            bash -c "$(curl -sL --insecure "$URL_PNETLAB_V6")"
            ;;
        $((${#options[@]} + 1)))
            break
            ;;
        *)
            # Invalid option
            total_options=${#options[@]}
            echo -e "${RED}Invalid option: Select a number from 1 to $total_options${NO_COLOR}"
            continue
            ;;
        esac
    done
}

# Function to show the ishare2 upgrade menu
menu_ishare2_upgrade() {
    prompt="Please, select an option: "
    options=(
        "Upgrade ishare2"
        "Upgrade PNETLab"
        "Upgrade ishare2 GUI"
    )

    PS3="$prompt"
    select opt in "${options[@]}" "Exit"; do
        case "$REPLY" in
        1)
            upgrade_ishare2
            break
            ;;
        2)
            menu_ishare2_upgrade_pnetlab
            break
            ;;
        3)
            ishare2 gui install
            break
            ;;
        $((${#options[@]} + 1)))
            break
            ;;
        *)
            STR="Invalid option: Select a number from 1 to 4"
            echo -e "${RED}$STR${NO_COLOR}"
            continue
            ;;
        esac
    done
}

# Function to show the ishare2 changelog
show_changelog() {
    FILE=/root/CHANGELOG.md
    if [[ -e $FILE ]]; then rm $FILE; fi

    wget -q "$URL_CHANGELOG_MD" -P /root
    head -n 15 $FILE
    rm $FILE
}

# Function to install ishare2 GUI
ishare2_gui_install() {
    curl -sL "$URL_ISHARE2_GUI_INSTALL" | bash
}

# Function to start ishare2 GUI
ishare2_gui_start() {
    systemctl start ishare2_gui.service
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[-] Error starting ishare2 GUI service. ${NO_COLOR}"
        echo -e "${RED}[-] Please see the logs for troubleshooting. Run: systemctl status ishare2_gui.service ${NO_COLOR}"
        exit 1
    fi
}

# Function to stop ishare2 GUI
ishare2_gui_stop() {
    systemctl stop ishare2_gui.service
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[-] Error stopping ishare2 GUI service. ${NO_COLOR}"
        echo -e "${RED}[-] Please see the logs for troubleshooting. Run: systemctl status ishare2_gui.service ${NO_COLOR}"
        exit 1
    fi
}

# Function to restart ishare2 GUI
ishare2_gui_restart() {
    systemctl restart ishare2_gui.service
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[-] Error restarting ishare2 GUI service. ${NO_COLOR}"
        echo -e "${RED}[-] Please see the logs for troubleshooting. Run: systemctl status ishare2_gui.service ${NO_COLOR}"
        exit 1
    fi
}
