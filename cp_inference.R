# cp_inference.R
# Inference primitives for the Cieslak & Povala (2015) predictive regressions
# (Tables 2 and 4). Sourced by empirical.R.
#
# The predictive regressions are h=12-month overlapping forecasts
#   rx_{t->t+12} = a + b' x_t + e_{t+12},
# so plain OLS standard errors are badly biased downward. CP 2015 report
# t-statistics from the "reverse-regression delta method" (Wei & Wright 2013).
# That estimator pairs backward-summed regressors with ONE-PERIOD (monthly)
# return innovations; reg_data only stores the 12-month overlapping returns, so
# the genuine reverse-regression form is not identified from the available data
# (and the paper's appendix is not accessible in this environment). We therefore
# use Hansen-Hodrick / Newey-West HAC standard errors -- the standard, robust
# inference for overlapping returns and exactly the convention empirical.R
# already uses for Table 1 (NW, 18 lags). Treat the reported t-stats as robust
# HAC t-stats; signs, magnitudes and the R2 / Wald / BIC structure are faithful,
# but the exact reverse-regression t-values would require the CP appendix.
# =============================================================================

library(sandwich)
library(lmtest)


# Hansen-Hodrick / Newey-West HAC inference for an overlapping predictive lm.
# -----------------------------------------------------------------------------
# fit : an lm object for rx_{t->t+h} ~ predictors_t.
# lag : HAC bandwidth (default 18, the CP 2015 Table 1 convention for h=12).
# Returns coefficients, HAC standard errors / t-stats, and a joint Wald chi^2
# on the slopes (intercept excluded) with its p-value.
hac_inf <- function(fit, lag = 18L) {
  V  <- sandwich::NeweyWest(fit, lag = lag, prewhite = FALSE, adjust = TRUE)
  b  <- coef(fit)
  se <- sqrt(diag(V))
  sl  <- b[-1]
  Vsl <- V[-1, -1, drop = FALSE]
  wald <- as.numeric(t(sl) %*% solve(Vsl) %*% sl)
  list(coef = b, vcov = V, se = se, t = b / se,
       wald = wald, wald_df = length(sl),
       wald_p = stats::pchisq(wald, df = length(sl), lower.tail = FALSE))
}


# BIC relative probabilities (Table 2 note).
# -----------------------------------------------------------------------------
# BIC_i = ln(sigma2_i) + ln(T) * n_i / T,  sigma2_i = SSE_i / T,
#   n_i = number of slope regressors (intercept excluded, same convention for
#   every model). Relative probability of model i = exp{ (BIC_best - BIC_i)/2 },
#   so the best (lowest-BIC) model maps to 1.0 and the rest to (0, 1].
# fits : named list of lm objects estimated on the SAME sample.
bic_relprob <- function(fits) {
  bic <- vapply(fits, function(f) {
    e <- residuals(f); Tn <- length(e)
    n <- length(coef(f)) - 1L                  # slopes only
    sigma2 <- sum(e^2) / Tn
    log(sigma2) + log(Tn) * n / Tn
  }, numeric(1))
  best <- min(bic)
  list(bic = bic, relprob = exp((best - bic) / 2))
}


# Stationary (Politis-Romano) block bootstrap of the predictive t-statistic.
# -----------------------------------------------------------------------------
# Table 4 reports the small-sample [5%, 95%] distribution of the reverse-
# regression t-statistic. We resample (rx, cf) pairs in stationary blocks of
# mean length L (>= the 12-month overlap), refit rx ~ cf on each pseudo-sample,
# and studentize the slope, recentered at the full-sample estimate so the
# interval reflects sampling dispersion around the point estimate.
#
# rx, cf : aligned numeric vectors (the LHS return and the cycle factor).
# L      : mean block length (default 12, to span the overlap).
# R      : number of bootstrap replications.
# lag    : HAC bandwidth for the per-replication t (must match the headline t,
#          else the overlap is ignored and the t-stat is badly inflated).
# recenter : FALSE -> distribution of the t-statistic b/se itself (centered near
#            the point t, as in the paper's SS interval); TRUE -> (b - b_full)/se.
# Returns the [5%, 95%] quantiles of the bootstrap t.
block_boot_t <- function(rx, cf, L = 12L, R = 5000L, seed = 1L,
                         lag = 18L, recenter = FALSE) {
  d  <- data.frame(rx = rx, cf = cf)
  d  <- d[stats::complete.cases(d), ]
  n  <- nrow(d)
  b_full <- coef(lm(rx ~ cf, data = d))[["cf"]]
  p_restart <- 1 / L

  set.seed(seed)
  one <- function() {
    idx <- integer(0)
    while (length(idx) < n) {
      start <- sample.int(n, 1L)
      len   <- rgeom(1L, prob = p_restart) + 1L
      blk   <- ((start - 1L) + 0:(len - 1L)) %% n + 1L     # wrap-around
      idx   <- c(idx, blk)
    }
    fit <- lm(rx ~ cf, data = d[idx[seq_len(n)], ])
    b   <- coef(fit)[["cf"]]
    se  <- sqrt(diag(sandwich::NeweyWest(fit, lag = lag,
                                         prewhite = FALSE, adjust = TRUE)))[["cf"]]
    if (!is.finite(se) || se <= 0) return(NA_real_)
    (b - if (recenter) b_full else 0) / se
  }
  tdist <- replicate(R, one())
  tdist <- tdist[is.finite(tdist)]
  c(lo = unname(quantile(tdist, 0.05)),
    hi = unname(quantile(tdist, 0.95)))
}


# Stationary block bootstrap 90% CI for the adjusted R^2 of a predictive
# regression (Dahlquist-Hasseltoft 2013 Tables 4/6/7 convention).
# -----------------------------------------------------------------------------
# Resamples rows of (y, X) in stationary (Politis-Romano) blocks of mean length
# L (>= the 12-month return overlap), refits by OLS, and returns the 5th/95th
# percentiles of the bootstrap adjusted-R^2 distribution. Uses lm.fit on a
# prepended intercept for speed (hundreds of these are run across the tables).
#
# y : numeric response (length m). X : m x k predictor matrix (no intercept).
block_boot_r2_ci <- function(y, X, L = 18L, R = 1000L, seed = 1L) {
  X  <- as.matrix(X)
  ok <- stats::complete.cases(X, y)
  X  <- X[ok, , drop = FALSE]; y <- y[ok]
  m  <- length(y); k <- ncol(X)
  Xc <- cbind(1, X)
  p_restart <- 1 / L

  adj_r2 <- function(idx) {
    yi <- y[idx]; Xi <- Xc[idx, , drop = FALSE]
    fit <- stats::lm.fit(Xi, yi)
    sse <- sum(fit$residuals^2)
    sst <- sum((yi - mean(yi))^2)
    if (sst <= 0) return(NA_real_)
    1 - (sse / (m - k - 1)) / (sst / (m - 1))
  }

  set.seed(seed)
  one <- function() {
    idx <- integer(0)
    while (length(idx) < m) {
      start <- sample.int(m, 1L)
      len   <- rgeom(1L, prob = p_restart) + 1L
      idx   <- c(idx, ((start - 1L) + 0:(len - 1L)) %% m + 1L)
    }
    adj_r2(idx[seq_len(m)])
  }
  r2d <- replicate(R, one())
  r2d <- r2d[is.finite(r2d)]
  c(lo = unname(quantile(r2d, 0.05)),
    hi = unname(quantile(r2d, 0.95)))
}

