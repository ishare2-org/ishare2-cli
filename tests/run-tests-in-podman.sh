#!/bin/bash

set -euo pipefail

# Load .env
if [ -f .env.test ]; then
    export $(grep -v '^#' .env.test | xargs)
else
    echo ".env.test not found"
    exit 1
fi

# Build test container
podman build -f Dockerfile.test -t ishare2-test-env .

# Start container
CID=$(podman run -d --rm ishare2-test-env sleep infinity)
trap 'podman stop "$CID" >/dev/null 2>&1 || true' EXIT

# Copy test binary, modules, and script
podman cp "$ISHARE2_BIN" "$CID:/home/testuser/ishare2"
podman cp ../lib "$CID:/home/testuser/lib"
podman cp ./test-script.sh "$CID:/home/testuser/test-script.sh"

# Run test inside container
podman exec -u testuser "$CID" bash ./test-script.sh
