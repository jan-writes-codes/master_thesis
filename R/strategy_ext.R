# strategy_ext.R
# =============================================================================
# Extended performance analytics for the Portfolio Construction chapter:
#   1. Subperiod performance (halves of the OOS window + the 2022 episode).
#   2. Turnover and net-of-transaction-cost performance.
#   3. Maximum drawdown on the non-overlapping annual wealth curves.
#   4. Rolling five-year Sharpe ratios (overlapping 12m returns, descriptive).
#
# Sources strategy.R (which builds bt/btu and the baseline exhibits) and adds
# strat_t4_subperiod / strat_t5_costs tables and the strat_f3_drawdown /
# strat_f4_rolling_sharpe figures. Run from the project root.
# =============================================================================

source("R/strategy.R")

# -----------------------------------------------------------------------------
# 0. Common objects: equal-average-exposure weights of the three strategies.
# -----------------------------------------------------------------------------
g <- 5
bt$w_gcf  <- eq_exp(mv_raw(bt$mu_fac,  bt$var_rt, g))
bt$w_mean <- eq_exp(mv_raw(bt$mu_mean, bt$var_rt, g))
bt$r_gcf  <- bt$w_gcf  * bt$rx
bt$r_mean <- bt$w_mean * bt$rx
bt$r_bh   <- bt$rx

# -----------------------------------------------------------------------------
# 1. Subperiod performance.
# -----------------------------------------------------------------------------
sub_row <- function(r, label, window) {
  tibble::tibble(Window = window, Strategy = label,
                 mean = 100 * mean(r), vol = 100 * stats::sd(r), Sharpe = sr(r))
}
sub_stats <- function(idx, window) {
  dplyr::bind_rows(
    sub_row(bt$r_gcf[idx],  "GCF-timed",             window),
    sub_row(bt$r_mean[idx], "Recursive-mean timing", window),
    sub_row(bt$r_bh[idx],   "Buy-and-hold",          window))
}
yr <- as.integer(format(bt$date, "%Y"))
subperiods <- dplyr::bind_rows(
  sub_stats(yr <= 2014, "2005--2014"),
  sub_stats(yr >= 2015, "2015--2024"),
  sub_stats(yr %in% c(2021, 2022), "2021--2022 (hiking cycle)"))

cat("\n=== Subperiod performance (equal average exposure, gamma = 5) ===\n")
print(as.data.frame(subperiods), digits = 3)

# -----------------------------------------------------------------------------
# 2. Turnover and transaction costs.
# -----------------------------------------------------------------------------
# Monthly one-way turnover |w_t - w_{t-1}|; returns are 12-month, observed
# monthly, so the annualised cost drag subtracted from each return is
# c * 12 * |dw_t| (one-way proportional cost c on the notional traded).
turnover <- function(w) c(NA, abs(diff(w)))
bt$to_gcf  <- turnover(bt$w_gcf)
bt$to_mean <- turnover(bt$w_mean)

cost_row <- function(r_gross, to, label, cbps) {
  keep <- !is.na(to)
  r_net <- r_gross[keep] - (cbps / 1e4) * 12 * to[keep]
  tibble::tibble(Strategy = label, `Cost (bp)` = cbps,
                 mean = 100 * mean(r_net), Sharpe = sr(r_net),
                 cer = 100 * cer(r_net, g))
}
costs <- dplyr::bind_rows(lapply(c(0, 10, 25, 50), function(cb) dplyr::bind_rows(
  cost_row(bt$r_gcf,  bt$to_gcf,  "GCF-timed",             cb),
  cost_row(bt$r_mean, bt$to_mean, "Recursive-mean timing", cb))))

cat("\n=== Turnover ===\n")
cat(sprintf("GCF-timed : mean monthly one-way turnover = %.3f (annualised %.2f)\n",
            mean(bt$to_gcf,  na.rm = TRUE), 12 * mean(bt$to_gcf,  na.rm = TRUE)))
cat(sprintf("Mean-timed: mean monthly one-way turnover = %.3f (annualised %.2f)\n",
            mean(bt$to_mean, na.rm = TRUE), 12 * mean(bt$to_mean, na.rm = TRUE)))
cat("\n=== Net-of-cost performance (one-way proportional costs) ===\n")
print(as.data.frame(costs), digits = 3)

# Buy-and-hold reference Sharpe on the same rows (first row dropped by lag).
keep <- !is.na(bt$to_gcf)
cat(sprintf("\nBuy-and-hold on same rows: mean %.2f%%  Sharpe %.2f  CER %.2f%%\n",
            100 * mean(bt$r_bh[keep]), sr(bt$r_bh[keep]), 100 * cer(bt$r_bh[keep], g)))

# -----------------------------------------------------------------------------
# 3. Maximum drawdown on the monthly (1-month-holding) wealth curves
# (review remark R-133/R-139; the `mon` backtest is built in strategy.R).
# -----------------------------------------------------------------------------
max_dd <- function(r) { w <- cumprod(1 + r); 100 * min(w / cummax(w) - 1) }
cat("\n=== Maximum drawdown, monthly 1-month-holding wealth curves ===\n")
cat(sprintf("GCF-timed    : %.1f%%\n", max_dd(mon$r_gcf)))
cat(sprintf("Mean timing  : %.1f%%\n", max_dd(mon$r_mean)))
cat(sprintf("Buy-and-hold : %.1f%%\n", max_dd(mon$r_bh)))

# Underwater (drawdown) figure on the monthly curves.
dd_path <- function(r) { w <- cumprod(1 + r); 100 * (w / cummax(w) - 1) }
dd_df <- tibble::tibble(
  date = mon$date,
  `GCF-timed`    = dd_path(mon$r_gcf),
  `Buy-and-hold` = dd_path(mon$r_bh)) %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "dd")
strat_plots$strat_f3_drawdown <- ggplot2::ggplot(dd_df,
    ggplot2::aes(date, dd, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 0, colour = "grey60", linewidth = 0.3) +
  ggplot2::geom_step(linewidth = 0.7) +
  ggplot2::scale_colour_manual(values = c("GCF-timed" = col_pri,
                                          "Buy-and-hold" = col_sec), name = NULL) +
  ggplot2::labs(title = "Drawdown from peak: GCF-timed vs buy-and-hold",
                subtitle = "Monthly 1-month-holding wealth curves, equal average exposure",
                x = NULL, y = "Drawdown (%)") +
  theme_thesis

# -----------------------------------------------------------------------------
# 4. Rolling five-year Sharpe ratio (overlapping 12m returns, descriptive).
# -----------------------------------------------------------------------------
roll_sr <- function(r, width = 60) {
  n <- length(r)
  out <- rep(NA_real_, n)
  for (t in width:n) out[t] <- sr(r[(t - width + 1):t])
  out
}
rs_df <- tibble::tibble(
  date = bt$date,
  `GCF-timed`    = roll_sr(bt$r_gcf),
  `Buy-and-hold` = roll_sr(bt$r_bh)) %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "srr") %>%
  dplyr::filter(!is.na(srr))
strat_plots$strat_f4_rolling_sharpe <- ggplot2::ggplot(rs_df,
    ggplot2::aes(date, srr, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
  ggplot2::geom_line(linewidth = 0.7) +
  ggplot2::scale_colour_manual(values = c("GCF-timed" = col_pri,
                                          "Buy-and-hold" = col_sec), name = NULL) +
  ggplot2::labs(title = "Rolling five-year Sharpe ratio",
                subtitle = "Overlapping 12-month returns; descriptive, not a test",
                x = NULL, y = "Sharpe ratio (5y window)") +
  theme_thesis
rs_wide <- tidyr::pivot_wider(rs_df, names_from = strategy, values_from = srr)
cat(sprintf("\nRolling 5y Sharpe: GCF-timed above buy-and-hold in %.0f%% of windows\n",
            100 * mean(rs_wide$`GCF-timed` > rs_wide$`Buy-and-hold`, na.rm = TRUE)))

# -----------------------------------------------------------------------------
# Write the new figures.
# -----------------------------------------------------------------------------
save_strategy_ext <- function(fig_dir = "thesis/figures") {
  ggplot2::ggsave(file.path(fig_dir, "strat_f3_drawdown.pdf"),
                  strat_plots$strat_f3_drawdown, width = 9, height = 5)
  ggplot2::ggsave(file.path(fig_dir, "strat_f4_rolling_sharpe.pdf"),
                  strat_plots$strat_f4_rolling_sharpe, width = 9, height = 5)
  invisible(TRUE)
}
