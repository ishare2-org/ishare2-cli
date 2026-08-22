show_logs() {
    # Show logs for ishare2
    print_info "Showing logs for ishare2... "
    tail -n 50 "$LOG_FILE"
}

clear_logs() {
    # Clear logs for ishare2
    print_info "Clearing logs for ishare2... "
    true >"$LOG_FILE"
    print_success "Logs cleared successfully. "
}
