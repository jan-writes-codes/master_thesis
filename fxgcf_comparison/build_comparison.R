# build_comparison.R
# =============================================================================
# FXGCF construction comparison (supervisor request, 2026-06).
#
# Motivation. The thesis's FX-adjusted global cycle factor (FXGCF) is currently
# built TOP-DOWN on GDP-weighted aggregates and ends up ~0.99 correlated with
# the GCF -- far above the ~0.50 that Dahlquist-Hasseltoft (2013) report. The
# supervisor asked whether alternative constructions decouple the two factors
# while preserving predictive power. This script builds and compares:
#
#   M1  TD - GDP  (current)  FXGCF = fitted( rxUSD_bar^w  ~ c1_bar^w  + cbar_bar^w )
#   M2  TD - 1/n             FXGCF = fitted( rxUSD_bar^eq ~ c1_bar^eq + cbar_bar^eq )
#   M3  BU - GDP             FXGCF = sum_i w_i  * FXCF_i ,  FXCF_i = fitted(rxUSD_i ~ c1_i + cbar_i)
#   M4  BU - 1/n   (control) FXGCF = mean_i      FXCF_i
#
# M1-M3 are the three methods requested; M4 completes the 2x2
# (construction x weighting) so we can attribute any decoupling to the
# weighting scheme vs. the top-down/bottom-up choice. FXCF_i is exactly the
# CF_USD already built per country in data_preparation.R (the local cycle
# factor estimated on US-dollar excess returns instead of local-currency ones),
# so M3/M4 mirror the GCF construction with the dollar return on the LHS.
#
# Everything is evaluated against the GCF and against each other on three axes:
#   (a) correlation with the GCF and with one another,
#   (b) in-sample predictive power for the USD-investor return (HAC),
#   (c) fully-recursive out-of-sample Campbell-Thompson R^2.
#
# Run from the repository root:
#   Rscript fxgcf_comparison/build_comparison.R
# Writes fxgcf_comparison/figures/*.pdf and fxgcf_comparison/tables/*.tex and
# prints a headline summary block (the numbers quoted in the slides).
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(tibble)
  library(ggplot2)
  library(scales)
  library(sandwich)
  library(lmtest)
})

# oos.R sources data_preparation.R and leaves both the in-sample objects
# (reg_data, gcf, fxgcf) and the recursive ones (reg_data_oos, gcf_oos,
# fxgcf_oos, panel_oos, oos_predict, oos_r2_components) in the workspace.
if (!exists("panel_oos") || !exists("oos_predict")) source("R/oos.R")
source("R/thesis_palette.R")
source("R/thesis_utils.R")

FIG <- "fxgcf_comparison/figures"
TAB <- "fxgcf_comparison/tables"
dir.create(FIG, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB, showWarnings = FALSE, recursive = TRUE)

# Country display order / names, as in main_results.R.
mr_order <- c("BE", "DE", "FR", "IT", "NL", "CH", "GB", "SE", "CA", "JP", "US")
mr_name  <- c(BE = "Belgium", CA = "Canada", CH = "Switzerland", DE = "Germany",
              FR = "France", GB = "UK", IT = "Italy", JP = "Japan",
              NL = "Netherlands", SE = "Sweden", US = "US")

# Method metadata (single source of truth for labels/colours/order).
meth <- tibble::tribble(
  ~key,         ~short,            ~construction, ~weight, ~colour,
  "M1_TD_gdp",  "TD - GDP (current)", "top-down",    "GDP",   col_pri,
  "M2_TD_eq",   "TD - 1/n",           "top-down",    "1/n",   col_sec,
  "M3_BU_gdp",  "BU - GDP",           "bottom-up",   "GDP",   col_ter,
  "M4_BU_eq",   "BU - 1/n",           "bottom-up",   "1/n",   col_qua
)
meth_keys   <- meth$key
meth_labels <- setNames(meth$short, meth$key)
meth_cols   <- setNames(meth$colour, meth$key)

# =============================================================================
# 1. IN-SAMPLE variants
# =============================================================================
# reg_data is already filtered to non-missing rx_t12 / rx_USD_t12 / cycles, and
# carries the GDP weight w (sum_i w_{i,t} = 1) plus the per-country bottom-up
# factor CF_USD. We add an equal weight w_eq = 1/n_t for the 1/n variants.
panel_is <- reg_data %>%
  group_by(ym) %>%
  mutate(n_ctry = dplyr::n(), w_eq = 1 / n_ctry) %>%
  ungroup()

# -- top-down aggregates (GDP and equal) ------------------------------------
agg_is <- panel_is %>%
  group_by(ym, date) %>%
  summarise(
    # GDP-weighted predictor menu + dollar return (= the current construction)
    c1_bar_w    = sum(w * cycle_1y),
    cbar_bar_w  = sum(w * c_bar),
    rxUSD_bar_w = sum(w * rx_USD_t12),
    # equal-weighted counterparts
    c1_bar_eq    = mean(cycle_1y),
    cbar_bar_eq  = mean(c_bar),
    rxUSD_bar_eq = mean(rx_USD_t12),
    .groups = "drop"
  ) %>%
  arrange(ym)

# M1 (current): top-down GDP. Fit on the menu, read fitted value off everywhere.
fit_td_gdp <- lm(rxUSD_bar_w ~ c1_bar_w + cbar_bar_w, data = agg_is)
agg_is$M1_TD_gdp <- as.numeric(predict(fit_td_gdp, newdata = agg_is))

# M2: top-down 1/n.
fit_td_eq <- lm(rxUSD_bar_eq ~ c1_bar_eq + cbar_bar_eq, data = agg_is)
agg_is$M2_TD_eq <- as.numeric(predict(fit_td_eq, newdata = agg_is))

# -- bottom-up aggregates (GDP and equal) of the local FX factor CF_USD ------
bu_is <- panel_is %>%
  group_by(ym, date) %>%
  summarise(
    M3_BU_gdp = sum(w * CF_USD),
    M4_BU_eq  = mean(CF_USD),
    .groups   = "drop"
  ) %>%
  arrange(ym)

fx_is <- agg_is %>%
  select(ym, date, M1_TD_gdp, M2_TD_eq) %>%
  left_join(bu_is, by = c("ym", "date")) %>%
  left_join(gcf %>% select(ym, GCF), by = "ym") %>%
  arrange(ym)

# Fidelity check: the rebuilt M1 must reproduce the shipped fxgcf object.
m1_check <- fx_is %>%
  inner_join(fxgcf %>% select(ym, FXGCF), by = "ym") %>%
  filter(!is.na(M1_TD_gdp), !is.na(FXGCF))
stopifnot(max(abs(m1_check$M1_TD_gdp - m1_check$FXGCF)) < 1e-8)
cat(sprintf("[check] rebuilt M1 reproduces shipped FXGCF (max abs diff %.2e)\n",
            max(abs(m1_check$M1_TD_gdp - m1_check$FXGCF))))

# =============================================================================
# 2. Correlations (in-sample)
# =============================================================================
cor_cols <- c("GCF", meth_keys)
cor_mat  <- fx_is %>% select(all_of(cor_cols)) %>% filter(complete.cases(.)) %>% cor()
n_common <- fx_is %>% select(all_of(cor_cols)) %>% filter(complete.cases(.)) %>% nrow()

corr_gcf <- tibble(key = meth_keys, rho_gcf = cor_mat["GCF", meth_keys]) %>%
  left_join(meth, by = "key") %>%
  mutate(key = factor(key, levels = meth_keys))

cat("\n========== CORRELATIONS (in-sample, n =", n_common, "months) ==========\n")
cat("\nCorrelation of each FXGCF variant with the GCF:\n")
print(corr_gcf %>% transmute(method = short, construction, weight,
                             `cor(.,GCF)` = round(rho_gcf, 3)) %>% as.data.frame(),
      row.names = FALSE)
cat("\nFull correlation matrix (GCF + variants):\n")
print(round(cor_mat, 3))

# =============================================================================
# 3. In-sample predictive power for the USD-investor return
# =============================================================================
# Per-country HAC regression rx_USD_{i,t+12} ~ factor_t, for each variant plus
# the GCF and the local CF baselines. Factor is merged onto the country panel.
pred_panel <- reg_data %>%
  select(country, ym, date, rx_USD_t12, CF) %>%
  left_join(fx_is %>% select(ym, all_of(meth_keys)), by = "ym") %>%
  left_join(gcf   %>% select(ym, GCF),                by = "ym")

is_specs <- c(setNames(meth_keys, meth_keys), c(GCF = "GCF", CF = "CF"))

is_by_country <- imap_dfr(is_specs, function(var, lab) {
  run_by_country(pred_panel, as.formula(sprintf("rx_USD_t12 ~ %s", var))) %>%
    filter(term == var) %>%
    transmute(country, spec = lab, b = estimate, t = t, r2 = r_sq, n)
})

is_pooled <- imap_dfr(is_specs, function(var, lab) {
  fit <- hac_fit(pred_panel, as.formula(sprintf("rx_USD_t12 ~ %s", var))) %>%
    filter(term == var)
  tibble(spec = lab, b = fit$estimate, t = fit$t, r2_pooled = fit$r_sq, n = fit$n)
})

is_meanr2 <- is_by_country %>%
  group_by(spec) %>%
  summarise(mean_r2 = mean(r2, na.rm = TRUE),
            n_sig   = sum(abs(t) > 1.96, na.rm = TRUE),
            n_ctry  = sum(!is.na(r2)), .groups = "drop")

cat("\n========== IN-SAMPLE PREDICTIVE POWER (rx_USD ~ factor) ==========\n")
cat("\nMean per-country R^2, #markets |t|>1.96, and pooled-panel R^2:\n")
print(is_meanr2 %>%
        left_join(is_pooled %>% select(spec, t_pooled = t, r2_pooled), by = "spec") %>%
        mutate(spec = factor(spec, levels = c(meth_keys, "GCF", "CF"))) %>%
        arrange(spec) %>%
        transmute(spec = recode(as.character(spec), !!!meth_labels),
                  mean_R2 = round(mean_r2, 3), `#|t|>1.96` = paste0(n_sig, "/", n_ctry),
                  pooled_t = round(t_pooled, 2), pooled_R2 = round(r2_pooled, 3)) %>%
        as.data.frame(), row.names = FALSE)

# =============================================================================
# 4. OUT-OF-SAMPLE variants (fully recursive) + Campbell-Thompson R^2
# =============================================================================
# Build the recursive analogues from reg_data_oos (recursive cycles, dollar
# returns, GDP weights). M1 OOS = fxgcf_oos$FXGCF_oos (already recursive).

# Bottom-up: recursive per-country CF_USD_oos (rx_USD ~ recursive cycles),
# mirroring CF_oos in oos.R but on the dollar return.
cat("\noos: building recursive CF_USD_oos (bottom-up building block) ...\n")
reg_oos_fx <- reg_data_oos %>%
  filter(!is.na(cycle_1y_oos), !is.na(c_bar_oos)) %>%
  group_by(country) %>%
  arrange(ym, .by_group = TRUE) %>%
  group_modify(~ {
    .x$CF_USD_oos <- oos_predict(.x, rx_USD_t12 ~ cycle_1y_oos + c_bar_oos,
                                 min_train = 60, h = 12)
    .x
  }) %>%
  ungroup()

bu_oos <- reg_oos_fx %>%
  filter(!is.na(CF_USD_oos), !is.na(gdp_val)) %>%
  group_by(ym) %>%
  mutate(w_oos = gdp_val / sum(gdp_val), n_ctry = dplyr::n()) %>%
  group_by(ym, date) %>%
  summarise(M3_BU_gdp_oos = sum(w_oos * CF_USD_oos),
            M4_BU_eq_oos  = mean(CF_USD_oos),
            .groups = "drop") %>%
  arrange(ym)

# Top-down 1/n: recursive, equal-weighted aggregates -> recursive regression.
cat("oos: building recursive top-down 1/n FXGCF ...\n")
agg_eq_oos <- reg_data_oos %>%
  filter(!is.na(cycle_1y_oos), !is.na(c_bar_oos)) %>%
  group_by(ym, date) %>%
  summarise(c1_bar_eq_oos   = mean(cycle_1y_oos),
            cbar_bar_eq_oos = mean(c_bar_oos),
            .groups = "drop")

rxusd_eq_oos <- reg_data_oos %>%
  filter(!is.na(rx_USD_t12), !is.na(cycle_1y_oos), !is.na(c_bar_oos)) %>%
  group_by(ym, date) %>%
  summarise(rxUSD_bar_eq_oos = mean(rx_USD_t12), .groups = "drop")

td_eq_oos_data <- agg_eq_oos %>%
  left_join(rxusd_eq_oos, by = c("ym", "date")) %>%
  arrange(ym)
td_eq_oos_data$M2_TD_eq_oos <- oos_predict(
  td_eq_oos_data, rxUSD_bar_eq_oos ~ c1_bar_eq_oos + cbar_bar_eq_oos,
  min_train = 60, h = 12)

# Assemble the OOS country panel: dollar return + each recursive variant + GCF_oos.
panel_oos_fx <- reg_data_oos %>%
  select(country, ym, date, rx_USD_t12) %>%
  left_join(fxgcf_oos %>% select(ym, M1_TD_gdp_oos = FXGCF_oos), by = "ym") %>%
  left_join(td_eq_oos_data %>% select(ym, M2_TD_eq_oos),          by = "ym") %>%
  left_join(bu_oos %>% select(ym, M3_BU_gdp_oos, M4_BU_eq_oos),   by = "ym") %>%
  left_join(gcf_oos %>% select(ym, GCF_oos),                      by = "ym") %>%
  arrange(country, date)

oos_var <- c(setNames(paste0(meth_keys, "_oos"), meth_keys), c(GCF = "GCF_oos"))

# Common-sample alignment: score every variant on the SAME (country, month)
# cells, so differing recursive burn-ins cannot confound the OOS ranking. Keep
# only rows where the dollar return and all five recursive factors are present.
oos_cols_all     <- c("rx_USD_t12", unname(oos_var))
panel_oos_common <- panel_oos_fx %>% filter(if_all(all_of(oos_cols_all), ~ !is.na(.)))
cat(sprintf("oos: common-sample cells = %d (country-months), %d months, %d countries\n",
            nrow(panel_oos_common), dplyr::n_distinct(panel_oos_common$ym),
            dplyr::n_distinct(panel_oos_common$country)))

cat("oos: scoring Campbell-Thompson R^2 for each variant (rx_USD ~ factor_oos) ...\n")
oos_r2_min_train <- 60
ct_by_country <- imap_dfr(oos_var, function(var, lab) {
  panel_oos_common %>%
    group_by(country) %>%
    group_split() %>%
    set_names(map_chr(., ~ unique(.x$country))) %>%
    imap_dfr(function(df, cn) {
      d <- df %>% filter(!is.na(.data[[var]]), !is.na(rx_USD_t12))
      if (nrow(d) < oos_r2_min_train + 12)
        return(tibble(country = cn, spec = lab, r2_oos = NA_real_,
                      n_fcst = 0L, ss_fcst = NA_real_, ss_bench = NA_real_))
      r <- oos_r2_components(d, as.formula(sprintf("rx_USD_t12 ~ %s", var)),
                             min_train = oos_r2_min_train, h = 12)
      tibble(country = cn, spec = lab, r2_oos = r$r2_oos, n_fcst = r$n_fcst,
             ss_fcst = r$ss_fcst, ss_bench = r$ss_bench)
    })
})

ct_pooled <- ct_by_country %>%
  group_by(spec) %>%
  summarise(r2_oos_pooled = if (sum(ss_bench, na.rm = TRUE) > 0)
              1 - sum(ss_fcst, na.rm = TRUE) / sum(ss_bench, na.rm = TRUE) else NA_real_,
            n_pos = sum(r2_oos > 0, na.rm = TRUE),
            n_ctry = sum(!is.na(r2_oos)), .groups = "drop")

cat("\n========== OUT-OF-SAMPLE (Campbell-Thompson R^2_oos, rx_USD ~ factor_oos) ==========\n")
print(ct_pooled %>%
        mutate(spec = factor(spec, levels = c(meth_keys, "GCF"))) %>%
        arrange(spec) %>%
        transmute(method = recode(as.character(spec), !!!meth_labels, GCF = "GCF (baseline)"),
                  pooled_R2_oos = round(r2_oos_pooled, 4),
                  markets_pos = paste0(n_pos, "/", n_ctry)) %>%
        as.data.frame(), row.names = FALSE)

# =============================================================================
# 5. FIGURES
# =============================================================================
zscore <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

# -- F1: standardised time series, GCF vs the variants ----------------------
ts_long <- fx_is %>%
  filter(complete.cases(select(., all_of(cor_cols)))) %>%
  transmute(date,
            `GCF`              = zscore(GCF),
            `TD - GDP (current)` = zscore(M1_TD_gdp),
            `TD - 1/n`         = zscore(M2_TD_eq),
            `BU - GDP`         = zscore(M3_BU_gdp),
            `BU - 1/n`         = zscore(M4_BU_eq)) %>%
  pivot_longer(-date, names_to = "series", values_to = "z")
ts_levels <- c("GCF", "TD - GDP (current)", "TD - 1/n", "BU - GDP", "BU - 1/n")
ts_cols   <- c("GCF" = "grey35", setNames(meth$colour, meth$short))

p_f1 <- ts_long %>%
  mutate(series = factor(series, levels = ts_levels)) %>%
  ggplot(aes(date, z, colour = series)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey70") +
  geom_line(aes(linewidth = series == "GCF")) +
  scale_linewidth_manual(values = c(`TRUE` = 0.9, `FALSE` = 0.5), guide = "none") +
  scale_colour_manual(values = ts_cols, name = NULL) +
  labs(title = "FXGCF constructions vs. the GCF (standardised)",
       subtitle = "All series z-scored over the common sample; the GCF is the thick grey line",
       x = NULL, y = "Standardised factor") +
  theme_thesis
ggsave(file.path(FIG, "fx_f1_timeseries.pdf"), p_f1, width = 8.6, height = 4.6)

# -- F2: correlation with the GCF, by method (the headline metric) ----------
p_f2 <- corr_gcf %>%
  mutate(short = factor(short, levels = meth$short)) %>%
  ggplot(aes(short, rho_gcf, fill = short)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 0.50, linetype = "dashed", colour = "grey30") +
  annotate("text", x = 0.7, y = 0.53, hjust = 0, size = 3, colour = "grey30",
           label = "DH (2013) ~ 0.50") +
  geom_text(aes(label = sprintf("%.2f", rho_gcf)), vjust = -0.4, size = 3.4) +
  scale_fill_manual(values = setNames(meth$colour, meth$short), guide = "none") +
  scale_y_continuous(limits = c(0, 1.05), breaks = seq(0, 1, 0.25)) +
  labs(title = "Correlation of each FXGCF construction with the GCF",
       subtitle = "Lower is better: a distinct FX factor should not be a GCF clone",
       x = NULL, y = "cor(FXGCF, GCF)") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
ggsave(file.path(FIG, "fx_f2_corr_gcf.pdf"), p_f2, width = 7.6, height = 4.5)

# -- F3: correlation heatmap among GCF + variants ---------------------------
cor_lab <- c(GCF = "GCF", meth_labels)
heat <- as.data.frame(cor_mat) %>%
  tibble::rownames_to_column("row") %>%
  pivot_longer(-row, names_to = "col", values_to = "rho") %>%
  mutate(row = factor(cor_lab[row], levels = rev(cor_lab)),
         col = factor(cor_lab[col], levels = cor_lab))
p_f3 <- ggplot(heat, aes(col, row, fill = rho)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.2f", rho)), size = 3.2) +
  scale_fill_gradient2(low = col_sec, mid = "white", high = col_pri,
                       midpoint = 0, limits = c(-1, 1), name = expression(rho)) +
  labs(title = "Correlation matrix: GCF and the FXGCF constructions",
       x = NULL, y = NULL) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 25, hjust = 1),
        panel.grid = element_blank())
ggsave(file.path(FIG, "fx_f3_corr_heatmap.pdf"), p_f3, width = 7.2, height = 5.4)

# -- F4: in-sample USD-investor R^2 by method (mean across markets) ----------
r2_bar <- is_meanr2 %>%
  mutate(spec = factor(spec, levels = c(meth_keys, "GCF", "CF")),
         lab  = recode(as.character(spec), !!!meth_labels,
                       GCF = "GCF (baseline)", CF = "local CF")) %>%
  arrange(spec)
r2_cols <- c(setNames(meth$colour, meth$short), `GCF (baseline)` = "grey35",
             `local CF` = "grey65")
p_f4 <- r2_bar %>%
  mutate(lab = factor(lab, levels = lab)) %>%
  ggplot(aes(lab, mean_r2, fill = lab)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = sprintf("%.1f%%", 100 * mean_r2)), vjust = -0.4, size = 3.3) +
  scale_fill_manual(values = r2_cols, guide = "none") +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     expand = expansion(mult = c(0, 0.12))) +
  labs(title = expression(paste("In-sample USD-investor ", R^2, " by FXGCF construction")),
       subtitle = "Mean per-country R^2 of rx_USD ~ factor (GCF and local CF for reference)",
       x = NULL, y = expression(R^2)) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
ggsave(file.path(FIG, "fx_f4_is_r2.pdf"), p_f4, width = 7.8, height = 4.6)

# -- F5: pooled out-of-sample R^2 by method ---------------------------------
oos_bar <- ct_pooled %>%
  mutate(spec = factor(spec, levels = c(meth_keys, "GCF")),
         lab  = recode(as.character(spec), !!!meth_labels, GCF = "GCF (baseline)")) %>%
  arrange(spec)
oos_cols <- c(setNames(meth$colour, meth$short), `GCF (baseline)` = "grey35")
p_f5 <- oos_bar %>%
  mutate(lab = factor(lab, levels = lab)) %>%
  ggplot(aes(lab, r2_oos_pooled, fill = lab)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 0, colour = "grey40") +
  geom_text(aes(label = sprintf("%.3f", r2_oos_pooled),
                vjust = ifelse(r2_oos_pooled >= 0, -0.4, 1.2)), size = 3.3) +
  scale_fill_manual(values = oos_cols, guide = "none") +
  labs(title = expression(paste("Out-of-sample pooled Campbell-Thompson ", R[oos]^2)),
       subtitle = "rx_USD ~ recursive factor vs. recursive prevailing mean (doubly OOS)",
       x = NULL, y = expression(R[oos]^2)) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
ggsave(file.path(FIG, "fx_f5_oos_r2.pdf"), p_f5, width = 7.8, height = 4.6)

cat(sprintf("\n[figures] wrote 5 PDFs to %s/\n", FIG))

# =============================================================================
# 6. LaTeX tables (native booktabs, matching the deck style)
# =============================================================================
fmt <- function(x, d = 3) ifelse(is.na(x), "--", formatC(x, format = "f", digits = d))

emit <- function(lines, file) {
  writeLines(lines, file.path(TAB, file))
  cat(sprintf("[table] %s\n", file))
}

# -- T1: master summary (the 2x2 + baselines) -------------------------------
master <- meth %>%
  left_join(corr_gcf %>% select(key, rho_gcf), by = "key") %>%
  left_join(is_meanr2 %>% rename(key = spec), by = "key") %>%
  left_join(ct_pooled %>% rename(key = spec) %>%
              select(key, r2_oos_pooled, n_pos, n_ctry_oos = n_ctry), by = "key")

gcf_is  <- is_meanr2 %>% filter(spec == "GCF")
gcf_oos <- ct_pooled %>% filter(spec == "GCF")

t1 <- c(
  "% fx_t1_summary -- master comparison of FXGCF constructions (build_comparison.R)",
  "\\setlength{\\tabcolsep}{5pt}",
  "\\resizebox{\\linewidth}{!}{%",
  "\\begin{tabular}{l l c c c c c}",
  "  \\toprule",
  "  Construction & Weights & $\\Corr(\\cdot,\\GCF)$ & $\\overline{R^2}_{\\text{IS}}$ & $|t|\\!>\\!1.96$ & pooled $R^2_{\\text{oos}}$ & OOS$^{+}$ \\\\",
  "  \\midrule",
  paste0("  \\multicolumn{7}{@{}l}{\\textit{FX-adjusted global cycle factor (FXGCF)}}\\\\")
)
for (i in seq_len(nrow(master))) {
  r <- master[i, ]
  star <- if (r$key == "M1_TD_gdp") " (current)" else ""
  t1 <- c(t1, sprintf("  %s%s & %s & $%s$ & $%s$ & %d/%d & $%s$ & %d/%d \\\\",
                      r$construction, star, r$weight, fmt(r$rho_gcf, 2),
                      fmt(r$mean_r2, 3), r$n_sig, r$n_ctry,
                      fmt(r$r2_oos_pooled, 3), r$n_pos, r$n_ctry_oos))
}
t1 <- c(t1,
  "  \\midrule",
  paste0("  \\multicolumn{7}{@{}l}{\\textit{Reference}}\\\\"),
  sprintf("  GCF (local-currency) & GDP & $1.00$ & $%s$ & %d/%d & $%s$ & %d/%d \\\\",
          fmt(gcf_is$mean_r2, 3), gcf_is$n_sig, gcf_is$n_ctry,
          fmt(gcf_oos$r2_oos_pooled, 3), gcf_oos$n_pos, gcf_oos$n_ctry),
  "  \\bottomrule",
  "\\end{tabular}}\\\\[0.8ex]",
  "{\\scriptsize\\begin{minipage}{0.97\\linewidth}",
  sprintf(paste0("All factors predict the US-dollar excess return $\\rxbar^{\\,\\mathrm{USD}}_{i,t+12}$. ",
                 "$\\Corr(\\cdot,\\GCF)$ is the full-sample correlation with the GCF (n=%d months); ",
                 "$\\overline{R^2}_{\\text{IS}}$ is the cross-country mean in-sample $R^2$; ",
                 "pooled $R^2_{\\text{oos}}$ is the Campbell--Thompson statistic against the recursive ",
                 "prevailing mean (doubly out-of-sample); OOS$^{+}$ counts markets with positive $R^2_{\\text{oos}}$. ",
                 "Dahlquist--Hasseltoft (2013) report $\\Corr(\\text{FXGCP},\\GCP)\\approx0.50$."), n_common),
  "\\end{minipage}}"
)
emit(t1, "fx_t1_summary.tex")

# -- T2: correlation matrix -------------------------------------------------
cm <- cor_mat
labs2 <- c("GCF", meth_labels[meth_keys])
t2 <- c(
  "% fx_t2_corr -- correlation matrix of GCF and FXGCF constructions",
  "\\resizebox{\\linewidth}{!}{%",
  paste0("\\begin{tabular}{l", paste(rep("c", length(labs2)), collapse = ""), "}"),
  "  \\toprule",
  paste0("  & ", paste(sprintf("\\rotatebox{45}{%s}", labs2), collapse = " & "), " \\\\"),
  "  \\midrule"
)
for (i in seq_along(cor_cols)) {
  vals <- sapply(seq_along(cor_cols), function(j)
    if (j <= i) sprintf("$%s$", fmt(cm[i, j], 2)) else "")
  t2 <- c(t2, sprintf("  %s & %s \\\\", labs2[i], paste(vals, collapse = " & ")))
}
t2 <- c(t2, "  \\bottomrule", "\\end{tabular}}")
emit(t2, "fx_t2_corr.tex")

# -- T3: per-country in-sample R^2 ------------------------------------------
is_wide <- is_by_country %>%
  filter(spec %in% c("CF", "GCF", meth_keys)) %>%
  select(country, spec, r2) %>%
  pivot_wider(names_from = spec, values_from = r2) %>%
  mutate(country = factor(country, levels = mr_order)) %>%
  arrange(country)
t3 <- c(
  "% fx_t3_is_r2 -- per-country in-sample R^2 (rx_USD ~ factor)",
  "\\setlength{\\tabcolsep}{5pt}",
  "\\resizebox{\\linewidth}{!}{%",
  "\\begin{tabular}{l c c c c c c}",
  "  \\toprule",
  "  Country & local CF & GCF & TD-GDP & TD-1/n & BU-GDP & BU-1/n \\\\",
  "  \\midrule"
)
for (i in seq_len(nrow(is_wide))) {
  r <- is_wide[i, ]
  t3 <- c(t3, sprintf("  %s & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ \\\\",
                      mr_name[as.character(r$country)],
                      fmt(r$CF, 3), fmt(r$GCF, 3), fmt(r$M1_TD_gdp, 3),
                      fmt(r$M2_TD_eq, 3), fmt(r$M3_BU_gdp, 3), fmt(r$M4_BU_eq, 3)))
}
t3 <- c(t3, "  \\bottomrule", "\\end{tabular}}\\\\[0.6ex]",
  "{\\scriptsize In-sample $R^2$ of $\\rxbar^{\\,\\mathrm{USD}}_{i,t+12}\\sim$ factor, per market.}")
emit(t3, "fx_t3_is_r2.tex")

# -- T4: per-country OOS R^2 ------------------------------------------------
oos_wide <- ct_by_country %>%
  filter(spec %in% c("GCF", meth_keys)) %>%
  select(country, spec, r2_oos) %>%
  pivot_wider(names_from = spec, values_from = r2_oos) %>%
  mutate(country = factor(country, levels = mr_order)) %>%
  arrange(country)
t4 <- c(
  "% fx_t4_oos_r2 -- per-country Campbell-Thompson R^2_oos (rx_USD ~ factor_oos)",
  "\\setlength{\\tabcolsep}{5pt}",
  "\\resizebox{\\linewidth}{!}{%",
  "\\begin{tabular}{l c c c c c}",
  "  \\toprule",
  "  Country & GCF & TD-GDP & TD-1/n & BU-GDP & BU-1/n \\\\",
  "  \\midrule"
)
for (i in seq_len(nrow(oos_wide))) {
  r <- oos_wide[i, ]
  t4 <- c(t4, sprintf("  %s & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ \\\\",
                      mr_name[as.character(r$country)],
                      fmt(r$GCF, 3), fmt(r$M1_TD_gdp, 3), fmt(r$M2_TD_eq, 3),
                      fmt(r$M3_BU_gdp, 3), fmt(r$M4_BU_eq, 3)))
}
t4 <- c(t4, "  \\bottomrule", "\\end{tabular}}\\\\[0.6ex]",
  "{\\scriptsize Campbell--Thompson $R^2_{\\text{oos}}$ vs. the recursive prevailing mean, per market.}")
emit(t4, "fx_t4_oos_r2.tex")

# =============================================================================
# 7. Headline summary block (numbers quoted in the slides)
# =============================================================================
g <- function(k, col) master[[col]][master$key == k]
cat("\n\n################## HEADLINE SUMMARY ##################\n")
cat(sprintf("Common in-sample window: %d months\n", n_common))
cat("\nCorrelation with GCF:\n")
for (k in meth_keys) cat(sprintf("  %-20s %.3f\n", meth_labels[k], g(k, "rho_gcf")))
cat(sprintf("\nBU-GDP vs TD-GDP correlation: %.3f\n", cor_mat["M3_BU_gdp", "M1_TD_gdp"]))
cat("\nMean in-sample USD R^2:\n")
for (k in meth_keys) cat(sprintf("  %-20s %.3f\n", meth_labels[k], g(k, "mean_r2")))
cat(sprintf("  %-20s %.3f\n", "GCF baseline", gcf_is$mean_r2))
cat("\nPooled OOS R^2_oos:\n")
for (k in meth_keys) cat(sprintf("  %-20s %+.4f (%d/%d markets +)\n",
    meth_labels[k], g(k, "r2_oos_pooled"), g(k, "n_pos"), g(k, "n_ctry_oos")))
cat(sprintf("  %-20s %+.4f (%d/%d markets +)\n", "GCF baseline",
    gcf_oos$r2_oos_pooled, gcf_oos$n_pos, gcf_oos$n_ctry))
cat("#####################################################\n")
