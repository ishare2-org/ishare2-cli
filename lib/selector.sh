# Display installed images for a given type without recursing through ishare2.
show_installed_images() {
    local type=$1
    case "$type" in
    "qemu")
        echo -e
        print_separator "Showing installed QEMU images"
        tree -hp /opt/unetlab/addons/qemu/
        echo -e
        ;;
    "dynamips")
        echo -e
        print_separator "Showing installed DYNAMIPS images"
        tree -hp /opt/unetlab/addons/dynamips/
        echo -e
        ;;
    "iol")
        echo -e
        print_separator "Showing installed IOL images"
        tree -hp /opt/unetlab/addons/iol/bin/
        echo -e
        ;;
    "docker")
        list_dockers
        count_dockers
        ;;
    esac
}

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
                show_installed_images "qemu"
                show_installed_images "dynamips"
                show_installed_images "iol"
                show_installed_images "docker"
                ;;
            "qemu" | "dynamips" | "docker")
                show_installed_images "$2"
                ;;
            "bin" | "iol")
                show_installed_images "iol"
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
            elif [[ "$3" ]]; then
                install_images_from_lab "$1" "$2" "$3"
                exit 0
            fi
            list_labs "$1" "$2"
            exit 0
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
            print_error "Invalid action: $2 "
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
            print_error "Invalid action: $2 "
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
                print_error "Invalid action: $2 "
                echo -e "Usage: $SCR_NAME logs <action>"
                echo -e "Actions: show, clear"
                exit 1
                ;;
            esac
        else
            print_error "Invalid action: $2 "
            echo -e "Usage: $SCR_NAME logs <action>"
            echo -e "Actions: show, clear"
            exit 1
        fi
        ;;
    "gui")
        print_error "This feature won't work most of the time. "
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
                print_error "Invalid action: $2 "
                echo -e "Usage: $SCR_NAME gui <action>"
                echo -e "Actions: install, start, stop, restart"
                ;;
            esac
        else
            print_error "Invalid action: $2 "
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
