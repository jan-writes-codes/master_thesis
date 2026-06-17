#!/usr/bin/env bash
# =============================================================================
# tools/make_snapshot.sh <out-dir>
# -----------------------------------------------------------------------------
# Runs the whole analysis pipeline (each script in its own R process, in
# parallel), rendering exhibits to a throwaway dir and fingerprinting every
# result object via tools/snapshot.R. Produces, under <out-dir>:
#   <script>/_digest.csv, <script>/full__*.csv, <script>/console.txt
#   _pdftext/<exhibit>.pdf.txt   (text layer of every regenerated PDF)
#
# Verify a refactor with:
#   tools/make_snapshot.sh snapshots/before   # on the pre-refactor commit
#   tools/make_snapshot.sh snapshots/after    # after refactoring
#   diff -r snapshots/before snapshots/after  # must be empty (ignore console
#                                             # timing if ever added)
# Run from anywhere; it locates the repo root from its own path.
# =============================================================================
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p "$1"; OUT="$(cd "$1" && pwd)"

# Path to each analysis script (update the prefix here if scripts move to R/).
SDIR="R"

run() {  # 1=name 2=script 3=save-call template (TAB/FIG placeholders)
  local name="$1" script="$2" tmpl="$3"
  local d="$OUT/$name"; mkdir -p "$d/tab" "$d/fig"
  local call="${tmpl//TAB/$d/tab}"; call="${call//FIG/$d/fig}"
  Rscript tools/snapshot.R "$SDIR/$script" "$call" "$d" > "$d/console.txt" 2>&1
  echo "  [done] $name (exit $?)"
}

echo "[snapshot] -> $OUT"
run empirical    empirical.R    'save_all_tables(dir="TAB")' &
run oos          oos.R          '-' &
run main_results main_results.R 'save_main_results(tab_dir="TAB", fig_dir="FIG")' &
run robustness   robustness.R   'save_robustness(tab_dir="TAB", fig_dir="FIG")' &
run strategy     strategy.R     'save_strategy(tab_dir="TAB", fig_dir="FIG")' &
run plots        plots.R        'save_all_plots(dir="FIG")' &
wait

# Extract the text layer of every regenerated PDF (strips embedded dates).
mkdir -p "$OUT/_pdftext"
shopt -s nullglob
for f in "$OUT"/*/tab/*.pdf "$OUT"/*/fig/*.pdf; do
  base="$(basename "$(dirname "$(dirname "$f")")")__$(basename "$f")"
  pdftotext -layout "$f" "$OUT/_pdftext/$base.txt" 2>/dev/null
done
echo "[snapshot] complete: $OUT"
