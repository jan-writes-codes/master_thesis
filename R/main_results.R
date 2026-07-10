# main_results.R
# =============================================================================
# Chapter 7 (Main Results): the three-phase predictive programme.
#
# This is the single home for the MAIN-RESULT exhibits of the thesis. It mirrors
# the pattern of empirical.R (replication tables) and plots.R (figures): every
# table is printed to the console AND rendered to a PDF grob in `mr_tables`;
# every figure is stored in `mr_plots`. Write all exhibits to disk with
#   save_main_results()  ->  thesis/tables/<name>.pdf , thesis/figures/<name>.pdf
#
# Scope: IN-SAMPLE predictive regressions for the local-currency and US-dollar
# investor (framework Eqs 18-23). The fully-recursive out-of-sample evidence
# (oos.R) and the alternative factor constructions are the subject of Ch.8
# (Robustness); they are deliberately NOT re-run here, so this script is light
# (it sources only the factor pipeline and the inference primitives).
#
# Phase I   : does the local cycle factor predict returns in each G10 market?
#             rx_bar_{i,t+12} = a_i + b_i CF_{i,t} + e         (Eq 18 / h-local)
#             reported via its underlying forecasting regression on the two
#             cycle predictors, of which CF is the fitted value (Eq cf-reg).
# Phase II  : does the global factor subsume the local factor?
#             horse race rx_bar ~ CF_perp + GCF, CF_perp = CF orthogonal to GCF
#             (Eq 19-20 / h-horse, h-global).
# Phase III : does currency risk break the model, and does the FX-adjusted
#             factor restore it? rx_USD ~ GCF (Eq 22) vs rx_USD ~ FXGCF (Eq 23).
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

if (!exists("reg_data")) source("R/data_preparation.R")
source("R/cp_inference.R")
source("R/thesis_palette.R")  # shared colour scheme (col_pri/col_sec/col_ter/col_qua)
source("R/thesis_utils.R")    # shared analysis helpers (hac_fit, run_by_country, wald_p, theme_thesis)

mr_tables <- list()
mr_plots  <- list()

# Country display order (euro bloc, other Europe, RoW), as in empirical.R.
mr_order <- c("BE", "DE", "FR", "IT", "NL", "CH", "GB", "SE", "CA", "JP", "US")
mr_name  <- c(BE = "Belgium", CA = "Canada", CH = "Switzerland", DE = "Germany",
              FR = "France", GB = "UK", IT = "Italy", JP = "Japan",
              NL = "Netherlands", SE = "Sweden", US = "US")

# Country-month panel with the local and global factors side by side.
panel <- reg_data %>%
  dplyr::left_join(gcf   %>% dplyr::select(ym, GCF),             by = "ym") %>%
  dplyr::left_join(gcp   %>% dplyr::select(ym, GCP),             by = "ym") %>%
  dplyr::left_join(fxgcf %>% dplyr::select(ym, FXGCF),           by = "ym")

ord <- function(x) factor(x, levels = mr_order)


# =============================================================================
# PHASE I -- The local cycle factor across the G10 (Eq 18).
# =============================================================================
# The local cycle factor CF_{i,t} is the fitted value of the one-year-ahead
# excess return on the two cycle predictors (c^(1), c-bar), so rx ~ CF has slope
# exactly one and R^2 equal to the fit of that forecasting regression. We
# therefore report the underlying forecasting regression itself -- the
# informative object -- with HAC t-stats on each cycle predictor and the joint
# Wald test of no predictability (the empirical content of H0: b_i = 0 in Eq 18).

phase1 <- split(reg_data, reg_data$country) %>%
  purrr::imap_dfr(function(d, cc) {
    d <- d %>% dplyr::filter(!is.na(rx_t12), !is.na(cycle_1y), !is.na(c_bar))
    o <- hac_fit_full(d, rx_t12 ~ cycle_1y + c_bar); if (is.null(o)) return(NULL)
    ct <- lmtest::coeftest(o$fit, vcov. = o$vcov)
    tibble::tibble(
      country = cc,
      g1 = ct["cycle_1y", 1], t1 = ct["cycle_1y", 3],
      g2 = ct["c_bar", 1],    t2 = ct["c_bar", 3],
      r2 = summary(o$fit)$r.squared,
      wp = wald_p(o$fit, o$vcov, c("cycle_1y", "c_bar")),
      n  = o$T_obs)
  }) %>%
  dplyr::mutate(country = ord(country)) %>% dplyr::arrange(country)

# Pooled G10 panel (country fixed effects), HAC on the stacked panel.
p1_fe  <- lm(rx_t12 ~ cycle_1y + c_bar + factor(country), data = reg_data)
L_fe   <- ceiling(max(18, 1.3 * sqrt(stats::nobs(p1_fe))))
V_fe   <- sandwich::NeweyWest(p1_fe, lag = L_fe, prewhite = FALSE, adjust = TRUE)
ct_fe  <- lmtest::coeftest(p1_fe, vcov. = V_fe)
p1_pool <- tibble::tibble(
  country = "G10 panel",
  g1 = ct_fe["cycle_1y", 1], t1 = ct_fe["cycle_1y", 3],
  g2 = ct_fe["c_bar", 1],    t2 = ct_fe["c_bar", 3],
  r2 = summary(p1_fe)$r.squared,
  wp = wald_p(p1_fe, V_fe, c("cycle_1y", "c_bar")),
  n  = stats::nobs(p1_fe))

cat("\n===== Phase I: rx_bar ~ c^(1) + c-bar (local cycle factor, Eq 18) =====\n")
print(as.data.frame(dplyr::bind_rows(phase1, p1_pool) %>%
        dplyr::transmute(country, g1 = round(g1, 2), t1 = round(t1, 2),
                         g2 = round(g2, 2), t2 = round(t2, 2),
                         R2 = round(r2, 3), Wald_p = round(wp, 3), n)),
      row.names = FALSE)

fmt2 <- function(x) formatC(x, format = "f", digits = 2)
fmt3 <- function(x) formatC(x, format = "f", digits = 3)
t1_disp <- dplyr::bind_rows(phase1, p1_pool) %>%
  dplyr::transmute(
    Country = dplyr::recode(as.character(country), !!!mr_name, "G10 panel" = "G10 panel"),
    `c(1)`   = fmt2(g1), `t`  = paste0("(", fmt2(t1), ")"),
    `c-bar`  = fmt2(g2), `t ` = paste0("(", fmt2(t2), ")"),
    `R2`     = fmt3(r2),
    `Wald p` = fmt3(wp), N = n)

mr_tables$mr_t1_phase1 <- table_to_grob(
  as.data.frame(t1_disp),
  title = "Phase I -- Local cycle-factor predictability across the G10",
  note  = paste0("LHS: duration-standardized, maturity-averaged one-year excess return ",
                 "rx_bar_{i,t+12}. Each row is rx_bar ~ c^(1) + c-bar by country;\n",
                 "the local cycle factor CF is the fitted value of this regression. ",
                 "Newey-West HAC t-stats (12m overlap) in (.); Wald p is the joint\n",
                 "test that both cycle slopes are zero. 'G10 panel' adds country fixed ",
                 "effects. In-sample R^2. Sample as in Table 4.1."),
  base_size = 8)

# Figure: in-sample R^2 of rx ~ CF by country (Eq 18).
mr_plots$mr_f1_r2_phase1 <- run_by_country(panel, rx_t12 ~ CF) %>%
  dplyr::filter(term == "CF") %>%
  ggplot2::ggplot(ggplot2::aes(stats::reorder(country, r_sq), r_sq)) +
  ggplot2::geom_col(fill = col_pri) +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::labs(title = expression(paste("In-sample ", R^2, " of ", rx %~% CF, " by country (Eq 18)")),
                x = NULL, y = expression(R^2)) +
  theme_thesis

# --- Phase I, by maturity (Cieslak-Povala 2015, Table 4, Panel A). -----------
# Predict the duration-standardized INDIVIDUAL excess return rx^(n)/n with the
# local cycle factor, for n in {2, 5, 10}, market by market. This shows the cycle
# factor prices the whole curve, not just the maturity-averaged return; loadings
# are flat-to-rising in maturity and the R^2 mirrors the averaged figures.
mr_mats <- c(2L, 5L, 10L)

phase1_mat <- purrr::map_dfr(mr_order, function(cc) {
  d   <- panel %>% dplyr::filter(country == cc)
  out <- tibble::tibble(country = cc)
  for (nn in mr_mats) {
    d$rx_std <- d[[paste0("rx_", nn, "_t12")]] / nn          # duration-standardized
    o  <- hac_fit(d, rx_std ~ CF)
    cf <- if (is.null(o)) NULL else dplyr::filter(o, term == "CF")
    out[[paste0("b", nn)]] <- if (is.null(cf)) NA_real_ else cf$estimate
    out[[paste0("t", nn)]] <- if (is.null(cf)) NA_real_ else cf$t
    out[[paste0("r", nn)]] <- if (is.null(cf)) NA_real_ else cf$r_sq
  }
  out
})

# Pooled G10 panel (country fixed effects), per maturity.
p1m_pool <- tibble::tibble(country = "G10 panel")
for (nn in mr_mats) {
  pp <- panel; pp$rx_std <- pp[[paste0("rx_", nn, "_t12")]] / nn
  fit <- lm(rx_std ~ CF + factor(country), data = pp)
  Lp  <- ceiling(max(18, 1.3 * sqrt(stats::nobs(fit))))
  ctp <- lmtest::coeftest(fit, vcov. = sandwich::NeweyWest(fit, lag = Lp, prewhite = FALSE, adjust = TRUE))
  p1m_pool[[paste0("b", nn)]] <- ctp["CF", 1]
  p1m_pool[[paste0("t", nn)]] <- ctp["CF", 3]
  p1m_pool[[paste0("r", nn)]] <- summary(fit)$r.squared
}

phase1_mat <- phase1_mat %>% dplyr::mutate(country = ord(country)) %>% dplyr::arrange(country)

cat("\n===== Phase I by maturity: rx^(n)/n ~ CF, n in {2,5,10} (CP-2015 Table 4) =====\n")
print(as.data.frame(dplyr::bind_rows(phase1_mat, p1m_pool) %>%
        dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(., 3)))),
      row.names = FALSE)

t1b_disp <- dplyr::bind_rows(phase1_mat, p1m_pool) %>%
  dplyr::transmute(
    Country = dplyr::recode(as.character(country), !!!mr_name, "G10 panel" = "G10 panel"),
    `cf (2Y)`  = paste0(fmt2(b2),  " (", fmt2(t2),  ")"), `R2 (2Y)`  = fmt3(r2),
    `cf (5Y)`  = paste0(fmt2(b5),  " (", fmt2(t5),  ")"), `R2 (5Y)`  = fmt3(r5),
    `cf (10Y)` = paste0(fmt2(b10), " (", fmt2(t10), ")"), `R2 (10Y)` = fmt3(r10))

mr_tables$mr_t1b_maturity <- table_to_grob(
  as.data.frame(t1b_disp),
  title = "Phase I -- Predicting individual excess returns with the cycle factor",
  note  = paste0("LHS: duration-standardized individual excess return rx^(n)/n, ",
                 "n in {2,5,10} years; regressor: the local cycle factor CF (Eq 18).\n",
                 "Cells: cf loading (Newey-West HAC t-stat, 12m overlap); R2 is the ",
                 "in-sample fit. 'G10 panel' adds country fixed effects.\n",
                 "Mirrors Cieslak-Povala (2015), Table 4, Panel A: a single factor ",
                 "prices the whole curve, with loadings flat-to-rising in maturity."),
  base_size = 8)


# =============================================================================
# PHASE II -- Does the global factor subsume the local factor? (Eq 19-20)
# =============================================================================
# Horse race in the spirit of Dahlquist-Hasseltoft (2013, Eq 7): the local
# factor is orthogonalized against the global factor (CF_perp = residual of
# CF ~ GCF), so its slope measures the *incremental* local content once the
# global factor is in. We report the R^2 ladder (local-only / global-only /
# joint), the HAC t-stats on CF_perp and GCF, and the joint HAC Wald test, with
# a Benjamini-Hochberg FDR adjustment across the eleven markets.

r2_cf  <- run_by_country(panel, rx_t12 ~ CF)  %>% dplyr::filter(term == "CF")  %>%
  dplyr::transmute(country, r2_loc = r_sq)
r2_gcf <- run_by_country(panel, rx_t12 ~ GCF) %>% dplyr::filter(term == "GCF") %>%
  dplyr::transmute(country, r2_glb = r_sq)

panel_perp <- panel %>%
  dplyr::group_by(country) %>%
  dplyr::group_modify(~ {
    d <- .x; ok <- !is.na(d$CF) & !is.na(d$GCF); d$CF_perp <- NA_real_
    if (sum(ok) >= 24) d$CF_perp[ok] <- residuals(lm(CF ~ GCF, data = d[ok, ], na.action = na.exclude))
    d
  }) %>% dplyr::ungroup()

phase2 <- split(panel_perp, panel_perp$country) %>%
  purrr::imap_dfr(function(d, cc) {
    d <- d %>% dplyr::filter(!is.na(rx_t12), !is.na(CF_perp), !is.na(GCF))
    o <- hac_fit_full(d, rx_t12 ~ CF_perp + GCF); if (is.null(o)) return(NULL)
    ct <- lmtest::coeftest(o$fit, vcov. = o$vcov)
    tibble::tibble(
      country = cc, t_loc = ct["CF_perp", 3], t_glb = ct["GCF", 3],
      r2_jnt = summary(o$fit)$r.squared,
      wp = wald_p(o$fit, o$vcov, c("CF_perp", "GCF")), n = o$T_obs)
  }) %>%
  dplyr::left_join(r2_cf,  by = "country") %>%
  dplyr::left_join(r2_gcf, by = "country") %>%
  dplyr::mutate(wp_bh = stats::p.adjust(wp, method = "BH"),
                country = ord(country)) %>%
  dplyr::arrange(country)

cat("\n===== Phase II: horse race rx_bar ~ CF_perp + GCF (Eq 19-20) =====\n")
print(as.data.frame(phase2 %>%
        dplyr::transmute(country, R2_CF = round(r2_loc, 3), R2_GCF = round(r2_glb, 3),
                         R2_joint = round(r2_jnt, 3), t_CFperp = round(t_loc, 2),
                         t_GCF = round(t_glb, 2), Wald_p = round(wp, 3),
                         Wald_p_BH = round(wp_bh, 3), n)),
      row.names = FALSE)
cat(sprintf("CF_perp significant (|t|>1.96): %d/11 ; GCF significant: %d/11\n",
            sum(abs(phase2$t_loc) > 1.96), sum(abs(phase2$t_glb) > 1.96)))

t2_disp <- phase2 %>%
  dplyr::transmute(
    Country = dplyr::recode(as.character(country), !!!mr_name),
    `R2 CF`    = fmt3(r2_loc), `R2 GCF` = fmt3(r2_glb), `R2 joint` = fmt3(r2_jnt),
    `t(CF_perp)` = fmt2(t_loc), `t(GCF)` = fmt2(t_glb),
    `Wald p` = fmt3(wp), `Wald p (BH)` = fmt3(wp_bh))

mr_tables$mr_t2_phase2 <- table_to_grob(
  as.data.frame(t2_disp),
  title = "Phase II -- Global vs local cycle factor (horse race)",
  note  = paste0("LHS: local-currency rx_bar_{i,t+12}. 'R2 CF' and 'R2 GCF' are ",
                 "single-factor fits (Eq 18, Eq 20); 'R2 joint' is rx_bar ~ ",
                 "CF_perp + GCF,\nwith CF_perp the part of the local factor ",
                 "orthogonal to GCF (Eq 19). HAC t-stats; Wald p tests joint ",
                 "significance; BH = Benjamini-\nHochberg FDR across the eleven ",
                 "markets. A significant GCF with an insignificant CF_perp signals ",
                 "subsumption by the global factor."),
  base_size = 8)

# Figure: R^2 ladder (local-only / global-only / joint) per country.
mr_plots$mr_f2_r2_ladder <- phase2 %>%
  dplyr::select(country, `Local CF` = r2_loc, `Global GCF` = r2_glb, Joint = r2_jnt) %>%
  tidyr::pivot_longer(-country, names_to = "model", values_to = "r_sq") %>%
  dplyr::mutate(model = factor(model, levels = c("Local CF", "Global GCF", "Joint"))) %>%
  ggplot2::ggplot(ggplot2::aes(country, r_sq, fill = model)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::scale_fill_manual(values = c("Local CF" = col_pri, "Global GCF" = col_sec,
                                        "Joint" = col_ter), name = NULL) +
  ggplot2::labs(title = expression(paste("Phase II: in-sample ", R^2, " ladder per country")),
                x = NULL, y = expression(R^2)) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

# Figure: per-country HAC t-stats, CF_perp vs GCF in the joint regression.
mr_plots$mr_f2_hr_tstats <- phase2 %>%
  dplyr::select(country, `Local (CF_perp)` = t_loc, `Global (GCF)` = t_glb) %>%
  tidyr::pivot_longer(-country, names_to = "factor", values_to = "t_stat") %>%
  dplyr::mutate(factor = factor(factor, levels = c("Local (CF_perp)", "Global (GCF)"))) %>%
  ggplot2::ggplot(ggplot2::aes(country, t_stat, fill = factor)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::geom_hline(yintercept = c(-1.96, 1.96), linetype = "dashed", colour = "grey50") +
  ggplot2::geom_hline(yintercept = 0, colour = "grey30") +
  ggplot2::scale_fill_manual(values = c("Local (CF_perp)" = col_pri,
                                        "Global (GCF)" = col_sec), name = NULL) +
  ggplot2::labs(title = "Phase II horse race: per-country HAC t-statistics",
                subtitle = "Dashed lines at +/- 1.96; CF_perp = local factor orthogonal to GCF",
                x = NULL, y = "HAC t-statistic") +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))


# =============================================================================
# PHASE III -- The US-dollar investor and the FX-adjusted factor (Eq 21-23).
# =============================================================================
# For a USD investor the local-currency return is augmented by the realized
# currency return (Eq rx-usd). We ask (a) how far currency risk erodes the
# global-factor predictability that held in local currency, and (b) whether the
# purpose-built FX-adjusted global factor FXGCF recovers it.

g_usd  <- run_by_country(panel, rx_USD_t12 ~ GCF)   %>% dplyr::filter(term == "GCF")   %>%
  dplyr::transmute(country, b_g = estimate, t_g = t, r2_g = r_sq, n)
fx_usd <- run_by_country(panel, rx_USD_t12 ~ FXGCF) %>% dplyr::filter(term == "FXGCF") %>%
  dplyr::transmute(country, b_f = estimate, t_f = t, r2_f = r_sq)
loc_usd <- run_by_country(panel, rx_USD_t12 ~ CF)   %>% dplyr::filter(term == "CF")    %>%
  dplyr::transmute(country, r2_cfusd = r_sq)

phase3 <- g_usd %>%
  dplyr::left_join(fx_usd, by = "country") %>%
  dplyr::left_join(loc_usd, by = "country") %>%
  dplyr::mutate(country = ord(country)) %>% dplyr::arrange(country)

# Correlation between the global and FX-adjusted global factors (key diagnostic).
gcf_fxgcf_rho <- with(fxgcf %>% dplyr::filter(!is.na(GCF), !is.na(FXGCF)), cor(GCF, FXGCF))

cat("\n===== Phase III: USD-investor returns, GCF (Eq 22) vs FXGCF (Eq 23) =====\n")
print(as.data.frame(phase3 %>%
        dplyr::transmute(country, R2_CF_usd = round(r2_cfusd, 3),
                         b_GCF = round(b_g, 2), t_GCF = round(t_g, 2), R2_GCF = round(r2_g, 3),
                         b_FXGCF = round(b_f, 2), t_FXGCF = round(t_f, 2), R2_FXGCF = round(r2_f, 3), n)),
      row.names = FALSE)
cat(sprintf("FXGCF R2 > GCF R2 in %d/11 markets ; cor(GCF, FXGCF) = %.2f\n",
            sum(phase3$r2_f > phase3$r2_g, na.rm = TRUE), gcf_fxgcf_rho))

t3_disp <- phase3 %>%
  dplyr::transmute(
    Country = dplyr::recode(as.character(country), !!!mr_name),
    `R2 (local CF)` = fmt3(r2_cfusd),
    `GCF`   = fmt2(b_g), `t`  = paste0("(", fmt2(t_g), ")"), `R2 GCF`   = fmt3(r2_g),
    `FXGCF` = fmt2(b_f), `t ` = paste0("(", fmt2(t_f), ")"), `R2 FXGCF` = fmt3(r2_f), N = n)

mr_tables$mr_t3_phase3 <- table_to_grob(
  as.data.frame(t3_disp),
  title = "Phase III -- US-dollar investor: GCF vs the FX-adjusted FXGCF",
  note  = paste0("LHS: US-dollar excess return rx_USD_{i,t+12} (Eq 11). 'R2 (local CF)' ",
                 "repeats the dollar return on the local factor for reference; the\n",
                 "GCF and FXGCF blocks regress rx_USD on the global (Eq 22) and the ",
                 "FX-adjusted global (Eq 23) factor. HAC t-stats in (.). The US row\n",
                 "carries no currency leg. cor(GCF, FXGCF) = ",
                 formatC(gcf_fxgcf_rho, format = "f", digits = 2),
                 " in this sample, so the two factors are close substitutes."),
  base_size = 8)

# Figure: USD-investor R^2, GCF vs FXGCF, by country.
mr_plots$mr_f3_usd_r2 <- phase3 %>%
  dplyr::select(country, `rx_USD ~ GCF (Eq 22)` = r2_g, `rx_USD ~ FXGCF (Eq 23)` = r2_f) %>%
  tidyr::pivot_longer(-country, names_to = "model", values_to = "r_sq") %>%
  ggplot2::ggplot(ggplot2::aes(country, r_sq, fill = model)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::scale_fill_manual(values = c("rx_USD ~ GCF (Eq 22)" = col_pri,
                                        "rx_USD ~ FXGCF (Eq 23)" = col_sec), name = NULL) +
  ggplot2::labs(title = expression(paste("Phase III: US-dollar-investor ", R^2, ": GCF vs FX-adjusted FXGCF")),
                subtitle = "Value of the FX adjustment for a US-dollar investor",
                x = NULL, y = expression(R^2)) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

# Figure: GCF vs FXGCF over time (the close-substitute diagnostic).
mr_plots$mr_f4_gcf_fxgcf <- fxgcf %>%
  dplyr::filter(!is.na(GCF), !is.na(FXGCF)) %>%
  ggplot2::ggplot(ggplot2::aes(date)) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  ggplot2::geom_line(ggplot2::aes(y = GCF,   colour = "GCF (Eq 7)"),   linewidth = 0.5) +
  ggplot2::geom_line(ggplot2::aes(y = FXGCF, colour = "FXGCF (Eq 23)"), linewidth = 0.5) +
  ggplot2::scale_colour_manual(values = c("GCF (Eq 7)" = col_pri,
                                          "FXGCF (Eq 23)" = col_sec), name = NULL) +
  ggplot2::labs(title = "Global cycle factor vs FX-adjusted global cycle factor",
                subtitle = sprintf("Correlation = %.2f over the common sample", gcf_fxgcf_rho),
                x = NULL, y = "Factor value") +
  theme_thesis


# =============================================================================
# OUT-OF-SAMPLE SUMMARY -- fully-recursive Campbell-Thompson R^2 (Eq meth-ctr2).
# =============================================================================
# In-sample predictability can reflect over-fitting of generated regressors, so
# the whole factor chain is rebuilt recursively (oos.R) and each phase is
# re-evaluated in real time against the recursive prevailing-mean benchmark. This
# block reuses oos.R's r2_oos_tab / r2_oos_pooled and contrasts the pooled OOS
# R^2 with the in-sample fit, phase by phase. Detailed per-country / per-spec OOS
# evidence and the forward-factor comparison are deferred to Ch.8.

source("R/oos.R")   # recursive factors + Campbell-Thompson R^2 (slow, fully recursive)

oos_pool <- function(lbl) r2_oos_pooled$r2_oos_pooled[as.character(r2_oos_pooled$spec) == lbl]
oos_npos <- function(lbl) sum(r2_oos_tab$r2_oos[r2_oos_tab$spec == lbl] > 0, na.rm = TRUE)
oos_n    <- function(lbl) sum(!is.na(r2_oos_tab$r2_oos[r2_oos_tab$spec == lbl]))

oos_summary <- tibble::tibble(
  phase = c("I -- local", "II -- global", "III -- USD, global", "III -- USD, FX-adj."),
  spec  = c("rx ~ CF", "rx ~ GCF", "rx_USD ~ GCF", "rx_USD ~ FXGCF"),
  lbl   = c("rx ~ CF_oos", "rx ~ GCF_oos", "rx_USD ~ GCF_oos", "rx_USD ~ FXGCF_oos"),
  is_r2 = c(mean(phase1$r2, na.rm = TRUE), mean(phase2$r2_glb, na.rm = TRUE),
            mean(phase3$r2_g, na.rm = TRUE), mean(phase3$r2_f, na.rm = TRUE))) %>%
  dplyr::mutate(
    oos_r2 = vapply(lbl, oos_pool, numeric(1)),
    npos   = vapply(lbl, oos_npos, integer(1)),
    ntot   = vapply(lbl, oos_n,    integer(1)))

cat("\n===== Out-of-sample summary: in-sample vs Campbell-Thompson R^2_oos =====\n")
print(as.data.frame(oos_summary %>%
        dplyr::transmute(phase, spec, IS_R2 = round(is_r2, 3),
                         OOS_R2_pooled = round(oos_r2, 3), markets_pos = paste0(npos, "/", ntot))),
      row.names = FALSE)

t4_disp <- oos_summary %>%
  dplyr::transmute(
    Phase = phase, Specification = spec,
    `In-sample R2 (mean)` = fmt3(is_r2),
    `OOS R2 (pooled)`     = fmt3(oos_r2),
    `Markets OOS+`        = paste0(npos, "/", ntot))

mr_tables$mr_t4_oos <- table_to_grob(
  as.data.frame(t4_disp),
  title = "Out-of-sample summary -- recursive Campbell-Thompson R^2 by phase",
  note  = paste0("In-sample R2 is the cross-country mean of the single-factor ",
                 "fits (Eq 18, 20, 22, 23). OOS R2 is the pooled Campbell-Thompson\n",
                 "(2008) R2 of the fully-recursive factor forecast against the ",
                 "recursive prevailing mean (Eq meth-ctr2); 'Markets OOS+' counts ",
                 "markets\nwith positive OOS R2. The factor and the forecasting ",
                 "regression both respect time t (doubly out-of-sample). Detail in Ch.8."),
  base_size = 8)

# Figure: per-country CT R^2_oos, local CF vs global GCF (the IS->OOS contrast).
mr_plots$mr_f5_oos_r2 <- r2_oos_tab %>%
  dplyr::filter(spec %in% c("rx ~ CF_oos", "rx ~ GCF_oos"), !is.na(r2_oos)) %>%
  dplyr::mutate(spec = factor(spec, levels = c("rx ~ CF_oos", "rx ~ GCF_oos")),
                country = ord(country)) %>%
  ggplot2::ggplot(ggplot2::aes(country, r2_oos, fill = spec)) +
  ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.75) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  # Per-bar value labels (review remark R-122: "the graph with more detail").
  ggplot2::geom_text(ggplot2::aes(label = scales::percent(r2_oos, accuracy = 1),
                                  y = r2_oos + ifelse(r2_oos >= 0, 0.012, -0.012)),
                     position = ggplot2::position_dodge(width = 0.8),
                     size = 2.1, colour = "grey25") +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  ggplot2::scale_fill_manual(values = c("rx ~ CF_oos" = col_pri, "rx ~ GCF_oos" = col_sec),
                             name = NULL) +
  ggplot2::labs(title = expression(paste("Out-of-sample ", R[oos]^2, ": local CF vs global GCF")),
                subtitle = "Recursive factor forecast vs recursive prevailing mean; bar labels show pooled-scored per-country R2_oos",
                x = NULL, y = expression(R[oos]^2)) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))


# =============================================================================
# Write every exhibit to disk as a vector PDF.
# =============================================================================
save_main_results <- function(tab_dir = "thesis/tables", fig_dir = "thesis/figures") {
  dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
  tab_size <- list(mr_t1_phase1    = c(w = 9,  h = 5.0),
                   mr_t1b_maturity = c(w = 11, h = 5.0),
                   mr_t2_phase2    = c(w = 10, h = 5.0),
                   mr_t3_phase3    = c(w = 11, h = 4.8),
                   mr_t4_oos       = c(w = 10, h = 3.6))
  purrr::iwalk(mr_tables, function(g, nm) {
    sz <- tab_size[[nm]]; w <- if (is.null(sz)) 9 else sz[["w"]]; h <- if (is.null(sz)) 5 else sz[["h"]]
    ggplot2::ggsave(file.path(tab_dir, paste0(nm, ".pdf")), g, width = w, height = h)
  })
  purrr::iwalk(mr_plots, function(p, nm) {
    ggplot2::ggsave(file.path(fig_dir, paste0(nm, ".pdf")), p, width = 9, height = 5.5)
  })
  invisible(c(file.path(tab_dir, paste0(names(mr_tables), ".pdf")),
              file.path(fig_dir, paste0(names(mr_plots), ".pdf"))))
}

cat(sprintf(
  "\nmain_results.R loaded: %d tables in `mr_tables`, %d figures in `mr_plots`. Write all with save_main_results().\n",
  length(mr_tables), length(mr_plots)))
