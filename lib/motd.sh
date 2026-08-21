# Function to initialize motd checks
check_motd() {
    if fetch_latest_motd; then
        # A fresh MOTD was fetched; compare it with the current one
        if motds_are_different; then
            show_motd
            update_motd_info
        else
            logger info "MOTD is up to date. No changes were made."
            if should_show_motd; then
                show_motd
                update_motd_info
            fi
        fi
    else
        # Cached fetch; honor the show-frequency limit
        if should_show_motd; then
            show_motd
            update_motd_info
        fi
    fi
}

# Function to check if the MOTD should be shown
should_show_motd() {
    current_date=$(date +"%Y-%m-%d")
    last_shown_date=$(jq -r '.last_shown_date' "$MOTD_FILE")
    show_count=$(jq -r '.show_count' "$MOTD_FILE")

    # Check if MOTD has not been shown today or shown less than 3 times
    if [ "$current_date" != "$last_shown_date" ] || [ "$show_count" -lt 3 ]; then
        return 0 # Show MOTD
    else
        return 1 # Do not show MOTD
    fi
}

# Function to display the MOTD
show_motd() {
    message=$(jq -r '.message' "$MOTD_FILE")
    messages=(
        "MOTD from the ishare2 team:"
        "$message"
        ""
        "Telegram: https://t.me/NetLabHub"
        "Donate: https://buymeacoffee.com/sudoalex"
        "GitHub: https://github.com/ishare2-org/ishare2-cli"
    )
    print_box "${messages[@]}"
}

# Function to update the MOTD information
update_motd_info() {
    current_date=$(date +"%Y-%m-%d")
    jq '.last_shown_date = $date | .show_count += 1' --arg date "$current_date" "$MOTD_FILE" >$ISHARE2_DIR/motd.tmp.json
    times_shown=$(jq -r '.show_count' "$ISHARE2_DIR/motd.tmp.json")
    logger info "MOTD has been shown $times_shown out of 3 times today."
    mv $ISHARE2_DIR/motd.tmp.json "$MOTD_FILE"
}

# Function to fetch the latest MOTD from a remote source
fetch_latest_motd() {
    # Refresh the MOTD at most once per day
    if [[ -f "$MOTD_FILE" ]] && [[ -z "$(find "$MOTD_FILE" -mtime +1 -print 2>/dev/null)" ]]; then
        return 1
    fi

    if [ ! -f "$MOTD_FILE" ]; then
        logger info "MOTD file does not exist. Fetching the latest MOTD from the remote source."
        curl -s "$REMOTE_MOTD_URL" >"$MOTD_FILE"
        return 0
    fi

    curl -s "$REMOTE_MOTD_URL" >"$ISHARE2_DIR/motd.tmp.json"
    # if curl failed then write custom message to motd file
    if [ $? -ne 0 ]; then
        echo -e '{"message":"Failed to fetch the latest MOTD. Please check your internet connection."}' >"$ISHARE2_DIR/motd.tmp.json"
    fi
    return 0
}

# Function to compare the current MOTD with the fetched MOTD
motds_are_different() {
    local current_motd
    local fetched_motd
    if [ ! -f "$MOTD_FILE" ] || [ ! -f "$ISHARE2_DIR/motd.tmp.json" ]; then
        return 0
    fi
    current_motd=$(jq -r '.message' "$MOTD_FILE")
    fetched_motd=$(jq -r '.message' "$ISHARE2_DIR/motd.tmp.json")
    # Compare the current MOTD with the fetched MOTD
    if [ "$current_motd" != "$fetched_motd" ]; then
        mv $ISHARE2_DIR/motd.tmp.json "$MOTD_FILE"
    fi

    [ "$current_motd" != "$fetched_motd" ]
}
