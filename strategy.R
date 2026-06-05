# strategy.R
# =============================================================================
# Economic value of the global cycle factor: a real-time bond-timing strategy.
#
# The out-of-sample evidence (Ch.7, oos.R) shows that only the GLOBAL cycle
# factor beats the recursive prevailing mean. This script asks whether that
# statistical predictability is economically exploitable, by building a
# fully out-of-sample market-timing strategy for a global government-bond
# investor and scoring it against a passive benchmark.
#
# Design (forced by the evidence):
#   * Asset    : a GDP-weighted, 10-year global government-bond portfolio,
#                LOCAL CURRENCY (a currency-hedged investor). The unhedged USD
#                signal was negative OOS, so it is reported only as a contrast.
#   * Signal   : the fully-recursive global cycle factor GCF_oos (oos.R) -- a
#                single global series, so it times AGGREGATE exposure, not the
#                cross-section.
#   * Rule     : mean-variance exposure w_t propto Ehat_t[rx]/sigmahat^2_t, with
#                the forecast Ehat_t[rx] from the recursive rx ~ GCF_oos
#                regression and sigmahat^2_t the recursive return variance; both
#                use data <= t only (doubly out-of-sample).
#
# Evaluation (Campbell-Thompson 2008 economic value):
#   * Sharpe ratio  -- scale-invariant, so robust to how exposure is sized.
#   * Certainty-equivalent (CER) gain of a mean-variance investor, reported at
#     equal average exposure so the variance penalty is comparable across
#     strategies; benchmark = the same investor using the recursive prevailing
#     mean, and a passive buy-and-hold.
#
# Exhibits -> strat_tables / strat_plots; write with save_strategy().
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(purrr); library(tibble)
  library(ggplot2); library(scales); library(grid); library(gridExtra)
})

source("oos.R")   # recursive factors: reg_data, gcf_oos, oos_predict(); slow

strat_tables <- list()
strat_plots  <- list()

theme_thesis <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(
    legend.position  = "bottom",
    panel.grid.minor = ggplot2::element_blank(),
    plot.title       = ggplot2::element_text(face = "bold"))

table_to_grob <- function(df, title = NULL, note = NULL, base_size = 9) {
  tt <- gridExtra::ttheme_minimal(
    base_size = base_size,
    core    = list(fg_params = list(hjust = 1, x = 0.95)),
    colhead = list(fg_params = list(fontface = "bold")))
  tab <- gridExtra::tableGrob(df, rows = NULL, theme = tt)
  parts <- list(tab); heights <- grid::unit(1, "null")
  if (!is.null(title)) {
    th <- grid::textGrob(title, gp = grid::gpar(fontface = "bold", fontsize = base_size + 3),
                         hjust = 0, x = 0.02)
    parts <- c(list(th), parts); heights <- grid::unit.c(grid::unit(1.8, "lines"), heights)
  }
  if (!is.null(note)) {
    nt <- grid::textGrob(note, gp = grid::gpar(fontsize = base_size - 1, col = "grey30"),
                         hjust = 0, x = 0.02)
    parts <- c(parts, list(nt)); heights <- grid::unit.c(heights, grid::unit(4, "lines"))
  }
  gridExtra::arrangeGrob(grobs = parts, ncol = 1, heights = heights)
}

# -----------------------------------------------------------------------------
# 1. The investable asset and the real-time signal.
# -----------------------------------------------------------------------------
# rx[t] : 12-month excess return on the GDP-weighted 10Y global bond portfolio
#         (local currency), in decimal. signal: recursive GCF_oos.
build_glob <- function(rxvar) {
  reg_data %>%
    dplyr::filter(!is.na(.data[[rxvar]]), !is.na(w)) %>%
    dplyr::group_by(ym, date) %>%
    dplyr::summarise(rx = sum(w * .data[[rxvar]], na.rm = TRUE) / 100, .groups = "drop") %>%
    dplyr::left_join(gcf_oos %>% dplyr::select(ym, GCF_oos), by = "ym") %>%
    dplyr::arrange(ym) %>% dplyr::filter(!is.na(GCF_oos))
}

# recursive return variance, expanding window, respecting the 12m outcome lag.
rec_var <- function(df, min_train = 60, h = 12) {
  mo <- as.integer(format(df$date, "%Y")) * 12L + as.integer(format(df$date, "%m"))
  vapply(seq_len(nrow(df)), function(t) {
    idx <- which(mo <= mo[t] - h); if (length(idx) < min_train) return(NA_real_)
    v <- stats::var(df$rx[idx], na.rm = TRUE); if (!is.finite(v) || v <= 0) NA_real_ else v
  }, numeric(1))
}

glob <- build_glob("rx_10_t12")
glob$mu_fac  <- oos_predict(glob, rx ~ GCF_oos, min_train = 60, h = 12)   # real-time factor forecast
glob$mu_mean <- oos_predict(glob, rx ~ 1,        min_train = 60, h = 12)   # recursive prevailing mean
glob$var_rt  <- rec_var(glob)

bt <- glob %>% dplyr::filter(!is.na(mu_fac), !is.na(mu_mean), !is.na(var_rt), !is.na(rx))

# Strategy asset's own out-of-sample R^2 (Campbell-Thompson).
oos_r2 <- 1 - sum((bt$rx - bt$mu_fac)^2) / sum((bt$rx - bt$mu_mean)^2)

# -----------------------------------------------------------------------------
# 2. Strategy weights and performance statistics.
# -----------------------------------------------------------------------------
# Raw mean-variance exposure (long-only); the Sharpe ratio is invariant to a
# constant rescaling, and the CER is reported after rescaling each strategy to
# average exposure 1 so the variance penalty is comparable.
mv_raw <- function(mu, v, g) pmax((1 / g) * mu / v, 0)
eq_exp <- function(w) w / mean(w)                       # rescale to avg exposure = 1
cer    <- function(r, g) mean(r) - 0.5 * g * stats::var(r)
sr     <- function(r) mean(r) / stats::sd(r)

perf_row <- function(w_raw, g, label) {
  w <- eq_exp(w_raw); r <- w * bt$rx
  tibble::tibble(Strategy = label, mean = 100 * mean(r), vol = 100 * stats::sd(r),
                 Sharpe = sr(r), cer = 100 * cer(r, g))
}

build_perf <- function(g) {
  wf <- mv_raw(bt$mu_fac,  bt$var_rt, g)
  wm <- mv_raw(bt$mu_mean, bt$var_rt, g)
  bh <- rep(1, nrow(bt))
  dplyr::bind_rows(
    perf_row(wf, g, "GCF-timed"),
    perf_row(wm, g, "Recursive-mean timing"),
    perf_row(bh, g, "Buy-and-hold"))
}

perf5  <- build_perf(5)
perf10 <- build_perf(10)

cat(sprintf("\n=== GCF bond-timing strategy (10Y global, local ccy) ===\n"))
cat(sprintf("OOS sample: %s..%s  (n=%d months)  asset OOS R2 = %.3f  corr(fcst,rx)=%.2f\n",
            format(min(bt$date), "%Y-%m"), format(max(bt$date), "%Y-%m"),
            nrow(bt), oos_r2, cor(bt$mu_fac, bt$rx)))
cat("\n-- gamma = 5 (CER at equal average exposure) --\n"); print(as.data.frame(perf5),  digits = 3)
cat("\n-- gamma = 10 --\n");                                  print(as.data.frame(perf10), digits = 3)
g5 <- function(s) perf5$cer[perf5$Strategy == s]
cat(sprintf("\nCER gain (gamma=5): GCF vs buy-and-hold = %.2f%%/yr ; GCF vs mean-timing = %.2f%%/yr\n",
            g5("GCF-timed") - g5("Buy-and-hold"), g5("GCF-timed") - g5("Recursive-mean timing")))

# Result table (gamma = 5 headline, gamma = 10 CER appended as a column).
strat_perf_disp <- perf5 %>%
  dplyr::transmute(Strategy,
                   `Mean (%)` = formatC(mean, format = "f", digits = 2),
                   `Vol (%)`  = formatC(vol,  format = "f", digits = 2),
                   `Sharpe`   = formatC(Sharpe, format = "f", digits = 2),
                   `CER, gamma=5 (%)`  = formatC(cer, format = "f", digits = 2),
                   `CER, gamma=10 (%)` = formatC(perf10$cer, format = "f", digits = 2))

strat_tables$strat_t1_performance <- table_to_grob(
  as.data.frame(strat_perf_disp),
  title = "Economic value of the global cycle factor -- timing a 10Y global bond portfolio",
  note  = paste0("Real-time strategy, ", format(min(bt$date), "%Y"), "-",
                 format(max(bt$date), "%Y"), " (n=", nrow(bt), " months, asset OOS R2 = ",
                 formatC(oos_r2, format = "f", digits = 2), ").\n",
                 "Mean-variance exposure w propto Ehat[rx]/sigmahat^2 from the recursive ",
                 "GCF_oos forecast (doubly out-of-sample). The Sharpe ratio is\n",
                 "scale-invariant; mean, volatility and CER are reported at equal ",
                 "average exposure so the variance penalty is comparable. CER is the\n",
                 "annual certainty equivalent of a mean-variance investor. Returns are ",
                 "local-currency excess returns; overlapping 12m returns."),
  base_size = 8)

# -----------------------------------------------------------------------------
# 3. Equity curve (NON-overlapping annual, December-to-December) and exposure.
# -----------------------------------------------------------------------------
ann <- bt %>%
  dplyr::mutate(mth = as.integer(format(date, "%m"))) %>%
  dplyr::filter(mth == 12) %>%
  dplyr::mutate(w_gcf = eq_exp(mv_raw(mu_fac, var_rt, 5)))
ann$r_gcf <- ann$w_gcf * ann$rx
ann$r_bh  <- ann$rx
ann_curve <- tibble::tibble(
  date = c(min(ann$date) - 365, ann$date),
  `GCF-timed`    = cumprod(c(1, 1 + ann$r_gcf)),
  `Buy-and-hold` = cumprod(c(1, 1 + ann$r_bh)))
ann_sr_gcf <- sr(ann$r_gcf); ann_sr_bh <- sr(ann$r_bh)

strat_plots$strat_f1_cumret <- ann_curve %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "wealth") %>%
  ggplot2::ggplot(ggplot2::aes(date, wealth, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = "grey60") +
  ggplot2::geom_line(linewidth = 0.7) +
  ggplot2::scale_colour_manual(values = c("GCF-timed" = "#a50f15", "Buy-and-hold" = "#08519c"),
                               name = NULL) +
  ggplot2::labs(title = "Growth of $1: GCF-timed global bond portfolio vs buy-and-hold",
                subtitle = sprintf("Non-overlapping annual rebalancing, equal average exposure. Annual Sharpe %.2f vs %.2f",
                                   ann_sr_gcf, ann_sr_bh),
                x = NULL, y = "Cumulative wealth (excess of cash)") +
  theme_thesis

# Real-time exposure vs the recursive prevailing-mean investor: shows the
# strategy de-risking when the global cycle signals a low risk premium.
strat_plots$strat_f2_exposure <- bt %>%
  dplyr::transmute(date,
                   `GCF-timed` = eq_exp(mv_raw(mu_fac,  var_rt, 5)),
                   `Mean timing` = eq_exp(mv_raw(mu_mean, var_rt, 5))) %>%
  tidyr::pivot_longer(-date, names_to = "strategy", values_to = "w") %>%
  ggplot2::ggplot(ggplot2::aes(date, w, colour = strategy)) +
  ggplot2::geom_hline(yintercept = 1, linetype = "dashed", colour = "grey60") +
  ggplot2::geom_line(linewidth = 0.5) +
  ggplot2::scale_colour_manual(values = c("GCF-timed" = "#a50f15", "Mean timing" = "#08519c"),
                               name = NULL) +
  ggplot2::labs(title = "Real-time portfolio exposure (average = 1)",
                subtitle = "The GCF investor cuts bond exposure when the global cycle signals a low risk premium",
                x = NULL, y = "Exposure weight") +
  theme_thesis

# -----------------------------------------------------------------------------
# 4. Unhedged USD contrast (for the chapter's caveat): the same rule on USD
#    returns, where the OOS signal was negative.
# -----------------------------------------------------------------------------
glob_usd <- build_glob("rx_10_USD_t12")
glob_usd$mu_fac  <- oos_predict(glob_usd, rx ~ GCF_oos, min_train = 60, h = 12)
glob_usd$mu_mean <- oos_predict(glob_usd, rx ~ 1,        min_train = 60, h = 12)
glob_usd$var_rt  <- rec_var(glob_usd)
btu <- glob_usd %>% dplyr::filter(!is.na(mu_fac), !is.na(mu_mean), !is.na(var_rt), !is.na(rx))
usd_oos_r2 <- 1 - sum((btu$rx - btu$mu_fac)^2) / sum((btu$rx - btu$mu_mean)^2)
usd_sr <- sr(eq_exp(mv_raw(btu$mu_fac, btu$var_rt, 5)) * btu$rx)
cat(sprintf("\nUnhedged USD contrast: asset OOS R2 = %.3f ; GCF-timed Sharpe = %.2f (buy-and-hold %.2f)\n",
            usd_oos_r2, usd_sr, sr(btu$rx)))

# -----------------------------------------------------------------------------
# Write exhibits.
# -----------------------------------------------------------------------------
save_strategy <- function(tab_dir = "thesis/tables", fig_dir = "thesis/figures") {
  dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(file.path(tab_dir, "strat_t1_performance.pdf"),
                  strat_tables$strat_t1_performance, width = 10, height = 3.4)
  purrr::iwalk(strat_plots, function(p, nm)
    ggplot2::ggsave(file.path(fig_dir, paste0(nm, ".pdf")), p, width = 9, height = 5))
  invisible(TRUE)
}

cat(sprintf("\nstrategy.R loaded: %d table, %d figures. Write with save_strategy().\n",
            length(strat_tables), length(strat_plots)))
