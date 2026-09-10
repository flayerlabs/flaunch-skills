#!/usr/bin/env bash
# Re-vendor the Game Mode skills from a gamemode-sdk checkout at a tag.
# Usage: scripts/sync-gamemode-skills.sh <path-to-gamemode-sdk> [ref]   (ref defaults to the checkout's tag or HEAD)
set -euo pipefail
SDK=${1:?usage: sync-gamemode-skills.sh <path-to-gamemode-sdk> [ref]}
REF=${2:-$(git -C "$SDK" describe --tags --exact-match 2>/dev/null || git -C "$SDK" rev-parse --short HEAD)}
DEST=${DEST:-$(cd "$(dirname "$0")/.." && pwd)/skills/advanced}
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# <skill name> <path inside the SDK>. A path absent from $REF is skipped: that skill is canonical here.
for entry in \
  "build-game-mode .agents/skills/build-game-mode" \
  "run-a-game-server .agents/skills/run-a-game-server" \
  "port-game-mode skills/port-game-mode"; do
  set -- $entry; name=$1; src=$2
  if ! git -C "$SDK" cat-file -e "$REF:$src/SKILL.md" 2>/dev/null; then
    echo "skip  $name: $src is not in $REF (canonical copy lives here)"; continue
  fi
  git -C "$SDK" archive "$REF" "$src" | tar -x -C "$TMP"
  rm -rf "$DEST/$name"; mkdir -p "$DEST/$name"; cp -R "$TMP/$src/." "$DEST/$name/"
  awk -v line="<!-- vendored_from: flayerlabs/gamemode-sdk@$REF $src -->" \
    'NR>1 && /^---$/ && !done {print; print line; done=1; next} {print}' \
    "$DEST/$name/SKILL.md" > "$TMP/SKILL.md" && mv "$TMP/SKILL.md" "$DEST/$name/SKILL.md"
  echo "synced $name from $REF:$src"
done
echo "Review 'git diff': re-apply flaunch-skills-only edits (dashboard flow, cross-skill pointers) the SDK copy lacks."
