# =============================================================================
# tools/snapshot.R  —  result fingerprint for refactor verification
# -----------------------------------------------------------------------------
# Usage:  Rscript tools/snapshot.R <script.R> <save-call|-> <out-dir>
#
# Sources <script.R> (run from the repo root), optionally evaluates a save call
# (e.g. 'save_all_tables(dir="/tmp/x")'), then writes a deterministic numeric
# fingerprint of every data frame / numeric matrix left in the global env:
#   * _digest.csv  — per-column sum/mean/sd/nobs/nrow for ALL numeric frames
#   * full__<obj>.csv — full rounded contents of every small frame (the result
#                       tables), so equivalence is checked value-by-value
# Diffing two out-dirs (before vs after a refactor) must yield no differences.
# =============================================================================
args     <- commandArgs(trailingOnly = TRUE)
script   <- args[[1]]
savecall <- args[[2]]            # "-" for scripts with nothing to save (oos.R)
outdir   <- args[[3]]
options(digits = 10, width = 300, warn = 1)
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

source(script)
if (!identical(savecall, "-")) eval(parse(text = savecall), envir = globalenv())

fmt <- function(v) formatC(v, format = "e", digits = 8)   # stable text for floats

# Fingerprint one global object. Numeric matrix columns are flattened so they
# are still captured; the full dump keeps only plain atomic columns so
# write.csv never chokes on matrix/list columns. Guarded by the caller.
process <- function(nm) {
  x <- get(nm, envir = globalenv())
  if (is.matrix(x) && is.numeric(x)) x <- as.data.frame(x)
  if (!is.data.frame(x)) return(NULL)

  rows <- list()
  for (cn in names(x)) {
    col <- x[[cn]]
    if (!is.numeric(col)) next
    v <- as.vector(col)                      # flattens matrix columns
    rows[[cn]] <- data.frame(
      object = nm, col = cn,
      sum  = fmt(sum(v,  na.rm = TRUE)),
      mean = fmt(mean(v, na.rm = TRUE)),
      sd   = fmt(stats::sd(v, na.rm = TRUE)),
      nobs = sum(!is.na(v)), nrow = nrow(x), stringsAsFactors = FALSE)
  }
  if (!length(rows)) return(NULL)

  # full value-by-value dump for the (small) result tables
  if (nrow(x) * ncol(x) <= 4000) {
    keep <- vapply(x, function(c) is.atomic(c) && is.null(dim(c)), logical(1))
    xx <- x[keep]
    isn <- vapply(xx, is.numeric, logical(1))
    for (j in which(isn)) xx[[j]] <- fmt(xx[[j]])
    if (ncol(xx)) write.csv(xx, file.path(outdir, paste0("full__", nm, ".csv")),
                            row.names = FALSE)
  }
  do.call(rbind, rows)
}

digest_rows <- list()
for (nm in sort(ls(globalenv()))) {
  drow <- tryCatch(process(nm), error = function(e) {
    cat(sprintf("[snapshot] skip %s: %s\n", nm, conditionMessage(e))); NULL })
  if (!is.null(drow)) digest_rows[[nm]] <- drow
}
allrows <- do.call(rbind, digest_rows)
if (!is.null(allrows)) write.csv(allrows, file.path(outdir, "_digest.csv"), row.names = FALSE)
cat(sprintf("[snapshot] %s -> %d numeric data frames fingerprinted\n",
            script, length(digest_rows)))
