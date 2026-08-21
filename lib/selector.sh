# Function to handle parameters passed to ishare2
selector() {
    case "$1" in
    "search")
        TYPE_INPUT="${2,,}" # normalize to lowercase
        QUERY="${3:-}"      # optional filter

        case "$TYPE_INPUT" in
        "qemu" | "iol" | "dynamips")
            TYPE="${TYPE_INPUT^^}" # convert to uppercase
            search_images "$TYPE" "$QUERY"
            ;;

        "bin") # alias for iol
            TYPE="IOL"
            search_images "$TYPE" "$QUERY"
            ;;

        "all")
            # If keyword is passed, search across all types
            if [[ -n "$QUERY" ]]; then
                search_images "any" "$QUERY"
            else
                for type in "QEMU" "IOL" "DYNAMIPS"; do
                    search_images "$type"
                    echo
                done
            fi
            ;;

        *)
            if [ -n "$2" ]; then
                # Assume $2 is a filter term, so search across all types
                search_images "any" "$2"
            else
                echo "Usage: $SCR_NAME search <type> [keyword]"
                echo "       $SCR_NAME search all [keyword]"
                echo "Types: qemu, iol, dynamips, bin, all"
                exit 1
            fi
            ;;
        esac
        ;;
    "pull")
        case "$2" in
        "qemu" | "iol" | "dynamips" | "bin")
            TYPE="${2^^}" # Convert to uppercase
            if [[ "$3" ]]; then
                if [[ "$3" = "all" ]]; then
                    pull_all "$TYPE"
                    exit 0
                fi
            fi
            pull_images "$TYPE" "$3" "$4"
            ;;
        *) # If the type is not specified, print the usage
            echo "Usage: $SCR_NAME pull <type> <id>"
            echo "       $SCR_NAME pull <type> all"
            echo "Types: qemu, iol, dynamips"
            ;;
        esac
        ;;
    "installed")
        if [[ "$2" ]]; then
            case "$2" in
            "all")
                ishare2 installed qemu
                ishare2 installed dynamips
                ishare2 installed iol
                ishare2 installed docker
                ;;
            "qemu")
                echo -e
                print_separator "Showing installed ${2^^} images"
                tree -hp /opt/unetlab/addons/qemu/
                echo -e
                ;;
            "dynamips")
                echo -e
                print_separator "Showing installed ${2^^} images"
                tree -hp /opt/unetlab/addons/dynamips/
                echo -e
                ;;
            "bin" | "iol")
                echo -e
                print_separator "Showing installed ${2^^} images"
                tree -hp /opt/unetlab/addons/iol/bin/
                echo -e
                ;;
            "docker")
                list_dockers
                count_dockers
                ;;
            *)
                echo "Usage: $SCR_NAME installed <type>"
                echo "       $SCR_NAME installed all"
                echo "Types: qemu, dynamips, iol, docker"
                ;;
            esac
        else
            echo "Usage: $SCR_NAME installed <type>"
            echo "       $SCR_NAME installed all"
            echo "Types: qemu, dynamips, iol, docker"
        fi
        ;;
    "labs")
        if [[ "$2" ]]; then
            if [[ "$2" = "all" ]]; then
                install_images_all_labs "$1"
                exit 0
            else
                install_images_from_lab "$2"
                exit 0
            fi
        fi
        list_labs "$1"
        ;;
    "mylabs")
        if [[ "$2" ]]; then
            if [[ "$2" = "all" ]]; then
                install_images_all_labs "$1"
                exit 0
            else
                install_images_from_lab "$1" "$2" "$3"
                exit 0
            fi
        fi
        list_labs "$1"
        ;;
    "relicense" | "license")
        generate_iourc_license
        ;;
    "upgrade")
        menu_ishare2_upgrade
        ;;
    "changelog")
        show_changelog
        ;;
    "fix")
        # if $2 is not passed
        if [[ -z "$2" ]]; then
            echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
            echo -e "Usage: $SCR_NAME fix <action>"
            echo -e "Actions: permissions, dns, block_cisco"
            exit 1
        fi
        case "$2" in
        "permissions")
            fix_permissions
            ;;
        "dns")
            fix_dns
            ;;
        "block_cisco")
            block_cisco
            ;;
        *) # If the action is not specified, print the usage
            echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
            echo -e "Usage: $SCR_NAME fix <action>"
            echo -e "Actions: permissions, dns"
            exit 1
            ;;
        esac
        ;;
    "logs")
        if [[ "$2" ]]; then
            case "$2" in
            "show")
                show_logs
                ;;
            "clear")
                clear_logs
                ;;
            *)
                echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
                echo -e "Usage: $SCR_NAME logs <action>"
                echo -e "Actions: show, clear"
                exit 1
                ;;
            esac
        else
            echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
            echo -e "Usage: $SCR_NAME logs <action>"
            echo -e "Actions: show, clear"
            exit 1
        fi
        ;;
    "gui")
        echo -e "${RED}[-] This feature won't work most of the time. ${NO_COLOR}"
        if [[ "$2" ]]; then
            case "$2" in
            "install")
                ishare2_gui_install
                ;;
            "start")
                ishare2_gui_start
                ;;
            "stop")
                ishare2_gui_stop
                ;;
            "restart")
                ishare2_gui_restart
                ;;
            *)
                echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
                echo -e "Usage: $SCR_NAME gui <action>"
                echo -e "Actions: install, start, stop, restart"
                ;;
            esac
        else
            echo -e "${RED}[-] Invalid action: $2 ${NO_COLOR}"
            echo -e "Usage: $SCR_NAME gui <action>"
            echo -e "Actions: install, start, stop, restart"
        fi
        ;;
    "help")
        show_ishare2_help
        ;;
    "test")
        connection_tests
        ;;
    "config")
        create_config
        ;;
    "--version")
        ishare2_version "show"
        ;;
    *)
        ishare2_quick_help
        ;;
    esac
}
