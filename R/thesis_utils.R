# =============================================================================
# R/thesis_utils.R
# -----------------------------------------------------------------------------
# Inference and plotting helpers shared across the analysis scripts. Sourced
# (after the library() calls and thesis_palette.R) by main_results.R, plots.R,
# robustness.R, strategy.R and empirical.R, so every chapter uses one HAC fit,
# one per-country driver and one figure theme rather than per-file copies.
# Behaviour is identical to the definitions these replaced.
# =============================================================================

# HAC (Newey-West) predictive regression for 12-month overlapping returns.
# Bandwidth L = ceil(max(1.5*h, 1.3*sqrt(T))). Returns one tidy row per
# coefficient: estimate, HAC standard error, t, regression R^2 and n.
hac_fit <- function(df, fml, h = 12, min_obs = 24) {
  fit <- tryCatch(lm(fml, data = df, na.action = na.omit),
                  error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  Tn <- stats::nobs(fit)
  if (Tn < min_obs) return(NULL)
  L <- ceiling(max(1.5 * h, 1.3 * sqrt(Tn)))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  ct <- lmtest::coeftest(fit, vcov. = V)
  tibble::tibble(
    term     = rownames(ct),
    estimate = ct[, 1],
    std_err  = ct[, 2],
    t        = ct[, 3],
    r_sq     = summary(fit)$r.squared,
    n        = Tn
  )
}

# Per-country HAC fit, stacked into one tidy frame over the G10 cross-section.
run_by_country <- function(df, fml) {
  split(df, df$country) %>%
    purrr::imap_dfr(function(d, cty) {
      res <- hac_fit(d, fml)
      if (is.null(res)) return(NULL)
      res$country <- cty
      res
    })
}

# Like hac_fit() but returns the fitted model, HAC vcov and bandwidth for
# downstream joint Wald tests.
hac_fit_full <- function(df, fml, h = 12, min_obs = 24) {
  fit <- tryCatch(lm(fml, data = df, na.action = na.omit),
                  error = function(e) NULL)
  if (is.null(fit) || stats::nobs(fit) < min_obs) return(NULL)
  L <- ceiling(max(1.5 * h, 1.3 * sqrt(stats::nobs(fit))))
  V <- tryCatch(sandwich::NeweyWest(fit, lag = L, prewhite = FALSE, adjust = TRUE),
                error = function(e) sandwich::vcovHC(fit))
  list(fit = fit, vcov = V, T_obs = stats::nobs(fit), lag = L)
}

# Joint HAC Wald p-value for the hypothesis that the given slope `terms`
# are all zero.
wald_p <- function(fit, V, terms) {
  b <- coef(fit)
  if (!all(terms %in% names(b))) return(NA_real_)
  bt <- b[terms]
  Vt <- V[terms, terms, drop = FALSE]
  W  <- tryCatch(as.numeric(t(bt) %*% solve(Vt) %*% bt), error = function(e) NA_real_)
  if (is.na(W)) return(NA_real_)
  stats::pchisq(W, df = length(bt), lower.tail = FALSE)
}

# Shared ggplot2 theme so every figure in the thesis has one consistent look.
# The strip.* settings only affect faceted plots; they are harmless on the
# non-faceted strategy figures.
theme_thesis <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(
    strip.background = ggplot2::element_rect(fill = "grey92", colour = NA),
    strip.text       = ggplot2::element_text(face = "bold"),
    legend.position  = "bottom",
    panel.grid.minor = ggplot2::element_blank(),
    plot.title       = ggplot2::element_text(face = "bold")
  )

# Render a data frame as a styled, PDF-able table grob: an optional bold title
# on top, the table in the middle, an optional grey footnote below. base_size
# is passed by every caller; note_lines sets the vertical space reserved for
# the footnote (the CP/DH replication tables use 3, the robustness subsample
# tables 4.5, everything else 4).
table_to_grob <- function(df, title = NULL, note = NULL, base_size = 9,
                          note_lines = 4) {
  tt <- gridExtra::ttheme_minimal(
    base_size = base_size,
    core    = list(fg_params = list(hjust = 1, x = 0.95)),
    colhead = list(fg_params = list(fontface = "bold")))
  tab   <- gridExtra::tableGrob(df, rows = NULL, theme = tt)
  parts <- list(tab); heights <- grid::unit(1, "null")
  if (!is.null(title)) {
    th <- grid::textGrob(title, gp = grid::gpar(fontface = "bold",
                         fontsize = base_size + 3), hjust = 0, x = 0.02)
    parts   <- c(list(th), parts)
    heights <- grid::unit.c(grid::unit(1.8, "lines"), heights)
  }
  if (!is.null(note)) {
    nt <- grid::textGrob(note, gp = grid::gpar(fontsize = base_size - 1, col = "grey30"),
                         hjust = 0, x = 0.02)
    parts   <- c(parts, list(nt))
    heights <- grid::unit.c(heights, grid::unit(note_lines, "lines"))
  }
  gridExtra::arrangeGrob(grobs = parts, ncol = 1, heights = heights)
}
