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

fit_us <- lm(rx_2_t12 ~ CF, data = us_data)
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



