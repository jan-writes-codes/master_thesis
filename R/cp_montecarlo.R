# cp_montecarlo.R
# Expectations-Hypothesis (EH) Monte Carlo for Cieslak & Povala (2015) Table 2,
# Panel B: the finite-sample distribution of the predictive R-bar^2 under the
# null of no bond risk premia. Sourced by empirical.R.
#
# Model (CP 2015, Section 1). Two AR(1) state variables, trend inflation tau_t
# and a real factor r_t, drive the nominal short rate
#   i_t = delta0 + delta_tau * tau_t + delta_r * r_t,   delta0=0, delta_tau=1.43, delta_r=1.
# Under the EH (zero risk premia, lambda_0 = lambda_1 = 0) the n-year yield is
# the average expected future short rate, so with E_t[f_{t+j}] = phi^j f_t it is
# affine in (tau_t, r_t):
#   y_t^(n) = delta0 + delta_tau * tau_t * Abar(phi_tau, N)
#                    + delta_r   * r_t   * Abar(phi_r,   N),
#   Abar(phi, N) = (1 - phi^N) / ((1 - phi) * N),   N = 12 * n months.
# Calibration (CP 2015): sd(tau) = 1.90% and sd of the 1-year cycle c^(1) = 1.74%
# (the 1-year cycle is the part of y^(1) orthogonal to tau, ~ Abar(phi_r,12)*r_t,
# so sigma_r is set so sd(c^(1)) hits its target, not sd(r)). The predictive
# regression is rx_bar on (tau_t, r_t) -- "trend inflation and the real factor"
# in the paper -- so the R^2 responds to both phi_tau and phi_r. Realized
# 12-month excess returns are non-zero in finite samples (through the y_{t+12}
# term), so the predictive R^2 has a non-degenerate null distribution; CP report
# its 95th percentile at ~19-23% (T = 470).
# =============================================================================

# Geometric-mean loading Abar(phi, N) = (1/N) sum_{j=0}^{N-1} phi^j.
geo_mean_load <- function(phi, N) {
  if (abs(1 - phi) < 1e-12) return(1)
  (1 - phi^N) / ((1 - phi) * N)
}

# EH affine loadings (b0, b_tau, b_r) of the n-year yield on (tau_t, r_t).
eh_yield_loadings <- function(phi_tau, phi_r, n_years,
                              delta0 = 0, dtau = 1.43, dr = 1) {
  N <- n_years * 12L
  c(b0   = delta0,
    btau = dtau * geo_mean_load(phi_tau, N),
    br   = dr   * geo_mean_load(phi_r,   N))
}

# --- Predictor builders (pluggable) -----------------------------------------
# Each takes the simulated yield matrix Y (rows = t, named "y_<n>"), the latent
# tau_t and r_t, and returns the predictor matrix for the predictive regression.

# Factor predictors: trend inflation and the real factor (tau_t, r_t). This is
# the CP 2015 Panel-B specification ("predictive regressions of excess returns
# on trend inflation and the real factor"); its R^2 responds to both phi_tau and
# phi_r. Default for Panel B.
predictor_factors <- function(Y, tau, r) cbind(tau = tau, r = r)

# Cycle predictors (CP Table 2, column 5): cycle_n = residual of y^(n) ~ tau,
# then (cycle_1y, c_bar) with c_bar averaged over maturities != 1 -- the
# construction in data_preparation.R. Under the stylized EH model every cycle is
# a scalar multiple of the same tau-orthogonal real factor, so this collapses to
# one effective regressor in r (responds to phi_r only). Provided for comparison.
predictor_cycle <- function(Y, tau, r) {
  mats <- as.integer(sub("^y_", "", colnames(Y)))
  taud <- tau - mean(tau); vt <- sum(taud^2)
  cyc <- apply(Y, 2, function(y) { yd <- y - mean(y); yd - (sum(taud * yd) / vt) * taud })
  cbind(cycle_1y = cyc[, "y_1"], c_bar = rowMeans(cyc[, mats != 1L, drop = FALSE]))
}

# Six-yield predictors (CP Table 2, column 1). Provided for comparison.
predictor_sixyields <- function(Y, tau, r) Y

# --- One Monte Carlo draw ----------------------------------------------------
# Simulates T_ + 12 usable months (plus burn-in), forms EH yields on the
# maturity menu {1,2,4,5,9,10}, the duration-standardized maturity-averaged
# excess return rx_bar over n in {2,5,10} (D_n = n; matches data_preparation.R),
# and the chosen predictor, then returns the adjusted R^2 of rx_bar ~ predictor.
simulate_eh_once <- function(phi_tau, phi_r, T_ = 470L,
                             sd_tau = 1.90, sd_c1 = 1.74,
                             rx_mats = c(2L, 5L, 10L),
                             menu = c(1L, 2L, 4L, 5L, 9L, 10L),
                             burn = 200L,
                             predictor_fn = predictor_factors) {
  # sd(tau) target directly; sd(c^(1)) target via the 1-year yield's loading on
  # r, since c^(1) ~ Abar(phi_r, 12) * r_t (the part of y^(1) orthogonal to tau).
  sig_tau <- sd_tau * sqrt(1 - phi_tau^2)
  sig_r   <- (sd_c1 / geo_mean_load(phi_r, 12L)) * sqrt(1 - phi_r^2)
  Ttot <- burn + T_ + 12L

  # AR(1) state paths via the recursive filter (fast C loop).
  tau <- as.numeric(stats::filter(rnorm(Ttot, 0, sig_tau), phi_tau, method = "recursive"))
  rr  <- as.numeric(stats::filter(rnorm(Ttot, 0, sig_r),   phi_r,   method = "recursive"))
  keep <- (burn + 1L):Ttot
  tau <- tau[keep]; rr <- rr[keep]             # length T_ + 12

  need <- sort(unique(c(1L, menu, rx_mats, rx_mats - 1L)))
  Y <- sapply(need, function(nn) {
    L <- eh_yield_loadings(phi_tau, phi_r, nn)
    L[["b0"]] + L[["btau"]] * tau + L[["br"]] * rr
  })
  colnames(Y) <- paste0("y_", need)
  getY <- function(nn) Y[, paste0("y_", nn)]

  Tn <- length(tau) - 12L
  t0 <- seq_len(Tn); t1 <- t0 + 12L

  rx <- sapply(rx_mats, function(nn) {
    rxn <- nn * getY(nn)[t0] - (nn - 1L) * getY(nn - 1L)[t1] - getY(1L)[t0]
    rxn / nn                                   # duration standardize, D_n = n
  })
  rx_bar <- rowMeans(rx)

  Ymenu <- Y[t0, paste0("y_", menu), drop = FALSE]
  Xp <- predictor_fn(Ymenu, tau[t0], rr[t0])
  summary(lm(rx_bar ~ Xp))$adj.r.squared
}

# --- R^2 distribution over n_sims draws --------------------------------------
eh_r2_distribution <- function(phi_tau, phi_r, T_ = 470L, n_sims = 10000L,
                               predictor_fn = predictor_factors, seed = 1L, ...) {
  set.seed(seed)
  r2 <- vapply(seq_len(n_sims), function(i)
    simulate_eh_once(phi_tau, phi_r, T_ = T_, predictor_fn = predictor_fn, ...),
    numeric(1))
  c(P5 = unname(quantile(r2, 0.05, na.rm = TRUE)),
    P50 = unname(quantile(r2, 0.50, na.rm = TRUE)),
    P95 = unname(quantile(r2, 0.95, na.rm = TRUE)))
}

# --- Grid driver (the phi combinations tabulated in CP 2015 Table 2B) --------
run_eh_grid <- function(T_ = 470L, n_sims = 10000L,
                        predictor_fn = predictor_factors, seed = 1L) {
  grid <- rbind(
    data.frame(phi_r = 0.75,  phi_tau = c(0.80, 0.975, 0.999)),
    data.frame(phi_r = c(0.60, 0.75, 0.90), phi_tau = 0.975)
  )
  out <- lapply(seq_len(nrow(grid)), function(i) {
    q <- eh_r2_distribution(grid$phi_tau[i], grid$phi_r[i],
                            T_ = T_, n_sims = n_sims,
                            predictor_fn = predictor_fn, seed = seed + i)
    data.frame(phi_tau = grid$phi_tau[i], phi_r = grid$phi_r[i],
               P5 = q[["P5"]], P50 = q[["P50"]], P95 = q[["P95"]])
  })
  do.call(rbind, out)
}
