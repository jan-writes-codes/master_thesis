library(readxl)
library(dplyr)
library(purrr)
library(stringr)

# @todo add namesspace in front of every function
# @todo check BE inflation data, seems to be offset in the excel

# File path for the data
file_path <- "data.xlsx"

# Curve map
curve_map <- read_excel(file_path, sheet = "curve_translation") %>%
  mutate(indicator = trimws(indicator))   # remove any stray whitespace

# FX (EOM)
fx <- read_excel(file_path, sheet = "fx") %>%
  rename(date = Dates) %>%
  mutate(ym = as.integer(format(date, "%Y%m"))) %>%
  arrange(date)

# Yields (EOM)
yields_raw <- read_excel(file_path, sheet = "yields") %>%
  rename(date = Dates) %>%
  mutate(ym   = as.integer(format(date, "%Y%m")))

old_cols <- setdiff(names(yields_raw), c("date", "ym"))

col_lookup <- tibble(original = old_cols) %>%
  mutate(
    indicator_num = paste0("I", as.integer(str_extract(original, "(?<=G)\\d+(?=Z)"))),
    maturity_yr   = as.integer(str_extract(original, "\\d+(?=Y)"))
  ) %>%
  left_join(curve_map, by = c("indicator_num" = "indicator")) %>%
  mutate(new_name = paste0(country, "_", maturity_yr))

rename_vec <- setNames(col_lookup$original, col_lookup$new_name)
yields <- yields_raw %>% rename(!!!rename_vec)


# Inflation (EOM)
inflation <- read_excel(file_path, sheet = "inflation") %>%
  rename(date = Date) %>%
  mutate(ym = as.integer(format(date, "%Y%m"))) %>%
  arrange(date)

# GDP (EOY), local currency
gdp <- read_excel(file_path, sheet = "gdp") %>%
  rename(date = year) %>%
  mutate(y = as.integer(format(date, "%Y")))

# Year-end FX (USD per unit of foreign currency) for GDP conversion
# Take the December observation each year from the monthly fx panel
fx_eoy <- fx %>%
  mutate(y = as.integer(format(date, "%Y")),
         m = as.integer(format(date, "%m"))) %>%
  filter(m == 12) %>%
  select(-date, -ym, -m) %>%
  pivot_longer(-y, names_to = "currency", values_to = "fx_USD_eoy") %>%
  mutate(currency = str_extract(currency, "^[A-Z]{3}")) %>%
  bind_rows(
    tibble(y = unique(.$y), currency = "USD", fx_USD_eoy = 1.0)
  )

# Convert GDP to USD using year-end FX
gdp <- gdp %>%
  pivot_longer(-c(date, y), names_to = "country", values_to = "gdp_local") %>%
  left_join(curve_map %>% select(country, currency), by = "country") %>%
  left_join(fx_eoy, by = c("y", "currency")) %>%
  mutate(gdp_val = gdp_local * fx_USD_eoy) %>%   # now in USD
  select(date, y, country, gdp_val)


library(tidyr)
library(purrr)

# --- CP trend inflation: equation (3) ---
# Parameters
v <- 0.9       # @Todo: estimated from survey data; CP use ~0.9-0.99, check your thesis spec
M <- 120       # 10-year window

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
    yoy_infl  = (cpi / dplyr::lag(cpi, 12) - 1) * 100, # @Todo divide or substract index?
    trend_inf = cp_trend(yoy_infl)
  ) %>%
  dplyr::ungroup()

yields_long <- yields %>%
  pivot_longer(-c(date, ym), names_to = "series", values_to = "yield") %>%
  separate(series, into = c("country", "maturity"), sep = "_") %>%
  mutate(maturity = as.integer(maturity))

# ── Step 3: Join & compute cycle ─────────────────────────────
# Eq (1): y_{i,t}^{(n)} = α_{i,n} + β_{i,n} * π^e_{i,t} + ε_{i,t}^{(n)}
# Eq (2): c_{i,t}^{(n)} = ε_{i,t}^{(n)}
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
  

# ── Step 5: Excess returns ────────────────────────────────────
# All yields are in decimals (e.g. 0.05 for 5%) — if in percent, divide by 100

# Eq (10): rx_{i,t+12}^{(n)} = n*y_{i,t}^{(n)} - (n-1)*y_{i,t+12}^{(n-1)} - y_{i,t}^{(1)}
# Need yields at maturity n and n-1, and lead 12 months for (n-1)

# Pivot yields wide by maturity for easy cross-maturity access
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


# Compute raw excess return per maturity per country (eq 10) and
# USD excess return for a global investor (eq 11)
rx_raw <- yields_wide %>%
  arrange(country, date) %>%
  group_by(country) %>%
  left_join(y1_US,     join_by("ym")) %>%
  left_join(curve_map, join_by("country")) %>%                  # brings in `currency`
  left_join(fx_long,   join_by("ym", "currency")) %>%           # brings in `fx_USD`
  mutate(
    # lead yields: y_{i,t+12}^{(n-1)} for each n
    y1_lead  = dplyr::lead(y_1,  12),
    y4_lead  = dplyr::lead(y_4,  12),
    y9_lead  = dplyr::lead(y_9,  12),
    # raw local-currency rx per maturity (eq 10)
    rx_2  = 2  * y_2  - 1  * y1_lead  - y_1,
    rx_5  = 5  * y_5  - 4  * y4_lead  - y_1,
    rx_10 = 10 * y_10 - 9  * y9_lead  - y_1,
    # 12-month log FX return: s_{i,t+12} - s_{i,t}, with s = log(USD per FX)
    s         = log(fx_USD),
    s_lead12  = dplyr::lead(s, 12),
    fx_ret    = s_lead12 - s,
    # USD excess return for a global investor (eq 11):
    # rx^(n),USD = (p^(n-1)_{t+12} - p^(n)_t) + (s_{t+12} - s_t) - y^(1)_{US,t}
    # Note: p^(n-1)_{t+12} - p^(n)_t = rx^(n) + y^(1)_{i,t}  (under p = -n*y)
    rx_2_USD  = rx_2  + y_1 + fx_ret - y1_US,
    rx_5_USD  = rx_5  + y_1 + fx_ret - y1_US,
    rx_10_USD = rx_10 + y_1 + fx_ret - y1_US,
  ) %>%
  ungroup()


# ── Eq (14): Duration D_{i,t}^{(n)} = n / (1 + y_{i,t}^{(n)}) ───
# ── Eq (13): rx~_{i,t+12}^{(n)} = rx^{(n)} / D^{(n)}          ───
# ── Eq (12): rx_{i,t+12} = (1/K) * sum over n of rx~^{(n)}    ───
# K = 3 (maturities 2, 5, 10 — we skip n=1 since rx^{(1)} needs y^{(0)} which is undefined)

rx_avg <- rx_raw %>%
  mutate(
    # Durations (eq 14)
    D_2  = 2  / (1 + y_2),
    D_5  = 5  / (1 + y_5),
    D_10 = 10 / (1 + y_10),
    # Duration-standardized local-currency rx (eq 13)
    rx_tilde_2  = rx_2  / D_2,
    rx_tilde_5  = rx_5  / D_5,
    rx_tilde_10 = rx_10 / D_10,
    # Maturity-averaged local-currency rx (eq 12), K = 3
    rx = (1/3) * (rx_tilde_2 + rx_tilde_5 + rx_tilde_10),
    # Duration-standardized USD rx (eq 13 applied to eq 11)
    rx_tilde_2_USD  = rx_2_USD  / D_2,
    rx_tilde_5_USD  = rx_5_USD  / D_5,
    rx_tilde_10_USD = rx_10_USD / D_10,
    # Maturity-averaged USD rx (eq 12), K = 3
    rx_USD = (1/3) * (rx_tilde_2_USD + rx_tilde_5_USD + rx_tilde_10_USD)
  ) %>%
  select(country, ym, date, rx, rx_USD)


# ── Step 6: Average cycle (eq 5) & 1Y cycle ──────────────────
cycle_avg <- cycle %>%
  group_by(country, ym, date) %>%
  summarise(c_bar = mean(cycle, na.rm = TRUE), .groups = "drop")

cycle_1y <- cycle %>%
  filter(maturity == 1) %>%
  select(country, ym, date, cycle_1y = cycle)


reg_data <- cycle_1y %>%
  left_join(cycle_avg, by = c("country", "ym", "date")) %>%
  left_join(rx_avg,    by = c("country", "ym", "date")) %>%
  filter(!is.na(rx), !is.na(cycle_1y), !is.na(c_bar))


local_cf <- reg_data %>%
  group_by(country) %>%
  group_modify(~ {
    fit <- lm(rx ~ cycle_1y + c_bar, data = .x, na.action = na.exclude)
    .x %>% mutate(
      gamma_1 = coef(fit)[["cycle_1y"]],
      gamma_2 = coef(fit)[["c_bar"]],
      CF      = gamma_1 * cycle_1y + gamma_2 * c_bar    # eq (6)
    )
  }) %>%
  ungroup()

us_data <- local_cf %>%
  filter(country == "US") %>%
  filter(!is.na(rx), !is.na(CF)) %>%
  mutate(CF = CF/100)

fit_us <- lm(rx ~ CF, data = us_data)
summary(fit_us)


# ── Step 7: Global Cycle Factor (GCF) ────────────────────────
# Eq (7): GCF_t = sum_{i in G10} w_{i,t} * CF_{i,t}
# Eq (8): w_{i,t} = GDP_{i,t} / sum_{j in G10} GDP_{j,t}


# Attach calendar year to local_cf so we can join annual GDP onto monthly data
local_cf_yr <- local_cf %>%
  mutate(y = as.integer(format(date, "%Y")))

# Join GDP value for each country-year
cf_gdp <- local_cf_yr %>%
  left_join(gdp %>% select(y, country, gdp_val),
            by = c("y", "country"))

# Compute time-varying GDP weights across all available G10 countries  (Eq 8)
cf_gdp <- cf_gdp %>%
  group_by(ym) %>%
  mutate(
    gdp_total = sum(gdp_val, na.rm = TRUE),
    w         = gdp_val / gdp_total
  ) %>%
  ungroup()

# Sanity check: weights should sum to 1 each period
weight_check <- cf_gdp %>%
  group_by(ym) %>%
  summarise(w_sum = sum(w, na.rm = TRUE), .groups = "drop")
#stopifnot(all(abs(weight_check$w_sum - 1) < 1e-6))

# Compute GCF_t as GDP-weighted sum of country cycle factors  (Eq 7)
gcf <- cf_gdp %>%
  group_by(ym, date) %>%
  summarise(
    GCF         = sum(w * CF, na.rm = TRUE),
    n_countries = sum(!is.na(CF) & !is.na(w)),
    .groups     = "drop"
  ) %>%
  arrange(date)

# ── FX-Global CF (eq 15-17) ──────────────────────────────────
# Eq (15): rxbar^USD_t = sum_{i in G10} w_{i,t} * rx^USD_{i,t+12}
# Attach USD excess returns to the weighted panel
cf_gdp_usd <- cf_gdp %>%
  left_join(rx_avg %>% select(country, ym, rx_USD),
            by = c("country", "ym")) %>%
  rename(rx_USD = rx_USD.x)

# GDP-weighted cross-country average of USD excess returns (eq 15)
rx_usd_bar <- cf_gdp_usd %>%
  group_by(ym, date) %>%
  summarise(
    rx_USD_bar = sum(w * rx_USD, na.rm = TRUE),
    n_countries_usd = sum(!is.na(rx_USD) & !is.na(w)),
    .groups = "drop"
  ) %>%
  arrange(date)

# Eq (16): rxbar^USD_{t+12} = delta_0 + delta_1 * GCF_t + eps_{t+12}
# rx_USD_bar at row ym=t already holds the t+12 realized return,
# and GCF at row ym=t already holds GCF_t — so just join on ym.
fxgcf_data <- gcf %>%
  select(ym, date, GCF) %>%
  left_join(rx_usd_bar %>% select(ym, rx_USD_bar), by = "ym") %>%
  filter(!is.na(rx_USD_bar), !is.na(GCF))

fit_fxgcf <- lm(rx_USD_bar ~ GCF, data = fxgcf_data)
summary(fit_fxgcf)

# Eq (17): FXGCF_t = delta_0_hat + delta_1_hat * GCF_t  (fitted values)
fxgcf <- gcf %>%
  select(ym, date, GCF) %>%
  filter(!is.na(GCF)) %>%
  mutate(FXGCF = predict(fit_fxgcf, newdata = .))

