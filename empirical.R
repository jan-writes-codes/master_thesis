# empirical
# Expanding window: for each t, estimate eq(4) on data up to t,
# then predict CF at t+1

library(lmtest)
library(sandwich)

min_window <- 120   
# @Todo window size

local_cf_oos <- reg_data %>%
  filter(country == "DE") %>%
  arrange(date) %>%
  mutate(CF_oos = NA_real_)

for (t in min_window:(nrow(local_cf_oos) - 1)) {
  train <- local_cf_oos[1:t, ]
  fit   <- lm(rx ~ cycle_1y + c_bar, data = train, na.action = na.exclude)
  local_cf_oos$CF_oos[t + 1] <- predict(fit, newdata = local_cf_oos[t + 1, ])
}

# Now test eq (18) out-of-sample
fit_oos <- lm(rx ~ CF_oos, data = local_cf_oos %>% filter(!is.na(CF_oos), !is.na(rx)))
# @Todo what makes this different to 
coeftest(fit_oos, vcov = NeweyWest(fit_oos, lag = 18, prewhite = FALSE))
coeftest(fit_oos, vcov = NeweyWest(fit_oos, prewhite = FALSE))
summary(fit_oos)

# Extract residuals from the OOS regression
resid_oos <- residuals(fit_oos)

# ACF plot
acf(resid_oos, lag.max = 100, na.action = na.omit,
    main = "Residual Autocorrelation — US OOS Predictability Regression",
    xlab = "Lag (months)", ylab = "ACF")



# =============================================================
# Regressions: international Cieslak-Povala (2015) framework
# Tackles equations (18)-(23) and the two research subquestions:
#   1. Role of local CF vs GDP-weighted global CF
#   2. Does the global CF subsume local CF?
# Plus: does FXGCF improve on GCF for USD-investor returns?
#
# Assumes data_preperation.R has been sourced and the following
# objects exist:
#   local_cf : country panel with rx, CF, cycle_1y, c_bar
#   rx_avg   : country panel with rx, rx_USD
#   gcf      : time series with GCF
#   fxgcf    : time series with FXGCF
# =============================================================

library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(sandwich)   # NeweyWest, vcovHAC
library(lmtest)     # coeftest, waldtest
library(plm)        # panel models
library(boot)       # block bootstrap

# -------------------------------------------------------------
# 0. Build the master regression panel
# -------------------------------------------------------------
# rx and rx_USD: 12m-ahead returns indexed at t (already constructed
# as forward-looking in data_preperation.R, so no further lead needed).
# CF, GCF, FXGCF: factors known at t.

panel <- local_cf %>%
  select(country, ym, date, CF) %>%
  left_join(rx_avg  %>% select(country, ym, rx, rx_USD), by = c("country","ym")) %>%
  left_join(gcf     %>% select(ym, GCF),                  by = "ym") %>%
  left_join(fxgcf   %>% select(ym, FXGCF),                by = "ym") %>%
  arrange(country, date) %>%
  filter(!is.na(rx), !is.na(CF), !is.na(GCF), !is.na(FXGCF))

# Newey-West lag: Lazarus-Lewis-Stock-Watson (2018) recommend
# lag = 1.3*T^(1/2) for general cases; for h-period overlapping returns
# the floor is 1.5*h. With h=12 -> 18. Take max as a conservative choice.
nw_lag_for <- function(T_obs, h = 12) {
  max(ceiling(1.5 * h), ceiling(1.3 * sqrt(T_obs)))
}

# Helper: country-level OLS with Newey-West HAC SEs
run_country_lm <- function(df, formula) {
  fit  <- lm(formula, data = df)
  T_o  <- nobs(fit)
  L    <- nw_lag_for(T_o, h = 12)
  vc   <- NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE)
  tt   <- coeftest(fit, vcov. = vc)
  list(fit = fit, vcov = vc, coeftest = tt, T_obs = T_o, lag = L)
}

# Helper: tidy country-level result into a data frame
tidy_country <- function(res, country, model_name) {
  ct <- res$coeftest
  tibble(
    country  = country,
    model    = model_name,
    term     = rownames(ct),
    estimate = ct[, "Estimate"],
    std_err  = ct[, "Std. Error"],
    t_stat   = ct[, "t value"],
    p_value  = ct[, "Pr(>|t|)"],
    T_obs    = res$T_obs,
    nw_lag   = res$lag,
    r_sq     = summary(res$fit)$r.squared,
    adj_r_sq = summary(res$fit)$adj.r.squared
  )
}

# -------------------------------------------------------------
# 1. Eq (18): Local factor predictability per country
#    rx_{i,t+12} = alpha_i + beta_i * CF_{i,t} + eps
# -------------------------------------------------------------
res_18 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx ~ CF))

tab_18 <- imap_dfr(res_18, ~ tidy_country(.x, .y, "eq18_rx_on_CF"))

# -------------------------------------------------------------
# 2. Eq (19): Local + global side by side, country-by-country
#    rx_{i,t+12} = alpha_i + beta_i*CF_{i,t} + gamma_i*GCF_t + eps
# -------------------------------------------------------------
res_19 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx ~ CF + GCF))

tab_19 <- imap_dfr(res_19, ~ tidy_country(.x, .y, "eq19_rx_on_CF_GCF"))

# -------------------------------------------------------------
# 3. Eq (20): Global only
#    rx_{i,t+12} = alpha_i + gamma_i*GCF_t + eps
# -------------------------------------------------------------
res_20 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx ~ GCF))

tab_20 <- imap_dfr(res_20, ~ tidy_country(.x, .y, "eq20_rx_on_GCF"))

# -------------------------------------------------------------
# 4. Eq (21): USD return on CF + GCF (international investor view)
# -------------------------------------------------------------
res_21 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx_USD ~ CF + GCF))

tab_21 <- imap_dfr(res_21, ~ tidy_country(.x, .y, "eq21_rxUSD_on_CF_GCF"))

# -------------------------------------------------------------
# 5. Eq (22): USD return on GCF only
# -------------------------------------------------------------
res_22 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx_USD ~ GCF))

tab_22 <- imap_dfr(res_22, ~ tidy_country(.x, .y, "eq22_rxUSD_on_GCF"))

# -------------------------------------------------------------
# 6. Eq (23): USD return on FXGCF (the new factor)
# -------------------------------------------------------------
res_23 <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap(~ run_country_lm(.x, rx_USD ~ FXGCF))

tab_23 <- imap_dfr(res_23, ~ tidy_country(.x, .y, "eq23_rxUSD_on_FXGCF"))

# -------------------------------------------------------------
# 7. Pooled panel regressions with Driscoll-Kraay SEs
#    Driscoll-Kraay (1998) handles serial correlation,
#    heteroskedasticity, AND cross-sectional dependence -- the last
#    one matters because GCF is identical across countries, so
#    residuals are cross-sectionally correlated by construction.
# -------------------------------------------------------------
pdat <- pdata.frame(panel, index = c("country", "ym"))
dk_lag <- nw_lag_for(length(unique(panel$ym)), h = 12)

panel_dk <- function(formula, data) {
  fit <- plm(formula, data = data, model = "within")
  vc  <- vcovSCC(fit, type = "HC0", maxlag = dk_lag)
  list(fit = fit, vcov = vc, coeftest = coeftest(fit, vcov. = vc))
}

panel_18 <- panel_dk(rx     ~ CF,         pdat)
panel_19 <- panel_dk(rx     ~ CF + GCF,   pdat)
panel_20 <- panel_dk(rx     ~ GCF,        pdat)
panel_21 <- panel_dk(rx_USD ~ CF + GCF,   pdat)
panel_22 <- panel_dk(rx_USD ~ GCF,        pdat)
panel_23 <- panel_dk(rx_USD ~ FXGCF,      pdat)

panel_results <- list(
  eq18 = panel_18, eq19 = panel_19, eq20 = panel_20,
  eq21 = panel_21, eq22 = panel_22, eq23 = panel_23
)

# -------------------------------------------------------------
# 8. Nested-model tests for the "does global subsume local?" question
#    H0: beta_i = 0 in eq (19) / eq (21)
#    Wald test with HAC vcov (in-sample, Driscoll-Kraay for panel).
# -------------------------------------------------------------
wald_nested <- function(big, small, vcov_big) {
  waldtest(small$fit, big$fit, vcov = vcov_big, test = "Chisq")
}

# Country-by-country: does CF add anything once GCF is in?
nested_local_per_country <- imap_dfr(res_19, function(big, cn) {
  small <- res_20[[cn]]
  w <- waldtest(small$fit, big$fit, vcov = big$vcov, test = "Chisq")
  tibble(
    country = cn,
    test    = "H0: beta_CF = 0 in eq(19)",
    chisq   = w$Chisq[2],
    df      = w$Df[2],
    p_value = w$`Pr(>Chisq)`[2]
  )
})

nested_usd_per_country <- imap_dfr(res_21, function(big, cn) {
  small <- res_22[[cn]]
  w <- waldtest(small$fit, big$fit, vcov = big$vcov, test = "Chisq")
  tibble(
    country = cn,
    test    = "H0: beta_CF = 0 in eq(21)",
    chisq   = w$Chisq[2],
    df      = w$Df[2],
    p_value = w$`Pr(>Chisq)`[2]
  )
})

# Panel-level Wald test (Driscoll-Kraay)
nested_panel <- bind_rows(
  tibble(test = "Local: H0: beta_CF=0 in eq(19) | panel",
         p_value = waldtest(panel_20$fit, panel_19$fit,
                            vcov = panel_19$vcov, test = "Chisq")$`Pr(>Chisq)`[2]),
  tibble(test = "USD:   H0: beta_CF=0 in eq(21) | panel",
         p_value = waldtest(panel_22$fit, panel_21$fit,
                            vcov = panel_21$vcov, test = "Chisq")$`Pr(>Chisq)`[2])
)

# -------------------------------------------------------------
# 9. Multiple-testing adjustment
#    With ~10 countries per spec, raw p-values overstate significance.
#    Bonferroni: conservative FWER control.
#    Benjamini-Hochberg: FDR control, recommended as the headline.
# -------------------------------------------------------------
adjust_pvals <- function(tab, term_keep) {
  tab %>%
    filter(term == term_keep) %>%
    mutate(
      p_bonferroni = p.adjust(p_value, method = "bonferroni"),
      p_bh_fdr     = p.adjust(p_value, method = "BH")
    )
}

mt_18  <- adjust_pvals(tab_18,  "CF")
mt_20  <- adjust_pvals(tab_20,  "GCF")
mt_22  <- adjust_pvals(tab_22,  "GCF")
mt_23  <- adjust_pvals(tab_23,  "FXGCF")

# -------------------------------------------------------------
# 10. Out-of-sample Clark-West tests
#     Clark & West (2007) MSPE-adjusted statistic for nested
#     forecast comparisons. Standard when comparing a small model
#     (null) with a larger model that nests it -- which is exactly
#     the structure of (19) vs (20) and (23) vs (22).
#
#     Implementation:
#       - expanding window, minimum 60 obs (5y) before first forecast
#       - one-step-ahead 12m return forecast
#       - CW-adjusted t-stat against H0: nested model is true DGP
# -------------------------------------------------------------
cw_test <- function(df, f_small, f_large, min_train = 60) {
  df <- df %>% arrange(ym)
  T_obs <- nrow(df)
  if (T_obs <= min_train + 12) return(NULL)
  
  fhat_small <- rep(NA_real_, T_obs)
  fhat_large <- rep(NA_real_, T_obs)
  y_actual   <- df$rx
  if ("rx_USD" %in% all.vars(f_small)) y_actual <- df$rx_USD
  
  for (t in (min_train + 1):T_obs) {
    train <- df[1:(t - 1), ]
    m_s <- lm(f_small, data = train)
    m_l <- lm(f_large, data = train)
    fhat_small[t] <- predict(m_s, newdata = df[t, ])
    fhat_large[t] <- predict(m_l, newdata = df[t, ])
  }
  
  e_s <- (y_actual - fhat_small)^2
  e_l <- (y_actual - fhat_large)^2
  adj <- (fhat_small - fhat_large)^2
  f_stat <- e_s - e_l + adj   # Clark-West adjustment
  
  f_stat <- f_stat[!is.na(f_stat)]
  if (length(f_stat) < 30) return(NULL)
  
  # Newey-West variance for the CW statistic
  L <- nw_lag_for(length(f_stat), h = 12)
  m <- lm(f_stat ~ 1)
  vc <- NeweyWest(m, lag = L, prewhite = FALSE, adjust = TRUE)
  ct <- coeftest(m, vcov. = vc)
  
  tibble(
    cw_mean = ct[1, "Estimate"],
    cw_se   = ct[1, "Std. Error"],
    cw_t    = ct[1, "t value"],
    # one-sided p-value: H0: nested true, H1: large model better
    cw_p_one_sided = pnorm(ct[1, "t value"], lower.tail = FALSE),
    n_forecasts    = length(f_stat)
  )
}

cw_local <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    out <- cw_test(df, rx ~ GCF, rx ~ CF + GCF)
    if (is.null(out)) return(NULL)
    out %>% mutate(country = cn,
                   test = "Local: GCF vs CF+GCF (eq19 nests eq20)")
  })

cw_usd <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    out <- cw_test(df, rx_USD ~ GCF, rx_USD ~ CF + GCF)
    if (is.null(out)) return(NULL)
    out %>% mutate(country = cn,
                   test = "USD: GCF vs CF+GCF (eq21 nests eq22)")
  })

cw_fxgcf <- panel %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    # FXGCF vs GCF: not nested in the strict sense (same dim),
    # but FXGCF is an affine transform of GCF -> identical fit.
    # So CW is degenerate here. We instead compare GCF-only (eq22)
    # with FXGCF-only (eq23) via Diebold-Mariano on out-of-sample MSPE.
    df <- df %>% arrange(ym)
    T_obs <- nrow(df); min_train <- 60
    if (T_obs <= min_train + 12) return(NULL)
    fA <- fB <- rep(NA_real_, T_obs)
    for (t in (min_train + 1):T_obs) {
      train <- df[1:(t - 1), ]
      mA <- lm(rx_USD ~ GCF,   data = train)
      mB <- lm(rx_USD ~ FXGCF, data = train)
      fA[t] <- predict(mA, newdata = df[t, ])
      fB[t] <- predict(mB, newdata = df[t, ])
    }
    eA <- (df$rx_USD - fA)^2
    eB <- (df$rx_USD - fB)^2
    d  <- na.omit(eA - eB)
    if (length(d) < 30) return(NULL)
    L  <- nw_lag_for(length(d), h = 12)
    m  <- lm(d ~ 1)
    vc <- NeweyWest(m, lag = L, prewhite = FALSE, adjust = TRUE)
    ct <- coeftest(m, vcov. = vc)
    tibble(country = cn,
           test = "USD: GCF vs FXGCF (Diebold-Mariano)",
           dm_mean = ct[1,1], dm_se = ct[1,2], dm_t = ct[1,3],
           # two-sided: neither is nested
           dm_p_two_sided = 2 * pnorm(-abs(ct[1,3])),
           n_forecasts = length(d))
  })

# -------------------------------------------------------------
# 11. Print a tidy summary
# -------------------------------------------------------------
cat("\n====== Eq (18): rx ~ CF (per country) ======\n")
print(tab_18 %>% filter(term == "CF") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq, T_obs))

cat("\n====== Eq (20): rx ~ GCF (per country) ======\n")
print(tab_20 %>% filter(term == "GCF") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq, T_obs))

cat("\n====== Eq (19): rx ~ CF + GCF (per country) ======\n")
print(tab_19 %>% filter(term %in% c("CF","GCF")) %>%
        select(country, term, estimate, std_err, t_stat, p_value, r_sq))

cat("\n====== Eq (22): rx_USD ~ GCF (per country) ======\n")
print(tab_22 %>% filter(term == "GCF") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq))

cat("\n====== Eq (23): rx_USD ~ FXGCF (per country) ======\n")
print(tab_23 %>% filter(term == "FXGCF") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq))

cat("\n====== Panel (Driscoll-Kraay): all 6 specs ======\n")
for (nm in names(panel_results)) {
  cat("\n--", nm, "--\n")
  print(panel_results[[nm]]$coeftest)
}

cat("\n====== Nested test: does CF add to GCF? (Wald, NW) ======\n")
print(nested_local_per_country)
print(nested_usd_per_country)
print(nested_panel)

cat("\n====== Multiple-testing adjustment (BH-FDR) ======\n")
print(mt_18  %>% select(country, estimate, p_value, p_bonferroni, p_bh_fdr))
print(mt_20  %>% select(country, estimate, p_value, p_bonferroni, p_bh_fdr))
print(mt_22  %>% select(country, estimate, p_value, p_bonferroni, p_bh_fdr))
print(mt_23  %>% select(country, estimate, p_value, p_bonferroni, p_bh_fdr))

cat("\n====== Out-of-sample Clark-West ======\n")
print(cw_local)
print(cw_usd)
cat("\n====== Out-of-sample Diebold-Mariano: GCF vs FXGCF ======\n")
print(cw_fxgcf)

