# plots

library(ggplot2)
library(latex2exp)

cycle %>%
  mutate(maturity_label = paste0(maturity, "Y")) %>%
  ggplot(aes(x = date, y = cycle, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  facet_wrap(~ country, scales = "free_y", ncol = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  scale_colour_manual(
    values = c("1Y" = "#2166ac", "2Y" = "#4dac26", "5Y" = "#d6604d", "10Y" = "#762a83"),
    name   = "Maturity"
  ) +
  labs(
    title    = "Cycle Component by Country and Maturity",
    subtitle = "Residual from yield ~ trend inflation regression (Cieslak-Povala eq. 1-2)",
    x        = NULL,
    y        = "Cycle (pp)"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "grey92"),
    strip.text       = element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = element_blank()
  )


cycle_avg %>%
  ggplot(aes(x = date, y = c_bar, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(title = "Average Cycle Factor by Country", x = NULL, y = "c̄ (pp)", colour = "Country") +
  theme_bw() +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())


local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(
    title    = "Local Cycle Factor (CF) by Country",
    subtitle = "CF_{i,t} = γ̂_{i,1} · c_{i,t}^{(1)} + γ̂_{i,2} · c̄_{i,t}",
    x        = NULL,
    y        = "CF",
    colour   = "Country"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "grey92"),
    strip.text       = element_text(face = "bold"),
    legend.position  = "none",       # redundant with facet labels
    panel.grid.minor = element_blank()
  )

# Faceted
p_facet <- local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = "Local Cycle Factor by Country (Faceted)",
       x = NULL, y = "CF") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "grey92"),
        strip.text = element_text(face = "bold"),
        legend.position = "none",
        panel.grid.minor = element_blank())

# Single panel
local_cf %>%
  ggplot(aes(x = date, y = CF, colour = country)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(title = "Local Cycle Factor by Country",
       x = NULL, y = "CF", colour = "Country") +
  theme_bw() +
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank())



# plots.R
# =============================================================
# Visual diagnostics for the international Cieslak-Povala (2015)
# bond-return predictability framework. Run after sourcing
# `data preperation.R` and `empirical.R` so all factor objects exist
# (yields_long, inflation_long, fx_long, cycle, cycle_avg, reg_data,
# local_cf, local_cf_oos, rx_avg, gcf, fxgcf, cp_factor, cf_gdp,
# panel, tab_18..tab_23, us_data, us_R2_tab).
#
# Plot objects are stored in the `plots` list and not auto-printed,
# so sourcing this file is cheap. Render any single plot with
# `print(plots$<name>)`, or write all to disk with save_all_plots().
# =============================================================

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(purrr)
library(tibble)

plots <- list()

theme_thesis <- theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "grey92", colour = NA),
    strip.text       = element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold")
  )

mat_palette <- c("1Y" = "#2166ac", "2Y" = "#4dac26",
                 "5Y" = "#d6604d", "10Y" = "#762a83")

# =============================================================
# 1. Data overview
# =============================================================

# 1a. Time series of zero yields, faceted by country
plots$yield_ts <- yields_long %>%
  filter(maturity %in% c(1, 2, 5, 10), !is.na(yield)) %>%
  mutate(maturity_label = factor(paste0(maturity, "Y"),
                                 levels = c("1Y", "2Y", "5Y", "10Y"))) %>%
  ggplot(aes(date, yield, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = mat_palette, name = "Maturity") +
  labs(title = "Zero-coupon yields by country and maturity",
       y = "Yield (%)", x = NULL) +
  theme_thesis

# 1b. Average yield curve per country
plots$yield_curve_avg <- yields_long %>%
  filter(!is.na(yield)) %>%
  group_by(country, maturity) %>%
  summarise(mean_y = mean(yield), .groups = "drop") %>%
  ggplot(aes(maturity, mean_y, colour = country)) +
  geom_line(linewidth = 0.5) + geom_point(size = 1.6) +
  scale_x_continuous(breaks = c(1, 2, 4, 5, 9, 10)) +
  labs(title = "Average yield curve, full sample",
       x = "Maturity (years)", y = "Mean yield (%)") +
  theme_thesis

# 1c. Coverage of the yield panel
plots$coverage <- yields_long %>%
  group_by(country, date) %>%
  summarise(p_obs = mean(!is.na(yield)), .groups = "drop") %>%
  ggplot(aes(date, country, fill = p_obs)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "#08519c",
                      name = "Share of\nmaturities\nobserved") +
  labs(title = "Yield panel coverage", x = NULL, y = NULL) +
  theme_thesis + theme(panel.grid = element_blank())

# 1d. FX spot rates against USD (log scale)
plots$fx_ts <- fx_long %>%
  filter(currency != "USD", !is.na(fx_USD)) %>%
  ggplot(aes(as.Date(paste0(substr(ym,1,4),"-",substr(ym,5,6),"-01")),
             fx_USD, colour = currency)) +
  geom_line(linewidth = 0.5) +
  scale_y_log10() +
  labs(title = "FX spot rates (USD per FX, log scale)",
       y = "USD per unit of FX", x = NULL) +
  theme_thesis

# 1e. Nominal GDP in USD (annual, log scale)
plots$gdp_levels <- gdp %>%
  filter(!is.na(gdp_val)) %>%
  ggplot(aes(date, gdp_val, colour = country)) +
  geom_line(linewidth = 0.45) +
  geom_point(size = 0.9) +
  scale_y_log10(labels = scales::label_comma()) +
  labs(title = "Nominal GDP in USD (annual, log scale)",
       subtitle = "Local-currency GDP scaled by year-end FX/USD",
       x = NULL, y = "GDP (USD)", colour = "Country") +
  theme_thesis

# =============================================================
# 2. Inflation and trend inflation (eq 3)
# =============================================================

# 2a. YoY inflation vs DMA trend, per country
plots$inflation_trend <- inflation_long %>%
  filter(!is.na(yoy_infl)) %>%
  ggplot(aes(date)) +
  geom_line(aes(y = yoy_infl,  colour = "YoY core CPI"),         linewidth = 0.35) +
  geom_line(aes(y = trend_inf, colour = "Trend inflation π^e"),  linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c("YoY core CPI" = "grey60",
                                 "Trend inflation π^e" = "#b2182b"),
                      name = NULL) +
  labs(title = "YoY core CPI and DMA trend inflation (v = 0.987, M = 120)",
       y = "%", x = NULL) +
  theme_thesis

# 2b. Trend inflation across countries, single panel
plots$trend_panel <- inflation_long %>%
  filter(!is.na(trend_inf)) %>%
  ggplot(aes(date, trend_inf, colour = country)) +
  geom_line(linewidth = 0.4) +
  labs(title = "Trend inflation π^e_{i,t} across G10",
       y = "π^e (%)", x = NULL) +
  theme_thesis

# =============================================================
# 3. Yield decomposition (eq 1-2): cycle component
# =============================================================

# 3a. Cycle component by country and maturity
library(latex2exp)

plots$cycles_by_country <- cycle %>%
  filter(maturity %in% c(1, 2, 5, 10)) %>%
  mutate(
    maturity_label = factor(
      paste0(maturity, "Y"),
      levels = c("1Y", "2Y", "5Y", "10Y")
    )
  ) %>%
  ggplot(aes(date, cycle, colour = maturity_label)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = mat_palette, name = "Maturity") +
  labs(
    title = TeX("Cycle component: residual from $y \\sim \\pi^e$"),
    subtitle = TeX("$c_{i,t}^{(n)} = y_{i,t}^{(n)} - \\alpha_{i,n} - \\beta_{i,n}\\pi^e_{i,t}$"),
    y = "Cycle (pp)",
    x = NULL
  ) +
  theme_thesis


# 3b. β_{i,n}: how strongly does each yield load on trend inflation
plots$beta_loadings <- cycle %>%
  filter(maturity %in% c(1, 2, 5, 10)) %>%
  distinct(country, maturity, beta) %>%
  ggplot(aes(maturity, beta, colour = country, group = country)) +
  geom_line(linewidth = 0.5) + geom_point(size = 1.6) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  scale_x_continuous(breaks = c(1, 2, 5, 10)) +
  labs(title = "Yield-on-trend-inflation loadings β_{i,n}",
       subtitle = "Dashed line at 1 = one-for-one passthrough",
       x = "Maturity (years)", y = "β") +
  theme_thesis

# 3c. Average cycle c̄_{i,t} (eq 5)
plots$c_bar <- cycle_avg %>%
  ggplot(aes(date, c_bar, colour = country)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = "Average cycle c̄_{i,t} (eq 5, over N = {1,2,5,10})",
       y = "c̄ (pp)", x = NULL) +
  theme_thesis + theme(legend.position = "none")

# 3d. cycle_1y vs c̄ — relevant because eq (4) uses both as regressors
plots$cycle1y_vs_cbar <- reg_data %>%
  ggplot(aes(cycle_1y, c_bar, colour = country)) +
  geom_point(size = 0.5, alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.4) +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = "1y cycle c^(1) vs average cycle c̄",
       x = "c^(1)_{i,t}", y = "c̄_{i,t}") +
  theme_thesis + theme(legend.position = "none")

# =============================================================
# 4. Factor construction: CF, GCF, FXGCF, CP-2005
# =============================================================

# 4a. Local cycle factor CF_{i,t}
plots$local_cf <- local_cf %>%
  ggplot(aes(date, CF, colour = country)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = "Local cycle factor CF_{i,t} (eq 6)",
       y = "CF", x = NULL) +
  theme_thesis + theme(legend.position = "none")

# 4b. Global cycle factor (GDP-weighted, eq 7)
plots$gcf <- gcf %>%
  ggplot(aes(date, GCF)) +
  geom_line(linewidth = 0.5, colour = "#08519c") +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(title = "Global cycle factor GCF_t (eq 7-8)",
       y = "GCF", x = NULL) +
  theme_thesis

# 4c. GDP weights w_{i,t}
plots$gdp_weights <- cf_gdp %>%
  filter(!is.na(w)) %>%
  ggplot(aes(date, w, fill = country)) +
  geom_area(position = "fill") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "GDP weights w_{i,t} across G10 (eq 8)",
       y = "Weight", x = NULL, fill = NULL) +
  theme_thesis

# 4d. FXGCF vs GCF
plots$fxgcf_vs_gcf <- fxgcf %>%
  ggplot(aes(date)) +
  geom_line(aes(y = GCF,   colour = "GCF (eq 7)"),    linewidth = 0.5) +
  geom_line(aes(y = FXGCF, colour = "FXGCF (eq 17)"), linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("GCF (eq 7)"     = "#08519c",
                                 "FXGCF (eq 17)" = "#a50f15"),
                      name = NULL) +
  labs(title = "GCF vs FX-adjusted GCF",
       y = "Factor value", x = NULL) +
  theme_thesis

# 4e. CP-2015 (CF) vs CP-2005 (forwards-based) per country
plots$cp_vs_cf <- local_cf %>%
  select(country, ym, date, CF) %>%
  inner_join(cp_factor %>% select(country, ym, CP), by = c("country", "ym")) %>%
  pivot_longer(c(CF, CP), names_to = "factor", values_to = "value") %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c(CF = "#08519c", CP = "#d94801"),
                      labels = c("CF (CP-2015)", "CP-2005 forwards"),
                      name = NULL) +
  labs(title = "CP-2015 cycle factor vs CP-2005 forwards factor",
       y = "Factor", x = NULL) +
  theme_thesis

# =============================================================
# 5. Cross-country factor relationships (research subquestion 1)
# =============================================================

# 5a. Pairwise correlation of local CFs across G10
cf_wide <- local_cf %>%
  select(country, ym, CF) %>%
  pivot_wider(names_from = country, values_from = CF) %>%
  arrange(ym)

cf_corr <- cor(cf_wide %>% select(-ym), use = "pairwise.complete.obs")

plots$cf_corr_heatmap <- cf_corr %>%
  as.data.frame() %>%
  rownames_to_column("country_a") %>%
  pivot_longer(-country_a, names_to = "country_b", values_to = "rho") %>%
  ggplot(aes(country_a, country_b, fill = rho)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.2f", rho)), size = 2.6) +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac",
                       midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Pairwise correlation of local cycle factors",
       x = NULL, y = NULL, fill = "ρ") +
  theme_thesis +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1))

# 5b. Local CF vs global CF
plots$cf_vs_gcf <- panel %>%
  ggplot(aes(GCF, CF, colour = country)) +
  geom_point(size = 0.5, alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.4) +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = "Local CF vs global GCF",
       x = "GCF_t", y = "CF_{i,t}") +
  theme_thesis + theme(legend.position = "none")

# =============================================================
# 6. Excess returns (the dependent variable)
# =============================================================

# 6a. Local-currency rx
plots$rx_local <- rx_avg %>%
  ggplot(aes(date, rx, colour = country)) +
  geom_line(linewidth = 0.35) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  labs(title = "Maturity-averaged duration-standardized rx (local currency, eq 12-14)",
       y = "rx (pp)", x = NULL) +
  theme_thesis + theme(legend.position = "none")

# 6b. Local vs USD-investor rx
plots$rx_local_vs_usd <- rx_avg %>%
  pivot_longer(c(rx, rx_USD), names_to = "view", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = view)) +
  geom_line(linewidth = 0.35) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c(rx = "#08519c", rx_USD = "#d94801"),
                      labels = c("Local-currency rx", "USD-investor rx"),
                      name = NULL) +
  labs(title = "Local-currency vs USD-investor excess returns",
       y = "rx (pp)", x = NULL) +
  theme_thesis

# =============================================================
# 7. Predictability: scatters and fitted-vs-realized
# =============================================================

# 7a. rx vs CF (eq 18)
plots$rx_vs_cf_scatter <- panel %>%
  ggplot(aes(CF, rx)) +
  geom_point(size = 0.4, alpha = 0.4, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = "Eq (18): rx vs CF",
       x = "CF_{i,t}", y = "rx_{i,t+12} (pp)") +
  theme_thesis

# 7b. rx vs GCF (eq 20)
plots$rx_vs_gcf_scatter <- panel %>%
  ggplot(aes(GCF, rx)) +
  geom_point(size = 0.4, alpha = 0.4, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = "Eq (20): rx vs GCF",
       x = "GCF_t", y = "rx_{i,t+12} (pp)") +
  theme_thesis

# 7c. rx_USD vs FXGCF (eq 23)
plots$rxUSD_vs_fxgcf_scatter <- panel %>%
  ggplot(aes(FXGCF, rx_USD)) +
  geom_point(size = 0.4, alpha = 0.4, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#a50f15") +
  facet_wrap(~ country, ncol = 3, scales = "free") +
  labs(title = "Eq (23): rx_USD vs FXGCF",
       x = "FXGCF_t", y = "rx^USD_{i,t+12} (pp)") +
  theme_thesis

# 7d. Realized vs in-sample CF-fitted rx
fitted_panel <- panel %>%
  group_by(country) %>%
  group_modify(~ {
    fit <- lm(rx ~ CF, data = .x)
    .x %>% mutate(rx_fit = predict(fit, .x))
  }) %>%
  ungroup()

plots$fitted_vs_realized <- fitted_panel %>%
  ggplot(aes(date)) +
  geom_line(aes(y = rx,     colour = "Realized"),      linewidth = 0.35) +
  geom_line(aes(y = rx_fit, colour = "Fitted (CF)"),   linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c(Realized = "grey50",
                                 "Fitted (CF)" = "#08519c"),
                      name = NULL) +
  labs(title = "Realized vs in-sample CF-fitted rx",
       y = "rx (pp)", x = NULL) +
  theme_thesis

# =============================================================
# 8. R² and coefficient summaries (for the thesis tables)
# =============================================================

r2_summary <- bind_rows(
  tab_18 %>% filter(term == "CF")    %>% transmute(country, model = "rx ~ CF (eq18)",         r_sq),
  tab_20 %>% filter(term == "GCF")   %>% transmute(country, model = "rx ~ GCF (eq20)",        r_sq),
  tab_22 %>% filter(term == "GCF")   %>% transmute(country, model = "rx_USD ~ GCF (eq22)",    r_sq),
  tab_23 %>% filter(term == "FXGCF") %>% transmute(country, model = "rx_USD ~ FXGCF (eq23)",  r_sq)
)

plots$r2_compare <- r2_summary %>%
  ggplot(aes(country, r_sq, fill = model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set2", name = NULL) +
  labs(title = "In-sample R² across factor specifications",
       x = NULL, y = "R²") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 8b. Coefficients in eq (19): does GCF subsume local CF?
plots$coef_eq19 <- tab_19 %>%
  filter(term %in% c("CF", "GCF")) %>%
  mutate(lo = estimate - 1.96 * std_err,
         hi = estimate + 1.96 * std_err) %>%
  ggplot(aes(country, estimate, colour = term)) +
  geom_pointrange(aes(ymin = lo, ymax = hi),
                  position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(CF = "#08519c", GCF = "#a50f15"), name = NULL) +
  labs(title = "Eq (19): rx ~ CF + GCF coefficients (HAC ±1.96 SE)",
       subtitle = "Does the global CF subsume the local CF?",
       x = NULL, y = "Coefficient") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 8c. Coefficients in eq (21): USD-investor view
plots$coef_eq21 <- tab_21 %>%
  filter(term %in% c("CF", "GCF")) %>%
  mutate(lo = estimate - 1.96 * std_err,
         hi = estimate + 1.96 * std_err) %>%
  ggplot(aes(country, estimate, colour = term)) +
  geom_pointrange(aes(ymin = lo, ymax = hi),
                  position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(CF = "#08519c", GCF = "#a50f15"), name = NULL) +
  labs(title = "Eq (21): rx_USD ~ CF + GCF coefficients (HAC ±1.96 SE)",
       subtitle = "Does currency risk break the model?",
       x = NULL, y = "Coefficient") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 8d. Distribution of country t-stats (FDR-adjusted) per spec
plots$tstat_panel <- bind_rows(
  tab_18 %>% filter(term == "CF")    %>% transmute(country, spec = "rx ~ CF",         t = t_stat),
  tab_20 %>% filter(term == "GCF")   %>% transmute(country, spec = "rx ~ GCF",        t = t_stat),
  tab_22 %>% filter(term == "GCF")   %>% transmute(country, spec = "rx_USD ~ GCF",    t = t_stat),
  tab_23 %>% filter(term == "FXGCF") %>% transmute(country, spec = "rx_USD ~ FXGCF",  t = t_stat)
) %>%
  ggplot(aes(country, t, fill = spec)) +
  geom_col(position = position_dodge(width = 0.8)) +
  geom_hline(yintercept = c(-1.96, 1.96), linetype = "dashed", colour = "grey50") +
  scale_fill_brewer(palette = "Set2", name = NULL) +
  labs(title = "HAC t-statistics on the predictor coefficient",
       subtitle = "Dashed lines at ±1.96",
       x = NULL, y = "t") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 9. Out-of-sample diagnostics
# =============================================================

# 9a. In-sample CF vs OOS CF
plots$cf_oos_vs_in <- local_cf %>%
  select(country, ym, date, CF_in = CF) %>%
  left_join(local_cf_oos %>% select(country, ym, CF_oos),
            by = c("country", "ym")) %>%
  pivot_longer(c(CF_in, CF_oos), names_to = "type", values_to = "CF") %>%
  filter(!is.na(CF)) %>%
  ggplot(aes(date, CF, colour = type)) +
  geom_line(linewidth = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3, scales = "free_y") +
  scale_colour_manual(values = c(CF_in = "#08519c", CF_oos = "#d94801"),
                      labels = c("In-sample CF", "OOS CF (expanding)"),
                      name = NULL) +
  labs(title = "In-sample vs out-of-sample local CF",
       y = "CF", x = NULL) +
  theme_thesis

# 9b. US: realized rx vs OOS CF, with 45° reference
plots$us_oos_scatter <- local_cf_oos %>%
  filter(country == "US", !is.na(CF_oos), !is.na(rx)) %>%
  ggplot(aes(CF_oos, rx)) +
  geom_point(size = 0.6, alpha = 0.5, colour = "#525252") +
  geom_smooth(method = "lm", se = TRUE, colour = "#08519c") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey60") +
  labs(title = "US: realized rx vs OOS CF",
       subtitle = "Dashed: 45° (β = 1 reference)",
       x = "CF_oos", y = "rx (pp)") +
  theme_thesis

# 9c. Rolling-window 60m R² for rx ~ CF, US
us_rx_cf <- panel %>% filter(country == "US") %>% arrange(ym)
roll_R2 <- function(y, x, w = 60) {
  n <- length(y); out <- rep(NA_real_, n)
  for (i in w:n) {
    yi <- y[(i - w + 1):i]; xi <- x[(i - w + 1):i]
    if (any(is.na(yi)) || any(is.na(xi))) next
    out[i] <- summary(lm(yi ~ xi))$r.squared
  }
  out
}
plots$rolling_r2_us <- us_rx_cf %>%
  mutate(R2_60m = roll_R2(rx, CF, 60)) %>%
  filter(!is.na(R2_60m)) %>%
  ggplot(aes(date, R2_60m)) +
  geom_line(linewidth = 0.5, colour = "#08519c") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "US: 60-month rolling-window R² of rx ~ CF",
       y = "R²", x = NULL) +
  theme_thesis

# =============================================================
# 10. US replication: CP-2015 vs CP-2005
# =============================================================

# 10a. In-sample vs OOS R² across the three US specs
plots$us_replication_R2 <- us_R2_tab %>%
  pivot_longer(c(R2_in, R2_oos), names_to = "kind", values_to = "R2") %>%
  mutate(kind = recode(kind, R2_in = "In-sample", R2_oos = "Out-of-sample"),
         model = factor(model,
                        levels = c("CP-2015 (CF)", "CP-2005 (forwards)", "Encompassing"))) %>%
  ggplot(aes(model, R2, fill = kind)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = 0, colour = "grey40") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_manual(values = c("In-sample" = "#08519c",
                               "Out-of-sample" = "#d94801"),
                    name = NULL) +
  labs(title = "US replication: in-sample and OOS R²",
       x = NULL, y = "R²") +
  theme_thesis

# 10b. US fitted values: CF vs CP-2005 vs realized
us_replication_ts <- {
  d <- us_data
  d$rx_hat_CF  <- predict(lm(rx ~ cycle_1y + c_bar,                          data = d))
  d$rx_hat_CP  <- predict(lm(rx ~ y_1 + f_2 + f_5 + f_10,                    data = d))
  d$rx_hat_ENC <- predict(lm(rx ~ cycle_1y + c_bar + y_1 + f_2 + f_5 + f_10, data = d))
  d
}

plots$us_replication_ts <- us_replication_ts %>%
  pivot_longer(c(rx, rx_hat_CF, rx_hat_CP, rx_hat_ENC),
               names_to = "series", values_to = "value") %>%
  mutate(series = recode(series,
                         rx          = "Realized rx",
                         rx_hat_CF   = "Fitted: CP-2015 (CF)",
                         rx_hat_CP   = "Fitted: CP-2005 forwards",
                         rx_hat_ENC  = "Fitted: encompassing")) %>%
  ggplot(aes(date, value, colour = series, alpha = series)) +
  geom_line(linewidth = 0.45) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("Realized rx"             = "grey50",
                                 "Fitted: CP-2015 (CF)"    = "#08519c",
                                 "Fitted: CP-2005 forwards"= "#d94801",
                                 "Fitted: encompassing"    = "#762a83"),
                      name = NULL) +
  scale_alpha_manual(values = c("Realized rx"             = 0.6,
                                "Fitted: CP-2015 (CF)"    = 1,
                                "Fitted: CP-2005 forwards"= 1,
                                "Fitted: encompassing"    = 1),
                     guide = "none") +
  labs(title = "US: realized rx vs fitted from competing factors",
       y = "rx (pp)", x = NULL) +
  theme_thesis

# =============================================================
# 11. Diagnostics
# =============================================================

# 11a. Per-country residual ACF for rx ~ CF (12m overlap structure)
plots$residual_acf_panel <- panel %>%
  group_by(country) %>%
  group_modify(~ {
    fit <- lm(rx ~ CF, data = .x)
    a <- acf(residuals(fit), plot = FALSE, lag.max = 36, na.action = na.pass)
    tibble(lag = as.numeric(a$lag), acf = as.numeric(a$acf))
  }) %>%
  ungroup() %>%
  ggplot(aes(lag, acf)) +
  geom_segment(aes(xend = lag, yend = 0), colour = "#08519c") +
  geom_hline(yintercept = 0) +
  geom_hline(yintercept = c(-1.96, 1.96) /
               sqrt(nrow(panel) / n_distinct(panel$country)),
             linetype = "dashed", colour = "grey50") +
  facet_wrap(~ country, ncol = 3) +
  labs(title = "Residual ACF: rx ~ CF",
       subtitle = "12-month overlap induces strong autocorrelation through ~ lag 12",
       x = "Lag (months)", y = "ACF") +
  theme_thesis

# 11b. Persistence of cycles: lag-1 autocorrelation per country and maturity
plots$cycle_persistence <- cycle %>%
  filter(maturity %in% c(1, 2, 5, 10)) %>%
  group_by(country, maturity) %>%
  summarise(rho1 = cor(cycle, dplyr::lag(cycle, 1), use = "complete.obs"),
            .groups = "drop") %>%
  mutate(maturity_label = factor(paste0(maturity, "Y"),
                                 levels = c("1Y", "2Y", "5Y", "10Y"))) %>%
  ggplot(aes(country, rho1, fill = maturity_label)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_fill_manual(values = mat_palette, name = "Maturity") +
  labs(title = "Lag-1 autocorrelation of the cycle component",
       subtitle = "Cycle should be the least persistent layer of yields",
       x = NULL, y = "ρ(1)") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# 12. Fully-OOS factors: GCF_oos, FXGCF_oos and OOS R²
# =============================================================

# 12a. In-sample vs OOS GCF
plots$gcf_oos_vs_in <- gcf %>%
  select(ym, date, GCF) %>%
  full_join(gcf_oos %>% select(ym, GCF_oos), by = "ym") %>%
  pivot_longer(c(GCF, GCF_oos), names_to = "type", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = type)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(GCF = "#08519c", GCF_oos = "#d94801"),
                      labels = c("In-sample GCF", "OOS GCF (expanding)"),
                      name = NULL) +
  labs(title = "Global cycle factor: in-sample vs out-of-sample",
       y = "GCF", x = NULL) +
  theme_thesis

# 12b. In-sample vs OOS FXGCF
plots$fxgcf_oos_vs_in <- fxgcf %>%
  select(ym, date, FXGCF) %>%
  full_join(fxgcf_oos %>% select(ym, FXGCF_oos), by = "ym") %>%
  pivot_longer(c(FXGCF, FXGCF_oos), names_to = "type", values_to = "value") %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = type)) +
  geom_line(linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c(FXGCF = "#08519c", FXGCF_oos = "#a50f15"),
                      labels = c("In-sample FXGCF", "OOS FXGCF (recursive δ)"),
                      name = NULL) +
  labs(title = "FX-Global cycle factor: in-sample vs out-of-sample",
       y = "FXGCF", x = NULL) +
  theme_thesis

# 12c. All three OOS factors on one panel
plots$oos_factors_combined <- bind_rows(
  local_cf_oos %>%
    filter(country == "US") %>%
    transmute(date, factor = "CF_oos (US)", value = CF_oos),
  gcf_oos   %>% transmute(date, factor = "GCF_oos",   value = GCF_oos),
  fxgcf_oos %>% transmute(date, factor = "FXGCF_oos", value = FXGCF_oos)
) %>%
  filter(!is.na(value)) %>%
  ggplot(aes(date, value, colour = factor)) +
  geom_line(linewidth = 0.45) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  scale_colour_manual(values = c("CF_oos (US)" = "#08519c",
                                 "GCF_oos"     = "#4dac26",
                                 "FXGCF_oos"   = "#a50f15"),
                      name = NULL) +
  labs(title = "Out-of-sample factor time series",
       subtitle = "All three factors use only information available at t-1",
       y = "Factor value", x = NULL) +
  theme_thesis

# 12d. OOS R² across specs and countries
plots$oos_R2_compare <- oos_R2_tab %>%
  filter(!is.na(R2_oos)) %>%
  mutate(spec = factor(spec,
                       levels = c("rx ~ CF_oos",
                                  "rx ~ GCF_oos",
                                  "rx_USD ~ GCF_oos",
                                  "rx_USD ~ FXGCF_oos"))) %>%
  ggplot(aes(country, R2_oos, fill = spec)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = 0, colour = "grey40") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set2", name = NULL) +
  labs(title = "Out-of-sample R² (Campbell-Thompson) per country and spec",
       subtitle = "Negative values indicate the factor underperforms the recursive mean",
       x = NULL, y = "OOS R²") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 12e. Clark-West t-stat distribution across countries (OOS factors)
plots$cw_oos_tstat <- bind_rows(
  cw_local_oos %>% transmute(country, test = "Local rx", t = cw_t,
                             p_one_sided = cw_p_one_sided),
  cw_usd_oos   %>% transmute(country, test = "USD rx",   t = cw_t,
                             p_one_sided = cw_p_one_sided)
) %>%
  ggplot(aes(country, t, fill = test)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  geom_hline(yintercept = c(1.282, 1.645, 2.326),
             linetype = c("dotted", "dashed", "dotdash"),
             colour = "grey40") +
  scale_fill_manual(values = c("Local rx" = "#08519c",
                               "USD rx"   = "#a50f15"),
                    name = NULL) +
  labs(title = "Clark-West statistic with OOS factors",
       subtitle = "GCF_oos vs CF_oos + GCF_oos. Lines: 10%/5%/1% one-sided crit.",
       x = NULL, y = "CW t-stat") +
  theme_thesis +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================
# Convenience: write every plot to disk
# =============================================================
save_all_plots <- function(dir = "plots", width = 10, height = 7) {
  dir.create(dir, showWarnings = FALSE)
  iwalk(plots, function(p, nm) {
    ggsave(file.path(dir, paste0(nm, ".pdf")), p,
           width = width, height = height)
  })
  invisible(file.path(dir, paste0(names(plots), ".pdf")))
}

cat(sprintf(
  "\nplots.R loaded: %d plots in `plots`. Print one with print(plots$<name>); save all with save_all_plots().\n",
  length(plots)
))
