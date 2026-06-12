# thesis_palette.R
# =============================================================================
# Single source of truth for the thesis colour scheme. Sourced by plots.R,
# main_results.R, robustness.R and strategy.R so every figure draws from the
# same palette.
#
# Scheme: a muted teal/amber pairing, extended by plum and olive for 3- and
# 4-way comparisons. Roles, applied consistently across all figures:
#   col_pri -- deep teal   : the headline series of a figure (local factor,
#              fitted lines, the strategy under test)
#   col_sec -- burnt amber : the contrasting series (global factor, benchmark,
#              alternative construction)
#   col_ter -- muted plum  : third series in 3+-way comparisons
#   col_qua -- olive       : fourth series
# Diverging gradients (signed quantities such as correlations) run
# amber <- white -> teal, i.e. col_sec <- "white" -> col_pri; sequential
# gradients run "white" -> col_pri.
# =============================================================================

col_pri <- "#0F766E"  # deep teal
col_sec <- "#B45309"  # burnt amber
col_ter <- "#6A4C93"  # muted plum
col_qua <- "#4D7C0F"  # olive

# Bond maturities on an ordered dark-teal -> amber ramp, so the maturity
# ordering reads off the hue while staying inside the scheme.
mat_palette <- setNames(
  grDevices::colorRampPalette(
    c("#083F3B", "#0F766E", "#58A38F", "#C9A227", "#8C4A0F")
  )(6),
  c("1Y", "2Y", "4Y", "5Y", "9Y", "10Y")
)

# Qualitative palette for the G10+ country panel: muted tones anchored on the
# four scheme colours, with the US in near-black slate as the reference market.
country_palette <- c(
  US = "#37474F", DE = "#0F766E", GB = "#B45309", FR = "#6A4C93",
  JP = "#4D7C0F", IT = "#94434E", CA = "#8A5A3B", CH = "#4A7BA6",
  SE = "#C9A227", NL = "#B07AA1", BE = "#7FA074"
)
