# Function to pull images passed as parameters
pull_images() {
    local IMAGE_TYPE=$1
    local IMAGE_ID=$2
    local OVERWRITE=$3

    # Validate parameters
    [[ -z "$IMAGE_TYPE" ]] && {
        echo "Usage: $0 pull <type> <id>"
        exit 1
    }
    [[ -z "$IMAGE_ID" || ! "$IMAGE_ID" =~ ^[0-9]+$ ]] && {
        echo "Invalid ID"
        exit 1
    }

    IMAGE_TYPE=${IMAGE_TYPE^^}
    [[ "$IMAGE_TYPE" == "BIN" ]] && IMAGE_TYPE="IOL"
    [[ ! "$IMAGE_TYPE" =~ ^(QEMU|IOL|DYNAMIPS)$ ]] && {
        echo "Invalid type"
        exit 1
    }

    logger debug "Image type: $IMAGE_TYPE"
    logger debug "Image ID: $IMAGE_ID"

    fetch_json || {
        echo "Failed to fetch index"
        exit 1
    }

    local image_data image_name mirror install_path protocol hostname prefix download_path

    image_data=$(jq -r --arg type "$IMAGE_TYPE" --argjson id "$IMAGE_ID" \
        '.[$type][] | select(.id == $id)' "$TEMP_JSON")
    [[ -z "$image_data" ]] && {
        echo "Image not found"
        exit 1
    }

    image_name=$(jq -r '.name' <<<"$image_data")
    install_path=$(jq -r '.metadata.install_path' <<<"$image_data")
    protocol=$(jq -r '.url_properties.protocol' "$TEMP_JSON")

    # Mirror selection logic
    local state_file="$ISHARE2_DIR/last_mirror"
    local available_mirrors=("drive" "main")

    if [[ "$ROTATE" == "true" ]]; then
        # Read last used mirror or default to first available
        if [[ -f "$state_file" ]]; then
            last_mirror=$(<"$state_file")
            # Find next mirror in rotation
            for i in "${!available_mirrors[@]}"; do
                if [[ "${available_mirrors[$i]}" == "$last_mirror" ]]; then
                    next_index=$(((i + 1) % ${#available_mirrors[@]}))
                    mirror="${available_mirrors[$next_index]}"
                    break
                fi
            done
        else
            mirror="${available_mirrors[0]}"
        fi
        # Save selected mirror for next rotation
        mkdir -p "$(dirname "$state_file")"
        echo "$mirror" >"$state_file"
    else
        # Use MIRROR environment variable if set and valid
        if [[ -n "$MIRROR" ]]; then
            # Check if MIRROR value is valid
            if [[ " ${available_mirrors[*]} " == *" $MIRROR "* ]]; then
                mirror="$MIRROR"
            else
                mirror="main" # Default to main if invalid
                logger warn "Invalid MIRROR value '$MIRROR'. Defaulting to 'main'"
            fi
        else
            mirror="main" # Default to main if MIRROR not set
        fi
    fi

    hostname=$(jq -r --arg mirror "$mirror" '.url_properties.hostnames[$mirror]' "$TEMP_JSON")
    prefix=$(jq -r --arg mirror "$mirror" '.url_properties.prefixes[$mirror]' "$TEMP_JSON")
    download_path="$install_path"

    logger debug "Using mirror: $mirror"
    logger debug "image_name: $image_name"
    logger debug "install_path (raw): $install_path"
    logger debug "URL base: $protocol://$hostname$prefix"
    logger debug "download_path: $download_path"

    # Check if the image is already downloaded (QEMU images live in a directory,
    # other types are single files).
    if [[ "$IMAGE_TYPE" == "QEMU" ]]; then
        local already_downloaded="$download_path"
    else
        local already_downloaded="$download_path/$image_name"
    fi
    if [ -e "$already_downloaded" ] && [ "$OVERWRITE" != "--overwrite" ]; then
        echo "File exists. Use --overwrite"
        exit 0
    fi

    # Build download URLs
    download_urls=()
    while IFS= read -r url; do
        full_url="$protocol://$hostname$prefix$url"
        download_urls+=("$full_url")
    done < <(jq -r '.files[].path' <<<"$image_data")

    print_warn "IMAGE INFO "
    printf "%-20s: %s\n" "Name" "$image_name"
    printf "%-20s: %s\n" "Size" "$(jq -r '.metadata.total_human_size' <<<"$image_data")"
    printf "%-20s: %s\n" "Type" "$IMAGE_TYPE"
    printf "%-20s: %s\n" "Path" "$install_path"
    printf "%-20s: %s\n" "Host" "$hostname"
    printf "%-20s: %s\n" "Mirror" "$mirror"

    logger debug "mkdir -p $install_path"
    if [ -e "$install_path" ]; then
        if [ ! -d "$install_path" ]; then
            print_error "Error: $install_path exists but is not a directory."
            logger error "$install_path exists but is not a directory"
            exit 1
        else
            logger debug "Directory already exists, continuing."
        fi
    else
        mkdir -p "$install_path"
    fi

    for url in "${download_urls[@]}"; do
        filename=$(basename "$url")

        logger debug "Remote URL: $url"
        logger debug "filename resolved: $filename"
        logger debug "download_file $url -> $install_path/$filename"

        if is_risky_script "$filename"; then
            print_warn "WARNING: \"$filename\" is a script (${filename##*.}) that may execute code on your system."
            print_warn "Only continue if you trust the source."
            read -p "[?] Skip downloading \"$filename\"? [y/N]: " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_warn "Skipped downloading $filename."
                continue
            fi
        fi

        download_file "$url" "$install_path" "$filename"

        expected_size=$(jq -r --arg name "$filename" '.files[] | select(.filename == $name) | .size' <<<"$image_data")
        expected_sha1=$(jq -r --arg name "$filename" '.files[] | select(.filename == $name) | .checksum.sha1' <<<"$image_data")
        expected_md5=$(jq -r --arg name "$filename" '.files[] | select(.filename == $name) | .checksum.md5' <<<"$image_data")

        print_info "Running integrity checks for $filename... "
        logger info "${YELLOW}[-] Running integrity checks for $filename... ${NO_COLOR}"
        local verification_failed=0
        check_image_size "$install_path" "$filename" "$expected_size"
        if [[ $? -ne 0 ]]; then
            print_error "Size check failed for $filename. "
            verification_failed=1
        fi
        check_image_hash "$install_path" "$filename" "$expected_sha1" "sha1"
        if [[ $? -ne 0 ]]; then
            print_error "SHA1 check failed for $filename. "
            verification_failed=1
        fi
        check_image_hash "$install_path" "$filename" "$expected_md5" "md5"
        if [[ $? -ne 0 ]]; then
            print_error "MD5 check failed for $filename. "
            verification_failed=1
        fi

        if [[ $verification_failed -eq 0 ]]; then
            print_ok "Downloaded and verified: $filename!"
        else
            print_error "Integrity checks failed for $filename. The downloaded file may be corrupted."
            print_error "Please try downloading the image again (use --overwrite to replace the existing file)."
            exit 1
        fi
    done

    # Post-processing for QEMU
    if [ "$IMAGE_TYPE" = "QEMU" ]; then
        handle_tgz_files "$image_name"
        handle_tar_gz_files "$image_name"
        handle_zip_files "$image_name"
    fi

    if [[ "$AUTO_FIX_PERMISSIONS" == "true" ]]; then
        fix_permissions
    fi

    print_ok "Installation completed successfully! "
}

# Function to download all images of a specific type (IOL, DYNAMIPS, QEMU)
pull_all() {
    TYPE=${1^^}
    if [[ $TYPE == "BIN" ]]; then
        TYPE="IOL"
    fi
    if [[ $TYPE == "QEMU" ]]; then
        print_warn "WARNING: Pulling all QEMU images will take a long time.\n [!] Make sure you have enough disk space and bandwidth!"
        # Enter confirmation text
        CONFIRMATION="I understand that pulling all QEMU images will take a long time. I have enough disk space and bandwidth."
        # Ask the user to enter the confirmation text
        read -p "[?] Please enter the following text to confirm: \"$CONFIRMATION\" (case sensitive): " -r
        # If the confirmation text is incorrect then exit
        if [[ ! $REPLY =~ ^$CONFIRMATION$ ]]; then
            print_error "Aborting."
            exit 1
        fi
    fi
    print_info "Pulling all $TYPE images..."
    # Ask for confirmation
    read -p "[?] Are you sure you want to pull all $TYPE images? (y/n): " -r
    # If reply was no Y or y then exit
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborting."
        exit 1
    fi
    # Get the list of all images
    fetch_json
    # Get all the IDs for the images of the specified type
    IDS=$(jq -r --arg type "$TYPE" '.[$type][] | .id' "$TEMP_JSON")
    # Pull all the images
    i=1
    total=$(echo "$IDS" | wc -l)
    for ID in $IDS; do
        print_info "Pulling image $i/$total..."
        ishare2 pull ${TYPE,,} $ID
        i=$((i + 1))
    done
}
