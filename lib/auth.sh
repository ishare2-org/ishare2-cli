# Function to check if the user is root
check_user_is_root() {
    if ! [[ "$(id -u)" == 0 ]]; then
        user=$(whoami)
        print_error "This script requires root privileges to be executed. The current user, \"$user\", does not have enough permissions. Please, switch to the root user to run the script."
        exit 1
    fi
}
