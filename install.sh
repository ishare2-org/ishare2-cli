#!/bin/sh
# ishare2 installer
#
# Usage:
#   curl https://ishare2.sh/install | sh
#   curl https://ishare2.sh/install | DEV=true sh
#   wget -qO- https://ishare2.sh/install | sh
#
# Downloads the latest release bundle for the selected branch (default: main)
# from GitHub Releases and installs it.
set -e

ISHARE2_DIR=/opt/ishare2/cli
ISHARE2_LIB_DIR=$ISHARE2_DIR/lib
ISHARE2_PATH=/usr/sbin/ishare2
REPO=ishare2-org/ishare2-cli

# Require root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: please run this installer as root (or with sudo)."
    exit 1
fi

# Determine branch: DEV=true (or first argument "dev") selects the dev branch.
BRANCH=main
case "${DEV:-}" in
    true|TRUE|True|1|yes|YES|Yes|y|Y) BRANCH=dev ;;
esac
case "${1:-}" in
    dev) BRANCH=dev ;;
esac

echo "[*] Installing ishare2 (branch: $BRANCH)..."

# Pick a downloader
if command -v curl >/dev/null 2>&1; then
    fetch() { curl -fsSL "$1"; }
    fetch_to() { curl -fsSL -o "$2" "$1"; }
elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -qO- "$1"; }
    fetch_to() { wget -q -O "$2" "$1"; }
else
    echo "Error: curl or wget is required."
    exit 1
fi

# Find the latest release tag for the selected branch
API_URL="https://api.github.com/repos/$REPO/releases?per_page=100"

RELEASES=$(fetch "$API_URL") || {
    echo "Error: failed to query GitHub releases."
    exit 1
}

TAG=$(printf '%s\n' "$RELEASES" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' \
    | grep -- "-$BRANCH$" \
    | head -n 1)

if [ -z "$TAG" ]; then
    echo "Error: no release found for the '$BRANCH' branch."
    exit 1
fi

echo "[*] Latest $BRANCH release: $TAG"

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/$TAG.zip"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ZIP_FILE="$TMPDIR/$TAG.zip"

echo "[*] Downloading $TAG.zip..."
fetch_to "$DOWNLOAD_URL" "$ZIP_FILE"

# Ensure unzip is available
if ! command -v unzip >/dev/null 2>&1; then
    echo "[*] Installing unzip..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq && apt-get install -y -qq unzip
    elif command -v yum >/dev/null 2>&1; then
        yum install -y unzip
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y unzip
    else
        echo "Error: unzip is required but could not be installed automatically."
        exit 1
    fi
fi

echo "[*] Extracting..."
unzip -o -q "$ZIP_FILE" -d "$TMPDIR/root"

# Install entrypoint
mkdir -p "$ISHARE2_DIR"
if command -v install >/dev/null 2>&1; then
    install -m 755 "$TMPDIR/root/ishare2" "$ISHARE2_PATH"
else
    cp "$TMPDIR/root/ishare2" "$ISHARE2_PATH"
    chmod 755 "$ISHARE2_PATH"
fi

# Install modules
mkdir -p "$ISHARE2_LIB_DIR"
cp "$TMPDIR/root/lib/"*.sh "$ISHARE2_LIB_DIR/"

# Install the man page
if [ -f "$TMPDIR/root/ishare2.1" ]; then
    mkdir -p /usr/share/man/man1
    if command -v gzip >/dev/null 2>&1; then
        gzip -c "$TMPDIR/root/ishare2.1" > /usr/share/man/man1/ishare2.1.gz
    else
        cp "$TMPDIR/root/ishare2.1" /usr/share/man/man1/ishare2.1
    fi
fi

echo "[*] ishare2 installed successfully."
echo "[*] Launching ishare2..."
exec "$ISHARE2_PATH"
