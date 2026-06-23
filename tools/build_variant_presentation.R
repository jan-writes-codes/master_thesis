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
#   figures : mr_f3_usd_r2, mr_f4_gcf_fxgcf, rob_f1_oos_sub, rob_f2_oos_scheme,
#             and the deck-only Phase III / OOS / strategy figures pres_usd_drop,
#             pres_usd_r2, pres_oos_r2, pres_gcf_cumret, pres_usd_cumret
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
source("R/main_results.R")   # -> mr_plots, mr_tables, phase2/phase3, r2_oos_tab, oos_summary
source("R/strategy.R")       # -> usd_perf, btu (FX-adjusted dollar strategy)

# --- presentation-specific figures (FXGCF-method-dependent, deck only) --------
# Four exhibits for the redesigned Phase III / OOS / strategy slides. They reuse
# the in-memory pipeline frames (phase2, phase3, r2_oos_tab, btu) so every number
# matches the thesis machinery, and live here (not in the thesis R files) so no
# thesis exhibit changes. Written straight into the deck's figures/ folder, and
# defined before the slow robustness rebuild so they are produced regardless.
pres_dir <- file.path(target, "figures")
pct  <- scales::percent_format(accuracy = 1)
xrot <- ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

# (Slide 14) Currency drop: in-sample R^2 on GCF, local-currency vs dollar rx.
lab_drop <- c("rx ~ GCF (local currency)", "rx_USD ~ GCF (USD investor)")
f_drop <- dplyr::left_join(
    phase2 %>% dplyr::select(country, loc = r2_glb),
    phase3 %>% dplyr::select(country, usd = r2_g), by = "country") %>%
  tidyr::pivot_longer(c(loc, usd), names_to = "model", values_to = "r_sq") %>%
  dplyr::mutate(model = factor(model, levels = c("loc", "usd"), labels = lab_drop)) %>%
  ggplot2::ggplot(ggplot2::aes(country, r_sq, fill = model)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::scale_y_continuous(labels = pct) +
  ggplot2::scale_fill_manual(values = stats::setNames(c(col_pri, col_sec), lab_drop), name = NULL) +
  ggplot2::labs(title = expression(paste("Currency risk erodes the in-sample ", R^2)),
                subtitle = "Global-factor fit: local-currency vs US-dollar returns, by country",
                x = NULL, y = expression(R^2)) +
  theme_thesis + xrot
ggplot2::ggsave(file.path(pres_dir, "pres_usd_drop.pdf"), f_drop, width = 9, height = 5.5)

# (Slide 15) USD investor R^2: local rx~GCF, dollar rx_USD~GCF, dollar rx_USD~FXGCF.
lab_r2 <- c("rx ~ GCF (local)", "rx_USD ~ GCF (USD)", "rx_USD ~ FXGCF (USD)")
f_r2 <- dplyr::left_join(
    phase2 %>% dplyr::select(country, a = r2_glb),
    phase3 %>% dplyr::select(country, b = r2_g, c = r2_f), by = "country") %>%
  tidyr::pivot_longer(c(a, b, c), names_to = "model", values_to = "r_sq") %>%
  dplyr::mutate(model = factor(model, levels = c("a", "b", "c"), labels = lab_r2)) %>%
  ggplot2::ggplot(ggplot2::aes(country, r_sq, fill = model)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.85), width = 0.8) +
  ggplot2::scale_y_continuous(labels = pct) +
  ggplot2::scale_fill_manual(values = stats::setNames(c(col_pri, col_sec, col_ter), lab_r2), name = NULL) +
  ggplot2::labs(title = expression(paste("US-dollar-investor in-sample ", R^2, ": GCF vs FX-adjusted FXGCF")),
                subtitle = "Local-currency benchmark, the dollar return on GCF, and the dollar return on FXGCF",
                x = NULL, y = expression(R^2)) +
  theme_thesis + xrot
ggplot2::ggsave(file.path(pres_dir, "pres_usd_r2.pdf"), f_r2, width = 9, height = 5.5)

# (Slide 16) Out-of-sample R^2_oos: local CF, global GCF, and both USD specs.
lev_oos <- c("rx ~ CF_oos", "rx ~ GCF_oos", "rx_USD ~ GCF_oos", "rx_USD ~ FXGCF_oos")
lab_oos <- c("rx ~ CF (local)", "rx ~ GCF (global)", "rx_USD ~ GCF", "rx_USD ~ FXGCF")
f_oos <- r2_oos_tab %>%
  dplyr::filter(spec %in% lev_oos, !is.na(r2_oos)) %>%
  dplyr::mutate(spec = factor(as.character(spec), levels = lev_oos, labels = lab_oos),
                country = ord(country)) %>%
  ggplot2::ggplot(ggplot2::aes(country, r2_oos, fill = spec)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.85), width = 0.8) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  ggplot2::scale_y_continuous(labels = pct) +
  ggplot2::scale_fill_manual(values = stats::setNames(c(col_pri, col_sec, col_ter, col_qua), lab_oos), name = NULL) +
  ggplot2::labs(title = expression(paste("Out-of-sample ", R[oos]^2, ": local, global, and the USD investor")),
                subtitle = "Recursive factor forecast vs recursive prevailing mean (positive beats the mean)",
                x = NULL, y = expression(R[oos]^2)) +
  theme_thesis + xrot
ggplot2::ggsave(file.path(pres_dir, "pres_oos_r2.pdf"), f_oos, width = 9, height = 5.5)

# (Slide 17) Equity curves. The subtitles report the headline 12-month strategy
# Sharpe (from perf5 / usd_perf), so the chart matches the slide's strategy-table
# bullets -- not the annual-rebalancing Sharpe of the plotted growth-of-$1 curve.
gcf_sr_t <- perf5$Sharpe[perf5$Strategy == "GCF-timed"]
gcf_sr_h <- perf5$Sharpe[perf5$Strategy == "Buy-and-hold"]
f_gcf_cum <- ann_curve %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "wealth") %>%
  dplyr::mutate(strategy = factor(strategy, levels = c("GCF-timed", "Buy-and-hold"))) %>%
  ggplot2::ggplot(ggplot2::aes(date, wealth, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = "grey60") +
  ggplot2::geom_line(linewidth = 0.7) +
  ggplot2::scale_colour_manual(values = c("GCF-timed" = col_pri, "Buy-and-hold" = col_sec), name = NULL) +
  ggplot2::labs(title = "Growth of $1: GCF-timed global bond portfolio vs buy-and-hold",
                subtitle = sprintf("Currency-hedged, equal average exposure. 12-month Sharpe: timed %.2f vs hold %.2f",
                                   gcf_sr_t, gcf_sr_h),
                x = NULL, y = "Cumulative wealth (excess of cash)") +
  theme_thesis
ggplot2::ggsave(file.path(pres_dir, "pres_gcf_cumret.pdf"), f_gcf_cum, width = 9, height = 5)

annu <- btu %>%
  dplyr::mutate(mth = as.integer(format(date, "%m"))) %>%
  dplyr::filter(mth == 12) %>%
  dplyr::mutate(w_fx = eq_exp(mv_raw(mu_fx, var_rt, 5)))
annu$r_fx <- annu$w_fx * annu$rx
annu$r_bh <- annu$rx
usd_curve <- tibble::tibble(
  date = c(min(annu$date) - 365, annu$date),
  `FXGCF-timed`  = cumprod(c(1, 1 + annu$r_fx)),
  `Buy-and-hold` = cumprod(c(1, 1 + annu$r_bh)))
fx_sr_t <- usd_perf$Sharpe[usd_perf$Strategy == "FXGCF-timed"]
fx_sr_h <- usd_perf$Sharpe[usd_perf$Strategy == "Buy-and-hold"]
f_usd_cum <- usd_curve %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "wealth") %>%
  dplyr::mutate(strategy = factor(strategy, levels = c("FXGCF-timed", "Buy-and-hold"))) %>%
  ggplot2::ggplot(ggplot2::aes(date, wealth, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = "grey60") +
  ggplot2::geom_line(linewidth = 0.7) +
  ggplot2::scale_colour_manual(values = c("FXGCF-timed" = col_pri, "Buy-and-hold" = col_sec), name = NULL) +
  ggplot2::labs(title = "Growth of $1: FXGCF-timed US-dollar portfolio vs buy-and-hold",
                subtitle = sprintf("Unhedged USD investor, equal average exposure. 12-month Sharpe: timed %.2f vs hold %.2f",
                                   fx_sr_t, fx_sr_h),
                x = NULL, y = "Cumulative wealth (excess of cash)") +
  theme_thesis
ggplot2::ggsave(file.path(pres_dir, "pres_usd_cumret.pdf"), f_usd_cum, width = 9, height = 5)
cat("[figures] pres_usd_drop, pres_usd_r2, pres_oos_r2, pres_gcf_cumret, pres_usd_cumret ->", target, "\n")

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
