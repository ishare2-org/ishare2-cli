#!/usr/bin/bash
ISHARE2_REPO=https://raw.githubusercontent.com/ishare2-org/ishare2-cli/dev/ishare2
ISHARE2_PATH=/usr/sbin/ishare2

if wget -O $ISHARE2_PATH $ISHARE2_REPO; then
    chmod +x $ISHARE2_PATH && ishare2
else
    echo "Failed to download ishare2"
    exit 1
fi
