# plots.R
# =============================================================
# Figures for the international Cieslak-Povala (2015) bond-return
# predictability framework (CP 2015 mechanism, DH 2013 global
# integration, novel FX-adjusted global factor).
#
# Run from the project root. This sources `oos.R`, which itself sources
# `data preperation.R` (note the space in the filename). After sourcing,
# the workspace contains the in-sample factor objects (yields_long,
# inflation_long, cycle, cycle_avg, reg_data, gcf, fxgcf, gdp, fx_long,
# us_data) and their fully-recursive OOS counterparts (cycle_oos,
# reg_data_oos, gcf_oos, fxgcf_oos, panel_oos).
#
# Figures are stored in the `plots` list and NOT auto-printed, so
# sourcing is cheap. Render one with print(plots$<name>); write all
# to disk with save_all_plots().
# =============================================================

source("oos.R")  # transitively sources data preperation.R

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(purrr)
library(tibble)
# latex2exp renders TeX() labels; if it is unavailable (e.g. an offline
# environment without CRAN access) fall back to a plain-text shim so the
# figures still render with readable, if unformatted, labels.
if (requireNamespace("latex2exp", quietly = TRUE)) {
  library(latex2exp)
} else {
  TeX <- function(x, ...) gsub("\\$|\\\\mathrm|[{}]|\\\\", "", x)
}
library(sandwich)
library(lmtest)

plots <- list()

theme_thesis <- theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "grey92", colour = NA),
    strip.text       = element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold")
  )

mat_palette <- c("1Y" = "#2166ac", "2Y" = "#4dac26", "4Y" = "#e08214",
                 "5Y" = "#d6604d", "9Y" = "#c51b7d", "10Y" = "#762a83")

# Country-month panel with all factors side by side.
panel <- reg_data %>%
  left_join(gcf   %>% select(ym, GCF),              by = "ym") %>%
  left_join(gcp   %>% select(ym, GCP),              by = "ym") %>%
  left_join(fxgcf %>% select(ym, FXGCF, FXGCF_bu),  by = "ym")

# -------------------------------------------------------------
# HAC (Newey-West) predictive regression helper.
# 12-month overlapping returns -> lag = ceil(max(1.5*h, 1.3*sqrt(T))).
# Returns one tidy row per coefficient (estimate, HAC SE, t, R^2).
# -------------------------------------------------------------
hac_fit <- function(df, fml, h = 12, min_obs = 24) {
  fit <- tryCatch(lm(fml, data = df, na.action = na.omit),
                  error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  Tn <- stats::nobs(fit)
  if (Tn < min_obs) return(NULL)
  L <- ceiling(max(1.5 * h, 1.3 * sqrt(Tn)))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  ct <- lmtest::coeftest(fit, vcov. = V)
  tibble::tibble(
    term     = rownames(ct),
    estimate = ct[, 1],
    std_err  = ct[, 2],
    t        = ct[, 3],
    r_sq     = summary(fit)$r.squared,
    n        = Tn
  )
}

run_by_country <- function(df, fml) {
  split(df, df$country) %>%
    purrr::imap_dfr(function(d, cty) {
      res <- hac_fit(d, fml)
      if (is.null(res)) return(NULL)
      res$country <- cty
      res
    })
}

# Predictive regressions (proposal eq 18-22).
tab18 <- run_by_country(panel, rx_t12     ~ CF)         # local: rx ~ CF
tab19 <- run_by_country(panel, rx_t12     ~ CF + GCF)   # local: rx ~ CF + GCF
tab20 <- run_by_country(panel, rx_t12     ~ GCF)        # local: rx ~ GCF
tab21 <- run_by_country(panel, rx_USD_t12 ~ CF + GCF)   # USD:   rx_USD ~ CF + GCF

# -------------------------------------------------------------
# DH-style horse-race test for Eq 19: orthogonalise CF against GCF,
# then estimate rx ~ CF_perp + GCF per country with HAC SEs.
#
# CF_perp_i = residual of lm(CF_i ~ GCF) -- the part of the local
# factor not spanned by the global factor. The joint regression then
# asks (a) whether the truly-local component still matters once the
# global factor is in, (b) whether the global factor matters
# unconditionally, and (c) joint significance via a HAC Wald test.
# All three per-country regressions (local-only, global-only, joint)
# are estimated on the same observation set so the R^2 ladder is
# comparable.
# -------------------------------------------------------------

panel_perp <- panel %>%
  group_by(country) %>%
  group_modify(~ {
    d <- .x
    ok <- !is.na(d$CF) & !is.na(d$GCF)
    d$CF_perp <- NA_real_
    if (sum(ok) >= 24) {
      fit_perp <- lm(CF ~ GCF, data = d[ok, ], na.action = na.exclude)
      d$CF_perp[ok] <- residuals(fit_perp)
    }
    d
  }) %>%
  ungroup()

# Like hac_fit but returns the fit + HAC vcov for downstream Wald tests.
hac_fit_full <- function(df, fml, h = 12, min_obs = 24) {
  fit <- tryCatch(lm(fml, data = df, na.action = na.omit),
                  error = function(e) NULL)
  if (is.null(fit) || stats::nobs(fit) < min_obs) return(NULL)
  L <- ceiling(max(1.5 * h, 1.3 * sqrt(stats::nobs(fit))))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  list(fit = fit, vcov = V, T_obs = stats::nobs(fit), lag = L)
}

hr_results <- panel_perp %>%
  split(.$country) %>%
  purrr::imap_dfr(function(d, cn) {
    d <- d %>% filter(!is.na(rx_t12), !is.na(CF), !is.na(CF_perp), !is.na(GCF))
    if (nrow(d) < 24) return(NULL)
    loc   <- hac_fit_full(d, rx_t12 ~ CF)
    glob  <- hac_fit_full(d, rx_t12 ~ GCF)
    joint <- hac_fit_full(d, rx_t12 ~ CF_perp + GCF)
    if (is.null(joint)) return(NULL)
    ct <- lmtest::coeftest(joint$fit, vcov. = joint$vcov)
    # Joint HAC Wald test: H0: beta_CF_perp = beta_GCF = 0
    # Computed directly as W = b' V^{-1} b ~ Chi-sq(2). Avoids
    # lmtest::waldtest, which internally calls update() on the saved
    # lm call and would fail because hac_fit_full's stored call has
    # data = df (out of scope here; the local is `d`).
    test_terms <- c("CF_perp", "GCF")
    b <- coef(joint$fit)
    V <- joint$vcov
    if (all(test_terms %in% names(b)) && all(test_terms %in% rownames(V))) {
      b_t <- b[test_terms]
      V_t <- V[test_terms, test_terms]
      wald_chisq <- tryCatch(
        as.numeric(t(b_t) %*% solve(V_t) %*% b_t),
        error = function(e) NA_real_
      )
      wald_p <- if (!is.na(wald_chisq))
                  pchisq(wald_chisq, df = length(b_t), lower.tail = FALSE)
                else NA_real_
    } else {
      wald_chisq <- NA_real_
      wald_p     <- NA_real_
    }
    tibble::tibble(
      country    = cn,
      n          = joint$T_obs,
      b_local    = ct["CF_perp", "Estimate"],
      se_local   = ct["CF_perp", "Std. Error"],
      t_local    = ct["CF_perp", "t value"],
      p_local    = ct["CF_perp", "Pr(>|t|)"],
      b_global   = ct["GCF",     "Estimate"],
      se_global  = ct["GCF",     "Std. Error"],
      t_global   = ct["GCF",     "t value"],
      p_global   = ct["GCF",     "Pr(>|t|)"],
      r2_local   = if (!is.null(loc))  summary(loc$fit)$r.squared  else NA_real_,
      r2_global  = if (!is.null(glob)) summary(glob$fit)$r.squared else NA_real_,
      r2_joint   = summary(joint$fit)$r.squared,
      wald_chisq = wald_chisq,
      wald_p     = wald_p
    )
  })

# BH-FDR adjustment across the ~10 countries on the three p-value columns.
hr_results <- hr_results %>%
  mutate(
    p_local_bh  = p.adjust(p_local,  method = "BH"),
    p_global_bh = p.adjust(p_global, method = "BH"),
    wald_p_bh   = p.adjust(wald_p,   method = "BH")
  )

cat("\n=== DH horse-race test (Eq 19): rx ~ CF_perp + GCF (HAC) ===\n")
print(hr_results %>%
        select(country, n,
               b_local,  t_local,  p_local,  p_local_bh,
               b_global, t_global, p_global, p_global_bh,
               r2_local, r2_global, r2_joint,
               wald_chisq, wald_p, wald_p_bh))

# =============================================================
# 1. Data & sample
# =============================================================

# 1a. Zero-coupon yields by country and maturity
plots$s1_yield_ts <- yields_long %>%
  filter(!is.na(yield)) %>%
  mutate(maturity_label = factor(paste0(maturity, "Y"),
                                 levels = c("1Y", "2Y", "4Y", "5Y", "9Y", "10Y"))) %>%
  ggplot(aes(date, yield, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = mat_palette, name = "Maturity") +
  labs(title = "Zero-coupon yields by country and maturity",
       y = "Yield (%)", x = NULL) +
  theme_thesis

# 1b. Average yield curve per country (full sample)
plots$s1_yield_curve_avg <- yields_long %>%
  filter(!is.na(yield)) %>%
  group_by(country, maturity) %>%
  summarise(mean_y = mean(yield), .groups = "drop") %>%
  ggplot(aes(maturity, mean_y, colour = country)) +
  geom_line(linewidth = 0.5) + geom_point(size = 1.6) +
  scale_x_continuous(breaks = c(1, 2, 4, 5, 9, 10)) +
  labs(title = "Average yield curve, full sample",
       x = "Maturity (years)", y = "Mean yield (%)", colour = "Country") +
  theme_thesis

# 1c. Yield-panel coverage (justifies the unbalanced G10 panel)
plots$s1_coverage <- yields_long %>%
  group_by(country, date) %>%
  summarise(p_obs = mean(!is.na(yield)), .groups = "drop") %>%
  ggplot(aes(date, country, fill = p_obs)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "#08519c",
                      name = "Share of\nmaturities\nobserved") +
  labs(title = "Yield panel coverage", x = NULL, y = NULL) +
  theme_thesis + theme(panel.grid = element_blank())

# =============================================================
# 2. CP-2015 mechanism: trend inflation and the cycle (eq 1-3)
# =============================================================

# 2a. YoY core CPI vs DMA trend inflation pi^e (eq 3)
plots$s2_inflation_trend <- inflation_long %>%
  filter(!is.na(yoy_infl)) %>%
  ggplot(aes(date)) +
  geom_line(aes(y = yoy_infl,  colour = "YoY core CPI"),        linewidth = 0.35) +
  geom_line(aes(y = trend_inf, colour = "Trend inflation pi^e"), linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c("YoY core CPI" = "grey60",
                                 "Trend inflation pi^e" = "#b2182b"),
                      name = NULL) +
  labs(title = "YoY core CPI and DMA trend inflation (v = 0.987, M = 120)",
       y = "%", x = NULL) +
  theme_thesis

# 2b. Yield decomposition for representative countries (eq 1-2):
#     nominal 10Y yield vs the trend part alpha + beta * pi^e; the gap is the cycle.
plots$s2_yield_decomp <- cycle %>%
  filter(country %in% c("US", "DE", "GB", "JP"), maturity == 10) %>%
  mutate(trend_part = alpha + beta * trend_inf) %>%
  select(country, date, yield, trend_part) %>%
  pivot_longer(c(yield, trend_part), names_to = "component", values_to = "value") %>%
  ggplot(aes(date, value, colour = component)) +
  geom_line(linewidth = 0.5) +
  facet_wrap(~ country, ncol = 2, scales = "free_y") +
  scale_colour_manual(values = c(yield = "#08519c", trend_part = "#b2182b"),
                      labels = c(yield = "Nominal yield (10Y)",
                                 trend_part = "Trend: alpha + beta * pi^e"),
                      name = NULL) +
  labs(title = "Yield decomposition: nominal yield vs trend component",
       subtitle = "Vertical gap = cycle component c (CP-2015 eq 1-2)",
       y = "Yield (%)", x = NULL) +
  theme_thesis

# 2c. Cycle component by country and maturity (eq 1-2)
plots$s2_cycles_by_country <- cycle %>%
  mutate(maturity_label = factor(paste0(maturity, "Y"),
                                 levels = c("1Y", "2Y", "4Y", "5Y", "9Y", "10Y"))) %>%
  ggplot(aes(date, cycle, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = mat_palette, name = "Maturity") +
  labs(title = TeX("Cycle component: residual from $y \\sim \\pi^e$"),
       subtitle = TeX("$c_{i,t}^{(n)} = y_{i,t}^{(n)} - \\alpha_{i,n} - \\beta_{i,n}\\,\\pi^e_{i,t}$"),
       y = "Cycle (pp)", x = NULL) +
  theme_thesis

# 2d. beta_{i,n}: yield-on-trend-inflation loadings by maturity
plots$s2_beta_loadings <- cycle %>%
  distinct(country, maturity, beta) %>%
  ggplot(aes(maturity, beta, colour = country, group = country)) +
  geom_line(linewidth = 0.5) + geom_point(size = 1.6) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  scale_x_continuous(breaks = c(1, 2, 4, 5, 9, 10)) +
  labs(title = TeX("Yield-on-trend-inflation loadings $\\beta_{i,n}$"),
       subtitle = "Dashed line at 1 = one-for-one passthrough",
       x = "Maturity (years)", y = TeX("$\\beta$"), colour = "Country") +
  theme_thesis

# =============================================================
# 3. US replication of CP 2015 (validation)
# =============================================================

us_rho <- with(us_data, cor(c_bar, CF, use = "complete.obs"))

# 3a. CP-2015 Fig. 2 replication: return-forecasting factor and average cycle (US)
plots$s3_us_cf_cbar_ts <- us_data %>%
  select(date, CF, c_bar) %>%
  pivot_longer(c(CF, c_bar), names_to = "series", values_to = "value") %>%
  ggplot(aes(date, value, colour = series, linetype = series)) +
  geom_hline(yintercept = 0, colour = "grey60") +
  geom_line(linewidth = 0.5) +
  annotate("text",
           x = max(us_data$date, na.rm = TRUE),
           y = min(c(us_data$CF, us_data$c_bar), na.rm = TRUE),
           hjust = 1, vjust = 0,
           label = sprintf("Correlation = %.2f", us_rho)) +
  scale_colour_manual(values = c(CF = "#08519c", c_bar = "grey40"),
                      labels = c(CF = TeX("$\\widehat{cf}_t$ (CF)"),
                                 c_bar = TeX("$\\bar{c}_t$")),
                      name = NULL) +
  scale_linetype_manual(values = c(CF = "dashed", c_bar = "solid"),
                        labels = c(CF = TeX("$\\widehat{cf}_t$ (CF)"),
                                   c_bar = TeX("$\\bar{c}_t$")),
                        name = NULL) +
  labs(title = "US: return-forecasting factor and average cycle (CP-2015 Fig. 2)",
       y = "Factor (pp)", x = NULL) +
  theme_thesis

# 3b. c_bar vs CF for the US (CP-2015 reference correlation ~ 0.61)
plots$s3_us_cbar_vs_cf <- us_data %>%
  ggplot(aes(c_bar, CF)) +
  geom_point(size = 0.8, alpha = 0.5, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  labs(title = "US: average cycle vs local cycle factor",
       subtitle = sprintf("Correlation rho = %.2f (CP-2015 target ~ 0.61)", us_rho),
       x = TeX("$\\bar{c}_{US,t}$"), y = TeX("$CF_{US,t}$")) +
  theme_thesis

# 3c. US predictive scatter: rx_{t+12} vs CF
plots$s3_us_rx_vs_cf <- us_data %>%
  ggplot(aes(CF, rx_t12)) +
  geom_point(size = 0.8, alpha = 0.5, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  labs(title = "US: excess return vs cycle factor (CP-2015 predictability)",
       x = TeX("$CF_{US,t}$"), y = TeX("$rx_{US,t+12}$ (pp)")) +
  theme_thesis

# =============================================================
# 4. Local cycle factor across G10 (does CP-2015 extend?)
# =============================================================

# 4a. Local cycle factor CF_{i,t} by country (eq 6)
plots$s4_local_cf <- reg_data %>%
  ggplot(aes(date, CF, colour = country)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = TeX("Local cycle factor $CF_{i,t}$ (eq 6)"),
       y = "CF", x = NULL) +
  theme_thesis + theme(legend.position = "none")

# 4b. Predictive scatter rx_{t+12} vs CF by country (eq 18)
plots$s4_rx_vs_cf_scatter <- panel %>%
  ggplot(aes(CF, rx_t12)) +
  geom_point(size = 0.4, alpha = 0.4, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = TeX("Eq (18): $rx_{i,t+12}$ vs $CF_{i,t}$"),
       x = TeX("$CF_{i,t}$"), y = TeX("$rx_{i,t+12}$ (pp)")) +
  theme_thesis

# 4c. In-sample R^2 of rx ~ CF per country
plots$s4_r2_cf_by_country <- tab18 %>%
  filter(term == "CF") %>%
  ggplot(aes(reorder(country, r_sq), r_sq)) +
  geom_col(fill = "#08519c") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = TeX("In-sample $R^2$ of $rx \\sim CF$ by country"),
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis + theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 4d. In-sample R^2 by country and maturity: rx^(n) ~ country-specific CF
plots$s4_r2_cf_by_country_maturity <- bind_rows(
  run_by_country(panel, rx_2_t12  ~ CF) %>% filter(term == "CF") %>%
    transmute(country, maturity = "2Y",  r_sq),
  run_by_country(panel, rx_5_t12  ~ CF) %>% filter(term == "CF") %>%
    transmute(country, maturity = "5Y",  r_sq),
  run_by_country(panel, rx_10_t12 ~ CF) %>% filter(term == "CF") %>%
    transmute(country, maturity = "10Y", r_sq)
) %>%
  mutate(maturity = factor(maturity, levels = c("2Y", "5Y", "10Y"))) %>%
  ggplot(aes(country, maturity, fill = r_sq)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.0f%%", 100 * r_sq)), size = 2.6) +
  scale_fill_gradient(low = "white", high = "#08519c",
                      labels = percent_format(accuracy = 1), name = TeX("$R^2$")) +
  labs(title = TeX("In-sample $R^2$ of $rx^{(n)} \\sim CF$ by country and maturity"),
       x = NULL, y = "Maturity") +
  theme_thesis +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 5. Global integration (DH 2013; subquestions 1 & 2)
# =============================================================

# 5a. Global cycle factor with the country CFs faded behind (eq 7-8)
plots$s5_gcf <- ggplot() +
  geom_line(data = reg_data, aes(date, CF, group = country),
            colour = "grey80", linewidth = 0.3) +
  geom_line(data = gcf, aes(date, GCF), colour = "#08519c", linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(title = "Global cycle factor (GDP-weighted, eq 7-8)",
       subtitle = "Blue: GCF_t. Grey: country-level local CFs.",
       y = "Factor value", x = NULL) +
  theme_thesis

# 5b. GDP weights w_{i,t} (eq 8)
plots$s5_gdp_weights <- reg_data %>%
  filter(!is.na(w)) %>%
  ggplot(aes(date, w, fill = country)) +
  geom_area(position = "fill") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = TeX("GDP weights $w_{i,t}$ across the panel (eq 8)"),
       y = "Weight", x = NULL, fill = NULL) +
  theme_thesis

# 5c. Cross-country correlation of local CFs (comovement / integration)
cf_corr <- reg_data %>%
  select(country, ym, CF) %>%
  pivot_wider(names_from = country, values_from = CF) %>%
  arrange(ym) %>%
  select(-ym) %>%
  cor(use = "pairwise.complete.obs")

plots$s5_cf_corr_heatmap <- cf_corr %>%
  as.data.frame() %>%
  rownames_to_column("country_a") %>%
  pivot_longer(-country_a, names_to = "country_b", values_to = "rho") %>%
  ggplot(aes(country_a, country_b, fill = rho)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.2f", rho)), size = 2.4) +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac",
                       midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Pairwise correlation of local cycle factors",
       x = NULL, y = NULL, fill = "rho") +
  theme_thesis +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

# 5d. KEY: does the global CF subsume the local CF? (eq 19, local investor)
plots$s5_coef_eq19 <- tab19 %>%
  filter(term %in% c("CF", "GCF")) %>%
  mutate(lo = estimate - 1.96 * std_err,
         hi = estimate + 1.96 * std_err) %>%
  ggplot(aes(country, estimate, colour = term)) +
  geom_pointrange(aes(ymin = lo, ymax = hi),
                  position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(CF = "#08519c", GCF = "#a50f15"), name = NULL) +
  labs(title = "Eq (19): rx ~ CF + GCF coefficients (HAC +/-1.96 SE)",
       subtitle = "Does the global CF subsume the local CF? (local-currency investor)",
       x = NULL, y = "Coefficient") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 5e. R^2 comparison: local CF vs global GCF per country (eq 18 vs eq 20)
plots$s5_r2_cf_vs_gcf <- bind_rows(
  tab18 %>% filter(term == "CF")  %>% transmute(country, model = "rx ~ CF",  r_sq),
  tab20 %>% filter(term == "GCF") %>% transmute(country, model = "rx ~ GCF", r_sq)
) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx ~ CF" = "#08519c", "rx ~ GCF" = "#a50f15"),
                    name = NULL) +
  labs(title = TeX("In-sample $R^2$: local CF vs global GCF"),
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 6. Currency / FX-adjusted global factor (novel contribution)
# =============================================================

# 6a. GCF vs FX-adjusted GCF over time
gcf_fxgcf_rho <- with(fxgcf %>% filter(!is.na(GCF), !is.na(FXGCF)), cor(GCF, FXGCF))

plots$s6_fxgcf_vs_gcf <- fxgcf %>%
  ggplot(aes(date)) +
  geom_line(aes(y = GCF,   colour = "GCF (eq 7)"),    linewidth = 0.5) +
  geom_line(aes(y = FXGCF_bu, colour = "FXGCF (DH)"),    linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF (eq 7)" = "#08519c",
                                 "FXGCF (DH)" = "#a50f15"),
                      name = NULL) +
  labs(title = "Global cycle factor vs FX-adjusted global cycle factor",
       subtitle = sprintf("Correlation = %.2f (DH-2013 report ~0.50)", gcf_fxgcf_rho),
       y = "Factor value", x = NULL) +
  theme_thesis

# 6b. USD investor: does the global CF subsume the local CF? (eq 21)
plots$s6_coef_eq21 <- tab21 %>%
  filter(term %in% c("CF", "GCF")) %>%
  mutate(lo = estimate - 1.96 * std_err,
         hi = estimate + 1.96 * std_err) %>%
  ggplot(aes(country, estimate, colour = term)) +
  geom_pointrange(aes(ymin = lo, ymax = hi),
                  position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(CF = "#08519c", GCF = "#a50f15"), name = NULL) +
  labs(title = "Eq (21): rx_USD ~ CF + GCF coefficients (HAC +/-1.96 SE)",
       subtitle = "Does the global CF subsume the local CF? (USD investor)",
       x = NULL, y = "Coefficient") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 6c. USD investor: the value of the FX adjustment (eq 22 vs eq 23)
# Now that FXGCF is built per DH (not affine in GCF), these are genuinely different.
plots$s6_r2_usd_gcf_vs_fxgcf <- bind_rows(
  run_by_country(panel, rx_USD_t12 ~ GCF)   %>% filter(term == "GCF")   %>%
    transmute(country, model = "rx_USD ~ GCF (eq22)",   r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF) %>% filter(term == "FXGCF") %>%
    transmute(country, model = "rx_USD ~ FXGCF (eq23)", r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF_bu) %>% filter(term == "FXGCF_bu") %>%
    transmute(country, model = "rx_USD ~ FXGCF_bu (eq23)", r_sq)
) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx_USD ~ GCF (eq22)" = "#08519c",
                               "rx_USD ~ FXGCF (eq23)" = "#a50f15",
                               "rx_USD ~ FXGCF_bu (eq23)" = "#a5af15"),
                    , name = NULL) +
  labs(title = TeX("USD-investor $R^2$: GCF vs FX-adjusted GCF"),
       subtitle = "Value of the FX adjustment for a USD investor",
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 7. Robustness: top-down (baseline) vs bottom-up FXGCF
# =============================================================
# Baseline FXGCF is DH-style top-down (fitted of avg USD return on avg cycles).
# FXGCF_bu is the bottom-up GDP-weighted average of per-country CF_USD. These
# two constructions should largely agree -- a robustness check, not a main result.

fxgcf_bu_rho <- with(fxgcf %>% filter(!is.na(FXGCF), !is.na(FXGCF_bu)),
                     cor(FXGCF, FXGCF_bu))

# 7a. Robustness: FXGCF (top-down) vs FXGCF_bu (bottom-up) over time
plots$s7_rob_fxgcf_ts <- fxgcf %>%
  ggplot(aes(date)) +
  geom_line(aes(y = FXGCF,    colour = "FXGCF (top-down, baseline)"),  linewidth = 0.5) +
  geom_line(aes(y = FXGCF_bu, colour = "FXGCF (bottom-up)"),           linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("FXGCF (top-down, baseline)" = "#a50f15",
                                 "FXGCF (bottom-up)" = "#08519c"), name = NULL) +
  labs(title = "Robustness: FXGCF construction (top-down vs bottom-up)",
       subtitle = sprintf("Correlation = %.2f", fxgcf_bu_rho),
       y = "Factor value", x = NULL) +
  theme_thesis

# 7b. Robustness: USD-investor R^2 under the three FXGCF constructions.
# Leave-own-out (FXGCF_lou) strips out country c's own full-sample CF_USD from the
# weighted average, removing the in-sample own-inclusion bias. The gap between
# bottom-up and leave-own-out IS that bias (largest for high-weight US).
fxgcf_levels <- c("FXGCF (top-down)", "FXGCF (bottom-up)", "FXGCF (leave-own-out)")
plots$s7_rob_fxgcf_r2 <- bind_rows(
  run_by_country(panel, rx_USD_t12 ~ FXGCF)     %>% filter(term == "FXGCF")     %>%
    transmute(country, model = "FXGCF (top-down)",      r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF_bu)  %>% filter(term == "FXGCF_bu")  %>%
    transmute(country, model = "FXGCF (bottom-up)",     r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF_lou) %>% filter(term == "FXGCF_lou") %>%
    transmute(country, model = "FXGCF (leave-own-out)", r_sq)
) %>%
  mutate(model = factor(model, levels = fxgcf_levels)) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("FXGCF (top-down)"      = "#a50f15",
                               "FXGCF (bottom-up)"     = "#9aa200",
                               "FXGCF (leave-own-out)" = "#08519c"), name = NULL) +
  labs(title = TeX("Robustness: USD-investor $R^2$ across FXGCF constructions"),
       subtitle = "Bottom-up vs leave-own-out gap = in-sample own-inclusion bias (largest for US)",
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 8. Out-of-sample factors (fully recursive): CF_oos / GCF_oos / FXGCF_oos
# =============================================================
# Visual sanity check that the recursive factors track their full-sample
# counterparts after burn-in but lag/diverge before. Formal predictability
# tests (CT-R^2, Clark-West, Diebold-Mariano) are deferred to a later push.

# CF and CF_oos joined per country-month for the side-by-side comparisons.
cf_compare <- reg_data %>%
  select(country, ym, date, CF) %>%
  left_join(reg_data_oos %>% select(country, ym, CF_oos),
            by = c("country", "ym"))

# 8a. CF vs CF_oos by country (time series, faceted)
plots$s8_cf_oos_vs_is <- cf_compare %>%
  pivot_longer(c(CF, CF_oos), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c("CF" = "#08519c", "CF_oos" = "#a50f15"),
                      name = NULL) +
  labs(title = "Local cycle factor: full-sample CF vs fully-recursive CF_oos",
       subtitle = "Convergence after ~10y burn-in is the signature of a stable real-time estimator",
       x = NULL, y = "Factor value") +
  theme_thesis

# 8b. GCF vs GCF_oos (single global time series)
plots$s8_gcf_oos_vs_is <- gcf %>%
  select(ym, date, GCF) %>%
  left_join(gcf_oos %>% select(ym, GCF_oos), by = "ym") %>%
  pivot_longer(c(GCF, GCF_oos), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF" = "#08519c", "GCF_oos" = "#a50f15"),
                      name = NULL) +
  labs(title = "Global cycle factor: full-sample GCF vs fully-recursive GCF_oos",
       x = NULL, y = "Factor value") +
  theme_thesis

# 8c. FXGCF vs FXGCF_oos
plots$s8_fxgcf_oos_vs_is <- fxgcf %>%
  select(ym, date, FXGCF) %>%
  left_join(fxgcf_oos %>% select(ym, FXGCF_oos), by = "ym") %>%
  pivot_longer(c(FXGCF, FXGCF_oos), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("FXGCF" = "#08519c", "FXGCF_oos" = "#a50f15"),
                      name = NULL) +
  labs(title = "FX-adjusted GCF: full-sample FXGCF vs fully-recursive FXGCF_oos",
       x = NULL, y = "Factor value") +
  theme_thesis

# 8d. cor(CF, CF_oos) per country -- how much look-ahead inflated CF
plots$s8_oos_is_corr <- cf_compare %>%
  filter(!is.na(CF), !is.na(CF_oos)) %>%
  group_by(country) %>%
  summarise(cor_CF = cor(CF, CF_oos), n = n(), .groups = "drop") %>%
  ggplot(aes(reorder(country, cor_CF), cor_CF)) +
  geom_col(fill = "#08519c") +
  geom_hline(yintercept = c(0, 1), linetype = "dashed", colour = "grey50") +
  coord_flip() +
  scale_y_continuous(limits = c(-0.2, 1.0)) +
  labs(title = TeX("$\\mathrm{cor}(CF, CF_{\\mathrm{oos}})$ per country"),
       subtitle = "Closer to 1 means full-sample look-ahead added little to the local factor",
       x = NULL, y = "Correlation") +
  theme_thesis

# 8e. Realized rx_t12 vs CF_oos (out-of-sample predictive scatter, faceted)
plots$s8_rx_vs_cf_oos <- reg_data_oos %>%
  filter(!is.na(CF_oos), !is.na(rx_t12)) %>%
  ggplot(aes(CF_oos, rx_t12)) +
  geom_point(alpha = 0.3, size = 0.6) +
  geom_smooth(method = "lm", se = FALSE, colour = "#a50f15", linewidth = 0.5) +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = TeX("Realized 12m excess return vs $CF_{\\mathrm{oos}}$"),
       subtitle = "Out-of-sample predictive scatter per country",
       x = TeX("$CF_{\\mathrm{oos}}$"), y = TeX("$rx_{t+12}$")) +
  theme_thesis

# 8f. Campbell-Thompson R^2_oos: local-return predictability per country
# Positive bars => recursive factor forecast beats the recursive prevailing mean.
plots$s8_r2_oos_local <- r2_oos_tab %>%
  filter(spec %in% c("rx ~ CF_oos", "rx ~ GCF_oos"), !is.na(r2_oos)) %>%
  mutate(spec = factor(spec, levels = c("rx ~ CF_oos", "rx ~ GCF_oos"))) %>%
  ggplot(aes(country, r2_oos, fill = spec)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx ~ CF_oos" = "#08519c",
                               "rx ~ GCF_oos" = "#a50f15"), name = NULL) +
  labs(title = TeX("Campbell-Thompson $R^2_{\\mathrm{oos}}$: local-currency returns"),
       subtitle = "Recursive factor forecast vs recursive-mean benchmark (5y min training, 12m horizon)",
       x = NULL, y = TeX("$R^2_{\\mathrm{oos}}$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 8g. Campbell-Thompson R^2_oos: USD-investor returns per country
plots$s8_r2_oos_usd <- r2_oos_tab %>%
  filter(spec %in% c("rx_USD ~ GCF_oos", "rx_USD ~ FXGCF_oos"),
         !is.na(r2_oos)) %>%
  mutate(spec = factor(spec,
                       levels = c("rx_USD ~ GCF_oos", "rx_USD ~ FXGCF_oos"))) %>%
  ggplot(aes(country, r2_oos, fill = spec)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx_USD ~ GCF_oos"  = "#08519c",
                               "rx_USD ~ FXGCF_oos" = "#a50f15"), name = NULL) +
  labs(title = TeX("Campbell-Thompson $R^2_{\\mathrm{oos}}$: USD-investor returns"),
       subtitle = "GCF_oos vs FX-adjusted FXGCF_oos (recursive-mean benchmark)",
       x = NULL, y = TeX("$R^2_{\\mathrm{oos}}$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 8h. Pooled R^2_oos across countries, per spec (one bar per spec)
plots$s8_r2_oos_pooled <- r2_oos_pooled %>%
  filter(!is.na(r2_oos_pooled)) %>%
  ggplot(aes(spec, r2_oos_pooled, fill = spec)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx ~ CF_oos"        = "#08519c",
                               "rx ~ GCF_oos"       = "#9aa200",
                               "rx_USD ~ GCF_oos"   = "#a50f15",
                               "rx_USD ~ FXGCF_oos" = "#762a83")) +
  labs(title = TeX("Pooled Campbell-Thompson $R^2_{\\mathrm{oos}}$ across G10"),
       subtitle = "SS aggregated over countries; each country uses its own recursive-mean benchmark",
       x = NULL, y = TeX("$R^2_{\\mathrm{oos}}$ (pooled)")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# =============================================================
# 9. DH horse-race test for Eq 19: rx ~ CF_perp + GCF
# =============================================================
# Per-country HAC t-stats on the orthogonalised local factor and the
# global factor, plus an R^2 ladder (local-only / global-only / joint).
# Computed in `hr_results` above.

# 9a. Per-country HAC t-stats: CF_perp vs GCF in the joint regression.
plots$s9_hr_tstats <- hr_results %>%
  select(country, `Local (CF_perp)` = t_local, `Global (GCF)` = t_global) %>%
  pivot_longer(-country, names_to = "factor", values_to = "t_stat") %>%
  mutate(factor = factor(factor, levels = c("Local (CF_perp)", "Global (GCF)"))) %>%
  ggplot(aes(country, t_stat, fill = factor)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = c(-1.96, 1.96), linetype = "dashed", colour = "grey50") +
  geom_hline(yintercept = 0, colour = "grey30") +
  scale_fill_manual(values = c("Local (CF_perp)" = "#08519c",
                               "Global (GCF)"    = "#a50f15"), name = NULL) +
  labs(title = "DH horse-race (Eq 19): per-country HAC t-statistics",
       subtitle = TeX("$rx_{t+12} = a + \\beta\\, CF^{\\perp} + \\gamma\\, GCF + \\varepsilon$ -- dashed lines at $\\pm 1.96$"),
       x = NULL, y = "HAC t-statistic") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 9b. R^2 ladder: local-only / global-only / joint per country
plots$s9_hr_r2 <- hr_results %>%
  select(country, `Local only` = r2_local,
                  `Global only` = r2_global,
                  Joint = r2_joint) %>%
  pivot_longer(-country, names_to = "model", values_to = "r_sq") %>%
  mutate(model = factor(model,
                        levels = c("Local only", "Global only", "Joint"))) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("Local only"  = "#08519c",
                               "Global only" = "#a50f15",
                               "Joint"       = "#762a83"), name = NULL) +
  labs(title = TeX("DH horse-race: in-sample $R^2$ ladder per country"),
       subtitle = "Local = rx ~ CF; Global = rx ~ GCF; Joint = rx ~ CF_perp + GCF (same sample)",
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 9c. Joint HAC Wald test: -log10(p) per country (raw and BH-adjusted).
plots$s9_hr_wald <- hr_results %>%
  select(country, raw = wald_p, BH = wald_p_bh) %>%
  pivot_longer(-country, names_to = "adj", values_to = "p") %>%
  mutate(neg_log10_p = -log10(pmax(p, 1e-12)),
         adj = factor(adj, levels = c("raw", "BH"))) %>%
  ggplot(aes(country, neg_log10_p, fill = adj)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", colour = "grey50") +
  scale_fill_manual(values = c("raw" = "#08519c", "BH" = "#a50f15"), name = NULL) +
  labs(title = TeX("DH horse-race joint Wald test: $-\\log_{10}(p)$ per country"),
       subtitle = TeX("$H_0: \\beta = \\gamma = 0$; dashed line at $p = 0.05$ (BH = Benjamini-Hochberg across G10)"),
       x = NULL, y = TeX("$-\\log_{10}(p)$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 10. CP 2005 / GCP factor comparison (vs CF / GCF)
# =============================================================
# Side-by-side view of the cycle-based factor (CF, GCF) and the
# forward-based CP 2005 / DH 2013 factor (CP, GCP), in-sample and OOS.

# 10a. Local factor over time: CF vs CP per country (in-sample)
plots$s10_cf_vs_cp_ts <- reg_data %>%
  select(country, date, CF, CP) %>%
  pivot_longer(c(CF, CP), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c("CF" = "#08519c", "CP" = "#a50f15"), name = NULL) +
  labs(title = "Local factor: cycle-based CF vs forward-based CP (in-sample)",
       subtitle = "CF = CP 2015 cycle factor; CP = CP 2005 / DH 2013 forward factor",
       x = NULL, y = "Factor value") +
  theme_thesis

# 10b. Global factor over time: GCF vs GCP (in-sample)
plots$s10_gcf_vs_gcp_ts <- gcf %>%
  select(ym, date, GCF) %>%
  left_join(gcp %>% select(ym, GCP), by = "ym") %>%
  pivot_longer(c(GCF, GCP), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF" = "#08519c", "GCP" = "#a50f15"), name = NULL) +
  labs(title = "Global factor: GCF vs GCP (in-sample)",
       x = NULL, y = "Factor value") +
  theme_thesis

# 10c. Per-country correlation: cor(CF, CP) -- how much the two local
# factors overlap.
plots$s10_cf_cp_corr <- reg_data %>%
  filter(!is.na(CF), !is.na(CP)) %>%
  group_by(country) %>%
  summarise(cor_CF_CP = cor(CF, CP), n = n(), .groups = "drop") %>%
  ggplot(aes(reorder(country, cor_CF_CP), cor_CF_CP)) +
  geom_col(fill = "#08519c") +
  geom_hline(yintercept = c(0, 1), linetype = "dashed", colour = "grey50") +
  coord_flip() +
  scale_y_continuous(limits = c(-0.2, 1.0)) +
  labs(title = "Local factor overlap: cor(CF, CP) per country (in-sample)",
       subtitle = "Closer to 1 means the cycle and forward factors carry similar information",
       x = NULL, y = "Correlation") +
  theme_thesis

# 10d. In-sample R^2 ladder per country: rx ~ CF / CP / GCF / GCP
tab_cp  <- run_by_country(panel, rx_t12 ~ CP)
tab_gcp <- run_by_country(panel, rx_t12 ~ GCP)

plots$s10_r2_is_compare <- bind_rows(
  tab18   %>% filter(term == "CF")  %>% transmute(country, model = "rx ~ CF",  r_sq),
  tab_cp  %>% filter(term == "CP")  %>% transmute(country, model = "rx ~ CP",  r_sq),
  tab20   %>% filter(term == "GCF") %>% transmute(country, model = "rx ~ GCF", r_sq),
  tab_gcp %>% filter(term == "GCP") %>% transmute(country, model = "rx ~ GCP", r_sq)
) %>%
  mutate(model = factor(model, levels = c("rx ~ CF", "rx ~ CP",
                                          "rx ~ GCF", "rx ~ GCP"))) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx ~ CF"  = "#08519c",
                               "rx ~ CP"  = "#a50f15",
                               "rx ~ GCF" = "#9aa200",
                               "rx ~ GCP" = "#762a83"), name = NULL) +
  labs(title = TeX("In-sample $R^2$: cycle (CF / GCF) vs forward (CP / GCP) factors"),
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 10e. Local OOS factor over time: CF_oos vs CP_oos per country
plots$s10_cf_oos_vs_cp_oos_ts <- panel_oos %>%
  select(country, date, CF_oos, CP_oos) %>%
  pivot_longer(c(CF_oos, CP_oos), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c("CF_oos" = "#08519c", "CP_oos" = "#a50f15"),
                      name = NULL) +
  labs(title = "OOS local factor: CF_oos vs CP_oos (fully recursive)",
       x = NULL, y = "Factor value") +
  theme_thesis

# 10f. Global OOS factor over time: GCF_oos vs GCP_oos
plots$s10_gcf_oos_vs_gcp_oos_ts <- gcf_oos %>%
  select(ym, date, GCF_oos) %>%
  left_join(gcp_oos %>% select(ym, GCP_oos), by = "ym") %>%
  pivot_longer(c(GCF_oos, GCP_oos), names_to = "factor", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF_oos" = "#08519c", "GCP_oos" = "#a50f15"),
                      name = NULL) +
  labs(title = "OOS global factor: GCF_oos vs GCP_oos (fully recursive)",
       x = NULL, y = "Factor value") +
  theme_thesis

# 10g. OOS R^2 comparison per country: cycle vs forward factors
plots$s10_r2_oos_compare <- r2_oos_tab %>%
  filter(spec %in% c("rx ~ CF_oos", "rx ~ CP_oos",
                     "rx ~ GCF_oos", "rx ~ GCP_oos"),
         !is.na(r2_oos)) %>%
  mutate(spec = factor(spec, levels = c("rx ~ CF_oos", "rx ~ CP_oos",
                                        "rx ~ GCF_oos", "rx ~ GCP_oos"))) %>%
  ggplot(aes(country, r2_oos, fill = spec)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx ~ CF_oos"  = "#08519c",
                               "rx ~ CP_oos"  = "#a50f15",
                               "rx ~ GCF_oos" = "#9aa200",
                               "rx ~ GCP_oos" = "#762a83"), name = NULL) +
  labs(title = TeX("Campbell-Thompson $R^2_{\\mathrm{oos}}$: cycle vs forward factors"),
       subtitle = "Recursive factor forecast vs recursive-mean benchmark, 5y min training, 12m horizon",
       x = NULL, y = TeX("$R^2_{\\mathrm{oos}}$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# Convenience: write every plot to disk as a vector PDF
# =============================================================
save_all_plots <- function(dir = "thesis/figures", width = 10, height = 7) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  purrr::iwalk(plots, function(p, nm) {
    ggsave(file.path(dir, paste0(nm, ".pdf")), p, width = width, height = height)
  })
  invisible(file.path(dir, paste0(names(plots), ".pdf")))
}

cat(sprintf(
  "\nplots.R loaded: %d figures in `plots`. Print one with print(plots$<name>); save all with save_all_plots().\n",
  length(plots)
))
