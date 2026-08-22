#!/bin/bash
# Unit tests for ishare2 modules. No root or network required.
#
# Usage:
#   bash tests/test-units.sh            # uses ../lib relative to this script
#   bash tests/test-units.sh /path/lib  # explicit module directory
set -uo pipefail

LIB_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0

ok()  { echo "[PASS] $1"; PASS=$((PASS + 1)); }
bad() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# Color variables referenced by the modules under test.
RED=''; YELLOW=''; GREEN=''; BLUE=''; NO_COLOR=''
JSON_URL=''
LOG_FILE='/dev/null'
SCR_NAME='unittest'

# 1) Every module must be syntactically valid.
for f in "$LIB_DIR"/*.sh; do
    if bash -n "$f" 2>/dev/null; then
        ok "syntax: $(basename "$f")"
    else
        bad "syntax: $(basename "$f")"
    fi
done

# 2) Every module must source cleanly in a fresh shell.
for f in "$LIB_DIR"/*.sh; do
    if bash -c "source \"$f\"" 2>/dev/null; then
        ok "source: $(basename "$f")"
    else
        bad "source: $(basename "$f")"
    fi
done

# Load the pure functions under test.
# shellcheck source=/dev/null
source "$LIB_DIR/logger.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/ui.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/qemu_handlers.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/config.sh"
# shellcheck source=/dev/null
source "$LIB_DIR/downloads.sh"

# 3) is_risky_script flags scripts that can execute arbitrary code.
is_risky_script "setup.sh"     && ok "is_risky_script flags .sh"        || bad "is_risky_script flags .sh"
is_risky_script "index.php"    && ok "is_risky_script flags .php"       || bad "is_risky_script flags .php"
is_risky_script "SETUP.SH"     && ok "is_risky_script flags .SH (upper)" || bad "is_risky_script flags .SH (upper)"
! is_risky_script "disk.qcow2" && ok "is_risky_script ignores .qcow2"   || bad "is_risky_script ignores .qcow2"
! is_risky_script "readme.txt" && ok "is_risky_script ignores .txt"     || bad "is_risky_script ignores .txt"

# 4) logger writes the expected line to LOG_FILE.
TMP_LOG="$(mktemp)"
LOG_FILE="$TMP_LOG" SCR_NAME="unittest" logger info "unit-test-message"
grep -q "unit-test-message" "$TMP_LOG" && ok "logger writes to LOG_FILE" || bad "logger writes to LOG_FILE"
rm -f "$TMP_LOG"

# 5) Package manager detection resolves to a known backend.
detect_package_manager
case "${PKG_MANAGER:-}" in
    apt|dnf|yum|apk|pacman|zypper) ok "detect_package_manager -> $PKG_MANAGER" ;;
    *) bad "detect_package_manager returned unexpected value: ${PKG_MANAGER:-}" ;;
esac

# 6) Integrity checks: check_image_size / check_image_hash.
TMP_DIR="$(mktemp -d)"
head -c 30000 /dev/zero > "$TMP_DIR/file.bin"
check_image_size "$TMP_DIR" "file.bin" 30000 \
    && ok "check_image_size accepts matching size" || bad "check_image_size accepts matching size"
! check_image_size "$TMP_DIR" "file.bin" 30001 \
    && ok "check_image_size rejects mismatched size" || bad "check_image_size rejects mismatched size"
MD5="$(md5sum "$TMP_DIR/file.bin" | awk '{print $1}')"
check_image_hash "$TMP_DIR" "file.bin" "$MD5" md5 \
    && ok "check_image_hash accepts matching md5" || bad "check_image_hash accepts matching md5"
! check_image_hash "$TMP_DIR" "file.bin" "00000000000000000000000000000000" md5 \
    && ok "check_image_hash rejects mismatched md5" || bad "check_image_hash rejects mismatched md5"
rm -rf "$TMP_DIR"

# 7) The sample lab fixture matches the .unl format ishare2 parses.
FIXTURE="$SCRIPT_DIR/fixtures/sample-lab.unl"
if [[ -f "$FIXTURE" ]]; then
    grep -q 'encoding="UTF-8"' "$FIXTURE" \
        && ok "sample lab has encoding attribute" || bad "sample lab has encoding attribute"
    grep -q 'author="ishare2"' "$FIXTURE" \
        && ok "sample lab has author" || bad "sample lab has author"
    grep -qE 'type="iol".*image="c2600-advsecurityk9-mz.124-15.t14.bin"' "$FIXTURE" \
        && ok "sample lab has iol image" || bad "sample lab has iol image"
else
    bad "sample lab fixture missing: $FIXTURE"
fi

echo
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
