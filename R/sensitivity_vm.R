# sensitivity_vm.R
# =============================================================================
# Robustness of the cycle factor to the trend-inflation smoothing parameters
# (review remark R-167). Rebuilds trend inflation -> yield cycles -> local cycle
# factor CF -> GDP-weighted global factor GCF over a grid of the decay v and the
# window length M, and reports the cross-country mean in-sample R^2 (local and
# global) together with each alternative global factor's correlation with the
# baseline (v=0.987, M=120). Reuses the v/M-independent objects built by
# data_preparation.R: yields_long, inflation_long$yoy_infl, and reg_data
# (rx_t12, w, ym, country). Run from the repository root.
# =============================================================================

if (!exists("reg_data")) source("R/data_preparation.R")
suppressMessages({library(dplyr); library(tidyr); library(purrr)})

CYC_MATS <- c(1, 2, 4, 5, 9, 10)

# EWMA trend inflation for a single chronological yoy vector, given (v, M).
.trend <- function(pi_vec, v, M) {
  wn <- ((1 - v) / (1 - v^M)) * v^(0:(M - 1))   # sums to 1, j=0 is most recent
  n <- length(pi_vec); tr <- rep(NA_real_, n)
  for (t in M:n) {
    w <- pi_vec[(t - M + 1):t]
    if (!anyNA(w)) tr[t] <- sum(wn * rev(w))
  }
  tr
}

# Build CF (per country) and GCF (per month) for a given (v, M).
build_vm <- function(v, M) {
  infl <- inflation_long %>%
    arrange(country, date) %>%
    group_by(country) %>%
    mutate(trend_inf = .trend(yoy_infl, v, M)) %>%
    ungroup() %>%
    select(country, ym, trend_inf)

  cyc <- yields_long %>%
    inner_join(infl, by = c("country", "ym")) %>%
    filter(!is.na(trend_inf), !is.na(yield)) %>%
    group_by(country, maturity) %>%
    mutate(cycle = residuals(lm(yield ~ trend_inf, na.action = na.exclude))) %>%
    ungroup()

  cbar <- cyc %>% filter(maturity != 1) %>%
    group_by(country, ym) %>% summarise(c_bar = mean(cycle, na.rm = TRUE), .groups = "drop")
  c1   <- cyc %>% filter(maturity == 1) %>% transmute(country, ym, cycle_1y = cycle)

  d <- reg_data %>%
    select(country, ym, rx_t12, w) %>%
    inner_join(c1,   by = c("country", "ym")) %>%
    inner_join(cbar, by = c("country", "ym")) %>%
    filter(!is.na(rx_t12), !is.na(cycle_1y), !is.na(c_bar))

  d <- d %>% group_by(country) %>%
    mutate(CF = predict(lm(rx_t12 ~ cycle_1y + c_bar, na.action = na.exclude))) %>%
    ungroup()

  gcf <- d %>% filter(!is.na(CF), !is.na(w)) %>%
    group_by(ym) %>% summarise(GCF = sum(w * CF) / sum(w), .groups = "drop")
  d <- d %>% left_join(gcf, by = "ym")
  d
}

r2_local  <- function(d) d %>% group_by(country) %>%
  summarise(r2 = summary(lm(rx_t12 ~ cycle_1y + c_bar))$r.squared, .groups = "drop") %>%
  summarise(mean(r2)) %>% pull()
r2_global <- function(d) d %>% group_by(country) %>%
  summarise(r2 = summary(lm(rx_t12 ~ GCF))$r.squared, .groups = "drop") %>%
  summarise(mean(r2)) %>% pull()

grid <- expand.grid(M = c(60, 120, 180), v = c(0.859, 0.975, 0.987),
                    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)

base <- build_vm(0.987, 120)
base_gcf <- base %>% distinct(ym, GCF) %>% rename(GCF_base = GCF)

sens_vm <- pmap_dfr(grid, function(M, v) {
  d <- build_vm(v, M)
  gc <- d %>% distinct(ym, GCF) %>% inner_join(base_gcf, by = "ym")
  tibble(v = v, M = M,
         r2_loc = r2_local(d), r2_glb = r2_global(d),
         cor_base = suppressWarnings(cor(gc$GCF, gc$GCF_base, use = "complete.obs")))
})

cat("\n===== v/M sensitivity of the cycle factor (R-167) =====\n")
print(as.data.frame(sens_vm %>%
        transmute(v, M, `HL(months)` = round(log(0.5) / log(v), 0),
                  `Mean IS R2 local` = round(r2_loc, 3),
                  `Mean IS R2 global` = round(r2_glb, 3),
                  `cor(GCF, baseline)` = round(cor_base, 3))),
      row.names = FALSE)
