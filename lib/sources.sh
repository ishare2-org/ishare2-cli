# Function to fetch the latest list of sources needed for ishare2
ishare2_sources() {
    check_installed "curl"
    local sources_file="$ISHARE2_DIR/sources.list"
    local sources_url="https://raw.githubusercontent.com/ishare2-org/ishare2-cli/$CHANNEL/sources.list"
    local temporary_file="$sources_file.tmp"

    # Refresh only if missing or older than one day
    if [[ ! -f "$sources_file" ]] || [[ -n "$(find "$sources_file" -mtime +1 -print 2>/dev/null)" ]]; then
        if curl -fsSL "$sources_url" -o "$temporary_file"; then
            mv "$temporary_file" "$sources_file"
            logger info "The sources.list file has been downloaded successfully from the $CHANNEL channel."
        else
            rm -f "$temporary_file"
            logger error "Failed to download the sources.list file from the $CHANNEL channel."
            if [[ ! -f "$sources_file" ]]; then
                print_error "Failed to download the sources.list file."
                print_warn "Please check your internet connection and try again."
                exit 1
            fi

            print_warn "Failed to refresh sources.list. Using the existing file."
        fi
    fi

    # shellcheck source=/opt/ishare2/cli/sources.list
    source "$sources_file"
}
