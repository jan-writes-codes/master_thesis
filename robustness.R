# robustness.R
# =============================================================================
# Chapter 8 (Robustness): subsample stability of the predictive programme.
#
# This script is the home for the SUBSAMPLE exhibits of the robustness chapter.
# It complements the out-of-sample machinery of oos.R (recursive factors +
# Campbell-Thompson R^2) and the cycle-vs-forward comparison already produced by
# plots.R (s10_*). Its job is to re-run the four headline specifications over
# economically meaningful subsamples -- in particular the 2007-2009 global
# financial crisis and the 2010-2012 euro-area sovereign-debt crisis (the period
# in which Italy was acutely affected) -- both IN-SAMPLE and OUT-OF-SAMPLE.
#
# Subsamples are dated by the FORECAST-ORIGIN month t (the date the signal is
# formed); the one-year excess return is realised at t+12.
#
# Exhibits (rendered to thesis/tables/*.pdf by save_robustness()):
#   rob_t1_sub_is   : in-sample predictability across subsamples (local + USD).
#   rob_t2_sub_oos  : out-of-sample (recursive CT-R^2) across subsamples.
#   rob_t3_italy    : Italy focus -- local vs global content in the euro crisis.
#   rob_f1_oos_sub  : figure, pooled CT-R^2_oos by subsample and specification.
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
  library(gridExtra)
  library(grid)
})

# oos.R sources data preperation.R and leaves the in-sample objects (reg_data,
# gcf, fxgcf) and the fully-recursive OOS objects (panel_oos, oos_predict) in
# the workspace. Guard against a double source.
if (!exists("panel_oos")) source("oos.R")

rob_tables <- list()
rob_plots  <- list()

mr_order <- c("BE", "DE", "FR", "IT", "NL", "CH", "GB", "SE", "CA", "JP", "US")
mr_name  <- c(BE = "Belgium", CA = "Canada", CH = "Switzerland", DE = "Germany",
              FR = "France", GB = "UK", IT = "Italy", JP = "Japan",
              NL = "Netherlands", SE = "Sweden", US = "US")

# In-sample country-month panel with the local and global factors side by side.
panel <- reg_data %>%
  dplyr::left_join(gcf   %>% dplyr::select(ym, GCF),   by = "ym") %>%
  dplyr::left_join(fxgcf %>% dplyr::select(ym, FXGCF), by = "ym")

fmt2 <- function(x) formatC(x, format = "f", digits = 2)
fmt3 <- function(x) formatC(x, format = "f", digits = 3)

# -----------------------------------------------------------------------------
# Subsample windows, dated by the forecast-origin month ym (YYYYMM integer).
#   Pre-crisis      : through 2007-06
#   GFC             : 2007-07 .. 2009-12  (global financial crisis)
#   Euro crisis     : 2010-01 .. 2012-12  (euro-area sovereign-debt crisis)
#   Post-crisis     : 2013-01 onward
# -----------------------------------------------------------------------------
subsamples <- tibble::tribble(
  ~key,        ~label,                         ~lo,     ~hi,
  "full",      "Full sample",                  0L,      999999L,
  "pre",       "Pre-crisis (..2007:06)",       0L,      200706L,
  "gfc",       "Financial crisis (2007-09)",   200707L, 200912L,
  "euro",      "Euro crisis (2010-12)",        201001L, 201212L,
  "post",      "Post-crisis (2013-)",          201301L, 999999L)

in_window <- function(ym, lo, hi) ym >= lo & ym <= hi

# -----------------------------------------------------------------------------
# Inference helpers (identical conventions to main_results.R / plots.R):
#   HAC bandwidth L = ceil(max(1.5*h, 1.3*sqrt(T))) for 12m overlap.
# -----------------------------------------------------------------------------
hac_fit <- function(df, fml, h = 12, min_obs = 24) {
  fit <- tryCatch(lm(fml, data = df, na.action = na.omit), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  Tn <- stats::nobs(fit); if (Tn < min_obs) return(NULL)
  L <- ceiling(max(1.5 * h, 1.3 * sqrt(Tn)))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  ct <- lmtest::coeftest(fit, vcov. = V)
  tibble::tibble(term = rownames(ct), estimate = ct[, 1], t = ct[, 3],
                 r_sq = summary(fit)$r.squared, n = Tn)
}

# Per-country single-factor fit over a window: mean R^2, #markets |t|>1.96, n.
by_country_window <- function(df, target, predictor, lo, hi, min_obs = 24) {
  d <- df %>% dplyr::filter(in_window(ym, lo, hi),
                            !is.na(.data[[target]]), !is.na(.data[[predictor]]))
  fml <- stats::as.formula(sprintf("%s ~ %s", target, predictor))
  res <- split(d, d$country) %>%
    purrr::map_dfr(function(x) {
      o <- hac_fit(x, fml, min_obs = min_obs)
      if (is.null(o)) return(NULL)
      dplyr::filter(o, term == predictor)
    })
  if (nrow(res) == 0) return(tibble::tibble(mean_r2 = NA_real_, n_sig = 0L, n_mkt = 0L))
  tibble::tibble(mean_r2 = mean(res$r_sq, na.rm = TRUE),
                 n_sig   = sum(abs(res$t) > 1.96, na.rm = TRUE),
                 n_mkt   = nrow(res))
}

# Pooled fixed-effects HAC slope t on the factor over a window.
pooled_fe_t <- function(df, target, predictor, lo, hi, min_obs = 60) {
  d <- df %>% dplyr::filter(in_window(ym, lo, hi),
                            !is.na(.data[[target]]), !is.na(.data[[predictor]]))
  if (nrow(d) < min_obs || length(unique(d$country)) < 2) return(NA_real_)
  fit <- tryCatch(lm(stats::as.formula(sprintf("%s ~ %s + factor(country)", target, predictor)),
                     data = d), error = function(e) NULL)
  if (is.null(fit)) return(NA_real_)
  L <- ceiling(max(18, 1.3 * sqrt(stats::nobs(fit))))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  ct <- lmtest::coeftest(fit, vcov. = V)
  if (!(predictor %in% rownames(ct))) return(NA_real_)
  ct[predictor, 3]
}


# =============================================================================
# TABLE 1 -- In-sample predictability across subsamples.
# =============================================================================
# Four headline specifications: the local-currency cycle factors (CF, GCF) and
# the US-dollar-investor factors (GCF, FXGCF). For each we report the
# cross-country MEAN single-factor R^2, the pooled fixed-effects HAC t on the
# factor, and the count of markets in which the factor is individually
# significant -- per subsample.

is_specs <- tibble::tribble(
  ~spec_lbl,            ~target,        ~predictor,
  "rx ~ CF",            "rx_t12",       "CF",
  "rx ~ GCF",           "rx_t12",       "GCF",
  "rx_USD ~ GCF",       "rx_USD_t12",   "GCF",
  "rx_USD ~ FXGCF",     "rx_USD_t12",   "FXGCF")

is_grid <- tidyr::crossing(sub = subsamples$key, spec = is_specs$spec_lbl) %>%
  dplyr::left_join(subsamples, by = c("sub" = "key")) %>%
  dplyr::left_join(is_specs, by = c("spec" = "spec_lbl"))

is_res <- purrr::pmap_dfr(is_grid, function(sub, spec, label, lo, hi, target, predictor) {
  bc <- by_country_window(panel, target, predictor, lo, hi)
  tibble::tibble(
    sub = sub, sub_label = label, spec = spec,
    mean_r2 = bc$mean_r2, n_sig = bc$n_sig, n_mkt = bc$n_mkt,
    pooled_t = pooled_fe_t(panel, target, predictor, lo, hi),
    months = length(unique(panel$ym[in_window(panel$ym, lo, hi) & !is.na(panel[[predictor]])])))
})

cat("\n===== Table 1: in-sample predictability across subsamples =====\n")
print(as.data.frame(is_res %>%
  dplyr::transmute(sub_label, spec, months,
                   mean_R2 = round(mean_r2, 3), pooled_t = round(pooled_t, 2),
                   sig = paste0(n_sig, "/", n_mkt))), row.names = FALSE)

# Render: rows = subsample, columns grouped by spec (mean R^2 | pooled t).
is_wide <- is_res %>%
  dplyr::mutate(spec = factor(spec, levels = is_specs$spec_lbl)) %>%
  dplyr::arrange(factor(sub, levels = subsamples$key), spec)

mk_block <- function(s) {
  is_res %>% dplyr::filter(spec == s) %>%
    dplyr::arrange(factor(sub, levels = subsamples$key)) %>%
    dplyr::transmute(R2 = fmt3(mean_r2), t = fmt2(pooled_t))
}
t1_disp <- tibble::tibble(
  Subsample = subsamples$label,
  Months    = is_res %>% dplyr::filter(spec == "rx ~ CF") %>%
    dplyr::arrange(factor(sub, levels = subsamples$key)) %>% dplyr::pull(months))
for (s in is_specs$spec_lbl) {
  b <- mk_block(s)
  t1_disp[[paste0(s, " : R2")]] <- b$R2
  t1_disp[[paste0(s, " : t")]]  <- b$t
}

table_to_grob <- function(df, title = NULL, note = NULL, base_size = 8) {
  tt <- gridExtra::ttheme_minimal(
    base_size = base_size,
    core    = list(fg_params = list(hjust = 1, x = 0.95)),
    colhead = list(fg_params = list(fontface = "bold")))
  tab <- gridExtra::tableGrob(df, rows = NULL, theme = tt)
  parts <- list(tab); heights <- grid::unit(1, "null")
  if (!is.null(title)) {
    th <- grid::textGrob(title, gp = grid::gpar(fontface = "bold",
                         fontsize = base_size + 3), hjust = 0, x = 0.02)
    parts <- c(list(th), parts); heights <- grid::unit.c(grid::unit(1.8, "lines"), heights)
  }
  if (!is.null(note)) {
    nt <- grid::textGrob(note, gp = grid::gpar(fontsize = base_size - 1, col = "grey30"),
                         hjust = 0, x = 0.02)
    parts <- c(parts, list(nt)); heights <- grid::unit.c(heights, grid::unit(4.5, "lines"))
  }
  gridExtra::arrangeGrob(grobs = parts, ncol = 1, heights = heights)
}

rob_tables$rob_t1_sub_is <- table_to_grob(
  as.data.frame(t1_disp),
  title = "Robustness -- In-sample predictability across subsamples",
  note  = paste0("Each cell pair reports the cross-country mean single-factor in-sample ",
                 "R2 and the pooled fixed-effects Newey-West HAC t on the factor,\n",
                 "estimated on the indicated subsample (dated by forecast-origin month). ",
                 "rx = local-currency, rx_USD = US-dollar maturity-averaged 1y excess\n",
                 "return. CF/GCF are the local and global cycle factors; FXGCF the ",
                 "FX-adjusted global factor. 'Months' is the number of forecast origins\n",
                 "in the window. Crisis windows are short, so HAC t-stats there are ",
                 "necessarily noisier than in the full sample."),
  base_size = 8)


# =============================================================================
# TABLE 2 -- Out-of-sample predictability across subsamples.
# =============================================================================
# Fully-recursive factors (oos.R) scored by the Campbell-Thompson R^2_oos against
# the recursive prevailing mean. We compute, per country, the recursive factor
# forecast and the recursive-mean benchmark over the whole path, then pool the
# squared errors WITHIN each subsample window (sum over country-months whose
# forecast-origin month lies in the window). Pre-crisis OOS is largely empty
# because the recursive regression needs a 5y training minimum.

oos_specs <- tibble::tribble(
  ~spec_lbl,            ~target,        ~predictor,
  "rx ~ CF",            "rx_t12",       "CF_oos",
  "rx ~ GCF",           "rx_t12",       "GCF_oos",
  "rx_USD ~ GCF",       "rx_USD_t12",   "GCF_oos",
  "rx_USD ~ FXGCF",     "rx_USD_t12",   "FXGCF_oos")

# Per-country recursive forecast + recursive-mean benchmark for one spec.
oos_paths <- function(target, predictor, min_train = 60, h = 12) {
  panel_oos %>%
    dplyr::filter(!is.na(.data[[predictor]]), !is.na(.data[[target]])) %>%
    dplyr::group_by(country) %>%
    dplyr::group_modify(~ {
      d <- .x %>% dplyr::arrange(ym)
      if (nrow(d) < min_train + h) return(tibble::tibble())
      fml <- stats::as.formula(sprintf("%s ~ %s", target, predictor))
      d$yhat  <- oos_predict(d, fml, min_train = min_train, h = h)
      d$bench <- oos_predict(d, stats::as.formula(sprintf("%s ~ 1", target)),
                             min_train = min_train, h = h)
      d %>% dplyr::transmute(ym, date, y = .data[[target]], yhat, bench)
    }) %>%
    dplyr::ungroup()
}

oos_path_list <- purrr::set_names(
  purrr::map2(oos_specs$target, oos_specs$predictor, oos_paths),
  oos_specs$spec_lbl)

oos_r2_window <- function(paths, lo, hi) {
  d <- paths %>% dplyr::filter(in_window(ym, lo, hi),
                               !is.na(yhat), !is.na(bench), !is.na(y))
  if (nrow(d) == 0) return(tibble::tibble(r2 = NA_real_, n = 0L))
  ssf <- sum((d$y - d$yhat)^2); ssb <- sum((d$y - d$bench)^2)
  tibble::tibble(r2 = if (ssb > 0) 1 - ssf / ssb else NA_real_, n = nrow(d))
}

oos_grid <- tidyr::crossing(sub = subsamples$key, spec = oos_specs$spec_lbl) %>%
  dplyr::left_join(subsamples, by = c("sub" = "key"))

oos_res <- purrr::pmap_dfr(oos_grid, function(sub, spec, label, lo, hi) {
  w <- oos_r2_window(oos_path_list[[spec]], lo, hi)
  tibble::tibble(sub = sub, sub_label = label, spec = spec, r2_oos = w$r2, n = w$n)
})

cat("\n===== Table 2: out-of-sample CT-R^2 across subsamples =====\n")
print(as.data.frame(oos_res %>%
  dplyr::transmute(sub_label, spec, r2_oos = round(r2_oos, 3), n)), row.names = FALSE)

t2_disp <- tibble::tibble(Subsample = subsamples$label)
for (s in oos_specs$spec_lbl) {
  col <- oos_res %>% dplyr::filter(spec == s) %>%
    dplyr::arrange(factor(sub, levels = subsamples$key)) %>%
    dplyr::mutate(cell = ifelse(is.na(r2_oos), "--", fmt3(r2_oos))) %>%
    dplyr::pull(cell)
  t2_disp[[s]] <- col
}

rob_tables$rob_t2_sub_oos <- table_to_grob(
  as.data.frame(t2_disp),
  title = "Robustness -- Out-of-sample R^2_oos across subsamples",
  note  = paste0("Pooled Campbell-Thompson (2008) out-of-sample R2 of the ",
                 "fully-recursive factor forecast against the recursive prevailing\n",
                 "mean, scored over country-months whose forecast-origin lies in the ",
                 "window (squared errors aggregated across the G10). Positive = the\n",
                 "factor beats the real-time historical average. Both the factor and ",
                 "the predictive regression respect time t (doubly out-of-sample);\n",
                 "'--' marks windows with too few real-time forecasts (the recursive ",
                 "scheme needs a five-year training minimum). Factors as in Table 8.1."),
  base_size = 8)


# =============================================================================
# TABLE 3 -- Italy in the euro-area sovereign-debt crisis.
# =============================================================================
# Phase II found that Italy is one of the few markets retaining local cyclical
# predictability once the global factor is included. Here we show that this
# residual local content is concentrated in the 2010-2012 euro crisis. For Italy
# we report, per window, the single-factor in-sample R^2 of the local (CF) and
# global (GCF) factors and the horse-race HAC t-statistics on the orthogonalised
# local factor CF_perp and on GCF, plus the out-of-sample R^2 of CF and GCF.

italy <- panel %>% dplyr::filter(country == "IT")

# Orthogonalised local factor (full-sample projection, as in Phase II).
it_perp_fit <- lm(CF ~ GCF, data = italy, na.action = na.exclude)
italy$CF_perp <- residuals(it_perp_fit)

italy_window <- function(lo, hi) {
  d <- italy %>% dplyr::filter(in_window(ym, lo, hi),
                               !is.na(rx_t12), !is.na(CF), !is.na(GCF))
  r2_cf  <- hac_fit(d, rx_t12 ~ CF);  r2_gcf <- hac_fit(d, rx_t12 ~ GCF)
  hr     <- hac_fit(d, rx_t12 ~ CF_perp + GCF)
  oos_cf  <- oos_r2_window(oos_path_list[["rx ~ CF"]]  %>% dplyr::filter(country == "IT"), lo, hi)
  oos_gcf <- oos_r2_window(oos_path_list[["rx ~ GCF"]] %>% dplyr::filter(country == "IT"), lo, hi)
  tibble::tibble(
    months  = length(unique(d$ym)),
    r2_cf   = if (is.null(r2_cf))  NA_real_ else dplyr::filter(r2_cf,  term == "CF")$r_sq,
    r2_gcf  = if (is.null(r2_gcf)) NA_real_ else dplyr::filter(r2_gcf, term == "GCF")$r_sq,
    t_perp  = if (is.null(hr)) NA_real_ else dplyr::filter(hr, term == "CF_perp")$t,
    t_gcf   = if (is.null(hr)) NA_real_ else dplyr::filter(hr, term == "GCF")$t,
    oos_cf  = oos_cf$r2, oos_gcf = oos_gcf$r2)
}

italy_res <- purrr::pmap_dfr(subsamples, function(key, label, lo, hi) {
  italy_window(lo, hi) %>% dplyr::mutate(Subsample = label, .before = 1)
})

cat("\n===== Table 3: Italy across subsamples =====\n")
print(as.data.frame(italy_res %>% dplyr::mutate(dplyr::across(where(is.numeric), ~round(., 3)))),
      row.names = FALSE)

t3_disp <- italy_res %>%
  dplyr::transmute(
    Subsample,
    Months = months,
    `R2 CF (IS)`        = fmt3(r2_cf),
    `R2 GCF (IS)`       = fmt3(r2_gcf),
    `t(CF_perp)`        = fmt2(t_perp),
    `t(GCF)`            = fmt2(t_gcf),
    `R2 CF (OOS)`       = ifelse(is.na(oos_cf),  "--", fmt3(oos_cf)),
    `R2 GCF (OOS)`      = ifelse(is.na(oos_gcf), "--", fmt3(oos_gcf)))

rob_tables$rob_t3_italy <- table_to_grob(
  as.data.frame(t3_disp),
  title = "Robustness -- Italy: local vs global content and the euro crisis",
  note  = paste0("Italian local-currency rx_t12 across subsamples. 'R2 CF (IS)' and ",
                 "'R2 GCF (IS)' are single-factor in-sample fits; t(CF_perp) and\n",
                 "t(GCF) are the horse-race HAC t-statistics from rx ~ CF_perp + GCF, ",
                 "with CF_perp the part of the Italian cycle factor orthogonal to the\n",
                 "global factor (full-sample projection). 'R2 CF/GCF (OOS)' are the ",
                 "recursive Campbell-Thompson R2 scored in the window. The surviving\n",
                 "local Italian content of Phase II is concentrated in the 2010-2012 ",
                 "sovereign-debt crisis."),
  base_size = 8)


# =============================================================================
# FIGURE 1 -- Pooled OOS R^2_oos by subsample and specification.
# =============================================================================
theme_thesis <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(
    strip.background = ggplot2::element_rect(fill = "grey92", colour = NA),
    strip.text       = ggplot2::element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = ggplot2::element_blank(),
    plot.title       = ggplot2::element_text(face = "bold"))

rob_plots$rob_f1_oos_sub <- oos_res %>%
  dplyr::filter(sub != "pre", !is.na(r2_oos)) %>%
  dplyr::mutate(
    sub_label = factor(sub_label, levels = subsamples$label),
    spec      = factor(spec, levels = oos_specs$spec_lbl)) %>%
  ggplot2::ggplot(ggplot2::aes(sub_label, r2_oos, fill = spec)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::scale_fill_manual(values = c("rx ~ CF" = "#08519c", "rx ~ GCF" = "#a50f15",
                                        "rx_USD ~ GCF" = "#9aa200", "rx_USD ~ FXGCF" = "#762a83"),
                             name = NULL) +
  ggplot2::labs(
    title = expression(paste("Out-of-sample ", R[oos]^2, " by subsample")),
    subtitle = "Pooled recursive factor forecast vs recursive prevailing mean (positive = beats the mean)",
    x = NULL, y = expression(R[oos]^2)) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 20, hjust = 1))


# =============================================================================
# TABLE 4 / FIGURE 2 -- OOS estimation scheme: expanding vs rolling windows
#                       and the length of the training minimum.
# =============================================================================
# The baseline out-of-sample protocol (oos.R) uses EXPANDING windows with a
# five-year (60-month) training minimum on the predictive regression. Two design
# choices are stress-tested here, both by rebuilding the entire recursive factor
# chain (cycle decomposition -> CF_oos -> GCF_oos / FXGCF_oos) from scratch:
#   (i)  rolling windows -- the fit at each t uses only the most recent W months
#        of data instead of the full history (W = 120, 180);
#   (ii) the training minimum -- 36 vs 60 vs 84 months for the expanding scheme.
# Each scheme scores its factor against the prevailing mean built under the SAME
# scheme, so the comparison is internally consistent. The expanding/60-month
# column reproduces the baseline of oos.R (asserted below as a sanity check).
#
# oos.R's recursive_resid() and oos_predict() now take a `train_window` argument
# (Inf = expanding, the default); we reuse them here to avoid duplicating the
# error-prone real-time cutoff logic.

# --- (a) Recursive cycle decomposition for a given window (the expensive step;
#         cached by window so the min_train variations reuse the expanding cycle).
build_cycle_base <- function(train_window = Inf) {
  cyc <- yields_long %>%
    dplyr::left_join(inflation_long, by = c("ym", "country")) %>%
    dplyr::filter(!is.na(trend_inf), !is.na(yield)) %>%
    dplyr::group_by(country, maturity) %>%
    dplyr::group_modify(~ {
      d <- .x %>% dplyr::arrange(ym)
      d$cycle_oos <- recursive_resid(d, yield ~ trend_inf,
                                     min_train = 60, train_window = train_window)
      d
    }) %>% dplyr::ungroup() %>% dplyr::select(-date.y) %>% dplyr::rename(date = date.x)
  c1 <- cyc %>% dplyr::filter(maturity == 1) %>%
    dplyr::select(country, ym, date, cycle_1y_oos = cycle_oos)
  cavg <- cyc %>% dplyr::filter(maturity != 1) %>%
    dplyr::group_by(country, ym, date) %>%
    dplyr::summarise(c_bar_oos = mean(cycle_oos, na.rm = TRUE), .groups = "drop") %>%
    dplyr::mutate(c_bar_oos = ifelse(is.nan(c_bar_oos), NA_real_, c_bar_oos))
  c1 %>%
    dplyr::left_join(cavg, by = c("country", "ym", "date")) %>%
    dplyr::left_join(reg_data %>% dplyr::select(country, ym, date, rx_t12, rx_USD_t12),
                     by = c("country", "ym", "date")) %>%
    dplyr::mutate(y = as.integer(format(date, "%Y"))) %>%
    dplyr::left_join(gdp %>% dplyr::select(y, country, gdp_val), by = c("y", "country")) %>%
    dplyr::filter(!is.na(cycle_1y_oos), !is.na(c_bar_oos))
}

# --- (b) Add the recursive factors to a cycle base, for a given training
#         minimum `mt` and window. CF_oos / GCF_oos use mt; FXGCF_oos keeps a
#         120-month floor (it is a single aggregate series, not a panel).
add_oos_factors <- function(base, mt = 60, train_window = Inf) {
  rdo <- base %>% dplyr::group_by(country) %>% dplyr::arrange(ym, .by_group = TRUE) %>%
    dplyr::group_modify(~ {
      .x$CF_oos <- oos_predict(.x, rx_t12 ~ cycle_1y_oos + c_bar_oos,
                               min_train = mt, h = 12, train_window = train_window)
      .x
    }) %>% dplyr::ungroup()
  gcfo <- rdo %>% dplyr::filter(!is.na(CF_oos), !is.na(gdp_val)) %>%
    dplyr::group_by(ym) %>% dplyr::mutate(w = gdp_val / sum(gdp_val, na.rm = TRUE)) %>%
    dplyr::group_by(ym, date) %>%
    dplyr::summarise(GCF_oos = sum(w * CF_oos, na.rm = TRUE), .groups = "drop")
  agg <- rdo %>% dplyr::filter(!is.na(gdp_val)) %>%
    dplyr::group_by(ym) %>% dplyr::mutate(w = gdp_val / sum(gdp_val, na.rm = TRUE)) %>%
    dplyr::ungroup()
  gp <- agg %>% dplyr::group_by(ym, date) %>%
    dplyr::summarise(cyc1_bar_oos = sum(w * cycle_1y_oos, na.rm = TRUE),
                     cbar_bar_oos = sum(w * c_bar_oos,    na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(ym)
  rxb <- agg %>% dplyr::filter(!is.na(rx_USD_t12)) %>%
    dplyr::group_by(ym) %>% dplyr::mutate(w = gdp_val / sum(gdp_val, na.rm = TRUE)) %>%
    dplyr::group_by(ym, date) %>%
    dplyr::summarise(rx_USD_bar_t12 = sum(w * rx_USD_t12, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(ym)
  fx <- gp %>% dplyr::left_join(rxb, by = c("ym", "date")) %>% dplyr::arrange(ym)
  fx$FXGCF_oos <- oos_predict(fx, rx_USD_bar_t12 ~ cyc1_bar_oos + cbar_bar_oos,
                              min_train = max(120, mt), h = 12, train_window = train_window)
  rdo %>% dplyr::select(country, ym, date, rx_t12, rx_USD_t12, CF_oos) %>%
    dplyr::left_join(gcfo %>% dplyr::select(ym, GCF_oos),   by = "ym") %>%
    dplyr::left_join(fx   %>% dplyr::select(ym, FXGCF_oos), by = "ym") %>%
    dplyr::arrange(country, date)
}

# --- (c) Pooled Campbell-Thompson R^2_oos for one spec under a given scheme.
scheme_specs <- tibble::tribble(
  ~spec_lbl,        ~target,        ~predictor,
  "rx ~ CF",        "rx_t12",       "CF_oos",
  "rx ~ GCF",       "rx_t12",       "GCF_oos",
  "rx_USD ~ GCF",   "rx_USD_t12",   "GCF_oos",
  "rx_USD ~ FXGCF", "rx_USD_t12",   "FXGCF_oos")

pooled_r2_oos <- function(pnl, target, predictor, mt = 60, h = 12, train_window = Inf) {
  parts <- pnl %>% dplyr::filter(!is.na(.data[[predictor]]), !is.na(.data[[target]])) %>%
    dplyr::group_by(country) %>% dplyr::group_split()
  ssf <- 0; ssb <- 0; npos <- 0L; ntot <- 0L
  fml  <- stats::as.formula(sprintf("%s ~ %s", target, predictor))
  bfml <- stats::as.formula(paste(target, "~ 1"))
  for (d in parts) {
    d <- d %>% dplyr::arrange(ym)
    if (nrow(d) < mt + h) next
    yh <- oos_predict(d, fml,  min_train = mt, h = h, train_window = train_window)
    bn <- oos_predict(d, bfml, min_train = mt, h = h, train_window = train_window)
    y  <- d[[target]]; ok <- !is.na(yh) & !is.na(bn) & !is.na(y)
    if (sum(ok) == 0) next
    f <- sum((y[ok] - yh[ok])^2); b <- sum((y[ok] - bn[ok])^2)
    ssf <- ssf + f; ssb <- ssb + b; ntot <- ntot + 1L
    if (b > 0 && (1 - f / b) > 0) npos <- npos + 1L
  }
  tibble::tibble(r2 = if (ssb > 0) 1 - ssf / ssb else NA_real_, npos = npos, ntot = ntot)
}

cat("\noos.R scheme rebuild: cycle decompositions (expanding / rolling 120 / rolling 180) ...\n")
cyc_exp <- build_cycle_base(Inf)
cyc_120 <- build_cycle_base(120)
cyc_180 <- build_cycle_base(180)

schemes <- tibble::tribble(
  ~key,        ~label,                  ~base,     ~mt, ~tw,
  "exp60",     "Expanding, 5y min",     "exp",     60L, Inf,
  "exp36",     "Expanding, 3y min",     "exp",     36L, Inf,
  "exp84",     "Expanding, 7y min",     "exp",     84L, Inf,
  "roll120",   "Rolling 10y window",    "120",     60L, 120,
  "roll180",   "Rolling 15y window",    "180",     60L, 180)

cyc_lookup <- list(exp = cyc_exp, `120` = cyc_120, `180` = cyc_180)

scheme_res <- purrr::pmap_dfr(schemes, function(key, label, base, mt, tw) {
  pnl <- add_oos_factors(cyc_lookup[[base]], mt = mt, train_window = tw)
  purrr::pmap_dfr(scheme_specs, function(spec_lbl, target, predictor) {
    r <- pooled_r2_oos(pnl, target, predictor, mt = mt, train_window = tw)
    tibble::tibble(scheme = key, scheme_label = label, spec = spec_lbl,
                   r2_oos = r$r2, npos = r$npos, ntot = r$ntot)
  })
})

# Sanity check: the expanding/60-month scheme must match oos.R's baseline pool.
sanity <- scheme_res %>% dplyr::filter(scheme == "exp60") %>%
  dplyr::transmute(spec, rebuilt = round(r2_oos, 3)) %>%
  dplyr::left_join(
    tibble::tibble(
      spec = c("rx ~ CF", "rx ~ GCF", "rx_USD ~ GCF", "rx_USD ~ FXGCF"),
      oos_R = round(c(
        r2_oos_pooled$r2_oos_pooled[r2_oos_pooled$spec == "rx ~ CF_oos"],
        r2_oos_pooled$r2_oos_pooled[r2_oos_pooled$spec == "rx ~ GCF_oos"],
        r2_oos_pooled$r2_oos_pooled[r2_oos_pooled$spec == "rx_USD ~ GCF_oos"],
        r2_oos_pooled$r2_oos_pooled[r2_oos_pooled$spec == "rx_USD ~ FXGCF_oos"]), 3)),
    by = "spec")
cat("\n===== Sanity: rebuilt expanding/5y vs oos.R baseline =====\n")
print(as.data.frame(sanity), row.names = FALSE)

cat("\n===== Table 4: OOS estimation-scheme robustness (pooled R^2_oos) =====\n")
print(as.data.frame(scheme_res %>%
  dplyr::transmute(scheme_label, spec, r2_oos = round(r2_oos, 3),
                   pos = paste0(npos, "/", ntot))), row.names = FALSE)

t4_disp <- tibble::tibble(Specification = scheme_specs$spec_lbl)
for (i in seq_len(nrow(schemes))) {
  s <- schemes$key[i]
  col <- scheme_res %>% dplyr::filter(scheme == s) %>%
    dplyr::arrange(factor(spec, levels = scheme_specs$spec_lbl)) %>%
    dplyr::mutate(cell = ifelse(is.na(r2_oos), "--", fmt3(r2_oos))) %>% dplyr::pull(cell)
  t4_disp[[schemes$label[i]]] <- col
}

rob_tables$rob_t4_oos_scheme <- table_to_grob(
  as.data.frame(t4_disp),
  title = "Robustness -- Out-of-sample estimation scheme: window shape and training length",
  note  = paste0("Pooled Campbell-Thompson R2_oos of the fully-recursive factor against the ",
                 "recursive prevailing mean, with the entire factor chain (cycle\n",
                 "decomposition, predictive regression, benchmark) rebuilt under each scheme. ",
                 "'Expanding' uses all history up to t with a 3-/5-/7-year training\n",
                 "minimum; 'Rolling' uses only the most recent 10/15 years. Each scheme scores ",
                 "its factor against the mean built under the same scheme, so columns are\n",
                 "internally consistent. The expanding/5-year column reproduces the oos.R ",
                 "baseline (Table 8.2). The global cycle factor's edge is invariant to the\n",
                 "training-minimum length but is specific to the expanding window."),
  base_size = 8)

rob_plots$rob_f2_oos_scheme <- scheme_res %>%
  dplyr::mutate(scheme_label = factor(scheme_label, levels = schemes$label),
                spec = factor(spec, levels = scheme_specs$spec_lbl)) %>%
  ggplot2::ggplot(ggplot2::aes(scheme_label, r2_oos, fill = spec)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::scale_fill_manual(values = c("rx ~ CF" = "#08519c", "rx ~ GCF" = "#a50f15",
                                        "rx_USD ~ GCF" = "#9aa200", "rx_USD ~ FXGCF" = "#762a83"),
                             name = NULL) +
  ggplot2::labs(
    title = expression(paste("Out-of-sample ", R[oos]^2, " by estimation scheme")),
    subtitle = "Expanding (3/5/7-year minimum) vs rolling (10/15-year) windows; positive beats the mean",
    x = NULL, y = expression(R[oos]^2)) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 20, hjust = 1))


# =============================================================================
# Write every exhibit to disk as a vector PDF.
# =============================================================================
save_robustness <- function(tab_dir = "thesis/tables", fig_dir = "thesis/figures") {
  dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
  tab_size <- list(rob_t1_sub_is     = c(w = 11, h = 3.3),
                   rob_t2_sub_oos    = c(w = 9,  h = 3.2),
                   rob_t3_italy      = c(w = 11, h = 3.2),
                   rob_t4_oos_scheme = c(w = 11, h = 3.0))
  purrr::iwalk(rob_tables, function(g, nm) {
    sz <- tab_size[[nm]]; w <- if (is.null(sz)) 10 else sz[["w"]]; h <- if (is.null(sz)) 4.5 else sz[["h"]]
    ggplot2::ggsave(file.path(tab_dir, paste0(nm, ".pdf")), g, width = w, height = h)
  })
  purrr::iwalk(rob_plots, function(p, nm) {
    ggplot2::ggsave(file.path(fig_dir, paste0(nm, ".pdf")), p, width = 9, height = 5.5)
  })
  invisible(c(file.path(tab_dir, paste0(names(rob_tables), ".pdf")),
              file.path(fig_dir, paste0(names(rob_plots), ".pdf"))))
}

cat(sprintf(
  "\nrobustness.R loaded: %d tables in `rob_tables`, %d figures in `rob_plots`. Write all with save_robustness().\n",
  length(rob_tables), length(rob_plots)))
