library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)

# @todo add namesspace in front of every function
# @todo check BE inflation data, seems to be offset in the excel

# FXGCF construction selector (see the FXGCF block below). The thesis baseline
# is the top-down GDP-weighted factor ("td_gdp"); the FXGCF_METHOD environment
# variable lets the whole exhibit pipeline be regenerated under an alternative
# construction without editing code. Unset / "td_gdp" reproduces the baseline.
#   td_gdp : top-down, GDP-weighted   (baseline / default)
#   td_eq  : top-down, 1/n-weighted
#   bu_gdp : bottom-up (GDP-weighted aggregate of the local USD cycle factors)
.FXGCF_METHOD <- local({
  m <- Sys.getenv("FXGCF_METHOD", "td_gdp")
  if (identical(m, "")) m <- "td_gdp"
  if (!m %in% c("td_gdp", "td_eq", "bu_gdp"))
    stop("FXGCF_METHOD must be one of td_gdp, td_eq, bu_gdp (got '", m, "')")
  m
})

# File path for the data
file_path <- "data.xlsx"

# Curve map
curve_map <- read_excel(file_path, sheet = "curve_translation") %>%
  dplyr::mutate(indicator = trimws(indicator))   # remove any stray whitespace

# FX (EOM) -------------------------------------------------------------------
fx <- read_excel(file_path, sheet = "fx") %>%
  dplyr::rename(date = Dates) %>%
  dplyr::mutate(ym = as.integer(format(date, "%Y%m"))) %>%
  dplyr::arrange(date)

# Yields (EOM) ---------------------------------------------------------------
yields_raw <- read_excel(file_path, sheet = "yields") %>%
  dplyr::rename(date = Dates) %>%
  dplyr::mutate(ym   = as.integer(format(date, "%Y%m")))

# Renaming the yield columns to Country_Maturity (e.g. CA_1)
old_cols <- setdiff(names(yields_raw), c("date", "ym"))

col_lookup <- tibble(original = old_cols) %>%
  dplyr::mutate(
    indicator_num =paste0("I", as.integer(str_extract(original, "(?<=I)\\d+(?=\\d{2}Y)"))),
    maturity_yr   = as.integer(str_extract(original, "\\d{2}(?=Y)"))
  ) %>%
  dplyr::left_join(curve_map, by = c("indicator_num" = "indicator")) %>%
  dplyr::mutate(new_name = paste0(country, "_", maturity_yr))

rename_vec <- setNames(col_lookup$original, col_lookup$new_name)
yields <- yields_raw %>% rename(!!!rename_vec)

# Pivot
yields_long <- yields %>%
  pivot_longer(-c(date, ym), names_to = "series", values_to = "yield") %>%
  separate(series, into = c("country", "maturity"), sep = "_") %>%
  mutate(maturity = as.integer(maturity))


# Inflation (EOM) ------------------------------------------------------------
inflation <- read_excel(file_path, sheet = "inflation") %>%
  dplyr::rename(date = Date) %>%
  dplyr::mutate(ym = as.integer(format(date, "%Y%m"))) %>%
  dplyr::arrange(date)

# Japan core-CPI gap fill. The FRED core-CPI series for Japan (sheet
# "inflation") stops in 2021-06; left as is this drops roughly five years of
# Japanese observations -- and Japan's ~20% GDP weight -- from the recent panel.
# We extend Japan with the LSEG core-CPI series (sheet "inflation_dep"), which
# runs to 2026-01, chained to the FRED index base at the splice month so that
# year-on-year inflation stays consistent across the join (the two series' YoY
# rates correlate 0.98 over their 1990-2021 overlap). Only Japan is spliced;
# every other country's FRED series already runs to 2025-03/04.
inflation_dep <- read_excel(file_path, sheet = "inflation_dep") %>%
  dplyr::mutate(ym = as.integer(format(Date, "%Y%m"))) %>%
  dplyr::select(ym, JP_dep = JP)
jp_splice_ym <- max(inflation$ym[!is.na(inflation$JP)])          # last FRED month (202106)
jp_splice_ratio <- inflation$JP[inflation$ym == jp_splice_ym] /
                   inflation_dep$JP_dep[inflation_dep$ym == jp_splice_ym]
inflation <- inflation %>%
  dplyr::left_join(inflation_dep, by = "ym") %>%
  dplyr::mutate(JP = dplyr::if_else(is.na(JP) & ym > jp_splice_ym & !is.na(JP_dep),
                                    JP_dep * jp_splice_ratio, JP)) %>%
  dplyr::select(-JP_dep)
rm(inflation_dep, jp_splice_ym, jp_splice_ratio)

# GDP (EOY), local currency --------------------------------------------------
gdp_loc <- read_excel(file_path, sheet = "gdp") %>%
  dplyr::rename(date = year) %>%
  dplyr::mutate(y = as.integer(format(date, "%Y")))

# Year-end FX (USD per unit of foreign currency) for GDP conversion
fx_eoy <- fx %>%
  dplyr::mutate(y = as.integer(format(date, "%Y")),
         m = as.integer(format(date, "%m"))) %>%
  dplyr::filter(m == 12) %>%
  dplyr::select(-date, -ym, -m) %>%
  tidyr::pivot_longer(-y, names_to = "currency", values_to = "fx_USD_eoy") %>%
  dplyr::mutate(currency = str_extract(currency, "^[A-Z]{3}")) %>%
  dplyr::bind_rows(
    tibble(y = unique(.$y), currency = "USD", fx_USD_eoy = 1.0)
  )

# Convert GDP to USD using year-end FX
gdp <- gdp_loc %>%
  tidyr::pivot_longer(-c(date, y), names_to = "country", values_to = "gdp_local") %>%
  dplyr::left_join(curve_map %>% select(country, currency), by = "country") %>%
  dplyr::left_join(fx_eoy, by = c("y", "currency")) %>%
  dplyr::mutate(gdp_val = gdp_local * fx_USD_eoy) %>%   # now in USD
  dplyr::select(date, y, country, gdp_val)

rm(list=c("file_path", "old_cols", "rename_vec", "fx_eoy", "gdp_loc", "yields_raw", "col_lookup"))


# Trend inflation ------------------------------------------------------------
# Equation 3
# Parameters
v <- 0.987
M <- 120 # 10-year window

# Precompute weights: w_j = v^j, then normalize by (1-v)/(1-v^M)
weights <- v^(0:(M-1))
norm_factor <- (1 - v) / (1 - v^M)
weights_norm <- norm_factor * weights   # sums to 1

# Function: apply to a single country's yoy inflation vector (chronological order)
cp_trend <- function(pi_vec) {
  n <- length(pi_vec)
  trend <- rep(NA_real_, n)
  for (t in M:n) {
    window <- pi_vec[(t - M + 1):t]   # pi_{t}, pi_{t-1}, ..., pi_{t-M+1}
    if (any(is.na(window))) next
    # j=0 corresponds to most recent (pi_{i,t}), so window[1] = pi_{t-M+1}
    # reverse so j=0 is pi_t
    trend[t] <- sum(weights_norm * rev(window))
  }
  trend
}

inflation_long <- inflation %>%
  tidyr::pivot_longer(-c(date, ym), names_to = "country", values_to = "cpi") %>%
  dplyr::arrange(country, date) %>%
  dplyr::group_by(country) %>%
  dplyr::mutate(
    # Publication lag: at month-end t the most recent CPI print is for month t-1
    # (e.g. February CPI, released in March, is the latest known at end-March).
    # We therefore use the one-month-lagged "real-time" CPI everywhere downstream.
    cpi_rt    = dplyr::lag(cpi, 1),
    yoy_infl  = (cpi_rt / dplyr::lag(cpi_rt, 12) - 1) * 100, # YoY of the last known print
    trend_inf = cp_trend(yoy_infl)
  ) %>%
  dplyr::ungroup()

rm(list=c("v", "M", "cp_trend", "weights", "weights_norm", "norm_factor", "inflation"))


# Cycle (maturity individual) ----------------------------------------------------------------------
# Equation 1 & 2
cycle <- yields_long %>%
  left_join(inflation_long, by = c("ym", "country")) %>%
  filter(!is.na(trend_inf), !is.na(yield)) %>%
  group_by(country, maturity) %>%
  group_modify(~ {
    fit <- lm(yield ~ trend_inf, data = .x, na.action = na.exclude)
    .x %>% mutate(
      alpha = coef(fit)[["(Intercept)"]],
      beta  = coef(fit)[["trend_inf"]],
      cycle = residuals(fit)
    )
  }) %>%
  ungroup() %>%
  select(-date.y) %>%
  rename(date = date.x)


# Excess returns -------------------------------------------------------------
# Equation 10
# All yields are in percent -> 5% = 5

yields_wide <- cycle %>%
  select(country, ym, date, maturity, yield) %>%
  pivot_wider(names_from = maturity, values_from = yield, names_prefix = "y_")

# y1 of US, needed for global investor perspective
y1_US <- yields_wide %>%
  filter(country=='US') %>%
  rename(y1_US = y_1) %>%
  select(ym, y1_US)

fx_long <- fx %>%
  select(-date) %>%
  pivot_longer(-ym, names_to = "currency", values_to = "fx_USD") %>%
  mutate(currency = str_extract(currency, "^[A-Z]{3}")) %>%   # "EURUSD Curncy" -> "EUR"
  bind_rows(
    fx %>% distinct(ym) %>% mutate(currency = "USD", fx_USD = 1.0)
  )

rx_raw <- yields_wide %>%
  arrange(country, date) %>%
  group_by(country) %>%
  left_join(y1_US,     join_by("ym")) %>%
  left_join(curve_map, join_by("country")) %>%  # brings in currency
  left_join(fx_long,   join_by("ym", "currency")) %>%   # brings in fx_USD
  mutate(
    # lead yields: y_{i,t+12}^{(n-1)} for each n
    y1_lead  = dplyr::lead(y_1,  12),
    y4_lead  = dplyr::lead(y_4,  12),
    y9_lead  = dplyr::lead(y_9,  12),
    # local-currency rx per maturity (eq 10)
    rx_2_t12  = 2  * y_2  - 1  * y1_lead  - y_1,
    rx_5_t12  = 5  * y_5  - 4  * y4_lead  - y_1,
    rx_10_t12 = 10 * y_10 - 9  * y9_lead  - y_1,
    
    # local-currency rx per maturity (eq 10)
    rx_2  = dplyr::lag(rx_2_t12, 12),
    rx_5  = dplyr::lag(rx_5_t12, 12),
    rx_10 = dplyr::lag(rx_10_t12, 12),
    
    
    # 12-month log FX return: s_{i,t+12} - s_{i,t}, with s = log(USD per FX)
    s = log(fx_USD),
    s_t12 = dplyr::lead(s, 12),
    fx_ret_t12 = (s_t12 - s)*100,
    
    # USD excess return for a global investor (eq 11):
    # rx^(n),USD = (p^(n-1)_{t+12} - p^(n)_t) + (s_{t+12} - s_t) - y^(1)_{US,t}
    # Note: p^(n-1)_{t+12} - p^(n)_t = rx^(n) + y^(1)_{i,t}  (under p = -n*y)
    rx_2_USD_t12  = rx_2_t12  + y_1 + fx_ret_t12 - y1_US,
    rx_5_USD_t12  = rx_5_t12  + y_1 + fx_ret_t12 - y1_US,
    rx_10_USD_t12 = rx_10_t12 + y_1 + fx_ret_t12 - y1_US,
  ) %>%
  ungroup()
  

# @Todo: inflation data with longer time horizon

# Duration-standaridized and maturity averaged
rx_avg <- rx_raw %>%
  mutate(
    rx_t12 = 1/3 * (
      rx_2_t12 / 2
      + rx_5_t12 / 5
      + rx_10_t12 / 10
      ),
    rx = dplyr::lag(rx_t12, 12),
    
    # Durations (eq 14)
    D_2  = 2,  #/ (1 + y_2/100),
    D_5  = 5 , #/ (1 + y_5/100),
    D_10 = 10, #/ (1 + y_10/100),

    # Duration-standardized local-currency rx (eq 13)
    rx_tilde_2_t12  = rx_2_t12  / D_2,
    rx_tilde_5_t12  = rx_5_t12  / D_5,
    rx_tilde_10_t12 = rx_10_t12 / D_10,
    # Maturity-averaged local-currency rx (eq 12), K = 3
    rx_t12 = (1/3) * (rx_tilde_2_t12 + rx_tilde_5_t12 + rx_tilde_10_t12),
    rx = dplyr::lag(rx_t12, 12),
    # Todo: check yield convention this uses 
    # cont.comp. yields would not need to be divded by y_2/100
    # no further information: we assume continous compounding
,
    # Duration-standardized USD rx (eq 13 applied to eq 11)
    rx_tilde_2_USD_t12  = rx_2_USD_t12  / D_2,
    rx_tilde_5_USD_t12  = rx_5_USD_t12  / D_5,
    rx_tilde_10_USD_t12 = rx_10_USD_t12 / D_10,
    # Maturity-averaged USD rx (eq 12), K = 3
    rx_USD_t12 = (1/3) * (rx_tilde_2_USD_t12 + rx_tilde_5_USD_t12 + rx_tilde_10_USD_t12)
  ) %>%
  select(country, ym, date, rx_t12, rx_2_t12, rx_5_t12, rx_10_t12, rx_USD_t12, rx_2_USD_t12, rx_5_USD_t12, rx_10_USD_t12)


# Forwards for the CP 2005 / DH 2013 factor ----------------------------------
# Maturity menu (1Y, 2Y, 4Y, 5Y, 9Y, 10Y) is non-contiguous, so we use the
# 1-year forward where adjacent maturities are available and the per-annum
# average forward between non-adjacent maturities elsewhere:
#   f^{(n)}   = n*y_n - (n-1)*y_{n-1}                    (1-year forward, end year n)
#   f^{(m,n)} = (n*y_n - m*y_m) / (n - m)                (per-annum forward, m -> n)
# Yields are in percent (consistent with the rx_* columns).
forwards <- yields_wide %>%
  mutate(
    f_2  = 2 * y_2 - 1 * y_1,                            # 1y forward year 1 -> 2
    f_4  = (4 * y_4 - 2 * y_2) / 2,                      # per-annum forward year 2 -> 4
    f_5  = 5 * y_5 - 4 * y_4,                            # 1y forward year 4 -> 5
    f_9  = (9 * y_9 - 5 * y_5) / 4,                      # per-annum forward year 5 -> 9
    f_10 = 10 * y_10 - 9 * y_9                           # 1y forward year 9 -> 10
  ) %>%
  select(country, ym, date, y_1, f_2, f_4, f_5, f_9, f_10)


# Average Cycle and 1Y Cycle ---------------------------------------------
cycle_avg <- cycle %>%
  filter(maturity != 1) %>% # 1Y maturity not included in average cycle
  group_by(country, ym, date) %>%
  summarise(c_bar = mean(cycle, na.rm = TRUE), .groups = "drop")

# Per-maturity cycle columns: one wide column per maturity (cycle_1y, cycle_2y,
# ... cycle_10y), built in a loop instead of six copy-pasted filter/rename blocks.
cycle_mats <- c(1, 2, 4, 5, 9, 10)
cycle_wide <- purrr::map(cycle_mats, function(m) {
  cyc_m <- cycle %>%
    filter(maturity == m) %>%
    select(country, ym, date, cycle)
  names(cyc_m)[names(cyc_m) == "cycle"] <- paste0("cycle_", m, "y")
  cyc_m
})



# Assemble the regression panel: the six per-maturity cycles (joined in turn),
# the average cycle, and the maturity-averaged / forward returns. Every
# downstream step selects columns by name, so the join order is not load-bearing.
reg_data <- cycle_wide %>%
  purrr::reduce(left_join, by = c("country", "ym", "date")) %>%
  left_join(cycle_avg, by = c("country", "ym", "date")) %>%
  left_join(rx_avg,    by = c("country", "ym", "date")) %>%
  left_join(forwards,  by = c("country", "ym", "date")) %>%
  mutate(y = as.integer(format(date, "%Y"))) %>%
  left_join(gdp %>% select(y, country, gdp_val),
            by = c("y", "country")) %>%
  filter(!is.na(rx_t12), !is.na(rx_USD_t12), !is.na(cycle_1y), !is.na(c_bar)) %>%
  # Time-varying GDP weights computed over the countries that actually enter
  # the estimation panel each month, so that sum_i w_{i,t} = 1  (Eq 8)
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val, na.rm = TRUE),
    w         = gdp_val / gdp_total
  ) %>%
  ungroup() %>%
# Local CF ---------------------------------------------------------------
  group_by(country) %>%
  group_modify(~ {
    fit        <- lm(rx_t12     ~ cycle_1y + c_bar, data = .x, na.action = na.exclude)
    fit_usd    <- lm(rx_USD_t12 ~ cycle_1y + c_bar, data = .x, na.action = na.exclude)
    # CP 2005 / DH 2013 single-factor projection on the available forward menu.
    fit_cp     <- lm(rx_t12     ~ y_1 + f_2 + f_4 + f_5 + f_9 + f_10,
                     data = .x, na.action = na.exclude)
    fit_cp_usd <- lm(rx_USD_t12 ~ y_1 + f_2 + f_4 + f_5 + f_9 + f_10,
                     data = .x, na.action = na.exclude)
    .x %>% mutate(
      gamma_0 = coef(fit)[["(Intercept)"]],
      gamma_1 = coef(fit)[["cycle_1y"]],
      gamma_2 = coef(fit)[["c_bar"]],
      CF_alt = gamma_0 + gamma_1 * cycle_1y + gamma_2 * c_bar,    # eq (6)
      CF = predict(fit, new_data = .),    # eq (6)
      CF_USD = predict(fit_usd),          # USD analog of eq (6)
      CP     = predict(fit_cp),           # CP 2005 / DH 2013 local factor
      CP_USD = predict(fit_cp_usd)        # USD analog of CP
    )
  }) %>%
  ungroup()


# Global CF ---------------------------------------------------------------
# Equation 7, 8
gcf <- reg_data %>%
group_by(ym, date) %>%
  summarise(
    GCF         = sum(w * CF, na.rm = TRUE),
    n_countries = sum(!is.na(CF) & !is.na(w)),
    .groups     = "drop"
  ) %>%
  arrange(date)


# Global CP Factor (DH 2013) -------------------------------------------------
# GDP-weighted aggregation of the local CP 2005 / DH 2013 factor, mirroring
# the GCF construction (eq 7-8 with CP in place of CF).
gcp <- reg_data %>%
  group_by(ym, date) %>%
  summarise(
    GCP             = sum(w * CP, na.rm = TRUE),
    n_countries_gcp = sum(!is.na(CP) & !is.na(w)),
    .groups         = "drop"
  ) %>%
  arrange(date)


# Dollar-Return Global Cycle Factor (FXGCF) ------------------------------------
# Following Dahlquist-Hasseltoft (2013) FXGCP. The construction is selected by
# .FXGCF_METHOD (set at the top of this file from the FXGCF_METHOD env var):
#   td_gdp / td_eq : TOP-DOWN -- FXGCF is the FITTED VALUE of the (GDP- or
#       1/n-)weighted average USD-investor excess return on the weighted average
#       cycle PREDICTOR MENU. It is NOT a regression on GCF (that would be an
#       affine transform of GCF). DH report corr(FXGCP, GCP) ~ 0.50.
#   bu_gdp : BOTTOM-UP -- GDP-weighted aggregate of the per-country USD cycle
#       factor CF_USD, i.e. the GCF recipe (eq 7-8) with the US-dollar return on
#       the LHS instead of the local-currency return.

if (.FXGCF_METHOD == "bu_gdp") {
  # Bottom-up: mirror the GCF aggregation, but on the per-country USD factor.
  fxgcf <- reg_data %>%
    group_by(ym, date) %>%
    summarise(FXGCF = sum(w * CF_USD, na.rm = TRUE), .groups = "drop") %>%
    left_join(gcf %>% select(ym, GCF), by = "ym") %>%
    select(ym, date, GCF, FXGCF) %>%
    arrange(date)
} else {
  # Top-down: equal (1/n) or GDP weights in the cross-country aggregates.
  .eq <- (.FXGCF_METHOD == "td_eq")
  # Dependent variable: weighted cross-country average USD excess return (incl. US)
  rx_usd_bar <- reg_data %>%
    group_by(ym, date) %>%
    summarise(
      rx_USD_bar_t12 = if (.eq) mean(rx_USD_t12, na.rm = TRUE)
                       else     sum(w * rx_USD_t12, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(date)
  # Predictor menu: weighted cross-country average cycle predictors
  glob_pred <- reg_data %>%
    group_by(ym, date) %>%
    summarise(
      cyc1_bar = if (.eq) mean(cycle_1y, na.rm = TRUE) else sum(w * cycle_1y, na.rm = TRUE),
      cbar_bar = if (.eq) mean(c_bar,    na.rm = TRUE) else sum(w * c_bar,    na.rm = TRUE),
      .groups  = "drop"
    )
  fxgcf_data <- rx_usd_bar %>%
    left_join(glob_pred, by = c("ym", "date")) %>%
    filter(!is.na(rx_USD_bar_t12), !is.na(cyc1_bar), !is.na(cbar_bar))
  fit_fxgcf <- lm(rx_USD_bar_t12 ~ cyc1_bar + cbar_bar, data = fxgcf_data)
  fxgcf <- glob_pred %>%
    mutate(FXGCF = predict(fit_fxgcf, newdata = .)) %>%
    select(ym, date, FXGCF) %>%
    left_join(gcf %>% select(ym, GCF), by = "ym") %>%
    select(ym, date, GCF, FXGCF)
}

# Sanity: report the GCF correlation (DH report ~ 0.50; baseline td_gdp ~ 0.99)
fxgcf_diag <- fxgcf %>% filter(!is.na(GCF), !is.na(FXGCF))
cat(sprintf("FXGCF diagnostics [%s]: cor(GCF, FXGCF) = %.3f\n",
            .FXGCF_METHOD, cor(fxgcf_diag$GCF, fxgcf_diag$FXGCF)))


# Cleanup ----------------------------------------------------------------
# Keep objects needed downstream for plotting/analysis (cycle, cycle_avg, gcf,
# inflation_long, yields_long, fx_long, gdp); drop only intermediate temporaries.
# intersect() with ls() because the top-down-only temporaries (fit_fxgcf,
# fxgcf_data, glob_pred, rx_usd_bar) are not created on the bottom-up path.
rm(list = intersect(c("cycle_wide", "cycle_mats",
            "curve_map", "fit_fxgcf", "fx", "fxgcf_data", "glob_pred",
            "fxgcf_diag", "rx_avg", "rx_raw", "rx_usd_bar",
            "y1_US", "yields", "yields_wide"), ls()))



# CP 2015 replication -----------------------------------------------------
# Test for local CF (US): 2
us_data <- reg_data %>%
  filter(country == "US") %>%
  filter(date <= "2011/12/31")

fit_us <- lm(rx_2_t12 ~ CF, data = us_data)
summary(fit_us)

# Table 1
# T1.A # @Todo: all maturities AND R2
cycle %>% filter(country == "US", maturity == 10)

# T1.B
cor(us_data %>% select(cycle_1y, cycle_2y, cycle_4y, cycle_5y, cycle_9y, cycle_10y, c_bar))

# Figure 2 (corr = 0.61)
cor(us_data %>% select(c_bar, CF))

