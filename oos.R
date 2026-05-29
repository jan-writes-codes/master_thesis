# oos.R
# =============================================================
# Fully-recursive out-of-sample (OOS) versions of the cycle factor
# chain: CF_oos -> GCF_oos -> FXGCF_oos.
#
# Every layer is rebuilt from data <= t (no look-ahead):
#   1. eq 1-2 yield-cycle decomposition (lm(yield ~ trend_inf)
#      re-fit at each t per country x maturity)
#   2. eq 4-6 local CF predictive regression
#      (rx_t12 ~ cycle_1y_oos + c_bar_oos, training respects the
#      12-month outcome lag)
#   3. DH-style top-down FXGCF
#      (rx_USD_bar_t12 ~ cyc1_bar_oos + cbar_bar_oos, recursive)
#
# Trend inflation (`trend_inf` in `inflation_long`) is already
# backward-looking (cp_trend uses a trailing 120m DMA), so it is
# reused as-is.
#
# Run from project root; sources `data preperation.R` (which leaves
# `yields_long`, `inflation_long`, `reg_data`, `gcf`, `fxgcf`, `gdp`
# in the workspace).
# =============================================================

source("data preperation.R")

library(dplyr)
library(tidyr)
library(purrr)

# -------------------------------------------------------------
# Generic helpers
# -------------------------------------------------------------

# Real-time contemporaneous residual: at each row t, OLS-fit `fml` on
# rows 1..t (expanding window) and return the fitted residual AT t.
# Used for the yield-cycle decomposition where regressors and dependent
# variable are both known at t (no observation lag).
recursive_resid <- function(df, fml, min_train = 60) {
  df  <- df %>% arrange(ym)
  T_o <- nrow(df)
  out <- rep(NA_real_, T_o)
  yvar <- all.vars(fml)[1]
  if (T_o < min_train) return(out)
  for (t in min_train:T_o) {
    train <- df[1:t, , drop = FALSE]
    if (sum(!is.na(train[[yvar]])) < min_train) next
    fit <- tryCatch(lm(fml, data = train, na.action = na.exclude),
                    error = function(e) NULL)
    if (is.null(fit)) next
    pred_t <- tryCatch(as.numeric(predict(fit, newdata = df[t, , drop = FALSE])),
                       error = function(e) NA_real_)
    out[t] <- df[[yvar]][t] - pred_t
  }
  out
}

# 1-step expanding-window OLS prediction respecting an h-month outcome
# lag: yhat[t] uses coefficients estimated only on rows whose outcome is
# already realized by date[t] (training = rows with date[s] + h months
# <= date[t]). Requires a `date` column in df.
oos_predict <- function(df, fml, min_train = 120, h = 12) {
  df   <- df %>% arrange(ym)
  T_o  <- nrow(df)
  yhat <- rep(NA_real_, T_o)
  yvar <- all.vars(fml)[1]
  mo_idx <- as.integer(format(df$date, "%Y")) * 12L +
            as.integer(format(df$date, "%m"))
  for (t in seq_len(T_o)) {
    cutoff <- mo_idx[t] - h
    train_idx <- which(mo_idx <= cutoff)
    if (length(train_idx) == 0L) next
    train <- df[train_idx, , drop = FALSE]
    if (sum(!is.na(train[[yvar]])) < min_train) next
    fit <- tryCatch(lm(fml, data = train, na.action = na.exclude),
                    error = function(e) NULL)
    if (is.null(fit)) next
    yhat[t] <- tryCatch(as.numeric(predict(fit, newdata = df[t, , drop = FALSE])),
                        error = function(e) NA_real_)
  }
  yhat
}

# -------------------------------------------------------------
# 1. Recursive cycle decomposition (eq 1-2) per country x maturity
# -------------------------------------------------------------
cat("oos.R: building recursive cycle_oos per country x maturity ...\n")

cycle_oos <- yields_long %>%
  left_join(inflation_long, by = c("ym", "country")) %>%
  filter(!is.na(trend_inf), !is.na(yield)) %>%
  group_by(country, maturity) %>%
  group_modify(~ {
    d <- .x %>% arrange(ym)
    d$cycle_oos <- recursive_resid(d, yield ~ trend_inf, min_train = 60)
    d
  }) %>%
  ungroup() %>%
  select(-date.y) %>%
  rename(date = date.x)

# -------------------------------------------------------------
# 2. Derive cycle_1y_oos and c_bar_oos (eq 5)
# -------------------------------------------------------------
cycle_1y_oos <- cycle_oos %>%
  filter(maturity == 1) %>%
  select(country, ym, date, cycle_1y_oos = cycle_oos)

cycle_avg_oos <- cycle_oos %>%
  filter(maturity != 1) %>%
  group_by(country, ym, date) %>%
  summarise(c_bar_oos = mean(cycle_oos, na.rm = TRUE), .groups = "drop") %>%
  mutate(c_bar_oos = ifelse(is.nan(c_bar_oos), NA_real_, c_bar_oos))

# -------------------------------------------------------------
# 3. reg_data_oos with CF_oos (recursive predictive regression, eq 6)
# -------------------------------------------------------------
cat("oos.R: building reg_data_oos with recursive CF_oos ...\n")

reg_data_oos <- cycle_1y_oos %>%
  left_join(cycle_avg_oos, by = c("country", "ym", "date")) %>%
  left_join(forwards %>% select(country, ym, date,
                                y_1, f_2, f_4, f_5, f_9, f_10),
            by = c("country", "ym", "date")) %>%
  left_join(reg_data %>% select(country, ym, date, rx_t12, rx_USD_t12),
            by = c("country", "ym", "date")) %>%
  mutate(y = as.integer(format(date, "%Y"))) %>%
  left_join(gdp %>% select(y, country, gdp_val), by = c("y", "country")) %>%
  filter(!is.na(cycle_1y_oos), !is.na(c_bar_oos)) %>%
  group_by(country) %>%
  arrange(ym, .by_group = TRUE) %>%
  group_modify(~ {
    .x$CF_oos <- oos_predict(.x, rx_t12 ~ cycle_1y_oos + c_bar_oos,
                             min_train = 60, h = 12)
    # CP 2005 / DH 2013 local factor, fully recursive. Forwards (y_1,
    # f_2, f_4, f_5, f_9, f_10) are contemporaneous transforms of yields
    # and need no separate recursion -- only the predictive regression
    # respects t.
    .x$CP_oos <- oos_predict(.x, rx_t12 ~ y_1 + f_2 + f_4 + f_5 + f_9 + f_10,
                             min_train = 60, h = 12)
    .x
  }) %>%
  ungroup()

# -------------------------------------------------------------
# 4. GCF_oos (eq 7-8): GDP-weighted across OOS-eligible countries
# -------------------------------------------------------------
cat("oos.R: building GCF_oos ...\n")

gcf_oos <- reg_data_oos %>%
  filter(!is.na(CF_oos), !is.na(gdp_val)) %>%
  group_by(ym) %>%
  mutate(
    gdp_total_oos = sum(gdp_val, na.rm = TRUE),
    w_oos         = gdp_val / gdp_total_oos
  ) %>%
  group_by(ym, date) %>%
  summarise(
    GCF_oos         = sum(w_oos * CF_oos, na.rm = TRUE),
    n_countries_oos = n(),
    .groups = "drop"
  ) %>%
  arrange(ym)

# -------------------------------------------------------------
# 4b. GCP_oos: GDP-weighted aggregation of CP_oos (DH 2013 analog)
# -------------------------------------------------------------
cat("oos.R: building GCP_oos ...\n")

gcp_oos <- reg_data_oos %>%
  filter(!is.na(CP_oos), !is.na(gdp_val)) %>%
  group_by(ym) %>%
  mutate(
    gdp_total_oos = sum(gdp_val, na.rm = TRUE),
    w_oos         = gdp_val / gdp_total_oos
  ) %>%
  group_by(ym, date) %>%
  summarise(
    GCP_oos             = sum(w_oos * CP_oos, na.rm = TRUE),
    n_countries_oos_gcp = n(),
    .groups = "drop"
  ) %>%
  arrange(ym)

# -------------------------------------------------------------
# 5. FXGCF_oos: recursive DH-style top-down (eq 17 analog)
#    rx_USD_bar_t12 ~ cyc1_bar_oos + cbar_bar_oos, refit each t
# -------------------------------------------------------------
cat("oos.R: building FXGCF_oos (recursive DH top-down) ...\n")

agg_oos <- reg_data_oos %>%
  filter(!is.na(cycle_1y_oos), !is.na(c_bar_oos), !is.na(gdp_val)) %>%
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val, na.rm = TRUE),
    w_oos     = gdp_val / gdp_total
  ) %>%
  ungroup()

glob_pred_oos <- agg_oos %>%
  group_by(ym, date) %>%
  summarise(
    cyc1_bar_oos = sum(w_oos * cycle_1y_oos, na.rm = TRUE),
    cbar_bar_oos = sum(w_oos * c_bar_oos,    na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ym)

# rx_USD_bar_t12 aggregated over the same OOS-eligible set (renormalised
# weights to ensure consistency when rx_USD_t12 is NA at the sample tail).
rx_usd_bar_oos <- agg_oos %>%
  filter(!is.na(rx_USD_t12)) %>%
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val, na.rm = TRUE),
    w_oos     = gdp_val / gdp_total
  ) %>%
  group_by(ym, date) %>%
  summarise(
    rx_USD_bar_t12 = sum(w_oos * rx_USD_t12, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(ym)

fxgcf_oos_data <- glob_pred_oos %>%
  left_join(rx_usd_bar_oos, by = c("ym", "date")) %>%
  arrange(ym)

fxgcf_oos_data$FXGCF_oos <- oos_predict(
  fxgcf_oos_data,
  rx_USD_bar_t12 ~ cyc1_bar_oos + cbar_bar_oos,
  min_train = 120, h = 12
)

fxgcf_oos <- fxgcf_oos_data %>%
  select(ym, date, cyc1_bar_oos, cbar_bar_oos, FXGCF_oos)

# -------------------------------------------------------------
# 6. panel_oos: country-month panel with all OOS factors side by side
# -------------------------------------------------------------
panel_oos <- reg_data_oos %>%
  select(country, ym, date, rx_t12, rx_USD_t12,
         cycle_1y_oos, c_bar_oos, CF_oos, CP_oos, gdp_val) %>%
  left_join(gcf_oos   %>% select(ym, GCF_oos),   by = "ym") %>%
  left_join(gcp_oos   %>% select(ym, GCP_oos),   by = "ym") %>%
  left_join(fxgcf_oos %>% select(ym, FXGCF_oos), by = "ym") %>%
  arrange(country, date)

# -------------------------------------------------------------
# Sanity diagnostics (no formal tests this push)
# -------------------------------------------------------------
cat("\n=== OOS factor diagnostics ===\n")

cf_diag <- reg_data_oos %>%
  inner_join(reg_data %>% select(country, ym, CF), by = c("country", "ym")) %>%
  filter(!is.na(CF_oos), !is.na(CF)) %>%
  group_by(country) %>%
  summarise(
    n_oos          = n(),
    first_oos_date = min(date),
    cor_CF_CF_oos  = cor(CF, CF_oos),
    .groups = "drop"
  )
cat("\nCF_oos vs CF (per country):\n")
print(cf_diag)

gcf_diag_oos <- gcf_oos %>%
  inner_join(gcf %>% select(ym, GCF), by = "ym") %>%
  filter(!is.na(GCF_oos), !is.na(GCF)) %>%
  summarise(
    n_oos          = n(),
    first_oos_date = min(date),
    cor_GCF_oos    = cor(GCF, GCF_oos)
  )
cat("\nGCF_oos vs GCF:\n")
print(gcf_diag_oos)

fxgcf_diag_oos <- fxgcf_oos %>%
  inner_join(fxgcf %>% select(ym, FXGCF), by = "ym") %>%
  filter(!is.na(FXGCF_oos), !is.na(FXGCF)) %>%
  summarise(
    n_oos           = n(),
    first_oos_date  = min(date),
    cor_FXGCF_oos   = cor(FXGCF, FXGCF_oos)
  )
cat("\nFXGCF_oos vs FXGCF:\n")
print(fxgcf_diag_oos)

cp_diag <- reg_data_oos %>%
  inner_join(reg_data %>% select(country, ym, CP), by = c("country", "ym")) %>%
  filter(!is.na(CP_oos), !is.na(CP)) %>%
  group_by(country) %>%
  summarise(
    n_oos          = n(),
    first_oos_date = min(date),
    cor_CP_CP_oos  = cor(CP, CP_oos),
    .groups = "drop"
  )
cat("\nCP_oos vs CP (per country):\n")
print(cp_diag)

gcp_diag_oos <- gcp_oos %>%
  inner_join(gcp %>% select(ym, GCP), by = "ym") %>%
  filter(!is.na(GCP_oos), !is.na(GCP)) %>%
  summarise(
    n_oos          = n(),
    first_oos_date = min(date),
    cor_GCP_oos    = cor(GCP, GCP_oos)
  )
cat("\nGCP_oos vs GCP:\n")
print(gcp_diag_oos)

cat(sprintf(
  "\noos.R loaded: CF_oos %d rows | CP_oos %d rows | GCF_oos %d months | GCP_oos %d months | FXGCF_oos %d months.\n",
  sum(!is.na(panel_oos$CF_oos)),
  sum(!is.na(panel_oos$CP_oos)),
  sum(!is.na(gcf_oos$GCF_oos)),
  sum(!is.na(gcp_oos$GCP_oos)),
  sum(!is.na(fxgcf_oos$FXGCF_oos))
))

# -------------------------------------------------------------
# Campbell-Thompson out-of-sample R^2
# -------------------------------------------------------------
# R^2_oos = 1 - sum((y - yhat_factor)^2) / sum((y - yhat_bench)^2)
# where yhat_factor is the recursive forecast from `y ~ factor` and
# yhat_bench is the recursive prevailing mean (`y ~ 1`). Both go through
# `oos_predict` so they share the h-month outcome-lag training cutoff;
# the factor itself is already OOS, so this is a "doubly-OOS" R^2 (both
# the factor construction and the predictive regression respect t).
#
# Pooled across countries by summing the per-country SS_fcst / SS_bench
# components (each country contributes its own recursive-mean benchmark).
# -------------------------------------------------------------

cat("\noos.R: computing Campbell-Thompson OOS R^2 ...\n")

oos_r2_components <- function(df, formula, min_train = 60, h = 12) {
  df    <- df %>% arrange(ym)
  yvar  <- all.vars(formula)[1]
  yhat  <- oos_predict(df, formula,
                       min_train = min_train, h = h)
  bench <- oos_predict(df, stats::as.formula(paste(yvar, "~ 1")),
                       min_train = min_train, h = h)
  y     <- df[[yvar]]
  ok    <- !is.na(yhat) & !is.na(bench) & !is.na(y)
  ss_f  <- sum((y[ok] - yhat[ok])^2)
  ss_b  <- sum((y[ok] - bench[ok])^2)
  tibble(
    n_fcst   = sum(ok),
    ss_fcst  = ss_f,
    ss_bench = ss_b,
    r2_oos   = if (sum(ok) > 0 && ss_b > 0) 1 - ss_f / ss_b else NA_real_
  )
}

oos_r2_specs <- list(
  list(label = "rx ~ CF_oos",        target = "rx_t12",     predictor = "CF_oos"),
  list(label = "rx ~ CP_oos",        target = "rx_t12",     predictor = "CP_oos"),
  list(label = "rx ~ GCF_oos",       target = "rx_t12",     predictor = "GCF_oos"),
  list(label = "rx ~ GCP_oos",       target = "rx_t12",     predictor = "GCP_oos"),
  list(label = "rx_USD ~ GCF_oos",   target = "rx_USD_t12", predictor = "GCF_oos"),
  list(label = "rx_USD ~ FXGCF_oos", target = "rx_USD_t12", predictor = "FXGCF_oos")
)

r2_oos_min_train <- 60   # 5y of realized returns for the predictive regression

r2_oos_tab <- panel_oos %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    map_dfr(oos_r2_specs, function(s) {
      d <- df %>%
        filter(!is.na(.data[[s$predictor]]),
               !is.na(.data[[s$target]]))
      empty <- tibble(country = cn, spec = s$label,
                      r2_oos = NA_real_, n_fcst = 0L,
                      ss_fcst = NA_real_, ss_bench = NA_real_)
      if (nrow(d) < r2_oos_min_train + 12) return(empty)
      fml <- stats::as.formula(sprintf("%s ~ %s", s$target, s$predictor))
      r <- oos_r2_components(d, fml, min_train = r2_oos_min_train, h = 12)
      tibble(country = cn, spec = s$label,
             r2_oos = r$r2_oos, n_fcst = r$n_fcst,
             ss_fcst = r$ss_fcst, ss_bench = r$ss_bench)
    })
  })

# Pooled R^2_oos per spec: aggregate SS across countries, then 1 - ratio.
r2_oos_pooled <- r2_oos_tab %>%
  group_by(spec) %>%
  summarise(
    n_fcst_total = sum(n_fcst,  na.rm = TRUE),
    ss_fcst_tot  = sum(ss_fcst,  na.rm = TRUE),
    ss_bench_tot = sum(ss_bench, na.rm = TRUE),
    r2_oos_pooled = if (sum(ss_bench, na.rm = TRUE) > 0)
                      1 - sum(ss_fcst,  na.rm = TRUE) /
                          sum(ss_bench, na.rm = TRUE) else NA_real_,
    n_countries  = sum(!is.na(r2_oos)),
    .groups = "drop"
  ) %>%
  mutate(spec = factor(spec, levels = sapply(oos_r2_specs, `[[`, "label"))) %>%
  arrange(spec)

cat("\nCampbell-Thompson R^2_oos (per country, per spec):\n")
print(r2_oos_tab %>%
        select(country, spec, r2_oos, n_fcst) %>%
        pivot_wider(id_cols = country,
                    names_from = spec, values_from = r2_oos))

cat("\nCampbell-Thompson R^2_oos (pooled across countries):\n")
print(r2_oos_pooled %>%
        select(spec, r2_oos_pooled, n_countries, n_fcst_total))


panel_oos %>%
  filter(date >= as.Date("2023-01-01")) %>%
  group_by(country) %>%
  summarise(
    last_CF_oos = suppressWarnings(max(date[!is.na(CF_oos)])),
    last_CP_oos = suppressWarnings(max(date[!is.na(CP_oos)])),
    gap_months  = as.integer((last_CF_oos - last_CP_oos) / 30)
  ) %>%
  arrange(desc(gap_months))

# And to see which forward is the bottleneck:
reg_data_oos %>%
  filter(date >= as.Date("2023-01-01")) %>%
  group_by(country) %>%
  summarise(
    last_y_1  = suppressWarnings(max(date[!is.na(y_1) ])),
    last_f_2  = suppressWarnings(max(date[!is.na(f_2) ])),
    last_f_4  = suppressWarnings(max(date[!is.na(f_4) ])),
    last_f_5  = suppressWarnings(max(date[!is.na(f_5) ])),
    last_f_9  = suppressWarnings(max(date[!is.na(f_9) ])),
    last_f_10 = suppressWarnings(max(date[!is.na(f_10)]))
  )
