# Function to show information about ishare2
show_info() {
    echo -e "- For documentation about ishare2, visit: https://github.com/ishare2-org/ishare2-cli"
    echo -e "- If you face any issues with ishare2, please report them at @NetLabHub Telegram Group. Attach screenshots and relevant information."
    echo -e "- You can use ${YELLOW}ishare2 config${NO_COLOR} to change the chosen downloader."
    echo -e "- If you cancel a download, use the flag: --overwrite to first delete the existing image and then download it again."
    echo -e "- To submit new images, please use the following Google Form: https://forms.gle/SotrznrN3CmZdg8M8"
    echo -e "- Telegram Channel: https://t.me/NetLabHub (For announcements and updates)"
    echo -e "- Email: contact@labhub.eu.org"
}

# Function to show help for ishare2
show_ishare2_help() {
    # For ishare2
    ISHARE2_VERSION_INFO=$(cat $ISHARE2_DIR/ishare2_version)
    UPSTREAM_VERSION=$(curl -s "$URL_VERSION")
    if ! [[ $ISHARE2_VERSION_INFO == "$UPSTREAM_VERSION" ]]; then
        ISHARE2_VERSION_INFO="$ISHARE2_VERSION_INFO $(echo -e "${YELLOW}Update available: $UPSTREAM_VERSION. Run: ishare2 upgrade${NO_COLOR}")"
    else
        ISHARE2_VERSION_INFO="$ISHARE2_VERSION_INFO $(echo -e "${GREEN}Up to date${NO_COLOR}")"
    fi

    # For PNETLab
    data=$(mysql -uroot -ppnetlab -D pnetlab_db -e "SELECT control_value FROM control WHERE control_value>1;" 2>/dev/null)
    pnetlab_info=($data)
    if [[ ${#pnetlab_info[@]} -eq 0 ]]; then
        PNETLAB_INSTALLED=$(echo -e "${RED}PNETLab is not installed.${NO_COLOR}")
    else
        PNETLAB_INSTALLED=$(echo -e "${GREEN}PNETLab v${pnetlab_info[1]} is installed.${NO_COLOR}")
    fi
    cat <<EOF
Syntax

ishare2 [action] [param1] [param2] [--overwrite]

action:
    search      : Search for images by type
    pull        : Download an image by type and number
    installed   : Show installed images on server
    labs        : Show labs on server and download images for those labs
    mylabs      : Same as labs command but using a customized path to labs
    relicense   : Generate a new iourc license for bin images
    upgrade     : Retrieves a menu that allows users to upgrade ishare2 and PNETLab VM
    changelog   : Show the latest changes made to ishare2
    gui         : Web app to use ishare2 in browser
    test        : Test internet connectivity to required sites (Github, Google Sheets)
    help        : Show useful information

param1:
    type = all, bin, qemu, dynamips, docker or name

param2:
    number = This number can be obtained using ishare2 search <type>

--overwrite:
    Used to overwrite an existing image if it already exists on your system.

Examples:

- ishare2 search <type>
    - ishare2 search all
    - ishare2 search bin
    - ishare2 search qemu
    - ishare2 search dynamips
    - ishare2 search <name>
        Examples:
            - ishare2 search vios
            - ishare2 search win-
            - ishare2 search winserver
            - ishare2 search kali
            - ishare2 search mikro
            - ishare2 search forti
            - ishare2 search nxos
            - ishare2 search vmx
            - ishare2 search esxi
            - ishare2 search palo
            - ishare2 search Licensed
            - More <name> options using ishare2 search all

- ishare2 pull bin <number> [--overwrite]
- ishare2 pull qemu <number> [--overwrite]
- ishare2 pull dynamips <number> [--overwrite]

- ishare2 pull bin all
- ishare2 pull qemu all (Not available for qemu type due to its large size)
- ishare2 pull dynamips all

- ishare2 installed all
- ishare2 installed bin
- ishare2 installed qemu
- ishare2 installed dynamips
- ishare2 installed docker

- ishare2 labs
- ishare2 labs <number>
- ishare2 labs all

- ishare2 mylabs <path>
- ishare2 mylabs <path> <number>
- ishare2 mylabs <path> all

- ishare2 gui install
- ishare2 gui start
- ishare2 gui stop
- ishare2 gui restart

- ishare2 relicense
- ishare2 upgrade
- ishare2 changelog
- ishare2 test
- ishare2 config
- ishare2 help

ishare2: $ISHARE2_VERSION_INFO
ishare2 Channel: $CHANNEL
$PNETLAB_INSTALLED
EOF
}

# Function to show quick help for ishare2
ishare2_quick_help() {
    cat <<EOF
Syntax

ishare2 [action] [param1] [param2] [--overwrite]

action:
    search      : Search for images available on LabHub mirrors.
    pull        : Download an image by specifying the type and id.
    installed   : Shows images installed on the server.
    labs        : Shows available labs and downloads the images for the selected lab.
    mylabs      : Same as labs command but you can use a customized path.
    relicense   : Generates an iourc license for iol images.
    upgrade     : Shows a menu to upgrade ishare2 or PNETLab.
    test        : Test internet connectivity to required sites.
    help        : Shows full help information.

param1:
    type = all, iol, qemu, dynamips, docker or name.

param2:
    id = This can be obtained using ishare2 search <type>

--overwrite:
    Used to overwrite an existing image if it already exists on your system.

Try: ishare2 help for more information.
EOF
}
