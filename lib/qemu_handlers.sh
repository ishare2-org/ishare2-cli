# Check if a file is a script that could execute arbitrary code
is_risky_script() {
    case "${1,,}" in
    *.sh | *.php) return 0 ;;
    *) return 1 ;;
    esac
}

# Function to handle tgz archives
handle_tgz_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".tgz"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        tar -xf "$file" --strip-components 1 -C "$DIR"
        rm "$file"
        echo -e "${GREEN}[+] Extracted: $DIR. Image ready to use. ${NO_COLOR}"
    fi
}

# Function to handle tar.gz archives
handle_tar_gz_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".tar.gz"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        tar -xf "$file" --strip-components 1 -C "$DIR"
        rm "$file"
        echo -e "${GREEN}[+] Extracted: $DIR."
    fi
}

# Function to handle tar files
handle_tar_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".tar"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        tar -xf "$file" --strip-components 1 -C "$DIR"
        rm "$file"
        echo -e "${GREEN}[+] Extracted: $DIR. Image ready to use. ${NO_COLOR}"
    fi
}

# Function to handle zip files
handle_zip_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".zip"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        unzip -a -j "$file" -d "$DIR"
        rm "$file"
        echo -e "${GREEN}[+] Extracted: $DIR. Image ready to use. ${NO_COLOR}"
    fi
}

# Function to handle rar files
handle_rar_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".rar"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")

        install_suggested_package "unrar"

        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        unrar e "$file" "$DIR" >/dev/null 2>&1
        echo -e "${GREEN}[+] Extracted: $DIR. Image ready to use. ${NO_COLOR}"
        rm "$file"
    fi
}

# Function to handle OVA files
handle_ova_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".ova"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        COMPRESSED_FILE=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[-] Extracting: $FOLDERNAME$EXTENSION file... ${NO_COLOR}"
        tar -xvf "$COMPRESSED_FILE" -C "$DIR"
        rm "$COMPRESSED_FILE"
        echo -e "${GREEN}[+] Extracted: $DIR. Image ready to use. ${NO_COLOR}"
    fi
}

# Function to handle ISO files
handle_iso_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".iso"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        ISO_FILE=$(ls "${DIR}"/*"$EXTENSION")

        if ! [[ "${ISO_FILE: -9}" == "cdrom.iso" ]]; then
            mv "$ISO_FILE" "$DIR"/cdrom.iso # Rename file
            echo -e "${GREEN}[+] ISO file saved as: $DIR/cdrom.iso ${NO_COLOR}"
        fi

        if ! command -v qemu-img &>/dev/null; then
            echo -e "${YELLOW}[!] qemu-img is not installed.${NO_COLOR}"
            install_suggested_package "qemu-utils" "qemu-img"
        fi

        if [[ $FILES_COUNTER -eq 1 ]]; then
            qemu-img create -f qcow2 "$DIR"/virtioa.qcow2 20G
        fi
    fi
}

# Function to handle yaml templates
handle_yml_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSIONS=(".yml" ".yaml")
    YML_DIR="${YML_DIR:-/opt/unetlab/html/templates/}"

    for ext in "${EXTENSIONS[@]}"; do
        if ls "${DIR}"/*"$ext" &>/dev/null; then
            file=$(ls "${DIR}"/*"$ext" | head -1)
            cp "$file" "$YML_DIR"
            break
        fi
    done
}

# Function to handle txt and md files
handle_txt_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSIONS=(".txt" ".md")

    for ELEMENT in "$DIR"/*; do
        for EXTENSION in "${EXTENSIONS[@]}"; do
            if [[ "${ELEMENT: -${#EXTENSION}}" == "$EXTENSION" ]]; then
                echo -e "\nReading file: $ELEMENT\n"
                cat "$ELEMENT"
                echo -e
                break
            fi
        done
    done
}

# Function to handle sh files
handle_sh_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".sh"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${RED}[!] WARNING: This image includes a shell script: $file${NO_COLOR}"
        echo -e "${RED}[!] Scripts can execute arbitrary code. Only run it if you trust the source.${NO_COLOR}"
        chmod +x "$file"
        read -p "Do you want to run $file? [y/n]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bash "$file"
        else
            echo -e "${YELLOW}[!] $file was not executed. ${NO_COLOR}"
            echo -e "${YELLOW}[!] WARN: This script file might be needed for the image to work properly. ${NO_COLOR}"
        fi
    fi
}

# Function to handle png files (icons)
handle_png_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".png"
    PNG_DIR="/opt/unetlab/html/images/icons/"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")

        # Change .png filename for a Huawei device: from ne5000e.png to ne.png
        if [[ $file == "/opt/unetlab/addons/qemu/huaweine5ke-ne5000e/ne5000e.png" ]]; then
            NEW_PNG_FILENAME="/opt/unetlab/addons/qemu/huaweine5ke-ne5000e/ne.png"
            mv "$file" $NEW_PNG_FILENAME
            file=$NEW_PNG_FILENAME
        fi

        cp "$file" $PNG_DIR
    fi
}

# Function to handle php files
handle_php_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".php"
    PHP_DIR="/opt/unetlab/html/devices/qemu/"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        file=$(ls "${DIR}"/*"$EXTENSION")
        echo -e "${YELLOW}[!] WARNING: This image includes a PHP script: $file${NO_COLOR}"
        echo -e "${YELLOW}[!] PHP files run server-side code. Only install it if you trust the source.${NO_COLOR}"
        cp "$file" $PHP_DIR
    fi
}

# Function to handle vmdk files
handle_vmdk_files() {
    FOLDERNAME=$1

    DIR="/opt/unetlab/addons/qemu/$FOLDERNAME"

    EXTENSION=".vmdk"

    if ls "${DIR}"/*"$EXTENSION" &>/dev/null; then
        VMDK_FILE=$(ls "${DIR}"/*"$EXTENSION")
        install_qemu_tools

        echo -e "\nConverting .vmdk to .qcow2. It might take a while..."
        /opt/qemu/bin/qemu-img convert -p -f vmdk -O qcow2 "$VMDK_FILE" "$DIR"/hda.qcow2
        echo "File converted successfully"
        rm "$VMDK_FILE"
    fi
}

# Function to install qemu-utils
install_qemu_tools() {
    install_suggested_package "qemu-utils" "qemu-img"
    if ! command -v qemu-img &>/dev/null && ! [[ -e /opt/qemu/bin/qemu-img ]]; then
        echo -e "${RED}[-] qemu-img is not installed. Please install it manually. ${NO_COLOR}"
    fi
}
