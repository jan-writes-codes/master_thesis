#!/usr/bin/env bash
# =============================================================================
# tools/compare_snapshots.sh <dir-A> <dir-B>
# -----------------------------------------------------------------------------
# Compare two snapshots produced by tools/make_snapshot.sh. The per-column
# fingerprints (_digest.csv) are compared AS SETS (sorted), so a harmless change
# in a data frame's column ORDER does not register as a difference; everything
# that affects the thesis -- the full result-table values (full__*.csv), every
# regenerated PDF's text layer (_pdftext), and all console output -- is compared
# exactly. Exit status 0 means the two runs are equivalent.
# =============================================================================
set -u
A="$1"; B="$2"; fail=0

# 1) Numeric fingerprints: compare as sorted sets (column order is not meaningful).
for f in $(cd "$A" && find . -name '_digest.csv' | sort); do
  if ! diff <(sort "$A/$f") <(sort "$B/$f") >/dev/null 2>&1; then
    echo "VALUE DIFF in $f:"; diff <(sort "$A/$f") <(sort "$B/$f") | head -20; fail=1
  fi
done

# 2) Everything else must match exactly (ignore PDF binaries' timestamps and the
#    harness's own provenance line).
if ! diff -r "$A" "$B" -x '*.pdf' -x '_digest.csv' -I '^\[snapshot\]' > /tmp/cmp_rest.txt 2>&1; then
  echo "DIFF in result tables / PDF text / console:"; head -40 /tmp/cmp_rest.txt; fail=1
fi

if [ $fail -eq 0 ]; then
  echo "SNAPSHOTS EQUIVALENT ✓  (all numbers, tables, figures and console output"
  echo "identical; a data frame's column order may differ harmlessly)"
fi
exit $fail
