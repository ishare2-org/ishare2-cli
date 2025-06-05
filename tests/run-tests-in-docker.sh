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
docker build -f Dockerfile.test -t ishare2-test-env .

# Start container
CID=$(docker run -d --rm -it ishare2-test-env sleep infinity)

# Copy test binary and script
docker cp "$ISHARE2_BIN" "$CID:/home/testuser/ishare2"
docker cp ./test-script.sh "$CID:/home/testuser/test-script.sh"

# Run test inside container
docker exec -u testuser "$CID" bash ./test-script.sh

# Stop container
docker stop "$CID"
