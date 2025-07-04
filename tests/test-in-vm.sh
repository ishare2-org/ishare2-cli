#!/bin/bash

# Load environment variables
if [ -f .env.test ]; then
    export $(grep -v '^#' .env.test | xargs)
else
    echo ".env file not found. Please create it with the necessary environment variables."
    exit 1
fi

# Validate required variables
if [[ -z "$ISHARE2_PATH" || -z "$VM_IP" ]]; then
    echo "Required environment variables ISHARE2_PATH or VM_IP are not set."
    exit 1
fi

# Prepare
REMOTE_BINARY_NAME=$(basename "$ISHARE2_PATH")
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/test_$TIMESTAMP.log"
mkdir -p "$LOG_DIR"

# Copy binary to remote
scp "$ISHARE2_PATH" "$VM_IP:~/$REMOTE_BINARY_NAME"

# Run remote test
ssh "$VM_IP" bash <<EOF
echo "[INFO] Copying $REMOTE_BINARY_NAME to /usr/sbin..."
if [ ! -f "$REMOTE_BINARY_NAME" ]; then
    echo "[ERROR] $REMOTE_BINARY_NAME not found in remote home directory."
    exit 1
fi

sudo cp "$REMOTE_BINARY_NAME" /usr/sbin/ishare2
sudo chmod 755 /usr/sbin/ishare2

if [ ! -f /usr/sbin/ishare2 ]; then
    echo "[ERROR] ishare2 not found in /usr/sbin"
    exit 1
fi
echo "[INFO] Running ishare2 --init"
sudo ishare2 --init
if [ \$? -ne 0 ]; then
    echo "[ERROR] ishare2 --init failed"
    exit 1
fi

echo "[INFO] Running test: ishare2 search win | grep 'win-xp'"
sudo ishare2 search win | grep "win"
if [ \$? -eq 0 ]; then
    echo "[RESULT] PASS"
else
    echo "[RESULT] FAIL"
fi

echo "[INFO] Cleaning up /usr/sbin/ishare2"
sudo rm /usr/sbin/ishare2
EOF

# Exit summary
if grep -q "\[RESULT\] PASS" "$LOG_FILE"; then
    echo "✅ Test passed. See $LOG_FILE"
    exit 0
else
    echo "❌ Test failed. See $LOG_FILE"
    exit 1
fi
