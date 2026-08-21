# Function to search for images in the JSON index
search_images() {
    TYPE=${1^^}
    FILTER=${2:-}
    VALID_TYPES=("IOL" "QEMU" "DYNAMIPS")

    if [[ "$TYPE" == "ANY" || ! " ${VALID_TYPES[*]} " =~ " ${TYPE} " ]]; then
        SEARCH_ACROSS=true
    else
        SEARCH_ACROSS=false
    fi

    fetch_json

    if [[ "$SEARCH_ACROSS" == true ]]; then
        print_separator "Searching across all types for \"$FILTER\""

        data=$(jq -r --arg filter "$FILTER" '
          . as $root
          | ["IOL", "QEMU", "DYNAMIPS"] 
          | map($root[.][] 
            | select(($filter | length == 0) or (.name | test($filter; "i")))
            | [.id, .name, ., .metadata.total_human_size] 
            | [.[0], .[1], .[2].type, .[3]]) 
          | .[] 
          | @tsv
        ' "$TEMP_JSON")

        if [[ -z "$data" ]]; then
            echo -e "\n${RED}No matching images found for \"$FILTER\"${NO_COLOR}"
        else
            {
                echo -e "ID\tNAME\tTYPE\tSIZE"
                echo -e "--\t----\t----\t----"
                echo "$data"
            } | column -t -s $'\t'

            total_count=$(echo "$data" | wc -l)
            echo -e "\n${GREEN}$total_count image(s) found${NO_COLOR}"
        fi

    else
        print_separator "Available $TYPE images"

        data=$(jq -r --arg type "$TYPE" --arg filter "$FILTER" '
          .[$type][] 
          | select(($filter | length == 0) or (.name | test($filter; "i"))) 
          | [.id, .name, .metadata.total_human_size] 
          | @tsv' "$TEMP_JSON")

        if [[ -z "$data" ]]; then
            echo -e "\n${RED}No $TYPE images found for \"$FILTER\"${NO_COLOR}"
        else
            {
                echo -e "ID\tNAME\tSIZE"
                echo -e "--\t----\t----"
                echo "$data"
            } | column -t -s $'\t'

            total_count=$(echo "$data" | wc -l)
            echo -e "\n${GREEN}$total_count $TYPE image(s) found${NO_COLOR}"
        fi
    fi
    echo -e "${YELLOW}[!] ${NO_COLOR}You can use the command \033[32mishare2 pull <type> <id>\033[0m to download the image"
}
