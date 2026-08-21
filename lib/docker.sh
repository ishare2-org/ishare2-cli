# Function to check docker service status
check_docker_service_status() {
    local status=$(service docker status)

    if echo "$status" | grep -q "active (running)"; then
        return 0
    fi

    if echo "$status" | grep -q "inactive (dead)"; then
        echo -e "${RED}Detected: Docker service is down. Trying to restart it${NO_COLOR}"
        service docker restart
        status=$(service docker status)
    fi

    if echo "$status" | grep -q "active (running)"; then
        echo -e "${GREEN}Docker service has been restarted successfully${NO_COLOR}"
        return 0
    else
        echo -e "${RED}There was a problem trying to start docker service${NO_COLOR}"
        echo -e "Information about service docker status command:\n"
        echo "$status"
    fi
}

# Function to list docker images
list_dockers() {
    echo -e "\nDocker images in server"
    docker images
}

# Function to count docker images
count_dockers() {
    data=$(docker images | wc -l)
    docker_count=$((data - 1))

    if [[ $docker_count -eq 1 ]]; then
        echo -e "\n$docker_count docker image found in server"
    else
        echo -e "\n$docker_count docker images found in server"
    fi
}

# Function to correct the docker image name referenced inside a lab file
corrections_for_docker_images_in_lab_function() {
    DOCKER_NAME=$1
    LAB_PATH=$2

    declare -a array=(
        "eve-ostinato"
        "eve-ostinato-bionic"
        "eve-ostinato-focal"
        "eve-dind"
        "eve-dind-focal"
        "eve-chrome"
        "eve-chrome-bionic"
        "eve-chrome-focal"
        "eve-firefox"
        "eve-firefox-bionic"
        "eve-firefox-focal"
        "eve-desktop"
        "eve-desktop-bionic"
        "eve-desktop-focal"
        "eve-gui-server"
        "eve-gui-server-bionic"
        "eve-gui-server-focal"
        "eve-wireshark"
        "eve-wireshark-bionic"
        "eve-wireshark-focal"
        "eve-kali"
        "eve-kali-large"
        "eve-napalm-focal"
        "eve-ansible-focal"
        "dockergui-rdp"
        "eve-gui-server:latest"
        "eve-gui-server-bionic:latest"
    )

    for i in "${array[@]}"; do
        if [[ $DOCKER_NAME == "$i" ]]; then
            OLD_FILENAME=$DOCKER_NAME
            NEW_FILENAME=eveng/$DOCKER_NAME

            DOCKER_NAME=$NEW_FILENAME
            echo -e "\nDocker image name changed from:\n$OLD_FILENAME"
            echo -e "to\n$NEW_FILENAME\n"

            echo "Changing docker image name inside .unl lab file"
            echo Lab file: "$LAB_PATH"
            sed -i -e s+"$OLD_FILENAME"+"$NEW_FILENAME"+g "$LAB_PATH"
            echo -e "Changing: OK\n"
        fi
    done
}

# Function to download the docker images referenced by a lab
download_lab_docker_images() {
    filename1=/opt/unetlab/labs/docker_images.txt

    # Check docker service status before pulling any docker image
    if check_docker_service_status; then # When 0 is returned
        while read -r line; do
            DOCKER_NAME=$line

            corrections_for_docker_images_in_lab_"$DOCKER_NAME" "$LAB_PATH"

            STR="Docker requested: "
            echo -e "\033[33m$STR\033[0m $DOCKER_NAME"

            docker pull "$DOCKER_NAME"
        done <"$filename1"
    fi

    list_dockers
    count_dockers
}
