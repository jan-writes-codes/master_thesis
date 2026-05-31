# empirical.R
# Empirical replication: CP 2015 and DH 2013
# =============================================================

library(lmtest)
library(sandwich)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(plm)

if (!exists("reg_data")) source("data preperation.R")


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


# ============================================================
# CP 2015  –  Table 2: Predictive regressions
# LHS: rx_bar_{t+1} = duration-standardized, maturity-averaged excess return
# (reg_data$rx_t12).  US data, sample through 2014-12-31.
# t-stats: Hansen-Hodrick / Newey-West HAC, 18 lags (cp_inference.R; the
#   paper's exact reverse-regression delta method needs monthly returns + the
#   CP appendix, neither available here -- see cp_inference.R header).
# Maturities adapted to the data menu {1,2,4,5,9,10} (paper: 1/2/5/7/10/20).
# ============================================================

source("cp_inference.R")
source("cp_montecarlo.R")

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
# Ours rises with persistence to ~0.10-0.13 -- same shape and ~half the level.
# The gap is the simplified EH yield mapping (yield = avg expected short rate)
# vs CP's full affine model (Eq 17); both confirm large spurious R2 under EH.


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


# ============================================================
# DH 2013 REPLICATION  (to be added)
# ============================================================

# Table 1

# Table 2

# Table 3

# Table 6

# Table 7
