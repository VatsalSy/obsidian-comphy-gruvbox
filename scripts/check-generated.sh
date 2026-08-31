#!/usr/bin/env bash
# Fails when the committed theme.css does not match a fresh build of
# src/theme/*.css. Obsidian loads theme.css and the release workflow uploads it
# verbatim, so a stale artefact ships silently.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/build-theme.sh

if ! git diff --quiet -- theme.css; then
  echo "error: theme.css is stale. Run scripts/build-theme.sh and commit the result." >&2
  git --no-pager diff --stat -- theme.css >&2
  exit 1
fi

# manifest.json is what Obsidian reads; package.json is repository metadata.
# They drifted once already, so keep them pinned together.
manifest_version="$(node -p "require('./manifest.json').version")"
package_version="$(node -p "require('./package.json').version")"
if [[ "$manifest_version" != "$package_version" ]]; then
  echo "error: manifest.json is $manifest_version but package.json is $package_version." >&2
  exit 1
fi

echo "generated artefacts are in sync (version $manifest_version)"
