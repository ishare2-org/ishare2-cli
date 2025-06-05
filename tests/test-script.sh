#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Global Variables
# ─────────────────────────────────────────────────────────────────────────────
GLOBAL_IMAGE_NAME="linux-tinycore-6.4"
QEMU_IMAGE_NAME="linux-tinycore-6.4"
IOL_IMAGE_NAME="c2600-advsecurityk9-mz.124-15.t14.bin"
DYNAMIPS_IMAGE_NAME="c1710-bk9no3r2sy-mz.124-23.image"

# ─────────────────────────────────────────────────────────────────────────────
# Logger
# ─────────────────────────────────────────────────────────────────────────────
log() {
    echo "[${1:-INFO}] ${2}" >&2 # Redirect to stderr
}

# ─────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────

copy_binary() {
    log INFO "Copying ishare2 to /usr/sbin"
    sudo cp ishare2 /usr/sbin/ishare2
    log INFO "Setting permissions for /usr/sbin/ishare2"
    sudo chmod 755 /usr/sbin/ishare2
}

init_ishare2() {
    log INFO "Running ishare2 --init"
    if sudo ishare2 --init >/dev/null 2>&1; then
        log INFO "ishare2 initialized successfully"
    else
        log ERROR "ishare2 --init failed"
        exit 1
    fi
}

search_image() {
    local scope="$1"
    local name="$2"
    log INFO "Searching ${scope:-global} ${name}"
    if [ -n "$scope" ]; then
        sudo ishare2 search "$scope" "$name" || exit 1
    else
        sudo ishare2 search "$name" || exit 1
    fi
}

# Fixed function: Log to stderr and clean ID output
get_image_id() {
    local scope="$1"
    local name="$2"

    # Log to stderr only
    log INFO "Getting ID for $name ($scope)" >&2

    local id
    if [ -n "$scope" ]; then
        id=$(sudo ishare2 search "$scope" "$name" 2>/dev/null | grep -w "$name" | awk '{print $1}' | head -n1)
    else
        id=$(sudo ishare2 search "$name" 2>/dev/null | grep -w "$name" | awk '{print $1}' | head -n1)
    fi

    id="${id//[^0-9]/}" # Remove non-numeric characters

    if [ -z "$id" ]; then
        log ERROR "No ID found for $name ($scope)"
        exit 1
    fi

    # Clean output to stdout (ID only)
    echo "$id"
}

pull_image() {
    local scope="$1"
    local id="$2"
    local log_path="/tmp/${scope}_pull.log"

    log INFO "Pulling $scope image with ID: $id"
    if sudo ishare2 pull "$scope" "$id" 2>&1 | tee "$log_path" | tail -n 10; then
        log INFO "Pull successful for $scope ID: $id"
    else
        log ERROR "Failed to pull $scope image with ID: $id"
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Execution
# ─────────────────────────────────────────────────────────────────────────────

copy_binary
init_ishare2

# Step 1: Global search
search_image "" "$GLOBAL_IMAGE_NAME"
global_id=$(get_image_id "" "$GLOBAL_IMAGE_NAME")

# Step 2: QEMU test
search_image qemu "$QEMU_IMAGE_NAME"
qemu_id=$(get_image_id qemu "$QEMU_IMAGE_NAME")
pull_image qemu "$qemu_id"

# Step 3: IOL test
search_image iol "$IOL_IMAGE_NAME"
iol_id=$(get_image_id iol "$IOL_IMAGE_NAME")
pull_image iol "$iol_id"

# Step 4: DYNAMIPS test
search_image dynamips "$DYNAMIPS_IMAGE_NAME"
dynamips_id=$(get_image_id dynamips "$DYNAMIPS_IMAGE_NAME")
pull_image dynamips "$dynamips_id"

# Step 5: Show installed images
log INFO "Installed images for each scope:"
TYPES=("qemu" "iol" "dynamips")
for scope in "${TYPES[@]}"; do
    log INFO "Installed images: $scope"
    sudo ishare2 installed "$scope" || {
        log ERROR "Failed to list installed images for: $scope"
        exit 1
    }

done

# Step 6: Success
log RESULT "✅ ALL TESTS PASSED"

# Step 7: Cleanup
log INFO "Cleanup"
sudo rm /usr/sbin/ishare2
rm -f ishare2
