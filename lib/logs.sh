show_logs() {
    # Show logs for ishare2
    echo -e "${YELLOW}[-] Showing logs for ishare2... ${NO_COLOR}"
    tail -n 50 $ISHARE2_DIR/ishare2.log
}

clear_logs() {
    # Clear logs for ishare2
    echo -e "${YELLOW}[-] Clearing logs for ishare2... ${NO_COLOR}"
    true >$ISHARE2_DIR/ishare2.log
    echo -e "${GREEN}[+] Logs cleared successfully. ${NO_COLOR}"
}
