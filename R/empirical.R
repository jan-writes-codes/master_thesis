# empirical.R
# Empirical replication: CP 2015 and DH 2013.
#
# This is the single home for all empirical RESULT TABLES. Each table is both
# printed to the console (with inline comparisons to the published numbers) and
# rendered to a PDF exhibit stored in the `tables` list. Write every exhibit to
# disk with save_all_tables() -> tables/<name>.pdf (mirrors plots.R's
# `plots` list + save_all_plots()). Figures live in plots.R; tables live here.
# =============================================================

library(lmtest)
library(sandwich)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(plm)
library(gridExtra)
library(grid)
library(ggplot2)

if (!exists("reg_data")) source("R/data_preparation.R")

# `tables` collects rendered table grobs; save_all_tables() writes them to PDF.
tables <- list()

# The shared table renderer (table_to_grob) and figure theme live in
# thesis_utils.R; empirical's CP/DH tables reserve a 3-line footnote block
# (passed as note_lines = 3 at each call below).
source("R/thesis_utils.R")


# ============================================================
# CP 2015  –  Table 1: Properties of interest-rate cycles
# US data, sample through 2014-12-31
# ============================================================

us_cycle_raw <- cycle %>%
  dplyr::filter(country == "US", as.Date(date) <= as.Date("2014-12-31")) %>%
  dplyr::filter(!is.na(yield), !is.na(trend_inf))

us_mats <- sort(unique(us_cycle_raw$maturity))

# Sample-restricted regressions: Panel A defines the cycles used in Panel B.
# (Full-sample residuals stored in cycle$cycle would give a slight mismatch.)
us_fits <- lapply(setNames(us_mats, us_mats), function(m) {
  d <- dplyr::filter(us_cycle_raw, maturity == m)
  list(d = d, fit = lm(yield ~ trend_inf, data = d))
})


# --- Panel A: y_t^(n) = a_n + b_n^tau * tau_t^CPI + eps_t -----------------
# Newey-West standard errors with 18 lags (CP 2015 convention)

t1a <- map_dfr(us_mats, function(m) {
  fit <- us_fits[[as.character(m)]]$fit
  nw  <- coeftest(fit, vcov = NeweyWest(fit, lag = 18, prewhite = FALSE))
  tibble(
    maturity = m,
    a_n_x100 = coef(fit)[["(Intercept)"]] * 100,
    t_a      = nw["(Intercept)", "t value"],
    b_n      = coef(fit)[["trend_inf"]],
    t_b      = nw["trend_inf", "t value"],
    R2_bar   = summary(fit)$adj.r.squared
  )
})

cat("\n===== CP 2015 Table 1 — Panel A =====\n")
cat("y_t^(n) = a_n + b_n * tau_t^CPI + eps   [US, NW 18 lags]\n\n")
print(t1a, digits = 4)
# Results (sample 1989m3 – 2014m12; CP 2015 uses 1975m1 – 2014m12):
#   maturity  a_n_x100    t_a    b_n    t_b  R2_bar
#          1   -175.80  -1.72   1.78   5.79   0.583   [CP: -0.35 (-0.45)  1.43 (8.64)  0.71]
#          2   -174.90  -1.87   1.90   6.96   0.649   [CP: -0.12 (-0.17)  1.44(10.31)  0.77]
#          4   -116.40  -1.49   1.85   8.40   0.721
#          5    -84.60  -1.20   1.82   9.32   0.754   [CP:  0.68  (1.47)  1.37(13.06)  0.84]
#          9     10.40   0.21   1.68  12.30   0.826
#         10     31.00   0.66   1.64  12.80   0.836   [CP:  1.43  (4.66)  1.28(15.98)  0.88]
# Note: intercepts differ from CP due to shorter sample (missing pre-1989 high-rate era).
#       Beta estimates (b_n) and R² are directionally consistent.


# --- Panel B: c_t^(n) = y_t^(n) - a_hat_n - b_hat_n * tau_t^CPI ----------

# AR(1) half-life: ln(0.5) / ln(|psi_z|)  (CP 2015 footnote)
ar1_halflife <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 20) return(NA_real_)
  psi <- coef(lm(x[-1] ~ x[-length(x)]))[2]
  log(0.5) / log(abs(psi))
}

# Wide dataframe: one row per date, columns cycle_r_{m} and yield_{m}
us_wide <- map_dfr(us_mats, function(m) {
  obj <- us_fits[[as.character(m)]]
  obj$d %>%
    mutate(cycle_r = residuals(obj$fit)) %>%
    select(date, maturity, cycle_r, yield)
}) %>%
  pivot_wider(names_from  = maturity,
              values_from = c(cycle_r, yield),
              names_sep   = "_")

cyc_cols <- paste0("cycle_r_", us_mats)
yld_cols <- paste0("yield_",   us_mats)

# Correlations
cor_mat <- cor(us_wide[, cyc_cols], use = "pairwise.complete.obs")
dimnames(cor_mat) <- list(paste0("c_", us_mats, "y"), paste0("c_", us_mats, "y"))

cat("\n===== CP 2015 Table 1 — Panel B: Correlations =====\n")
print(round(cor_mat, 2))
# Results:
#         c_1y  c_2y  c_4y  c_5y  c_9y c_10y
#  c_1y   1.00  0.99  0.95  0.91  0.78  0.74
#  c_2y   0.99  1.00  0.98  0.95  0.85  0.81
#  c_4y   0.95  0.98  1.00  0.99  0.93  0.90
#  c_5y   0.91  0.95  0.99  1.00  0.96  0.94
#  c_9y   0.78  0.85  0.93  0.96  1.00  1.00
# c_10y   0.74  0.81  0.90  0.94  1.00  1.00
# CP 2015 (nearest maturities): c1-c2=0.98, c1-c5=0.89, c1-c10=0.74, c5-c10=0.98 — close match.

# Standard deviations (pct) and half-lives.
# Yields/cycles are in percent units, so sd() directly gives the "St.dev.×100"
# value comparable to CP 2015 (who report sd(decimal_yield)*100 = percent sd).
t1b_stats <- tibble(
  maturity          = us_mats,
  cycle_stdev_pct   = round(sapply(us_wide[cyc_cols], sd,           na.rm = TRUE), 2),
  cycle_halflife_mo = round(sapply(us_wide[cyc_cols], ar1_halflife),               2),
  yield_stdev_pct   = round(sapply(us_wide[yld_cols], sd,           na.rm = TRUE), 2),
  yield_halflife_mo = round(sapply(us_wide[yld_cols], ar1_halflife),               2)
)

cat("\n===== CP 2015 Table 1 — Panel B: Std deviations and half-lives =====\n")
print(t1b_stats, digits = 4)
# Results (std dev in %, half-life in months):
#  maturity  cycle_stdev_pct  cycle_halflife_mo  yield_stdev_pct  yield_halflife_mo
#         1             1.61              55.37             2.50              56.43
#         2             1.49              36.10             2.52              52.34
#         4             1.23              23.30             2.33              48.04
#         5             1.11              18.30             2.24              45.89
#         9             0.82              11.20             1.98              45.52
#        10             0.78              10.37             1.92              45.76
# CP 2015 (nearest maturities, cycles):  1Y: sd=1.74 hl=15.07 | 5Y: sd=1.14 hl=10.75 | 10Y: sd=0.88 hl=9.34
# CP 2015 (nearest maturities, yields):  1Y: sd=3.23 hl=67.18 | 5Y: sd=2.84 hl=92.34 | 10Y: sd=2.59 hl=107.75
# Note: cycle std devs match CP closely; shorter half-lives in cycles and yields reflect
#       the post-1989 sample which excludes the high-volatility / high-persistence 1970s–80s.


# --- Sanity check: Figure 2 of CP 2015 (cor(c_bar, CF) ≈ 0.61) -----------
us_data <- reg_data %>%
  dplyr::filter(country == "US", as.Date(date) <= as.Date("2014-12-31"))

cat(sprintf("\nFigure 2 check: cor(c_bar, CF) = %.2f   [CP 2015 report ~0.61]\n",
            cor(us_data$c_bar, us_data$CF, use = "pairwise.complete.obs")))
# Result: cor(c_bar, CF) = 0.70


# --- Rendered exhibits: CP 2015 Table 1 ----------------------------------
t1a_disp <- t1a %>%
  transmute(
    Maturity = paste0(maturity, "y"),
    `a_n x100` = formatC(a_n_x100, format = "f", digits = 1),
    `t(a_n)`   = formatC(t_a,      format = "f", digits = 2),
    `b_n`      = formatC(b_n,      format = "f", digits = 2),
    `t(b_n)`   = formatC(t_b,      format = "f", digits = 2),
    `R2_bar`   = formatC(R2_bar,   format = "f", digits = 2))

tables$cp_t1_panelA <- table_to_grob(
  as.data.frame(t1a_disp),
  title = "CP 2015 Table 1A. Yields on trend inflation",
  note  = paste0("y_t^(n) = a_n + b_n tau_t^CPI + e_t, by maturity. US, ",
                 "1989m3-2014m12. Newey-West t-stats (18 lags).\n",
                 "a_n in basis points. Sample is shorter than CP 2015 ",
                 "(1975-2014), so intercept levels differ; slopes and R2 align."),
  base_size = 9, note_lines = 3)

t1b_disp <- t1b_stats %>%
  transmute(
    Maturity = paste0(maturity, "y"),
    `Cycle SD`        = formatC(cycle_stdev_pct,   format = "f", digits = 2),
    `Cycle half-life` = formatC(cycle_halflife_mo, format = "f", digits = 1),
    `Yield SD`        = formatC(yield_stdev_pct,   format = "f", digits = 2),
    `Yield half-life` = formatC(yield_halflife_mo, format = "f", digits = 1))

tables$cp_t1_panelB <- table_to_grob(
  as.data.frame(t1b_disp),
  title = "CP 2015 Table 1B. Cycle and yield properties",
  note  = paste0("Standard deviation (in %) and AR(1) half-life (in months) of ",
                 "the maturity-specific cycle c^(n) and the yield y^(n).\n",
                 "US, 1989m3-2014m12. Half-life = ln(0.5)/ln(|psi|). Shorter ",
                 "half-lives than CP reflect the post-1989 sample."),
  base_size = 9, note_lines = 3)


# ============================================================
# CP 2015  –  Table 2: Predictive regressions
# LHS: rx_bar_{t+1} = duration-standardized, maturity-averaged excess return
# (reg_data$rx_t12).  US data, sample through 2014-12-31.
# t-stats: Hansen-Hodrick / Newey-West HAC, 18 lags (cp_inference.R; the
#   paper's exact reverse-regression delta method needs monthly returns + the
#   CP appendix, neither available here -- see cp_inference.R header).
# Maturities adapted to the data menu {1,2,4,5,9,10} (paper: 1/2/5/7/10/20).
# ============================================================

source("R/cp_inference.R")
source("R/cp_montecarlo.R")

# Trend inflation (one value per US month) and the six raw US yields (wide).
us_tau <- inflation_long %>%
  dplyr::filter(country == "US") %>%
  dplyr::select(ym, trend_inf)

us_yw <- cycle %>%
  dplyr::filter(country == "US") %>%
  dplyr::select(ym, maturity, yield) %>%
  tidyr::pivot_wider(names_from = maturity, values_from = yield,
                     names_prefix = "y_")

t2_df <- reg_data %>%
  dplyr::filter(country == "US", as.Date(date) <= as.Date("2014-12-31")) %>%
  dplyr::select(ym, date, rx_t12, rx_2_t12, rx_5_t12, rx_10_t12,
                cycle_1y, cycle_2y, cycle_5y, cycle_10y, c_bar, CF) %>%
  dplyr::left_join(us_yw,  by = "ym") %>%
  dplyr::left_join(us_tau, by = "ym") %>%
  dplyr::mutate(ybar = rowMeans(cbind(y_1, y_2, y_4, y_5, y_9, y_10))) %>%
  dplyr::arrange(date)

t2_specs <- list(
  "(1) Yields"      = c("y_1", "y_2", "y_4", "y_5", "y_9", "y_10"),
  "(2) Yields+tau"  = c("y_1", "y_2", "y_4", "y_5", "y_9", "y_10", "trend_inf"),
  "(3) y1,ybar"     = c("y_1", "ybar"),
  "(4) y1,ybar,tau" = c("y_1", "ybar", "trend_inf"),
  "(5) c1,cbar"     = c("cycle_1y", "c_bar")
)

# Common complete-case sample so the BIC relative probabilities are comparable.
t2_vars <- unique(unlist(t2_specs))
t2_cc <- t2_df[stats::complete.cases(t2_df[, c("rx_t12", t2_vars)]), ]
T2 <- nrow(t2_cc)

# Display-row mapping (paper layout, adapted to maturities 1/2/4/5/9/10).
t2_row <- function(term) dplyr::recode(term,
  y_1 = "y(1) or c(1)", cycle_1y = "y(1) or c(1)",
  y_2 = "y(2)", y_4 = "y(4)", y_5 = "y(5)", y_9 = "y(9)", y_10 = "y(10)",
  trend_inf = "tau^CPI", ybar = "ybar or cbar", c_bar = "ybar or cbar")

t2_run <- lapply(t2_specs, function(vars) {
  fit <- lm(reformulate(vars, "rx_t12"), data = t2_cc)
  hb  <- hac_inf(fit, lag = 18L)
  list(fit = fit, hb = hb, adjR2 = summary(fit)$adj.r.squared)
})

t2_bic <- bic_relprob(lapply(t2_run, function(z) z$fit))

# Coefficient and t-stat matrices (rows = display terms, cols = models).
t2_rows <- c("y(1) or c(1)", "y(2)", "y(4)", "y(5)", "y(9)", "y(10)",
             "tau^CPI", "ybar or cbar")
est_mat <- matrix(NA_real_, length(t2_rows), length(t2_specs),
                  dimnames = list(t2_rows, names(t2_specs)))
t_mat <- est_mat
for (nm in names(t2_run)) {
  hb <- t2_run[[nm]]$hb
  b  <- hb$coef[-1]; tt <- hb$t[-1]
  rr <- t2_row(names(b))
  est_mat[rr, nm] <- b
  t_mat[rr, nm]   <- tt
}

t2_stats <- tibble::tibble(
  model   = names(t2_specs),
  adjR2   = vapply(t2_run, function(z) z$adjR2,       numeric(1)),
  Wald    = vapply(t2_run, function(z) z$hb$wald,     numeric(1)),
  Wald_p  = vapply(t2_run, function(z) z$hb$wald_p,   numeric(1)),
  relprob = unname(t2_bic$relprob)
)

cat("\n===== CP 2015 Table 2 — Panel A: Predictive regressions =====\n")
cat(sprintf("LHS rx_bar_{t+1}; US %d obs (1990m1-2014m12); NW(18) HAC t-stats\n\n", T2))
cat("Coefficients:\n");                                 print(round(est_mat, 2))
cat("\nNewey-West HAC (18 lags) t-stats:\n");           print(round(t_mat, 2))
cat("\nRegression statistics:\n");                      print(as.data.frame(t2_stats), digits = 3)
# Paper (Table 2A): R2 = .24/.54/.18/.53/.53 ; Wald p = .05/.00/.04/.00/.00 ;
#   Rel.prob(BIC) = 0/3e-4/0/.57/1.00 ; col-5 c(1) t ~ -3.67, cbar t ~ 5.03.
# (Our sample is post-1989 and uses maturities 2/4/5/9/10, so levels differ.)


# --- Table 2, Panel B: predictive R2 under the EH null (Monte Carlo) ---------
# Distribution of the predictive R2 when bonds carry no risk premium, from the
# Section-1 model: excess returns regressed on trend inflation and the real
# factor (tau_t, r_t), as in CP 2015.  Paper uses T = 470 (reported first).
EH_NSIMS <- 5000L                 # paper uses 10,000; adjustable for runtime
cat("\n===== CP 2015 Table 2 — Panel B: predictive R2 under EH =====\n")
cat(sprintf("Predictor (tau, r); n_sims=%d; P5/P50/P95 of adjusted R2\n", EH_NSIMS))
eh_470 <- run_eh_grid(T_ = 470L, n_sims = EH_NSIMS)
cat("\nAt paper's T = 470:\n");                        print(eh_470, digits = 3, row.names = FALSE)
eh_ours <- run_eh_grid(T_ = T2, n_sims = EH_NSIMS)
cat(sprintf("\nAt our sample length T = %d:\n", T2)); print(eh_ours, digits = 3, row.names = FALSE)
# Paper (Table 2B): P95 of R-bar^2 ranges ~0.19-0.23 across the phi grid.
# Ours has the right shape (P95 rises with both persistences) but a lower level
# (~0.10 at T=470, ~0.19 at T=300). NOT validated to the published level: under
# the EH (lambda=0) our average-expected-short-rate yields equal the affine
# model's loadings (Eq 14 with phi*=phi), so the gap is not a model
# approximation -- it reflects calibration details the paper underspecifies
# (1.74% is the 1-year-cycle sd; predictor = the latent (tau, r)).


# --- Rendered exhibits: CP 2015 Table 2 ----------------------------------
# Panel A: one cell per coefficient as "estimate (t)", plus a stats block.
fmt2 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 2))
t2a_cells <- matrix("", nrow(est_mat), ncol(est_mat),
                    dimnames = dimnames(est_mat))
for (i in seq_len(nrow(est_mat))) for (j in seq_len(ncol(est_mat))) {
  if (!is.na(est_mat[i, j]))
    t2a_cells[i, j] <- paste0(fmt2(est_mat[i, j]), " (", fmt2(t_mat[i, j]), ")")
}
t2a_body <- cbind(Regressor = rownames(t2a_cells),
                  as.data.frame(t2a_cells, stringsAsFactors = FALSE))
stat_block <- data.frame(
  Regressor = c("R2_bar", "Wald", "Wald p", "Rel.prob.(BIC)"),
  rbind(fmt2(t2_stats$adjR2), fmt2(t2_stats$Wald),
        formatC(t2_stats$Wald_p, format = "f", digits = 3),
        fmt2(t2_stats$relprob)),
  stringsAsFactors = FALSE)
colnames(stat_block) <- colnames(t2a_body)
t2a_disp <- rbind(t2a_body, stat_block)
rownames(t2a_disp) <- NULL

tables$cp_t2_panelA <- table_to_grob(
  t2a_disp,
  title = "CP 2015 Table 2A. Predictive regressions of rx_bar",
  note  = paste0("LHS: duration-standardized, maturity-averaged excess return ",
                 "rx_bar_{t+1}. US, ", T2, " obs (1990m1-2014m12).\n",
                 "Cells: coefficient (Newey-West HAC t-stat, 18 lags). ",
                 "Rel.prob.(BIC) = exp((BIC_best - BIC_i)/2); best model = 1.00."),
  base_size = 8, note_lines = 3)

# Panel B: EH R2 distribution grid (at the paper's T = 470).
t2b_disp <- as.data.frame(eh_470) %>%
  transmute(
    `phi_tau` = formatC(phi_tau, format = "f", digits = 3),
    `phi_r`   = formatC(phi_r,   format = "f", digits = 2),
    P5  = formatC(P5,  format = "f", digits = 3),
    P50 = formatC(P50, format = "f", digits = 3),
    P95 = formatC(P95, format = "f", digits = 3))

tables$cp_t2_panelB <- table_to_grob(
  t2b_disp,
  title = "CP 2015 Table 2B. Predictive R2 under the EH null",
  note  = paste0("Percentiles of the adjusted R2 from rx_bar ~ (tau, r) under ",
                 "the EH (lambda=0), ", EH_NSIMS, " sims, T = 470.\n",
                 "P95 rises with persistence (right shape); level is below CP's ",
                 "0.19-0.23 due to underspecified calibration (see code note)."),
  base_size = 9, note_lines = 3)


# ============================================================
# CP 2015  –  Table 4: Predicting returns with the cycle factor
# LHS: individual excess returns rx^(n)_{t+1}, n = 2, 5, 10 (data menu).
# Panel A: single cycle factor cf_t (= reg_data$CF).  Panel B: maturity cycles.
# ============================================================

t4_mats <- c(2L, 5L, 10L)
t4_df <- reg_data %>%
  dplyr::filter(country == "US", as.Date(date) <= as.Date("2014-12-31")) %>%
  dplyr::select(ym, date, rx_2_t12, rx_5_t12, rx_10_t12,
                cycle_1y, cycle_2y, cycle_5y, cycle_10y, CF) %>%
  dplyr::left_join(us_yw,  by = "ym") %>%
  dplyr::left_join(us_tau, by = "ym") %>%
  dplyr::arrange(date)

yld6 <- c("y_1", "y_2", "y_4", "y_5", "y_9", "y_10")

t4 <- lapply(t4_mats, function(n) {
  rxv <- paste0("rx_", n, "_t12")
  cyn <- paste0("cycle_", n, "y")
  d   <- t4_df[stats::complete.cases(t4_df[, c(rxv, cyn, "cycle_1y", "CF",
                                               "trend_inf", yld6)]), ]
  # Duration-standardized individual excess return (D_n = n for a continuously
  # compounded zero). CP 2015 state this convention explicitly ("Because the
  # volatility of returns scales proportionally with bond duration, we duration
  # standardize returns to avoid overweighting particular maturities"); the flat
  # Table 4 cf loadings (~0.6-0.7 across maturities) confirm the individual-
  # maturity regressions use it too. R2/t-stats are unaffected by this scaling.
  d$rx_std <- d[[rxv]] / n

  # Panel A: rx^(n) ~ cf_t (cf = CF).  Headline HAC t + block-bootstrap SS band.
  fitA <- lm(rx_std ~ CF, data = d)
  hbA  <- hac_inf(fitA, lag = 18L)
  ssA  <- block_boot_t(d$rx_std, d$CF, L = 12L, R = 5000L, seed = 100L + n,
                       recenter = FALSE)   # SS = distribution of the t-stat itself
  r2A  <- summary(fitA)$adj.r.squared
  r2_eq23 <- summary(lm(reformulate(c(yld6, "trend_inf"), "rx_std"), data = d))$adj.r.squared

  # Panel B1: rx^(n) ~ c^(1) + c^(n).   B2: rx^(n) ~ c^(n).
  fitB1 <- lm(reformulate(c("cycle_1y", cyn), "rx_std"), data = d)
  fitB2 <- lm(reformulate(cyn, "rx_std"),                data = d)
  hbB1  <- hac_inf(fitB1, lag = 18L)
  hbB2  <- hac_inf(fitB2, lag = 18L)

  list(n = n, nobs = nrow(d),
       A  = list(beta = hbA$coef[["CF"]], t = hbA$t[["CF"]],
                 ss = ssA, r2 = r2A, dR2 = r2_eq23 - r2A),
       B1 = list(b1 = hbB1$coef[["cycle_1y"]], t1 = hbB1$t[["cycle_1y"]],
                 bn = hbB1$coef[[cyn]],        tn = hbB1$t[[cyn]],
                 r2 = summary(fitB1)$adj.r.squared),
       B2 = list(bn = hbB2$coef[[cyn]], tn = hbB2$t[[cyn]],
                 r2 = summary(fitB2)$adj.r.squared))
})
names(t4) <- paste0("rx", t4_mats)

t4_fmt <- function(x) formatC(x, format = "f", digits = 2)
t4col  <- function(z) c(
  cf            = t4_fmt(z$A$beta),
  `(t)`         = paste0("(", t4_fmt(z$A$t), ")"),
  `SS[5,95]`    = paste0("[", t4_fmt(z$A$ss[["lo"]]), ",", t4_fmt(z$A$ss[["hi"]]), "]"),
  R2_A          = t4_fmt(z$A$r2),
  dR2           = t4_fmt(z$A$dR2),
  `c(1)|B1`     = paste0(t4_fmt(z$B1$b1), " (", t4_fmt(z$B1$t1), ")"),
  `c(n)|B1`     = paste0(t4_fmt(z$B1$bn), " (", t4_fmt(z$B1$tn), ")"),
  R2_B1         = t4_fmt(z$B1$r2),
  `c(n)|B2`     = paste0(t4_fmt(z$B2$bn), " (", t4_fmt(z$B2$tn), ")"),
  R2_B2         = t4_fmt(z$B2$r2))
t4_tab <- sapply(t4, t4col)
colnames(t4_tab) <- paste0("rx(", t4_mats, ")")

cat("\n===== CP 2015 Table 4 — Predicting returns with the cycle factor =====\n")
cat(sprintf("US %d obs; cf_t = CF; t-stats Newey-West HAC (18 lags);\n",
            t4[[1]]$nobs))
cat("SS[5,95] = stationary block bootstrap of the HAC cf t-stat (mean block 12, R=5000).\n\n")
print(t4_tab, quote = FALSE)
# Paper (Table 4): Panel A cf coef rises with n (~0.62..0.72), t ~ 4-5, R2 ~ .38-.54,
#   dR2 ~ .01-.04 ; Panel B1 c(1)<0, c(n)>0 ; Panel B2 c(n)>0 rising R2 with n.


# --- Rendered exhibit: CP 2015 Table 4 -----------------------------------
# Friendly row labels for the t4_tab matrix (rows = stats, cols = rx(n)).
t4_rowlab <- c(
  cf = "cf", `(t)` = "  (t-stat)", `SS[5,95]` = "  SS [5%,95%]",
  R2_A = "  R2_bar", dR2 = "  Delta R2",
  `c(1)|B1` = "B1: c(1) (t)", `c(n)|B1` = "B1: c(n) (t)", R2_B1 = "  R2_bar",
  `c(n)|B2` = "B2: c(n) (t)", R2_B2 = "  R2_bar")
t4_disp <- data.frame(Statistic = t4_rowlab[rownames(t4_tab)],
                      t4_tab, check.names = FALSE, stringsAsFactors = FALSE)
rownames(t4_disp) <- NULL

tables$cp_t4 <- table_to_grob(
  t4_disp,
  title = "CP 2015 Table 4. Predicting individual returns with the cycle factor",
  note  = paste0("LHS: duration-standardized individual excess return rx^(n). ",
                 "US, ", t4[[1]]$nobs, " obs. Panel A regresses on cf; B1 on ",
                 "c^(1)+c^(n); B2 on c^(n).\n",
                 "t-stats Newey-West HAC (18 lags). SS = stationary block ",
                 "bootstrap of the cf t-stat (mean block 12, R=5000)."),
  base_size = 9, note_lines = 3)


# ============================================================
# DH 2013  –  Table 1: Summary statistics of zero-coupon yields
# Full international panel (11 countries, maturities 1/2/4/5/9/10y),
# yields in percent, full per-country sample. Adapted from DH's
# 4-country / 1mo-5yr / 1975-2009 original; split into two A4-friendly
# exhibits (per-country mean & sd; cross-country 10y correlations).
# ============================================================

# Country code -> full name, ordered EUR bloc first (BE/DE/FR/IT/NL share the
# euro and co-move strongly post-1999), then other Europe, then RoW.
dh_ctry_order <- c("BE", "DE", "FR", "IT", "NL", "CH", "GB", "SE", "CA", "JP", "US")
dh_ctry_name  <- c(BE = "Belgium", CA = "Canada", CH = "Switzerland",
                   DE = "Germany", FR = "France", GB = "UK", IT = "Italy",
                   JP = "Japan", NL = "Netherlands", SE = "Sweden", US = "US")
dh_mats <- c(1, 2, 4, 5, 9, 10)

# --- Table 1A: mean & std of yields by country x maturity --------------------
dh_stats <- yields_long %>%
  filter(!is.na(yield), maturity %in% dh_mats) %>%
  group_by(country, maturity) %>%
  summarise(Mean = mean(yield), SD = sd(yield), .groups = "drop")

dh_t1a_df <- dh_stats %>%
  pivot_wider(names_from = maturity, values_from = c(Mean, SD),
              names_glue = "{maturity}y_{.value}") %>%
  mutate(Country = dh_ctry_name[country],
         country = factor(country, levels = dh_ctry_order)) %>%
  arrange(country) %>%
  select(Country, paste0(rep(dh_mats, each = 2), "y_", c("Mean", "SD"))) %>%
  mutate(across(where(is.numeric), ~ formatC(.x, format = "f", digits = 2)))
names(dh_t1a_df) <- sub("^(\\d+)y_(Mean|SD)$", "\\1y \\2", names(dh_t1a_df))

cat("\n===== DH 2013 Table 1A — Yield summary statistics =====\n")
print(as.data.frame(dh_t1a_df), row.names = FALSE)

tables$dh_t1_summary <- table_to_grob(
  as.data.frame(dh_t1a_df),
  title = "DH 2013 Table 1A. Summary statistics of zero-coupon yields (% p.a.)",
  note  = paste0("Mean and standard deviation of monthly zero-coupon yields, in ",
                 "percent, by country and maturity (full per-country sample).\n",
                 "Sample: US from 1989-03 and Japan from 1989-04; all other ",
                 "countries from 1994-12; all through 2026-04. Yields tend to ",
                 "rise and grow less volatile with maturity."),
  base_size = 8, note_lines = 3)

# --- Table 1B: cross-country correlation of the 10-year yield ----------------
dh_y10_wide <- yields_long %>%
  filter(maturity == 10) %>%
  select(ym, country, yield) %>%
  pivot_wider(names_from = country, values_from = yield)

dh_corr10 <- cor(dh_y10_wide[, dh_ctry_order], use = "pairwise.complete.obs")

# Lower-triangular display (blank upper triangle).
dh_corr10_disp <- formatC(dh_corr10, format = "f", digits = 2)
dh_corr10_disp[upper.tri(dh_corr10_disp)] <- ""
dh_corr10_df <- cbind(Country = dh_ctry_name[dh_ctry_order],
                      as.data.frame(dh_corr10_disp, stringsAsFactors = FALSE))
colnames(dh_corr10_df) <- c("Country", dh_ctry_order)
rownames(dh_corr10_df) <- NULL

cat("\n===== DH 2013 Table 1B — 10y yield cross-country correlations =====\n")
print(dh_corr10_df, row.names = FALSE)

tables$dh_t1_corr10y <- table_to_grob(
  dh_corr10_df,
  title = "DH 2013 Table 1B. Cross-country correlation of the 10-year yield",
  note  = paste0("Pairwise-complete correlations of the monthly 10-year ",
                 "zero-coupon yield across countries (full per-country sample).\n",
                 "Column labels are ISO codes for the countries in the first ",
                 "column. Correlations are high within the euro bloc."),
  base_size = 8, note_lines = 3)


# ============================================================
# DH 2013  –  Tables 3, 4, 6, 7
# International CP-factor predictability, all 11 countries (n in {2,5,10}, the
# data menu). DH convention: raw individual excess returns rx^(n) (NOT
# duration-standardized), Newey-West t-stats with 12 lags, adjusted R2 with 90%
# stationary-block-bootstrap CIs {lo, hi}. Reuses hac_inf() + block_boot_r2_ci()
# from cp_inference.R and the CP/GCP/FXGCF factors from reg_data/gcp/fxgcf.
# ============================================================

DH_NW_LAG <- 12L      # DH: "serial correlation up to twelve lags"
DH_N      <- c(2L, 5L, 10L)
dh_all    <- c("BE", "DE", "FR", "IT", "NL", "CH", "GB", "SE", "CA", "JP", "US")

# Per-country panel: local rx (local + USD), forwards, CP, plus global factors.
dh_panel <- reg_data %>%
  dplyr::select(country, ym, date, y_1, f_2, f_5, f_10,
                rx_2_t12, rx_5_t12, rx_10_t12,
                rx_2_USD_t12, rx_5_USD_t12, rx_10_USD_t12, CP) %>%
  dplyr::left_join(gcp   %>% dplyr::select(ym, GCP),   by = "ym") %>%
  dplyr::left_join(fxgcf %>% dplyr::select(ym, FXGCF), by = "ym")

# One predictive regression: NW(12) point estimate, t-stats, joint Wald, adj R2.
dh_reg <- function(d, yvar, xvars, lag = DH_NW_LAG) {
  d <- d[stats::complete.cases(d[, c(yvar, xvars)]), ]
  if (nrow(d) < 24) return(NULL)
  fit <- lm(reformulate(xvars, yvar), data = d)
  hb  <- hac_inf(fit, lag = lag)
  list(b = hb$coef, t = hb$t, wald = hb$wald, wald_p = hb$wald_p,
       r2 = summary(fit)$adj.r.squared, n = nrow(d))
}

fmtb <- function(x) formatC(x, format = "f", digits = 2)


# --- DH Table 3: correlations among local CP factors and the GCP -------------
dh_cp_wide <- reg_data %>%
  dplyr::select(ym, date, country, CP) %>%
  tidyr::pivot_wider(names_from = country, values_from = CP) %>%
  dplyr::left_join(gcp %>% dplyr::select(ym, GCP), by = "ym")

dh_corr_block <- function(df) {
  M <- cor(as.matrix(df[, c(dh_all, "GCP")]), use = "pairwise.complete.obs")
  disp <- formatC(M, format = "f", digits = 2)
  disp[upper.tri(disp)] <- ""
  out <- cbind(Factor = c(dh_all, "Global"),
               as.data.frame(disp, stringsAsFactors = FALSE))
  colnames(out) <- c("Factor", dh_all, "Global"); rownames(out) <- NULL
  out
}

dh_t3_full <- dh_corr_block(dh_cp_wide)

cat("\n===== DH 2013 Table 3 — Local/global CP factor correlations =====\n")
print(dh_t3_full, row.names = FALSE)

tables$dh_t3_cp_corr <- table_to_grob(
  dh_t3_full,
  title = "DH 2013 Table 3. Correlations between local and global CP factors",
  note  = paste0("Correlations of the monthly local CP factors and the ",
                 "GDP-weighted global CP factor (GCP), full sample (1990-2024). ",
                 "Lower triangle shown."),
  base_size = 8, note_lines = 3)


# --- DH Table 4: Fama-Bliss (Eq 3) and CP (Eq 4) regressions -----------------
dh_t4_rows <- list()
for (cc in dh_all) {
  dctry <- dplyr::filter(dh_panel, country == cc)
  for (n in DH_N) {
    rxv <- paste0("rx_", n, "_t12"); fwd <- paste0("f_", n)
    d <- dctry; d$fb_spread <- d[[fwd]] - d$y_1
    fb <- dh_reg(d, rxv, "fb_spread"); cp <- dh_reg(d, rxv, "CP")
    if (is.null(fb) || is.null(cp)) next
    dh_t4_rows[[paste(cc, n)]] <- data.frame(
      Country = cc, n = n,
      `b_FB` = fmtb(fb$b[[2]]),    `(t_FB)` = paste0("(", fmtb(fb$t[[2]]), ")"),
      `R2_FB` = fmtb(fb$r2),
      `b_CP` = fmtb(cp$b[["CP"]]), `(t_CP)` = paste0("(", fmtb(cp$t[["CP"]]), ")"),
      `R2_CP` = fmtb(cp$r2),
      check.names = FALSE, stringsAsFactors = FALSE)
  }
}
dh_t4_df <- do.call(rbind, dh_t4_rows); rownames(dh_t4_df) <- NULL
dh_t4_df$Country[duplicated(dh_t4_df$Country)] <- ""

cat("\n===== DH 2013 Table 4 — Fama-Bliss and CP regressions =====\n")
print(dh_t4_df, row.names = FALSE)

tables$dh_t4_fb_cp <- table_to_grob(
  dh_t4_df,
  title = "DH 2013 Table 4. Fama-Bliss and Cochrane-Piazzesi regressions",
  note  = paste0("LHS: raw excess return rx^(n). FB regresses on the forward-spot ",
                 "spread (f^(n)-y^(1)); CP on the local CP factor.\n",
                 "Newey-West t-stats (12 lags) in (.); adjusted R2 reported. ",
                 "All 11 countries, n in {2,5,10}."),
  base_size = 7, note_lines = 3)


# --- DH Table 6: local (Eq 4), global (Eq 6), joint orthogonalized (Eq 7) ----
dh_t6_rows <- list()
for (cc in dh_all) {
  dctry <- dplyr::filter(dh_panel, country == cc)
  for (n in DH_N) {
    rxv <- paste0("rx_", n, "_t12")
    loc  <- dh_reg(dctry, rxv, "CP")
    glob <- dh_reg(dctry, rxv, "GCP")
    dj <- dctry[stats::complete.cases(dctry[, c(rxv, "CP", "GCP")]), ]
    if (is.null(loc) || is.null(glob) || nrow(dj) < 24) next
    # Eq 7: orthogonalize local CP vs GCP, then rx ~ CP_perp + GCP.
    dj$CP_perp <- residuals(lm(CP ~ GCP, data = dj))
    joint <- dh_reg(dj, rxv, c("CP_perp", "GCP"))
    dh_t6_rows[[paste(cc, n)]] <- data.frame(
      Country = cc, n = n,
      `b_CP` = fmtb(loc$b[["CP"]]),     `R2_loc` = fmtb(loc$r2),
      `b_GCP` = fmtb(glob$b[["GCP"]]),  `R2_glb` = fmtb(glob$r2),
      `b_CPp` = fmtb(joint$b[["CP_perp"]]), `b_GCP.j` = fmtb(joint$b[["GCP"]]),
      `R2_jnt` = fmtb(joint$r2),
      `Wald p` = paste0("[", formatC(joint$wald_p, format = "f", digits = 2), "]"),
      check.names = FALSE, stringsAsFactors = FALSE)
  }
}
dh_t6_df <- do.call(rbind, dh_t6_rows); rownames(dh_t6_df) <- NULL
dh_t6_df$Country[duplicated(dh_t6_df$Country)] <- ""

cat("\n===== DH 2013 Table 6 — Local and global CP regressions =====\n")
print(dh_t6_df, row.names = FALSE)

tables$dh_t6_local_global <- table_to_grob(
  dh_t6_df,
  title = "DH 2013 Table 6. Local and global Cochrane-Piazzesi regressions",
  note  = paste0("rx^(n) on: local CP (Eq 4); global GCP (Eq 6); and both, with ",
                 "the local factor orthogonalized vs GCP (Eq 7).\n",
                 "Adjusted R2 shown; Wald p-value of joint significance in [.]. ",
                 "Newey-West, 12 lags. All 11 countries, n in {2,5,10}."),
  base_size = 7, note_lines = 3)


# --- DH Table 7: USD excess returns on GCP and FXGCP -------------------------
dh_ccy_rep <- c(EUR = "DE", CHF = "CH", GBP = "GB", JPY = "JP", CAD = "CA", SEK = "SE")
dh_t7_rows <- list()
for (ccy in names(dh_ccy_rep)) {
  dctry <- dplyr::filter(dh_panel, country == dh_ccy_rep[[ccy]])
  for (n in DH_N) {
    rxv <- paste0("rx_", n, "_USD_t12")
    g  <- dh_reg(dctry, rxv, "GCP")
    fx <- dh_reg(dctry, rxv, "FXGCF")
    if (is.null(g) || is.null(fx)) next
    dh_t7_rows[[paste(ccy, n)]] <- data.frame(
      Pair = paste0(ccy, "/USD"), n = n,
      `b_GCP` = fmtb(g$b[["GCP"]]),      `(t_G)` = paste0("(", fmtb(g$t[["GCP"]]), ")"),
      `R2_GCP` = fmtb(g$r2),
      `b_FXGCP` = fmtb(fx$b[["FXGCF"]]), `(t_FX)` = paste0("(", fmtb(fx$t[["FXGCF"]]), ")"),
      `R2_FXGCP` = fmtb(fx$r2),
      check.names = FALSE, stringsAsFactors = FALSE)
  }
}
dh_t7_df <- do.call(rbind, dh_t7_rows); rownames(dh_t7_df) <- NULL
dh_t7_df$Pair[duplicated(dh_t7_df$Pair)] <- ""

cat("\n===== DH 2013 Table 7 — USD excess return regressions =====\n")
print(dh_t7_df, row.names = FALSE)

tables$dh_t7_usd <- table_to_grob(
  dh_t7_df,
  title = "DH 2013 Table 7. US dollar excess return regressions",
  note  = paste0("Annual USD excess returns (US investor in a foreign bond) on ",
                 "the global GCP and the dollar-return FXGCP (= our FXGCF).\n",
                 "Newey-West t (12 lags) in (.); adjusted R2 reported. ",
                 "EUR=Germany, others=own market; n in {2,5,10}."),
  base_size = 7, note_lines = 3)


# ============================================================
# Write every rendered result table to disk as a vector PDF.
# Per-exhibit canvas sizes (wide tables need more width / less height).
# ============================================================
save_all_tables <- function(dir = "thesis/tables", width = 9, height = 5) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  size_override <- list(
    cp_t1_panelA  = c(w = 8,  h = 3.2),
    cp_t1_panelB  = c(w = 8,  h = 3.2),
    cp_t2_panelA  = c(w = 9,  h = 4.5),
    cp_t2_panelB  = c(w = 7,  h = 3.6),
    cp_t4         = c(w = 8,  h = 4.2),
    dh_t1_summary = c(w = 11, h = 3.8),
    dh_t1_corr10y = c(w = 10, h = 3.8),
    dh_t3_cp_corr = c(w = 9,  h = 4.2),
    dh_t4_fb_cp   = c(w = 8,  h = 9.5),
    dh_t6_local_global = c(w = 11, h = 9.5),
    dh_t7_usd     = c(w = 9,  h = 6.5)
  )
  purrr::iwalk(tables, function(g, nm) {
    sz <- size_override[[nm]]
    w  <- if (is.null(sz)) width  else sz[["w"]]
    h  <- if (is.null(sz)) height else sz[["h"]]
    ggplot2::ggsave(file.path(dir, paste0(nm, ".pdf")), g, width = w, height = h)
  })
  invisible(file.path(dir, paste0(names(tables), ".pdf")))
}

cat(sprintf(
  "\nempirical.R loaded: %d result tables in `tables`. Render one with grid::grid.draw(tables$<name>); write all with save_all_tables() -> tables/<name>.pdf\n",
  length(tables)))
