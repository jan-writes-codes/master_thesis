# strategy.R
# =============================================================
# Backtest of Strategy 1: Global "risk-on/off" timing on a USD-
# investor basket of G10 government bonds, signal = FXGCF_oos.
#
# Two strategy variants:
#   Long-short (w in {-1, +1})
#   Long-only  (w in { 0, +1})  -- caps downside, no short exposure
#
# Benchmark: passive long position in the same GDP-weighted G10
# basket (constant w = +1, no timing). Strategy and benchmark see
# the exact same return process and time window, so the difference
# isolates the value added by the FXGCF_oos signal.
#
# Returns process: monthly USD-investor excess return on the basket,
# constructed from the underlying yields and FX panel via the
# duration approximation (1m horizon, ignores convexity):
#   r^{(n),local}_{i,t}   = y_{i,t}^{(n)}/12 - D_{i,t}^{(n)} *
#                           (y_{i,t+1}^{(n)} - y_{i,t}^{(n)})
#   r^{(n),USD}_{i,t}     = r^{(n),local}_{i,t}
#                           + (s_{i,t+1} - s_{i,t}) - y_{US,t}^{(1)}/12
#   r^{basket}_{t}        = sum_i w_{i,t} * mean_n r^{(n),USD}_{i,t}
# with w_{i,t} the GDP weights from data preperation.R.
#
# Signal is lagged one period -- position taken at the start of
# month t uses FXGCF_oos observed at the end of month t-1.
#
# Equity curve: monthly compounding from initial wealth = 1.
# Performance metrics: annualised mean / vol / Sharpe (Newey-West
# HAC SE on the mean), hit rate, max drawdown, alpha / beta /
# information ratio vs the benchmark.
# =============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(sandwich)
  library(lmtest)
})

# Source the pipeline once. Skip if all required objects are already loaded.
needed <- c("yields_wide", "fx_long", "curve_map", "cf_gdp", "fxgcf_oos")
if (!all(vapply(needed, exists, logical(1)))) {
  source("data preperation.R")
  source("empirical.R")
}

OUT_DIR <- "presentation"
FIG_DIR <- file.path(OUT_DIR, "figures")
TAB_DIR <- file.path(OUT_DIR, "tables")
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)

# -------------------------------------------------------------
# 1. Per-country, 1-month USD-investor excess return.
#    Average over maturities {2, 5, 10}; aggregate by GDP weights.
# -------------------------------------------------------------
r1m_country <- yields_wide %>%
  select(country, ym, date, y_2, y_5, y_10) %>%
  arrange(country, ym) %>%
  group_by(country) %>%
  mutate(
    dy_2  = lead(y_2)  - y_2,
    dy_5  = lead(y_5)  - y_5,
    dy_10 = lead(y_10) - y_10,
    D_2   = 2  / (1 + y_2  / 100),
    D_5   = 5  / (1 + y_5  / 100),
    D_10  = 10 / (1 + y_10 / 100),
    r_2_local  = y_2  / 12 - D_2  * dy_2,
    r_5_local  = y_5  / 12 - D_5  * dy_5,
    r_10_local = y_10 / 12 - D_10 * dy_10,
    r_local    = (r_2_local + r_5_local + r_10_local) / 3
  ) %>%
  ungroup()

fx_1m <- fx_long %>%
  arrange(currency, ym) %>%
  group_by(currency) %>%
  mutate(s = log(fx_USD),
         fx_ret_1m = (s - lag(s)) * 100) %>%   # in %
  ungroup() %>%
  select(ym, currency, fx_ret_1m)

y1_US_short <- yields_wide %>%
  filter(country == "US") %>%
  transmute(ym, y1_US = y_1)

r1m_usd <- r1m_country %>%
  left_join(curve_map %>% select(country, currency), by = "country") %>%
  left_join(fx_1m,                                   by = c("ym", "currency")) %>%
  left_join(y1_US_short,                             by = "ym") %>%
  mutate(r_usd_1m = r_local + coalesce(fx_ret_1m, 0) - y1_US / 12)

basket_1m <- r1m_usd %>%
  left_join(cf_gdp %>% select(country, ym, w), by = c("country", "ym")) %>%
  filter(!is.na(r_usd_1m), !is.na(w)) %>%
  group_by(ym, date) %>%
  summarise(
    r_basket_1m = sum(w * r_usd_1m, na.rm = TRUE) /
                  sum(w[!is.na(r_usd_1m)], na.rm = TRUE),
    n_countries = sum(!is.na(r_usd_1m) & !is.na(w)),
    .groups     = "drop"
  ) %>%
  arrange(date)

# -------------------------------------------------------------
# 2. Strategy panel: lag the signal one period
# -------------------------------------------------------------
strategy_panel <- basket_1m %>%
  left_join(fxgcf_oos %>% select(ym, FXGCF_oos), by = "ym") %>%
  arrange(date) %>%
  mutate(
    signal_lag = lag(FXGCF_oos, 1),
    w_LS = sign(signal_lag),
    w_LO = pmax(sign(signal_lag), 0),
    r_strat_LS = w_LS * r_basket_1m,
    r_strat_LO = w_LO * r_basket_1m,
    r_bench    = r_basket_1m
  ) %>%
  filter(!is.na(r_strat_LS), !is.na(r_bench))

if (nrow(strategy_panel) == 0L) {
  stop("strategy_panel is empty -- check that fxgcf_oos and basket_1m overlap.")
}

# -------------------------------------------------------------
# 3. Equity curves
# -------------------------------------------------------------
equity <- strategy_panel %>%
  mutate(
    eq_LS    = cumprod(1 + r_strat_LS / 100),
    eq_LO    = cumprod(1 + r_strat_LO / 100),
    eq_bench = cumprod(1 + r_bench    / 100)
  )

# -------------------------------------------------------------
# 4. Performance metrics
# -------------------------------------------------------------
nw_lag_for_local <- function(T_obs) max(ceiling(1.3 * sqrt(T_obs)), 6)

max_drawdown <- function(eq) {
  peak <- cummax(eq)
  min(eq / peak - 1)
}

perf <- function(R, name, bench = NULL) {
  R <- na.omit(R)
  n <- length(R)
  L <- nw_lag_for_local(n)
  m_mean <- lm(R ~ 1)
  vc     <- NeweyWest(m_mean, lag = L, prewhite = FALSE, adjust = TRUE)
  mu_m   <- coef(m_mean)[[1]]
  se_m   <- sqrt(diag(vc))[[1]]
  sd_m   <- sd(R)
  out <- tibble(
    strategy   = name,
    n_months   = n,
    mean_ann   = mu_m * 12,
    vol_ann    = sd_m * sqrt(12),
    sharpe     = mu_m * sqrt(12) / sd_m,
    t_mean_HAC = mu_m / se_m,
    hit_rate   = mean(R > 0)
  )
  if (!is.null(bench)) {
    bench <- bench[seq_along(R)]
    fit  <- lm(R ~ bench)
    vc2  <- NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE)
    ct   <- coeftest(fit, vcov. = vc2)
    te   <- sd(residuals(fit))
    out$alpha_ann   <- ct["(Intercept)", "Estimate"] * 12
    out$alpha_t_HAC <- ct["(Intercept)", "t value"]
    out$beta        <- ct["bench", "Estimate"]
    out$ir          <- if (te > 0)
      (ct["(Intercept)", "Estimate"] * sqrt(12)) / te else NA_real_
  }
  out
}

m_LS <- perf(strategy_panel$r_strat_LS, "Long-short (FXGCF$_{oos}$)",
             bench = strategy_panel$r_bench)
m_LO <- perf(strategy_panel$r_strat_LO, "Long-only (FXGCF$_{oos}$)",
             bench = strategy_panel$r_bench)
m_BH <- perf(strategy_panel$r_bench,    "Benchmark (passive long)",
             bench = strategy_panel$r_bench)

m_LS$max_dd <- max_drawdown(equity$eq_LS)
m_LO$max_dd <- max_drawdown(equity$eq_LO)
m_BH$max_dd <- max_drawdown(equity$eq_bench)

metrics <- bind_rows(m_LS, m_LO, m_BH) %>%
  select(strategy, n_months, mean_ann, vol_ann, sharpe, t_mean_HAC,
         hit_rate, max_dd, alpha_ann, alpha_t_HAC, beta, ir)

cat("\n====== Strategy 1 backtest: performance metrics ======\n")
print(metrics)

# -------------------------------------------------------------
# 5. Equity-curve plot (log scale to compare growth fairly)
# -------------------------------------------------------------
eq_long <- equity %>%
  select(date,
         `Long-short` = eq_LS,
         `Long-only`  = eq_LO,
         `Benchmark`  = eq_bench) %>%
  pivot_longer(-date, names_to = "Strategy", values_to = "Wealth") %>%
  mutate(Strategy = factor(Strategy,
                           levels = c("Long-short", "Long-only", "Benchmark")))

p_equity <- ggplot(eq_long, aes(date, Wealth, colour = Strategy)) +
  geom_line(linewidth = 0.6) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  scale_y_log10() +
  scale_colour_manual(values = c("Long-short" = "#08519c",
                                 "Long-only"  = "#4dac26",
                                 "Benchmark"  = "#d94801")) +
  labs(
    title    = "Strategy 1: FXGCF_oos timing on the USD G10 bond basket",
    subtitle = "Equity curves, monthly compounding (log scale). Initial wealth = 1.",
    x = NULL, y = "Wealth"
  ) +
  theme_bw() +
  theme(legend.position  = "bottom",
        plot.title       = element_text(face = "bold"),
        panel.grid.minor = element_blank())

ggsave(file.path(FIG_DIR, "strategy_equity.pdf"),
       p_equity, width = 9, height = 6)

# -------------------------------------------------------------
# 6. LaTeX table for the slide
# -------------------------------------------------------------
fmt_num <- function(x, d = 3)
  ifelse(is.na(x), "--", formatC(x, format = "f", digits = d))
fmt_pct <- function(x, d = 1)
  ifelse(is.na(x), "--",
         paste0(formatC(100 * x, format = "f", digits = d), "\\%"))

metrics_rows <- metrics %>%
  transmute(
    Strategy             = strategy,
    `$N_{m}$`            = n_months,
    `Mean (\\%/yr)`      = fmt_num(mean_ann, 2),
    `Vol (\\%/yr)`       = fmt_num(vol_ann, 2),
    `Sharpe`             = fmt_num(sharpe, 2),
    `$t$ (HAC)`          = fmt_num(t_mean_HAC, 2),
    `Hit \\%`            = fmt_pct(hit_rate),
    `Max DD`             = fmt_pct(max_dd),
    `$\\alpha$ (\\%/yr)` = fmt_num(alpha_ann, 2),
    `$\\alpha\\,t$`      = fmt_num(alpha_t_HAC, 2),
    `$\\beta$`           = fmt_num(beta, 2),
    `IR`                 = fmt_num(ir, 2)
  )

write_strategy_table <- function(rows, header, align, file) {
  body <- vapply(seq_len(nrow(rows)),
                 function(i) paste0(paste(rows[i, ], collapse = " & "), " \\\\"),
                 character(1))
  lines <- c(
    "% auto-generated by strategy.R; do not edit",
    sprintf("\\begin{tabular}{%s}", align),
    "\\toprule",
    paste0(paste(header, collapse = " & "), " \\\\"),
    "\\midrule",
    body,
    "\\bottomrule",
    "\\end{tabular}"
  )
  writeLines(lines, file.path(TAB_DIR, file))
}

write_strategy_table(
  rows   = as.matrix(metrics_rows),
  header = colnames(metrics_rows),
  align  = "lrrrrrrrrrrr",
  file   = "strategy_metrics.tex"
)

cat(sprintf(
  "\nSaved equity curve to %s\nSaved metrics table to %s\n",
  file.path(FIG_DIR, "strategy_equity.pdf"),
  file.path(TAB_DIR, "strategy_metrics.tex")
))
