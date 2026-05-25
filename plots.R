# plots.R
# =============================================================
# Figures for the international Cieslak-Povala (2015) bond-return
# predictability framework (CP 2015 mechanism, DH 2013 global
# integration, novel FX-adjusted global factor).
#
# Run from the project root. This sources `data preperation.R`
# (note the space in the filename), which leaves the factor objects
# in the workspace: yields_long, inflation_long, cycle, cycle_avg,
# reg_data, gcf, fxgcf, gdp, fx_long, us_data.
#
# Figures are stored in the `plots` list and NOT auto-printed, so
# sourcing is cheap. Render one with print(plots$<name>); write all
# to disk with save_all_plots().
# =============================================================

source("data preperation.R")

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(purrr)
library(tibble)
library(latex2exp)
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

# =============================================================
# 1. Data & sample
# =============================================================

# 1a. Zero-coupon yields by country and maturity
plots$yield_ts <- yields_long %>%
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
plots$yield_curve_avg <- yields_long %>%
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
plots$coverage <- yields_long %>%
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
plots$inflation_trend <- inflation_long %>%
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
plots$yield_decomp <- cycle %>%
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
plots$cycles_by_country <- cycle %>%
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
plots$beta_loadings <- cycle %>%
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
plots$us_cf_cbar_ts <- us_data %>%
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
plots$us_cbar_vs_cf <- us_data %>%
  ggplot(aes(c_bar, CF)) +
  geom_point(size = 0.8, alpha = 0.5, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  labs(title = "US: average cycle vs local cycle factor",
       subtitle = sprintf("Correlation rho = %.2f (CP-2015 target ~ 0.61)", us_rho),
       x = TeX("$\\bar{c}_{US,t}$"), y = TeX("$CF_{US,t}$")) +
  theme_thesis

# 3c. US predictive scatter: rx_{t+12} vs CF
plots$us_rx_vs_cf <- us_data %>%
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
plots$local_cf <- reg_data %>%
  ggplot(aes(date, CF, colour = country)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = TeX("Local cycle factor $CF_{i,t}$ (eq 6)"),
       y = "CF", x = NULL) +
  theme_thesis + theme(legend.position = "none")

# 4b. Predictive scatter rx_{t+12} vs CF by country (eq 18)
plots$rx_vs_cf_scatter <- panel %>%
  ggplot(aes(CF, rx_t12)) +
  geom_point(size = 0.4, alpha = 0.4, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = TeX("Eq (18): $rx_{i,t+12}$ vs $CF_{i,t}$"),
       x = TeX("$CF_{i,t}$"), y = TeX("$rx_{i,t+12}$ (pp)")) +
  theme_thesis

# 4c. In-sample R^2 of rx ~ CF per country
plots$r2_cf_by_country <- tab18 %>%
  filter(term == "CF") %>%
  ggplot(aes(reorder(country, r_sq), r_sq)) +
  geom_col(fill = "#08519c") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = TeX("In-sample $R^2$ of $rx \\sim CF$ by country"),
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis + theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 4d. In-sample R^2 by country and maturity: rx^(n) ~ country-specific CF
plots$r2_cf_by_country_maturity <- bind_rows(
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
plots$gcf <- ggplot() +
  geom_line(data = reg_data, aes(date, CF, group = country),
            colour = "grey80", linewidth = 0.3) +
  geom_line(data = gcf, aes(date, GCF), colour = "#08519c", linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(title = "Global cycle factor (GDP-weighted, eq 7-8)",
       subtitle = "Blue: GCF_t. Grey: country-level local CFs.",
       y = "Factor value", x = NULL) +
  theme_thesis

# 5b. GDP weights w_{i,t} (eq 8)
plots$gdp_weights <- reg_data %>%
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

plots$cf_corr_heatmap <- cf_corr %>%
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
plots$coef_eq19 <- tab19 %>%
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
plots$r2_cf_vs_gcf <- bind_rows(
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

plots$fxgcf_vs_gcf <- fxgcf %>%
  ggplot(aes(date)) +
  geom_line(aes(y = GCF,   colour = "GCF (eq 7)"),    linewidth = 0.5) +
  geom_line(aes(y = FXGCF, colour = "FXGCF (DH)"),    linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF (eq 7)" = "#08519c",
                                 "FXGCF (DH)" = "#a50f15"),
                      name = NULL) +
  labs(title = "Global cycle factor vs FX-adjusted global cycle factor",
       subtitle = sprintf("Correlation = %.2f (DH-2013 report ~0.50)", gcf_fxgcf_rho),
       y = "Factor value", x = NULL) +
  theme_thesis

# 6b. USD investor: does the global CF subsume the local CF? (eq 21)
plots$coef_eq21 <- tab21 %>%
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
plots$r2_usd_gcf_vs_fxgcf <- bind_rows(
  run_by_country(panel, rx_USD_t12 ~ GCF)   %>% filter(term == "GCF")   %>%
    transmute(country, model = "rx_USD ~ GCF (eq22)",   r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF) %>% filter(term == "FXGCF") %>%
    transmute(country, model = "rx_USD ~ FXGCF (eq23)", r_sq)
) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("rx_USD ~ GCF (eq22)" = "#08519c",
                               "rx_USD ~ FXGCF (eq23)" = "#a50f15"), name = NULL) +
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
plots$rob_fxgcf_ts <- fxgcf %>%
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

# 7b. Robustness: USD-investor R^2 under the two FXGCF constructions
plots$rob_fxgcf_r2 <- bind_rows(
  run_by_country(panel, rx_USD_t12 ~ FXGCF)    %>% filter(term == "FXGCF")    %>%
    transmute(country, model = "FXGCF (top-down)",  r_sq),
  run_by_country(panel, rx_USD_t12 ~ FXGCF_bu) %>% filter(term == "FXGCF_bu") %>%
    transmute(country, model = "FXGCF (bottom-up)", r_sq)
) %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("FXGCF (top-down)" = "#a50f15",
                               "FXGCF (bottom-up)" = "#08519c"), name = NULL) +
  labs(title = TeX("Robustness: USD-investor $R^2$ across FXGCF constructions"),
       subtitle = "Top-down (baseline) vs bottom-up should be similar",
       x = NULL, y = TeX("$R^2$")) +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# Convenience: write every plot to disk as a vector PDF
# =============================================================
save_all_plots <- function(dir = "figures", width = 10, height = 7) {
  dir.create(dir, showWarnings = FALSE)
  purrr::iwalk(plots, function(p, nm) {
    ggsave(file.path(dir, paste0(nm, ".pdf")), p, width = width, height = height)
  })
  invisible(file.path(dir, paste0(names(plots), ".pdf")))
}

cat(sprintf(
  "\nplots.R loaded: %d figures in `plots`. Print one with print(plots$<name>); save all with save_all_plots().\n",
  length(plots)
))
