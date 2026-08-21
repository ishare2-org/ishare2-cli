logger() {
    local log_level=${1^^} # Convert log level to uppercase
    shift                  # Remove log level from arguments

    # Ensure LOG_FILE is set
    if [[ -z "$LOG_FILE" ]]; then
        echo "LOG_FILE is not set" >&2
        return 1
    fi

    # Create LOG_FILE if it does not exist
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE" 2>/dev/null || {
            echo "Cannot create LOG_FILE: $LOG_FILE" >&2
            return 1
        }
    fi

    # Ensure LOG_FILE is writable
    if [[ ! -w "$LOG_FILE" ]]; then
        echo "Cannot write to LOG_FILE: $LOG_FILE" >&2
        return 1
    fi

    # Ensure SCR_NAME is set
    if [[ -z "$SCR_NAME" ]]; then
        SCR_NAME="UNKNOWN_SCRIPT"
    fi

    # Log the output to the log file
    echo -e "[$log_level][$SCR_NAME] $(date '+%Y-%m-%d %H:%M:%S'): $*" >>"$LOG_FILE"
}
