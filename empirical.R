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

if (!exists("cycle")) source("data preperation.R")


# ============================================================
# CP 2015  –  Table 1: Properties of interest-rate cycles
# US data, sample through 2014-12-31
# ============================================================

us_cycle_raw <- cycle %>%
  filter(country == "US", date <= as.Date("2014-12-31")) %>%
  filter(!is.na(yield), !is.na(trend_inf))

us_mats <- sort(unique(us_cycle_raw$maturity))

# Sample-restricted regressions: Panel A defines the cycles used in Panel B.
# (Full-sample residuals stored in cycle$cycle would give a slight mismatch.)
us_fits <- lapply(setNames(us_mats, us_mats), function(m) {
  d <- filter(us_cycle_raw, maturity == m)
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

# Standard deviations × 100 and half-lives
t1b_stats <- tibble(
  maturity          = us_mats,
  cycle_stdev_x100  = round(sapply(us_wide[cyc_cols], sd,           na.rm = TRUE) * 100, 2),
  cycle_halflife_mo = round(sapply(us_wide[cyc_cols], ar1_halflife),                     2),
  yield_stdev_x100  = round(sapply(us_wide[yld_cols], sd,           na.rm = TRUE) * 100, 2),
  yield_halflife_mo = round(sapply(us_wide[yld_cols], ar1_halflife),                     2)
)

cat("\n===== CP 2015 Table 1 — Panel B: Std deviations and half-lives =====\n")
print(t1b_stats, digits = 4)


# --- Sanity check: Figure 2 of CP 2015 (cor(c_bar, CF) ≈ 0.61) -----------
us_data <- reg_data %>%
  filter(country == "US", date <= as.Date("2014-12-31"))

cat(sprintf("\nFigure 2 check: cor(c_bar, CF) = %.2f   [CP 2015 report ~0.61]\n",
            cor(us_data$c_bar, us_data$CF, use = "pairwise.complete.obs")))


# ============================================================
# DH 2013 REPLICATION  (to be added)
# ============================================================

# Table 1

# Table 2

# Table 3

# Table 6

# Table 7
