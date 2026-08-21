# Function to fetch the latest list of sources needed for ishare2
ishare2_sources() {
    check_installed "curl"
    # Check if the sources.list file exists in the ishare2 directory
    if [ ! -f "$ISHARE2_DIR/sources.list" ]; then
        # If the sources.list file is older than 1 day, backup the file and download the latest sources.list
        if [ ! -f "$ISHARE2_DIR/sources.list" ] || [ $(find "$ISHARE2_DIR/sources.list" -mtime +1 -print) ]; then
            # Backup the sources.list file
            cp $ISHARE2_DIR/sources.list "$ISHARE2_DIR/sources.list.bak"
            # Download the latest sources.list
            curl -sL "$SOURCES_URL" >"$ISHARE2_DIR/sources.list"
            # Check if the sources.list file was downloaded successfully
            if [ $? -eq 0 ]; then
                logger info "The sources.list file has been downloaded successfully."
            else
                logger error "Failed to download the sources.list file."
                logger info "Restoring the backup sources.list file..."
                # Restore the backup sources.list file
                if [ -f "$ISHARE2_DIR/sources.list.bak" ]; then
                    cp "$ISHARE2_DIR/sources.list.bak" $ISHARE2_DIR/sources.list
                    logger info "The backup sources.list file has been restored."
                    echo -e "${RED}[-] Failed to download the sources.list file.${NO_COLOR}"
                    echo -e "${YELLOW}[!] Using the old sources.list file.${NO_COLOR}"
                    echo -e "${YELLOW}[!] Please check your internet connection and try again.${NO_COLOR}"
                else
                    logger info "The backup sources.list file does not exist."
                    echo -e "${RED}[-] Failed to download the sources.list file.${NO_COLOR}"
                    echo -e "${YELLOW}[!] Please check your internet connection and try again.${NO_COLOR}"
                    exit 1
                fi
            fi
        fi
    fi
    # Source the sources.list file
    source $ISHARE2_DIR/sources.list
}
