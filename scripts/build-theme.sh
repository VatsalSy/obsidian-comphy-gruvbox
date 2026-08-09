#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/src/theme"
OUT_FILE="$ROOT_DIR/theme.css"

parts=(
  "tokens.css"
  "foundations.css"
  "components.css"
  "navigation.css"
  "plugins.css"
  "accessibility.css"
  "plum.css"
)

tmp_dir="$(dirname "$OUT_FILE")"
tmp_file="$(mktemp "$tmp_dir/.theme.css.tmp.XXXXXX")"
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT INT TERM
existing_mode=""

if [[ -e "$OUT_FILE" ]]; then
  if existing_mode="$(stat -f '%Lp' "$OUT_FILE" 2>/dev/null)"; then
    :
  else
    existing_mode="$(stat -c '%a' "$OUT_FILE")"
  fi
fi

{
  echo "/*"
  echo " * comphy-obsidian-theme"
  echo " * Generated file. Do not edit directly."
  echo " * Source: src/theme/*.css"
  echo " */"
  echo

  for part in "${parts[@]}"; do
    if [[ ! -f "$SRC_DIR/$part" ]]; then
      echo "Missing source file: $SRC_DIR/$part" >&2
      exit 1
    fi

    echo "/* ========================================================================== */"
    echo "/* $part */"
    echo "/* ========================================================================== */"
    cat "$SRC_DIR/$part"
    echo
  done
} > "$tmp_file"

mv "$tmp_file" "$OUT_FILE"
if [[ -n "$existing_mode" ]]; then
  chmod "$existing_mode" "$OUT_FILE"
else
  chmod 644 "$OUT_FILE"
fi

echo "Built $OUT_FILE"
