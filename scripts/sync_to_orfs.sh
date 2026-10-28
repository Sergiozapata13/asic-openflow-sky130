#!/usr/bin/env bash
# Copy this repository's designs into an ORFS checkout, so they can be run
# with util/docker_shell (Docker only mounts the ORFS flow/ directory, so
# symbolic links pointing outside it do not work inside the container).
#
# Usage: scripts/sync_to_orfs.sh [ORFS_DIR]   (default: ~/OpenROAD-flow-scripts)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORFS_DIR="${1:-$HOME/OpenROAD-flow-scripts}"
DEST="$ORFS_DIR/flow/designs"

if [ ! -d "$DEST" ]; then
  echo "error: $DEST not found" >&2
  exit 1
fi

for sub in src sky130hd; do
  if [ -d "$REPO_DIR/designs/$sub" ]; then
    rsync -av "$REPO_DIR/designs/$sub/" "$DEST/$sub/"
  fi
done
