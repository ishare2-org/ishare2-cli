#!/usr/bin/bash
ISHARE2_BASE_URL=https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main
ISHARE2_REPO=$ISHARE2_BASE_URL/ishare2
ISHARE2_PATH=/usr/sbin/ishare2
ISHARE2_LIB_DIR=/opt/ishare2/cli/lib
ISHARE2_MODULES=(
    logger.sh
    sources.sh
    motd.sh
    ui.sh
    config.sh
    downloads.sh
    auth.sh
    labs.sh
    docker.sh
    upgrade_gui.sh
    search.sh
    license.sh
    help.sh
    qemu_handlers.sh
    pull.sh
    logs.sh
    maintenance.sh
    selector.sh
)

if wget -O $ISHARE2_PATH $ISHARE2_REPO; then
    mkdir -p "$ISHARE2_LIB_DIR"
    for module in "${ISHARE2_MODULES[@]}"; do
        wget -O "$ISHARE2_LIB_DIR/$module" "$ISHARE2_BASE_URL/lib/$module" || exit 1
    done
    chmod +x $ISHARE2_PATH && ishare2
else
    echo "Failed to download ishare2"
    exit 1
fi
