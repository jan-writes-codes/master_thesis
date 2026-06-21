# tools/build_variant_presentation.R
# =============================================================================
# Regenerate the FXGCF-sensitive exhibits of the FINAL presentation under an
# alternative FXGCF construction, for the supervisor's "mock final presentation"
# comparison. Driven by the FXGCF_METHOD env var (see data_preparation.R):
#   td_eq  -> top-down, 1/n-weighted        -> final_presentation_td_eq/
#   bu_gdp -> bottom-up, GDP-weighted       -> final_presentation_bu_gdp/
#
# It sources the real exhibit pipeline (so every number uses the exact thesis
# machinery, just with the variant FXGCF), then writes ONLY the exhibits that
# depend on the FXGCF:
#   figures : mr_f3_usd_r2, mr_f4_gcf_fxgcf, rob_f1_oos_sub, rob_f2_oos_scheme
#   tables  : mr_t3_phase3.tex, mr_t4_oos.tex   (native LaTeX, deck style)
# All FXGCF-independent exhibits are inherited from the copied final_presentation.
#
# Usage (from the repository root):
#   FXGCF_METHOD=bu_gdp Rscript tools/build_variant_presentation.R
#   FXGCF_METHOD=td_eq  Rscript tools/build_variant_presentation.R
# =============================================================================

method <- Sys.getenv("FXGCF_METHOD", "")
if (!method %in% c("td_eq", "bu_gdp"))
  stop("set FXGCF_METHOD to td_eq or bu_gdp (got '", method, "')")
target <- paste0("final_presentation_", method)
if (!dir.exists(target)) stop("target folder missing: ", target,
                              " (copy final_presentation first)")
dir.create(file.path(target, "figures"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(target, "tables"),  showWarnings = FALSE, recursive = TRUE)

# Build the real exhibits under the variant FXGCF (slow: fully recursive OOS).
suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })
source("R/main_results.R")   # -> mr_plots, mr_tables, phase3, oos_summary, gcf_fxgcf_rho
source("R/strategy.R")       # -> usd_perf (FX-adjusted dollar strategy)
source("R/robustness.R")     # -> rob_plots (rob_f1_oos_sub, rob_f2_oos_scheme)

# --- figures: write the four FXGCF-sensitive ones at the pipeline's dims ------
tmp <- tempfile("fxvar_"); dir.create(tmp)
save_main_results(tab_dir = tmp, fig_dir = tmp)
save_robustness(tab_dir = tmp, fig_dir = tmp)
figs <- c("mr_f3_usd_r2", "mr_f4_gcf_fxgcf", "rob_f1_oos_sub", "rob_f2_oos_scheme")
for (f in figs) {
  ok <- file.copy(file.path(tmp, paste0(f, ".pdf")),
                  file.path(target, "figures", paste0(f, ".pdf")), overwrite = TRUE)
  cat(sprintf("[figure] %s -> %s  (%s)\n", f, target, if (ok) "ok" else "FAILED"))
}

# --- tables: emit native-LaTeX versions from the in-memory result frames ------
fmt2 <- function(x) formatC(x, format = "f", digits = 2)
fmt3 <- function(x) formatC(x, format = "f", digits = 3)
mr_name <- c(BE = "Belgium", CA = "Canada", CH = "Switzerland", DE = "Germany",
             FR = "France", GB = "United Kingdom", IT = "Italy", JP = "Japan",
             NL = "Netherlands", SE = "Sweden", US = "United States")
meth_lab <- c(td_eq = "top-down, 1/n-weighted", bu_gdp = "bottom-up, GDP-weighted")

# mr_t3_phase3: per-country USD-investor regressions, GCF vs the (variant) FXGCF.
p3 <- phase3 %>% mutate(cn = as.character(country))
t3 <- c(
  sprintf("%% mr_t3_phase3 -- Phase III USD investor: GCF vs FX-adjusted FXGCF [%s].", method),
  "\\setlength{\\tabcolsep}{4pt}",
  "\\resizebox{\\linewidth}{!}{%",
  "\\begin{tabular}{l c ccc ccc r}",
  "  \\toprule",
  "  & & \\multicolumn{3}{c}{$\\GCF_{t}$} & \\multicolumn{3}{c}{$\\FXGCF_{t}$} & \\\\",
  "  \\cmidrule(lr){3-5}\\cmidrule(lr){6-8}",
  "  Country & $R^{2}$ ($\\CF$) & $\\hat{\\gamma}$ & $t$ & $R^{2}$ & $\\hat{\\delta}$ & $t$ & $R^{2}$ & $N$ \\\\",
  "  \\midrule")
for (i in seq_len(nrow(p3))) {
  r <- p3[i, ]
  t3 <- c(t3, sprintf("  %-14s & $%s$ & $%s$ & $(%s)$ & $%s$ & $%s$ & $(%s)$ & $%s$ & $%d$ \\\\",
                      mr_name[r$cn], fmt3(r$r2_cfusd), fmt2(r$b_g), fmt2(r$t_g), fmt3(r$r2_g),
                      fmt2(r$b_f), fmt2(r$t_f), fmt3(r$r2_f), r$n))
}
t3 <- c(t3,
  "  \\bottomrule", "\\end{tabular}}\\\\[0.8ex]",
  "{\\scriptsize\\begin{minipage}{0.96\\linewidth}",
  sprintf(paste0("Dependent variable: the US-dollar excess return ",
                 "$\\rxbar^{\\,\\mathrm{USD}}_{i,t+12}$. The first column repeats the $R^{2}$ of the ",
                 "dollar return on the local factor $\\CF_{i,t}$ for reference. The $\\GCF$ and ",
                 "$\\FXGCF$ blocks regress on the global and FX-adjusted global factors. Here the ",
                 "$\\FXGCF$ is built %s. Newey--West HAC $t$-statistics in parentheses. ",
                 "cor$(\\GCF,\\FXGCF)=%s$ in this sample."),
          meth_lab[method], fmt2(gcf_fxgcf_rho)),
  "\\end{minipage}}")
writeLines(t3, file.path(target, "tables", "mr_t3_phase3.tex"))
cat(sprintf("[table] mr_t3_phase3.tex -> %s\n", target))

# mr_t4_oos: in-sample vs recursive Campbell-Thompson R^2 by phase.
o <- oos_summary
spec_tex <- c("rx ~ CF" = "$\\rxbar \\sim \\CF$", "rx ~ GCF" = "$\\rxbar \\sim \\GCF$",
              "rx_USD ~ GCF" = "$\\rxbar^{\\,\\mathrm{USD}} \\sim \\GCF$",
              "rx_USD ~ FXGCF" = "$\\rxbar^{\\,\\mathrm{USD}} \\sim \\FXGCF$")
phase_tex <- c("I -- local" = "I (local)", "II -- global" = "II (global)",
               "III -- USD, global" = "III (USD, global)", "III -- USD, FX-adj." = "III (USD, FX-adj.)")
t4 <- c(
  sprintf("%% mr_t4_oos -- Out-of-sample summary by phase [FXGCF = %s].", method),
  "\\resizebox{0.95\\linewidth}{!}{%",
  "\\begin{tabular}{ll ccc}",
  "  \\toprule",
  "  Phase & Specification & In-sample $R^{2}$ (mean) & $R^{2}_{\\mathrm{oos}}$ (pooled) & Markets OOS$+$ \\\\",
  "  \\midrule")
for (i in seq_len(nrow(o))) {
  r <- o[i, ]
  t4 <- c(t4, sprintf("  %-18s & %-40s & $%s$ & $%s$ & $%d/%d$ \\\\",
                      phase_tex[r$phase], spec_tex[r$spec], fmt3(r$is_r2),
                      fmt3(r$oos_r2), r$npos, r$ntot))
}
t4 <- c(t4,
  "  \\bottomrule", "\\end{tabular}}\\\\[0.8ex]",
  "{\\scriptsize\\begin{minipage}{0.92\\linewidth}",
  paste0("In-sample $R^{2}$ is the cross-country mean of the single-factor fits. The ",
         "out-of-sample $R^{2}_{\\mathrm{oos}}$ is the pooled \\citet{campbellthompson2008} ",
         "statistic of the fully recursive factor forecast relative to the recursive prevailing ",
         "mean; positive means the factor beats the real-time historical average. Both factor ",
         "construction and forecasting regression respect time-$t$ information (doubly out of ",
         "sample). The two $R^{2}$ columns use different benchmarks and are not comparable in level."),
  "\\end{minipage}}")
writeLines(t4, file.path(target, "tables", "mr_t4_oos.tex"))
cat(sprintf("[table] mr_t4_oos.tex -> %s\n", target))

# --- narrative numbers (printed for transcription into the deck) --------------
cat("\n################## VARIANT SUMMARY [", method, "] ##################\n", sep = "")
cat(sprintf("cor(GCF, FXGCF) = %.3f\n", gcf_fxgcf_rho))
cat(sprintf("FXGCF R2 > GCF R2 in %d/11 markets\n", sum(phase3$r2_f > phase3$r2_g, na.rm = TRUE)))
cat(sprintf("mean USD R2: GCF = %.3f ; FXGCF = %.3f\n",
            mean(phase3$r2_g, na.rm = TRUE), mean(phase3$r2_f, na.rm = TRUE)))
cat(sprintf("FXGCF t-stat > GCF t-stat in %d/11 markets\n",
            sum(abs(phase3$t_f) > abs(phase3$t_g), na.rm = TRUE)))
cat("\n-- OOS summary by phase --\n")
print(as.data.frame(oos_summary %>% transmute(phase, spec, IS = round(is_r2, 3),
        OOS = round(oos_r2, 3), pos = paste0(npos, "/", ntot))), row.names = FALSE)
cat("\n-- US-dollar strategy (usd_perf) --\n")
print(as.data.frame(usd_perf %>% mutate(across(where(is.numeric), ~ round(., 3)))), row.names = FALSE)
cat("####################################################################\n")
