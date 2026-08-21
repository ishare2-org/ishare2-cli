logger() {
    local log_level=${1^^} # Convert log level to uppercase
    shift                  # Remove log level from arguments

    # Create LOG_FILE if it does not exist
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi

    # Ensure LOG_FILE is set and writable
    if [[ -z "$LOG_FILE" ]]; then
        echo "LOG_FILE is not set" >&2
        return 1
    elif [[ ! -w "$LOG_FILE" && ! -e "$LOG_FILE" ]]; then
        echo "Cannot write to LOG_FILE: $LOG_FILE" >&2
        # Attempt to create the log file
        touch "$LOG_FILE" || return 1
        # Attempt to fix the permissions
        chmod 644 "$LOG_FILE" || return 1
        return 1
    fi

    # Ensure SCR_NAME is set
    if [[ -z "$SCR_NAME" ]]; then
        SCR_NAME="UNKNOWN_SCRIPT"
    fi

    # Log the output to the log file
    echo -e "[$log_level][$SCR_NAME] $(date '+%Y-%m-%d %H:%M:%S'): $*" >>"$LOG_FILE"
}
