library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)

# @todo add namesspace in front of every function
# @todo check BE inflation data, seems to be offset in the excel

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
    yoy_infl  = (cpi / dplyr::lag(cpi, 12) - 1) * 100, # YoY inflation publicly at that month
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


# Average Cycle and 1Y Cycle ---------------------------------------------
cycle_avg <- cycle %>%
  filter(maturity != 1) %>% # 1Y maturity not included in average cycle
  group_by(country, ym, date) %>%
  summarise(c_bar = mean(cycle, na.rm = TRUE), .groups = "drop")

cycle_1y <- cycle %>%
  filter(maturity == 1) %>%
  select(country, ym, date, cycle_1y = cycle)

cycle_2y <- cycle %>%
  filter(maturity == 2) %>%
  select(country, ym, date, cycle_2y = cycle)

cycle_4y <- cycle %>%
  filter(maturity == 4) %>%
  select(country, ym, date, cycle_4y = cycle)

cycle_5y <- cycle %>%
  filter(maturity == 5) %>%
  select(country, ym, date, cycle_5y = cycle)

cycle_9y <- cycle %>%
  filter(maturity == 9) %>%
  select(country, ym, date, cycle_9y = cycle)

cycle_10y <- cycle %>%
  filter(maturity == 10) %>%
  select(country, ym, date, cycle_10y = cycle)



reg_data <- cycle_1y %>%
  left_join(cycle_avg, by = c("country", "ym", "date")) %>%
  left_join(cycle_2y, by = c("country", "ym", "date")) %>%
  left_join(cycle_4y, by = c("country", "ym", "date")) %>%
  left_join(cycle_5y, by = c("country", "ym", "date")) %>%
  left_join(cycle_9y, by = c("country", "ym", "date")) %>%
  left_join(cycle_10y, by = c("country", "ym", "date")) %>%
  left_join(rx_avg,    by = c("country", "ym", "date")) %>%
  # Compute time-varying GDP weights across all available G10 countries  (Eq 8)
  mutate(y = as.integer(format(date, "%Y"))) %>%
  left_join(gdp %>% select(y, country, gdp_val),
            by = c("y", "country")) %>%
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val, na.rm = TRUE),
    w         = gdp_val / gdp_total
  ) %>%
  ungroup() %>%
  filter(!is.na(rx_t12), !is.na(rx_USD_t12), !is.na(cycle_1y), !is.na(c_bar)) %>%
# Local CF ---------------------------------------------------------------
  group_by(country) %>%
  group_modify(~ {
    fit <- lm(rx_t12 ~ cycle_1y + c_bar, data = .x, na.action = na.exclude)
    .x %>% mutate(
      gamma_0 = coef(fit)[["(Intercept)"]],
      gamma_1 = coef(fit)[["cycle_1y"]],
      gamma_2 = coef(fit)[["c_bar"]],
      CF_alt = gamma_0 + gamma_1 * cycle_1y + gamma_2 * c_bar,    # eq (6)
      CF = predict(fit, new_data = .)    # eq (6)
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


# FX Global Cycle Factor (FXGCF) ---------------------------------------------
# Equation 15
# Attach USD excess returns to the weighted panel
cf_gdp_usd <- reg_data %>%
  left_join(rx_avg %>% select(country, ym, rx_USD_t12),
            by = c("country", "ym")) %>%
  rename(rx_USD_t12 = rx_USD_t12.x)

# GDP-weighted cross-country average of USD excess returns (eq 15)
rx_usd_bar <- cf_gdp_usd %>%
  group_by(ym, date) %>%
  summarise(
    rx_USD_bar_t12 = sum(w * rx_USD_t12, na.rm = TRUE),
    n_countries_usd = sum(!is.na(rx_USD_t12) & !is.na(w)),
    .groups = "drop"
  ) %>%
  arrange(date)

# Equation 16
fxgcf_data <- gcf %>%
  select(ym, date, GCF) %>%
  left_join(rx_usd_bar %>% select(ym, rx_USD_bar_t12), by = "ym") %>%
  filter(!is.na(rx_USD_bar_t12), !is.na(GCF))

fit_fxgcf <- lm(rx_USD_bar_t12 ~ GCF, data = fxgcf_data)
# Eq (17): FXGCF_t = delta_0_hat + delta_1_hat * GCF_t  (fitted values)
fxgcf <- gcf %>%
  select(ym, date, GCF) %>%
  filter(!is.na(GCF)) %>%
  mutate(FXGCF = predict(fit_fxgcf, newdata = .))


# Testing and cleanup ----------------------------------------------------
# Sanity check: weights should sum to 1 each period
weight_check <- cf_gdp %>%
  group_by(ym) %>%
  summarise(w_sum = sum(w, na.rm = TRUE), .groups = "drop")
stopifnot(all(abs(weight_check$w_sum - 1) < 1e-6))

rm(list = c("cycle_1y", "cycle_2y", "cycle_4y", "cycle_5y", "cycle_9y", "cycle_10y",
            "cf_gdp", "cf_gdp_usd", "curve_map", "cycle", "cycle_avg", "fit_fxgcf", "fit_us", "fx",
            "fx_long", "fxgcf_data", "gcf", "gdp", "inflation_long", "rx_avg", "rx_raw", "rx_usd_bar",
            "y1_US", "yields", "yields_long", "yields_wide"))



# CP 2015 replication -----------------------------------------------------
# Test for local CF (US): 2
us_data <- reg_data %>%
  filter(country == "US") %>%
  filter(date <= "2014/12/31")

fit_us <- lm(rx_2_t12 ~ CF, data = us_data)
summary(fit_us)

# Table 1
# T1.A # @Todo: all maturities AND R2
cycle %>% filter(country == "US", maturity == 10)

# T1.B
cor(us_data %>% select(cycle_1y, cycle_2y, cycle_4y, cycle_5y, cycle_9y, cycle_10y, c_bar))

# Figure 2 (corr = 0.61)
cor(us_data %>% select(c_bar, CF))

