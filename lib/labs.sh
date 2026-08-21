# Function to get the yaml templates directory based on the server platform
get_server_platform() {
    grep -q vmx /proc/cpuinfo && echo -n vmx >/opt/unetlab/platform
    grep -q svm /proc/cpuinfo && echo -n svm >/opt/unetlab/platform

    platform=$(cat /opt/unetlab/platform)

    if [[ $platform == "vmx" ]]; then YML_DIR="/opt/unetlab/html/templates/intel/"; fi
    if [[ $platform == "svm" ]]; then YML_DIR="/opt/unetlab/html/templates/amd/"; fi
}

# Function to set the yaml templates directory based on the PNETLab version
set_yml_template_folder_location() {
    data=$(mysql -uroot -ppnetlab -D pnetlab_db -e "SELECT control_value FROM control WHERE control_value>1;" 2>/dev/null)
    data_array=("$data")
    pnetlab_version=${data_array[1]}

    if [[ $pnetlab_version == "4.2.10" ]] || [[ $pnetlab_version == "5.0.1" ]]; then
        YML_DIR="/opt/unetlab/html/templates/"
    fi

    if [[ $pnetlab_version == *5.2* ]] || [[ $pnetlab_version == *5.3* ]] || [[ $pnetlab_version == *6.* ]]; then
        get_server_platform
    fi
}

# Function to list the labs available in the default or custom labs directory
list_labs() {
    # Check if the user passed a custom path for Labs directory
    if [[ $1 == "mylabs" ]]; then # If the command is "ishare2 mylabs"
        LABS_DIR=$2
        CUSTOM_PATH_FLAG=1
        RELATIVE_PATH=$LABS_DIR
        if [[ ! "$LABS_DIR" == /* ]]; then # If the path is not absolute
            # Convert the path to absolute
            LABS_DIR=$(realpath "$LABS_DIR")
            # Check if the path is a directory and add '/' if it's missing
            if [[ -d "$LABS_DIR" && "$LABS_DIR" != */ ]]; then
                LABS_DIR="$LABS_DIR/"
            fi
        fi
        NOT_FOUND_MESSAGE="Make sure you are passing the correct path to the folder where your labs are located"
        echo -e "${BLUE}Custom path for Labs directory:${NO_COLOR} ${YELLOW}$LABS_DIR${NO_COLOR}"
    else # Use default path for PNETLab Store
        LABS_DIR="/opt/unetlab/labs/Your labs from PNETLab Store/"
        NOT_FOUND_MESSAGE="This folder is automatically created when a lab from PNETLab Store is downloaded"
    fi

    if ! [[ -d $LABS_DIR ]]; then
        echo "\"$LABS_DIR\" directory has not been found"
        echo "$NOT_FOUND_MESSAGE"
        exit 0
    fi

    if [[ -z "$(ls -A "$LABS_DIR")" ]]; then
        echo "No labs found in \"$LABS_DIR\" directory"
        exit 0
    fi

    counter_all_labs_installed_on_server=0
    for file in "$LABS_DIR"*; do
        counter_all_labs_installed_on_server=$((counter_all_labs_installed_on_server + 1))
    done

    echo -e "Labs currently available in \"$RELATIVE_PATH\" directory: $counter_all_labs_installed_on_server"

    declare -a readableLabsArray=()
    declare -a authorLabsArray=()

    for file in "$LABS_DIR"*; do
        check=$(grep -Pio 'encoding="UTF-8"' "$file")
        SUB="encoding"
        if [[ $check == *"$SUB"* ]]; then
            readableLabsArray+=("$file")
            author_lab_name=$(grep -Pio '.*author="\K[^"]*' "$file" | sort -u)
            if [[ -z $author_lab_name ]]; then # Author name not specified
                author_lab_name=N/A
            fi
            authorLabsArray+=("$author_lab_name")
        fi
    done

    echo "Labs in plain text: ${#readableLabsArray[@]}"

    if [[ ${#readableLabsArray[@]} -eq 0 ]]; then
        STR="No readable labs were found, so images cannot be downloaded for any lab"
        echo -e "${RED}[-]$STR\033[0m"
        exit 0
    fi

    echo -e "\nList\n"

    counter_for_readable_labs=0

    for f in "${readableLabsArray[@]}"; do
        counter_for_readable_labs=$((counter_for_readable_labs + 1))
        echo -e "$counter_for_readable_labs) ${f##*/} - ${authorLabsArray[$((counter_for_readable_labs - 1))]}"
    done
    if [[ $CUSTOM_PATH_FLAG -eq 1 ]]; then
        CMD_TO_EXECUTE="ishare2 mylabs $RELATIVE_PATH <number>"
        CMD_TO_EXECUTE_ALL="ishare2 mylabs $RELATIVE_PATH all"
    else
        CMD_TO_EXECUTE="ishare2 labs <number>"
        CMD_TO_EXECUTE_ALL="ishare2 labs all"
    fi
    echo -e "\nTo install images for a specific lab, use the following command:\n\033[32m$CMD_TO_EXECUTE <number>\033[0m"
    echo -e "\nTo install images for all of the labs, use the following command:\n\033[32m$CMD_TO_EXECUTE_ALL\033[0m"
}

# Function to pull images for a lab
install_images_from_lab() {
    # Check if the user passed a custom path for Labs directory
    if [[ $1 == "mylabs" ]]; then # If the command is "ishare2 mylabs"
        LABS_DIR=$2
        RELATIVE_PATH=$LABS_DIR
        if [[ ! "$LABS_DIR" == /* ]]; then # If the path is not absolute
            # Convert the path to absolute
            LABS_DIR=$(realpath "$LABS_DIR")
            # Check if the path is a directory and add '/' if it's missing
            if [[ -d "$LABS_DIR" && "$LABS_DIR" != */ ]]; then
                LABS_DIR="$LABS_DIR/"
            fi
        fi
        NUMBER=$3
        echo -e "${BLUE}Custom path for Labs directory:${NO_COLOR} ${YELLOW}$LABS_DIR${NO_COLOR}"
        echo -e "${BLUE}Lab number:${NO_COLOR} ${YELLOW}$NUMBER${NO_COLOR}"
    else # Use default path for PNETLab Store
        LABS_DIR="/opt/unetlab/labs/Your labs from PNETLab Store/"
        NUMBER=$1
    fi

    if ! [[ -d $LABS_DIR ]]; then
        echo "\"Your labs from PNETLab Store\" directory has not been found"
        echo "This folder is automatically created when a lab from PNETLab Store is downloaded"
        exit 0
    fi

    if [[ -z "$(ls -A "$LABS_DIR")" ]]; then
        echo "No labs were found at PNETLab Store folder in server"
        exit 0
    fi

    declare -a readableLabsArray=()
    for file in "$LABS_DIR"*; do
        check=$(grep -Pio 'encoding="UTF-8"' "$file")
        SUB="encoding"
        if [[ $check == *"$SUB"* ]]; then
            readableLabsArray+=("$file")
        fi
    done

    counter_for_readable_labs=0
    for f in "${readableLabsArray[@]}"; do
        counter_for_readable_labs=$((counter_for_readable_labs + 1))
    done

    if [[ ${#readableLabsArray[@]} -eq 0 ]]; then
        STR="No readable labs were found so we cannot download images for any lab"
        echo -e "${RED}[-]$STR\033[0m"
        exit 0
    fi

    if [[ $NUMBER -gt $counter_for_readable_labs || $NUMBER -le 0 ]]; then
        if [[ $counter_for_readable_labs -eq 1 ]]; then
            STR="Last parameter must be 1 because you have only one lab"
            echo -e "${YELLOW}$STR${NO_COLOR}"
        else
            STR="Last parameter must be a number between 1 and $counter_for_readable_labs"
            echo -e "${YELLOW}$STR${NO_COLOR}"
        fi

        echo -e
        list_labs "$1" "$LABS_DIR"
        exit 0
    fi

    file=${readableLabsArray[$((NUMBER - 1))]}
    echo -e "File selected: $file"
    TYPES=(iol dynamips qemu docker)
    for type in "${TYPES[@]}"; do
        images=$(grep -Pio "type=\"$type\".*image=\"\K[^\"]*" "$file" | sort -u)
        echo "$images" >/opt/unetlab/labs/"$type"_images.txt
    done

    list_iol_images=/opt/unetlab/labs/iol_images.txt
    list_dynamips_images=/opt/unetlab/labs/dynamips_images.txt
    list_qemu_images=/opt/unetlab/labs/qemu_images.txt
    list_docker_images=/opt/unetlab/labs/docker_images.txt

    BIN_FLAG=0
    if ! grep -q '[^[:space:]]' $list_iol_images; then BIN_FLAG=1; fi

    DYNAMIPS_FLAG=0
    if ! grep -q '[^[:space:]]' $list_dynamips_images; then DYNAMIPS_FLAG=1; fi

    QEMU_FLAG=0
    if ! grep -q '[^[:space:]]' $list_qemu_images; then QEMU_FLAG=1; fi

    DOCKER_FLAG=0
    if ! grep -q '[^[:space:]]' $list_docker_images; then DOCKER_FLAG=1; fi

    print_separator "List of images found on lab"
    for type in "${TYPES[@]}"; do
        print_separator "List of ${type^^} images"
        list_file="/opt/unetlab/labs/${type}_images.txt"
        if ! grep -qv -e '^\s*$' "$list_file"; then
            echo "No ${type} images found"
        else
            n=1
            while read -r line; do
                echo "File $n : $line"
                n=$((n + 1))
            done <"$list_file"
        fi
    done

    TYPES=(iol dynamips qemu)
    for type in "${TYPES[@]}"; do
        print_separator "Start downloading ${type^^} images for this lab"
        pull_lab_images "$file" "$type"
    done

    print_separator "Start downloading DOCKER images for this lab"
    echo -e "\033[32m$STR_DOCKER\033[0m"
    if [[ DOCKER_FLAG -eq 1 ]]; then
        echo -e "${YELLOW}- Nothing to download${NO_COLOR}"
    else
        echo "Docker images"
        download_lab_docker_images
    fi

    # Remove csv file
    rm "$(pwd)"/"$FILENAME" >/dev/null 2>&1

    # Remove files
    rm /opt/unetlab/labs/{iol_images.txt,dynamips_images.txt,qemu_images.txt,docker_images.txt} >/dev/null 2>&1
}

# Function to download images for all labs
install_images_all_labs() {
    # Check if the user passed a custom path for Labs directory
    if [[ $1 == "mylabs" ]]; then # If the command is "ishare2 mylabs"
        LABS_DIR=$2
        CUSTOM_PATH_FLAG=1
        if [[ ! "$LABS_DIR" == /* ]]; then # If the path is not absolute
            # Convert the path to absolute
            LABS_DIR=$(realpath "$LABS_DIR")
            # Check if the path is a directory and add '/' if it's missing
            if [[ -d "$LABS_DIR" && "$LABS_DIR" != */ ]]; then
                LABS_DIR="$LABS_DIR/"
            fi
        fi
        NOT_FOUND_MESSAGE="Make sure you are passing the correct path to the folder where your labs are located"
        echo -e "${BLUE}Custom path for Labs directory:${NO_COLOR} ${YELLOW}$LABS_DIR${NO_COLOR}"
    else # Use default path for PNETLab Store
        LABS_DIR="/opt/unetlab/labs/Your labs from PNETLab Store/"
        NOT_FOUND_MESSAGE="This folder is automatically created when a lab from PNETLab Store is downloaded"
    fi

    if ! [[ -d $LABS_DIR ]]; then
        echo "\"$LABS_DIR\" directory has not been found"
        echo "$NOT_FOUND_MESSAGE"
        exit 0
    fi

    if [[ -z "$(ls -A "$LABS_DIR")" ]]; then
        echo "No labs found in \"$LABS_DIR\" directory"
        exit 0
    fi

    declare -a readableLabsArray=()
    for file in "$LABS_DIR"*; do
        check=$(grep -Pio 'encoding="UTF-8"' "$file")
        SUB="encoding"
        if [[ $check == *"$SUB"* ]]; then
            readableLabsArray+=("$file")
        fi
    done

    N=${#readableLabsArray[@]}

    if [[ $N -eq 0 ]]; then
        STR="No readable labs have been found so there is no way to continue with this command"
        echo -e "${RED}[-]$STR\033[0m"
        exit 0
    fi

    if [[ $N -eq 1 ]]; then
        echo "Starting to download images for $N lab"
    else
        echo "Starting to download images for $N labs"
    fi

    for ((i = 1; i <= N; i++)); do
        echo -e "\n\033[32mLab $i/$N\033[0m"
        if [[ $CUSTOM_PATH_FLAG -eq 1 ]]; then
            install_images_from_lab "mylabs" "$LABS_DIR" "$i"
        else
            install_images_from_lab "$i"
        fi
    done
    echo -e "\nDone"
}

# Function to download all images of a specific type (IOL, DYNAMIPS, QEMU, DOCKER)
pull_all() {
    TYPE=${1^^}
    if [[ $TYPE == "BIN" ]]; then
        TYPE="IOL"
    fi
    if [[ $TYPE == "QEMU" ]]; then
        echo -e "${YELLOW}[!] WARNING: Pulling all QEMU images will take a long time.\n [!] Make sure you have enough disk space and bandwidth!${NO_COLOR}"
        # Enter confirmation text
        CONFIRMATION="I understand that pulling all QEMU images will take a long time. I have enough disk space and bandwidth."
        # Ask the user to enter the confirmation text
        read -p "[?] Please enter the following text to confirm: \"$CONFIRMATION\" (case sensitive): " -r
        # If the confirmation text is incorrect then exit
        if [[ ! $REPLY =~ ^$CONFIRMATION$ ]]; then
            echo -e "${RED}[!] Aborting.${NO_COLOR}"
            exit 1
        fi
    fi
    echo -e "${YELLOW}[+] Pulling all $TYPE images...${NO_COLOR}"
    # Ask for conirmation
    read -p "[?] Are you sure you want to pull all $TYPE images? (y/n): " -r
    # If reply was no Y or y then exit
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}[!] Aborting.${NO_COLOR}"
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
        echo -e "${YELLOW}[+] Pulling image $i/$total...${NO_COLOR}"
        ishare2 pull ${TYPE,,} $ID
        i=$((i + 1))
    done
}

# Function to pull lab images
pull_lab_images() {
    # Pending to implement: corrections_for_bin_images_in_lab_"$IMAGE_NAME" "$LAB_PATH"
    # Pending to implement: corrections_for_qemu_images_in_lab_"$QEMU_NAME"
    LAB_PATH="$1"
    IMAGE_TYPE="$2"
    IMAGE_TYPE_UPPERCASE=$(echo "$IMAGE_TYPE" | tr '[:lower:]' '[:upper:]')

    filename1="/opt/unetlab/labs/${IMAGE_TYPE}_images.txt"
    n=1
    while read -r line; do
        n=$((n + 1))
        IMAGE_NAME="$line"
        if [[ -z $IMAGE_NAME ]]; then
            echo "No $IMAGE_TYPE images found"
        else
            fetch_json
            # Clear the ID variable at the start of each iteration
            ID=""
            # Search for the image in the "IMAGE_TYPE" section of the JSON file and get the ID
            ID=$(jq -r --arg image_name "$IMAGE_NAME" '.["'"$IMAGE_TYPE_UPPERCASE"'"][] | select(.name == $image_name) | .id' "$TEMP_JSON")

            if [ -n "$ID" ]; then
                # The image was found in the "IMAGE_TYPE" section of the JSON data
                echo "Image '$IMAGE_NAME' found in JSON data. ID: $ID"
                # Download the image
                ishare2 pull "$IMAGE_TYPE" "$ID"
            else
                echo "Image '$IMAGE_NAME' not found in JSON data."
            fi
        fi
    done <"$filename1"
}
