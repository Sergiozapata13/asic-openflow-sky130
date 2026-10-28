#!/usr/bin/env bash
# Copy the small, useful reports of one ORFS run into reports/<run>/ and write
# a summary.txt with the key lines from its logs.
# Usage: scripts/collect_reports.sh <run> [ORFS_DIR]   (PLATFORM defaults to sky130hd)
set -euo pipefail

RUN="${1:?usage: $0 <run> [ORFS_DIR]}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ORFS_DIR="${2:-$HOME/OpenROAD-flow-scripts}"
PLATFORM="${PLATFORM:-sky130hd}"
SRC_R="$ORFS_DIR/flow/reports/$PLATFORM/$RUN/base"
SRC_L="$ORFS_DIR/flow/logs/$PLATFORM/$RUN/base"
DEST="$REPO_DIR/reports/$RUN"

if [ ! -d "$SRC_R" ]; then
  echo "error: $SRC_R not found" >&2
  exit 1
fi
mkdir -p "$DEST"

for f in synth_stat.txt synth_check.txt 6_finish.rpt 6_drc_count.rpt drt_antennas.log \
         final_all.webp final_routing.webp final_placement.webp final_congestion.webp \
         final_worst_path.webp final_clocks.webp; do
  if [ -f "$SRC_R/$f" ]; then
    cp "$SRC_R/$f" "$DEST/"
  fi
done

# grep that never fails when a file or a match is missing
g() { [ -f "$2" ] && grep -E "$1" "$2" || true; }

{
  echo "run: $RUN ($PLATFORM)"
  echo "--- synthesis area"
  g "Chip area|sequential elements" "$SRC_R/synth_stat.txt" | tail -n 2
  echo "--- final timing"
  g "^(tns|wns) max|worst slack max" "$SRC_R/6_finish.rpt"
  echo "--- detailed route violations (last)"
  g "DRT-0199" "$SRC_L/5_2_route.log" | tail -n 1
  echo "--- global route congestion"
  [ -f "$SRC_L/5_1_grt.log" ] && grep -A10 "Final congestion report" "$SRC_L/5_1_grt.log" || true
  echo "--- final area"
  g "Design area" "$SRC_L/6_report.log"
  echo "--- logic equivalence (final)"
  [ -f "$SRC_L/6_final_lec_check.log" ] && tail -n 1 "$SRC_L/6_final_lec_check.log" || true
  echo "--- KLayout DRC count"
  [ -f "$SRC_R/6_drc_count.rpt" ] && cat "$SRC_R/6_drc_count.rpt" || echo "not run"
} > "$DEST/summary.txt"

echo "collected into $DEST:"
ls -la "$DEST"
