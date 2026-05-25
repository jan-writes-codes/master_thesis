# empirical
# =============================================================
# Out-of-sample CF (eq 4-6) for ALL countries via expanding window.
# At each t, eq (4) is re-fit on the training sample 1..t and used
# to predict CF at t+1 -- removing the in-sample lookahead that the
# panel-wide `local_cf` carries by construction.
# =============================================================

library(lmtest)
library(sandwich)
library(dplyr)
library(tidyr)
library(purrr)
library(broom)
library(plm)


# CP 2015 replication -----------------------------------------------------
# Test for local CF (US): 2
us_data <- reg_data %>%
  filter(country == "US") %>%
  filter(date <= "2014/12/31")

fit_us <- lm(rx_2_t12 ~ I(CF-y_1), data = us_data)
summary(fit_us)

# Table 1
# T1.A # @Todo: all maturities AND R2
cycle %>% filter(country == "US", maturity == 10)

# T1.B
cor(us_data %>% select(cycle_1y, cycle_2y, cycle_4y, cycle_5y, cycle_9y, cycle_10y, c_bar))

# Figure 2 (corr = 0.61)
cor(us_data %>% select(c_bar, CF))

# DH 2013 replication -----------------------------------------------------
# Table 1


# Table 2


# Table 3
cor(fxgcf %>% left_join(reg_data %>% filter(country==" ")) %>% filter(!is.na(CF)) %>%select(CF, GCF))

# Table 6

# Table 7
summary(lm(rx_2_USD_t12 ~ GCF, reg_data %>% filter(country == "SE")))
summary(lm(rx_2_USD_t12 ~ FXGCF, reg_data %>% filter(country == "SE"))) # currently FXGCF is just linear to GCF


# Previous code -------------------------------------------------------------

min_train <- 120   # 10 years of monthly observations

# Generic 1-step-ahead expanding-window OLS predictor.
oos_predict <- function(df, formula, min_train = 120) {
  df    <- df %>% arrange(ym)
  T_obs <- nrow(df)
  yhat  <- rep(NA_real_, T_obs)
  if (T_obs <= min_train) return(yhat)
  for (t in min_train:(T_obs - 1)) {
    train <- df[1:t, , drop = FALSE]
    fit   <- lm(formula, data = train, na.action = na.exclude)
    yhat[t + 1] <- as.numeric(predict(fit, newdata = df[t + 1, , drop = FALSE]))
  }
  yhat
}

local_cf_oos <- reg_data %>%
  group_by(country) %>%
  arrange(ym, .by_group = TRUE) %>%
  group_modify(~ .x %>% mutate(
    CF_oos = oos_predict(.x, rx ~ cycle_1y + c_bar, min_train)
  )) %>%
  ungroup()

# Sanity check: US OOS regression + residual ACF
us_oos <- local_cf_oos %>% filter(country == "US", !is.na(CF_oos), !is.na(rx))
fit_us_oos <- lm(rx ~ CF_oos, data = us_oos)
cat("\n====== US: rx ~ CF_oos (Newey-West, 12m overlap) ======\n")
print(coeftest(fit_us_oos, vcov = NeweyWest(fit_us_oos, lag = 18, prewhite = FALSE)))

acf(residuals(fit_us_oos), lag.max = 100, na.action = na.omit,
    main = "US: rx ~ CF_oos -- residual ACF",
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
  left_join(rx_avg    %>% select(country, ym, rx, rx_USD),       by = c("country","ym")) %>%
  left_join(gcf       %>% select(ym, GCF),                       by = "ym") %>%
  left_join(fxgcf     %>% select(ym, FXGCF),                     by = "ym") %>%
  left_join(cp_factor %>% select(country, ym, y_1, f_2, f_5, f_10, CP),
                                                                  by = c("country","ym")) %>%
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
# 10b. US replication: Cieslak-Povala (2015) vs. Cochrane-Piazzesi (2005)
#      In-sample and out-of-sample R^2; subsumption tests in the
#      encompassing regression rx ~ cycle_1y + c_bar + y_1 + f_2 + f_5 + f_10.
# -------------------------------------------------------------
us_data <- reg_data %>%
  filter(country == "US") %>%
  left_join(cp_factor %>% select(country, ym, y_1, f_2, f_5, f_10),
            by = c("country", "ym")) %>%
  filter(!is.na(rx), !is.na(cycle_1y), !is.na(c_bar),
         !is.na(y_1), !is.na(f_2), !is.na(f_5), !is.na(f_10)) %>%
  arrange(ym)

# In-sample fits (HAC SEs, NW lag = 18 for 12m overlapping returns)
nw_us <- function(m) NeweyWest(m, lag = 18, prewhite = FALSE)

m_cf  <- lm(rx ~ cycle_1y + c_bar,                                data = us_data)
m_cp  <- lm(rx ~ y_1 + f_2 + f_5 + f_10,                          data = us_data)
m_enc <- lm(rx ~ cycle_1y + c_bar + y_1 + f_2 + f_5 + f_10,       data = us_data)

cat("\n====== US in-sample: CP-2015 (CF = cycle_1y + c_bar) ======\n")
print(coeftest(m_cf,  nw_us(m_cf)))
cat("\n====== US in-sample: CP-2005 (y_1 + 1y forwards) ======\n")
print(coeftest(m_cp,  nw_us(m_cp)))
cat("\n====== US in-sample: encompassing (CF + forwards) ======\n")
print(coeftest(m_enc, nw_us(m_enc)))

cat("\n-- Wald: do CP-2005 forwards add to CF? (H0: y_1=f_2=f_5=f_10=0) --\n")
print(waldtest(m_cf, m_enc, vcov = nw_us(m_enc), test = "Chisq"))
cat("\n-- Wald: does CF add to CP-2005? (H0: cycle_1y=c_bar=0) --\n")
print(waldtest(m_cp, m_enc, vcov = nw_us(m_enc), test = "Chisq"))

# Out-of-sample R^2 (Campbell-Thompson 2008): benchmark = recursive mean
oos_R2 <- function(df, formula, min_train = 120) {
  df    <- df %>% arrange(ym)
  T_obs <- nrow(df)
  y     <- df$rx
  yhat  <- rep(NA_real_, T_obs)
  bench <- rep(NA_real_, T_obs)
  if (T_obs <= min_train + 1) return(NA_real_)
  for (t in min_train:(T_obs - 1)) {
    train <- df[1:t, , drop = FALSE]
    fit   <- lm(formula, data = train, na.action = na.exclude)
    yhat[t + 1]  <- as.numeric(predict(fit, newdata = df[t + 1, , drop = FALSE]))
    bench[t + 1] <- mean(train$rx, na.rm = TRUE)
  }
  ok <- !is.na(yhat) & !is.na(y) & !is.na(bench)
  if (!any(ok)) return(NA_real_)
  1 - sum((y[ok] - yhat[ok])^2) / sum((y[ok] - bench[ok])^2)
}

# Diebold-Mariano on squared OOS forecast errors (CF vs CP-2005)
oos_forecasts <- function(df, formula, min_train = 120) {
  df    <- df %>% arrange(ym)
  T_obs <- nrow(df)
  yhat  <- rep(NA_real_, T_obs)
  if (T_obs <= min_train + 1) return(yhat)
  for (t in min_train:(T_obs - 1)) {
    train <- df[1:t, , drop = FALSE]
    fit   <- lm(formula, data = train, na.action = na.exclude)
    yhat[t + 1] <- as.numeric(predict(fit, newdata = df[t + 1, , drop = FALSE]))
  }
  yhat
}

f_cf_oos  <- oos_forecasts(us_data, rx ~ cycle_1y + c_bar,                          min_train)
f_cp_oos  <- oos_forecasts(us_data, rx ~ y_1 + f_2 + f_5 + f_10,                    min_train)
f_enc_oos <- oos_forecasts(us_data, rx ~ cycle_1y + c_bar + y_1 + f_2 + f_5 + f_10, min_train)

us_R2_tab <- tibble(
  model = c("CP-2015 (CF)", "CP-2005 (forwards)", "Encompassing"),
  R2_in  = c(summary(m_cf)$r.squared,
             summary(m_cp)$r.squared,
             summary(m_enc)$r.squared),
  R2_oos = c(oos_R2(us_data, rx ~ cycle_1y + c_bar),
             oos_R2(us_data, rx ~ y_1 + f_2 + f_5 + f_10),
             oos_R2(us_data, rx ~ cycle_1y + c_bar + y_1 + f_2 + f_5 + f_10))
)
cat("\n====== US: in-sample vs OOS R^2 ======\n")
print(us_R2_tab)

# DM test: CF vs CP-2005 squared-error loss differential
d_us  <- (us_data$rx - f_cf_oos)^2 - (us_data$rx - f_cp_oos)^2
d_us  <- d_us[!is.na(d_us)]
if (length(d_us) >= 30) {
  L_dm <- max(ceiling(1.5 * 12), ceiling(1.3 * sqrt(length(d_us))))
  m_dm <- lm(d_us ~ 1)
  vc   <- NeweyWest(m_dm, lag = L_dm, prewhite = FALSE, adjust = TRUE)
  ct   <- coeftest(m_dm, vcov. = vc)
  cat("\n====== US Diebold-Mariano: CF vs CP-2005 (negative => CF better) ======\n")
  print(ct)
  cat(sprintf("two-sided p = %.4f, n_forecasts = %d\n",
              2 * pnorm(-abs(ct[1, "t value"])), length(d_us)))
}

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


# =============================================================
# 12. Fully out-of-sample factor versions
# -------------------------------------------------------------
# `local_cf_oos$CF_oos` already implements expanding-window OOS
# eq (4). We extend the OOS chain:
#   GCF_oos_t   = sum_i w_{i,t} * CF_oos_{i,t}      (eq 7 with OOS CF)
#   FXGCF_oos_t = δ̂_0(1..t-1) + δ̂_1(1..t-1)*GCF_oos_t   (eq 17, recursive δ)
# All three factors at time t therefore use information available
# at most through t-1.
#
# Tests on the OOS factors:
#   - Campbell-Thompson OOS R² (recursive-mean benchmark) per country
#   - Clark-West: GCF_oos vs CF_oos+GCF_oos for rx and rx_USD
#   - Diebold-Mariano: GCF_oos vs FXGCF_oos for rx_USD (same dim)
# =============================================================

# 12a. OOS GCF: GDP-weighted sum of CF_oos
gcf_oos <- local_cf_oos %>%
  mutate(y = as.integer(format(date, "%Y"))) %>%
  left_join(gdp %>% select(y, country, gdp_val),
            by = c("y", "country")) %>%
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val[!is.na(CF_oos)], na.rm = TRUE),
    w_oos     = ifelse(is.na(CF_oos), NA_real_, gdp_val / gdp_total)
  ) %>%
  group_by(ym, date) %>%
  summarise(
    GCF_oos     = sum(w_oos * CF_oos, na.rm = TRUE),
    n_countries = sum(!is.na(CF_oos) & !is.na(w_oos)),
    .groups     = "drop"
  ) %>%
  mutate(GCF_oos = ifelse(n_countries == 0, NA_real_, GCF_oos)) %>%
  arrange(date)

# 12b. OOS FXGCF: recursive δ̂ on rx_USD_bar ~ GCF_oos
fxgcf_oos_data <- gcf_oos %>%
  select(ym, date, GCF_oos) %>%
  left_join(rx_usd_bar %>% select(ym, rx_USD_bar), by = "ym") %>%
  arrange(ym) %>%
  mutate(FXGCF_oos = NA_real_)

min_train_fx <- 60
for (t in seq_len(nrow(fxgcf_oos_data))) {
  if (t <= min_train_fx) next
  train <- fxgcf_oos_data[1:(t - 1), ] %>%
    filter(!is.na(rx_USD_bar), !is.na(GCF_oos))
  if (nrow(train) < min_train_fx) next
  fit <- lm(rx_USD_bar ~ GCF_oos, data = train)
  if (!is.na(fxgcf_oos_data$GCF_oos[t])) {
    fxgcf_oos_data$FXGCF_oos[t] <-
      as.numeric(predict(fit, newdata = fxgcf_oos_data[t, ]))
  }
}

fxgcf_oos <- fxgcf_oos_data %>% select(ym, date, GCF_oos, FXGCF_oos)

# 12c. OOS panel for tests
panel_oos <- local_cf_oos %>%
  select(country, ym, date, CF_oos) %>%
  left_join(rx_avg    %>% select(country, ym, rx, rx_USD), by = c("country","ym")) %>%
  left_join(gcf_oos   %>% select(ym, GCF_oos),             by = "ym") %>%
  left_join(fxgcf_oos %>% select(ym, FXGCF_oos),           by = "ym") %>%
  arrange(country, date)

# 12d. Campbell-Thompson OOS R² for the 4 headline specs.
# Forecast at t uses β̂(1..t-1) * factor_t (factor itself is OOS).
oos_R2_factor <- function(df, target, predictor, min_train = 120) {
  df <- df %>% arrange(ym)
  df <- df[!is.na(df[[predictor]]), , drop = FALSE]
  T_obs <- nrow(df)
  if (T_obs <= min_train + 1) return(c(R2 = NA_real_, n_fcst = 0L))
  y     <- df[[target]]
  x     <- df[[predictor]]
  yhat  <- rep(NA_real_, T_obs)
  bench <- rep(NA_real_, T_obs)
  for (t in min_train:(T_obs - 1)) {
    train <- df[1:t, , drop = FALSE]
    if (sum(!is.na(train[[target]]) & !is.na(train[[predictor]])) < 30) next
    fit <- lm(as.formula(sprintf("%s ~ %s", target, predictor)),
              data = train, na.action = na.exclude)
    yhat[t + 1]  <- as.numeric(predict(fit, newdata = df[t + 1, , drop = FALSE]))
    bench[t + 1] <- mean(train[[target]], na.rm = TRUE)
  }
  ok <- !is.na(yhat) & !is.na(y) & !is.na(bench)
  if (!any(ok)) return(c(R2 = NA_real_, n_fcst = 0L))
  c(R2 = 1 - sum((y[ok] - yhat[ok])^2) / sum((y[ok] - bench[ok])^2),
    n_fcst = sum(ok))
}

ct_specs <- list(
  list(label = "rx ~ CF_oos",         target = "rx",     predictor = "CF_oos"),
  list(label = "rx ~ GCF_oos",        target = "rx",     predictor = "GCF_oos"),
  list(label = "rx_USD ~ GCF_oos",    target = "rx_USD", predictor = "GCF_oos"),
  list(label = "rx_USD ~ FXGCF_oos",  target = "rx_USD", predictor = "FXGCF_oos")
)

oos_R2_tab <- panel_oos %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    map_dfr(ct_specs, function(s) {
      r <- oos_R2_factor(df %>% filter(!is.na(.data[[s$target]])),
                         s$target, s$predictor)
      tibble(country = cn, spec = s$label,
             R2_oos  = unname(r["R2"]),
             n_fcst  = as.integer(unname(r["n_fcst"])))
    })
  })

# 12e. Clark-West with OOS factors
cw_oos_test <- function(df, target, small_pred, large_pred, min_train = 60) {
  df <- df %>%
    arrange(ym) %>%
    filter(!is.na(.data[[target]]),
           !is.na(.data[[small_pred]]),
           !is.na(.data[[large_pred]]))
  T_obs <- nrow(df)
  if (T_obs <= min_train + 12) return(NULL)
  y <- df[[target]]
  fhat_s <- rep(NA_real_, T_obs)
  fhat_l <- rep(NA_real_, T_obs)
  for (t in (min_train + 1):T_obs) {
    train <- df[1:(t - 1), ]
    m_s <- lm(as.formula(sprintf("%s ~ %s", target, small_pred)), data = train)
    m_l <- lm(as.formula(sprintf("%s ~ %s + %s", target, small_pred, large_pred)),
              data = train)
    fhat_s[t] <- as.numeric(predict(m_s, newdata = df[t, ]))
    fhat_l[t] <- as.numeric(predict(m_l, newdata = df[t, ]))
  }
  e_s <- (y - fhat_s)^2
  e_l <- (y - fhat_l)^2
  adj <- (fhat_s - fhat_l)^2
  f_stat <- e_s - e_l + adj
  f_stat <- f_stat[!is.na(f_stat)]
  if (length(f_stat) < 30) return(NULL)
  L  <- nw_lag_for(length(f_stat), h = 12)
  m  <- lm(f_stat ~ 1)
  vc <- NeweyWest(m, lag = L, prewhite = FALSE, adjust = TRUE)
  ct <- coeftest(m, vcov. = vc)
  tibble(
    cw_mean        = ct[1, "Estimate"],
    cw_se          = ct[1, "Std. Error"],
    cw_t           = ct[1, "t value"],
    cw_p_one_sided = pnorm(ct[1, "t value"], lower.tail = FALSE),
    n_forecasts    = length(f_stat)
  )
}

cw_local_oos <- panel_oos %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    out <- cw_oos_test(df, "rx", "GCF_oos", "CF_oos")
    if (is.null(out)) return(NULL)
    out %>% mutate(country = cn,
                   test = "Local OOS: GCF_oos vs CF_oos+GCF_oos")
  })

cw_usd_oos <- panel_oos %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    out <- cw_oos_test(df, "rx_USD", "GCF_oos", "CF_oos")
    if (is.null(out)) return(NULL)
    out %>% mutate(country = cn,
                   test = "USD OOS: GCF_oos vs CF_oos+GCF_oos")
  })

# 12f. Diebold-Mariano: GCF_oos vs FXGCF_oos for rx_USD
# Use a local min_train of 60 (matches the in-sample cw_fxgcf variant).
# The fully-OOS chain already eats the first ~15 years of the sample
# building CF_oos, GCF_oos and FXGCF_oos, so the global min_train = 120
# leaves no rows behind once panel_oos is filtered for non-NA factors.
dm_fxgcf_oos <- panel_oos %>%
  group_by(country) %>%
  group_split() %>%
  set_names(map_chr(., ~ unique(.x$country))) %>%
  imap_dfr(function(df, cn) {
    df <- df %>%
      arrange(ym) %>%
      filter(!is.na(rx_USD), !is.na(GCF_oos), !is.na(FXGCF_oos))
    T_obs <- nrow(df)
    min_train_dm <- 60
    if (T_obs <= min_train_dm + 12) {
      message(sprintf("dm_fxgcf_oos: skipping %s (T_obs = %d <= %d)",
                      cn, T_obs, min_train_dm + 12))
      return(NULL)
    }
    fA <- fB <- rep(NA_real_, T_obs)
    for (t in (min_train_dm + 1):T_obs) {
      train <- df[1:(t - 1), ]
      mA <- lm(rx_USD ~ GCF_oos,   data = train)
      mB <- lm(rx_USD ~ FXGCF_oos, data = train)
      fA[t] <- as.numeric(predict(mA, newdata = df[t, ]))
      fB[t] <- as.numeric(predict(mB, newdata = df[t, ]))
    }
    eA <- (df$rx_USD - fA)^2
    eB <- (df$rx_USD - fB)^2
    d  <- na.omit(eA - eB)
    if (length(d) < 30) {
      message(sprintf("dm_fxgcf_oos: skipping %s (n_forecasts = %d < 30)",
                      cn, length(d)))
      return(NULL)
    }
    L  <- nw_lag_for(length(d), h = 12)
    m  <- lm(d ~ 1)
    vc <- NeweyWest(m, lag = L, prewhite = FALSE, adjust = TRUE)
    ct <- coeftest(m, vcov. = vc)
    tibble(country = cn,
           test = "USD OOS: GCF_oos vs FXGCF_oos (DM)",
           dm_mean = ct[1, 1], dm_se = ct[1, 2], dm_t = ct[1, 3],
           dm_p_two_sided = 2 * pnorm(-abs(ct[1, 3])),
           n_forecasts = length(d))
  })

cat("\n====== OOS R² (Campbell-Thompson, recursive-mean benchmark) ======\n")
print(oos_R2_tab %>%
        pivot_wider(id_cols = country,
                    names_from = spec, values_from = R2_oos))

cat("\n====== Clark-West with OOS factors ======\n")
print(cw_local_oos)
print(cw_usd_oos)

cat("\n====== Diebold-Mariano with OOS factors: GCF_oos vs FXGCF_oos ======\n")
print(dm_fxgcf_oos)


# =============================================================
# 13. Per-country regressions on the OOS factors
# -------------------------------------------------------------
# Mirrors the in-sample tables for eq (18), (20), (19), (22), (23)
# but replaces CF / GCF / FXGCF with their fully-OOS counterparts.
# Uses the same HAC machinery (run_country_lm / tidy_country) so
# the output schemas match tab_18 .. tab_23 exactly.
# =============================================================

panel_oos_clean <- panel_oos %>%
  filter(!is.na(rx),  !is.na(CF_oos), !is.na(GCF_oos), !is.na(FXGCF_oos))
panel_oos_usd <- panel_oos_clean %>% filter(!is.na(rx_USD))

run_oos_country <- function(panel, formula) {
  panel %>%
    group_by(country) %>%
    group_split() %>%
    set_names(map_chr(., ~ unique(.x$country))) %>%
    imap(~ if (nrow(.x) >= 30) run_country_lm(.x, formula) else NULL)
}

tidy_or_null <- function(res, country, model) {
  if (is.null(res)) return(NULL)
  tidy_country(res, country, model)
}

res_18_oos <- run_oos_country(panel_oos_clean, rx     ~ CF_oos)
res_20_oos <- run_oos_country(panel_oos_clean, rx     ~ GCF_oos)
res_19_oos <- run_oos_country(panel_oos_clean, rx     ~ CF_oos + GCF_oos)
res_22_oos <- run_oos_country(panel_oos_usd,   rx_USD ~ GCF_oos)
res_23_oos <- run_oos_country(panel_oos_usd,   rx_USD ~ FXGCF_oos)

tab_18_oos <- imap_dfr(res_18_oos, ~ tidy_or_null(.x, .y, "eq18_oos"))
tab_20_oos <- imap_dfr(res_20_oos, ~ tidy_or_null(.x, .y, "eq20_oos"))
tab_19_oos <- imap_dfr(res_19_oos, ~ tidy_or_null(.x, .y, "eq19_oos"))
tab_22_oos <- imap_dfr(res_22_oos, ~ tidy_or_null(.x, .y, "eq22_oos"))
tab_23_oos <- imap_dfr(res_23_oos, ~ tidy_or_null(.x, .y, "eq23_oos"))

# Nested Wald for the OOS subsumption test
nested_local_oos_per_country <- imap_dfr(res_19_oos, function(big, cn) {
  small <- res_20_oos[[cn]]
  if (is.null(big) || is.null(small)) return(NULL)
  w <- waldtest(small$fit, big$fit, vcov = big$vcov, test = "Chisq")
  tibble(
    country = cn,
    test    = "H0: beta_CF_oos = 0 in eq(19)_oos",
    chisq   = w$Chisq[2],
    df      = w$Df[2],
    p_value = w$`Pr(>Chisq)`[2]
  )
})

cat("\n====== OOS per-country regressions (eq 18, 20, 19, 22, 23 with OOS factors) ======\n")
print(tab_18_oos %>% filter(term == "CF_oos") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq, T_obs))
print(tab_20_oos %>% filter(term == "GCF_oos") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq, T_obs))
print(nested_local_oos_per_country)
print(tab_22_oos %>% filter(term == "GCF_oos") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq))
print(tab_23_oos %>% filter(term == "FXGCF_oos") %>%
        select(country, estimate, std_err, t_stat, p_value, r_sq))
