#!/bin/bash

set -euo pipefail

# Usage: ./run-tests-in-docker.sh [distro]
#   distro  Name of the base image to test (default: ubuntu).
#           See Dockerfile.<distro> for available options.
DISTRO="${1:-ubuntu}"
DOCKERFILE="Dockerfile.${DISTRO}"
IMAGE="ishare2-test-env:${DISTRO}"

if [[ ! -f "$DOCKERFILE" ]]; then
    echo "Unknown distro: '$DISTRO' (missing $DOCKERFILE)"
    echo "Usage: $0 [distro]"
    echo "Available: $(ls Dockerfile.* 2>/dev/null | sed 's/^Dockerfile\.//' | tr '\n' ' ')"
    exit 1
fi

# Load .env
if [ -f .env.test ]; then
    export $(grep -v '^#' .env.test | xargs)
else
    echo ".env.test not found"
    exit 1
fi

echo "Testing distro: $DISTRO"

# Build test container
docker build -f "$DOCKERFILE" -t "$IMAGE" .

# Start container
CID=$(docker run -d --rm "$IMAGE" sleep 86400)

# Copy test binary and script
docker cp "$ISHARE2_BIN" "$CID:/home/testuser/ishare2"
docker cp ../lib "$CID:/home/testuser/lib"
docker cp ./test-script.sh "$CID:/home/testuser/test-script.sh"
docker cp ./test-units.sh "$CID:/home/testuser/test-units.sh"
docker cp ./fixtures "$CID:/home/testuser/fixtures"

# Run unit tests (fast, no network or root required)
docker exec -u testuser "$CID" bash ./test-units.sh /home/testuser/lib

# Run integration test inside container
docker exec -u testuser "$CID" bash ./test-script.sh

# Stop container
docker stop "$CID"
