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
# Write every exhibit to disk as a vector PDF.
# =============================================================================
save_robustness <- function(tab_dir = "thesis/tables", fig_dir = "thesis/figures") {
  dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
  tab_size <- list(rob_t1_sub_is  = c(w = 11, h = 3.3),
                   rob_t2_sub_oos = c(w = 9,  h = 3.2),
                   rob_t3_italy   = c(w = 11, h = 3.2))
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
