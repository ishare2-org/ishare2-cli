#!/bin/bash

set -e

# === Paths ===
ISHARE_FILE="ishare2"
VERSION_FILE="version"
MOTD_FILE="motd.json"

# === Display current version info ===
echo "=== Current Version Info ==="
grep "^# Version:" "$ISHARE_FILE"
grep "^# Last Updated:" "$ISHARE_FILE"
echo -n "version: "
cat "$VERSION_FILE"
echo "motd.json:"
jq . "$MOTD_FILE"
echo "============================"
echo

# === Confirm continuation ===
read -rp "Continue with release process? (y/N): " CONFIRM
[[ ! $CONFIRM =~ ^[Yy]$ ]] && echo "Aborted." && exit 1

# === Prompt for inputs ===
read -rp "Enter new version (e.g. 1.0.1): " VERSION
echo "Enter changelog items one at a time. Type 's' and press Enter to finish:"
CHANGELOG_ITEMS=()
while true; do
  read -rp "Change ${#CHANGELOG_ITEMS[@]}: " line
  [[ "$line" == "s" ]] && break
  [[ -z "$line" ]] && continue
  CHANGELOG_ITEMS+=("$line")
done

# === Line wrapper ===
wrap_line() {
  local line="$1"
  local max=28
  local out=""
  while [[ -n "$line" ]]; do
    if [[ ${#line} -le $max ]]; then
      out+="$line"
      break
    fi
    local chunk="${line:0:$max}"
    local space_pos=$(echo "$chunk" | awk '
      {
        pos = 0;
        for (i = length($0); i > 0; i--) {
          if (substr($0, i, 1) == " ") {
            pos = i;
            break;
          }
        }
        print pos
      }')

    if [[ $space_pos -gt 0 ]]; then
      out+="${chunk:0:$space_pos}\n"
      line="${line:$space_pos}"
      line="${line#"${line%%[![:space:]]*}"}"
    else
      out+="${chunk}-\n"
      line="${line:$max}"
    fi
  done
  echo -e "$out"
}

# === Build release body properly ===
RELEASE_BODY_LINES=()
for item in "${CHANGELOG_ITEMS[@]}"; do
  wrapped=$(wrap_line "- $item")
  RELEASE_BODY_LINES+=("$wrapped")
done
RELEASE_BODY=$(printf "%s\n" "${RELEASE_BODY_LINES[@]}")

# === Variables ===
TODAY=$(date +%F)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SUFFIX="-${BRANCH}"
FULL_VERSION="${VERSION}${SUFFIX}"
RELEASE_NAME="ishare2-${FULL_VERSION}"
RELEASE_TITLE="ishare2 ${FULL_VERSION}"

# === Update ishare2 metadata ===
echo "[*] Updating $ISHARE_FILE..."
sed -i "s/^# Version: .*/# Version: ${FULL_VERSION}/" "$ISHARE_FILE"
sed -i "s/^# Last Updated: .*/# Last Updated: ${TODAY}/" "$ISHARE_FILE"
sed -i "s/^VERSION=\".*\"/VERSION=\"${FULL_VERSION}\"/" "$ISHARE_FILE"

# === Update version file ===
echo "[*] Updating version file..."
echo "$FULL_VERSION" >"$VERSION_FILE"

# === Update MOTD ===
echo "[*] Updating $MOTD_FILE..."
jq --arg msg "$RELEASE_BODY" --arg date "$TODAY" '
  .message = "Changelog:\n" + $msg
  | .last_shown_date = $date
  | .show_count = 0
' "$MOTD_FILE" >tmp_motd.json && mv tmp_motd.json "$MOTD_FILE"

# === Git commit ===
echo "[*] Committing changes..."
git add "$ISHARE_FILE" "$VERSION_FILE" "$MOTD_FILE"
git commit -m "Release $FULL_VERSION"

# === Git tag ===
echo "[*] Tagging and pushing..."

if git rev-parse "$RELEASE_NAME" >/dev/null 2>&1; then
  echo "⚠️  Tag '$RELEASE_NAME' already exists."
  read -rp "Do you want to delete and recreate it? (y/N): " TAG_CONFIRM
  if [[ "$TAG_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[*] Deleting existing tag..."
    git tag -d "$RELEASE_NAME"
    git push --delete origin "$RELEASE_NAME"
  else
    echo "❌ Aborting release due to existing tag."
    exit 1
  fi
fi

git tag -a "$RELEASE_NAME" -m "Release $FULL_VERSION"
git push origin "$BRANCH"
git push origin "$RELEASE_NAME"

# === GitHub release ===
echo "[*] Creating GitHub release..."

RELEASE_BODY_FILE=$(mktemp)
echo -e "$RELEASE_BODY" >"$RELEASE_BODY_FILE"

gh release create "$RELEASE_NAME" \
  -t "$RELEASE_TITLE" \
  -F "$RELEASE_BODY_FILE" \
  ./ishare2 || {
  echo "❌ Failed to create GitHub release. Please check your GitHub CLI setup."
  rm -f "$RELEASE_BODY_FILE"
  exit 1
}

rm -f "$RELEASE_BODY_FILE"

echo
echo "🔗 Visit release page: https://github.com/ishare2-org/ishare2-cli/releases/latest"
echo "✅ Release $FULL_VERSION complete!"
echo "============================"
