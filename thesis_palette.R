# thesis_palette.R
# =============================================================================
# Single source of truth for the thesis colour scheme. Sourced by plots.R,
# main_results.R, robustness.R and strategy.R so every figure draws from the
# same palette.
#
# Scheme: two fixed brand palettes, used together.
#   "Friend" palette   #3333AB #AE97FF #4D9F8B #005242 -> series roles
#   "Neighbor" palette #3333AB #79B5BF #008493 #324B4F -> ordered ramps
#
# Roles, applied consistently across all figures:
#   col_pri -- indigo   #3333AB : the headline series of a figure (local
#              factor, fitted lines, the strategy under test)
#   col_sec -- sage     #4D9F8B : the contrasting series (global factor,
#              benchmark, alternative construction)
#   col_ter -- lavender #AE97FF : third series in 3+-way comparisons
#   col_qua -- forest   #005242 : fourth series
# Diverging gradients (signed quantities such as correlations) run
# sage <- white -> indigo, i.e. col_sec <- "white" -> col_pri; sequential
# gradients run "white" -> col_pri.
# =============================================================================

col_pri <- "#3333AB"  # indigo
col_sec <- "#4D9F8B"  # sage
col_ter <- "#AE97FF"  # lavender
col_qua <- "#005242"  # forest

# Bond maturities on the ordered light-steel -> teal -> dark-slate ramp of the
# neighbor palette, so maturity ordering reads off the luminance.
mat_palette <- setNames(
  grDevices::colorRampPalette(c("#79B5BF", "#008493", "#324B4F"))(6),
  c("1Y", "2Y", "4Y", "5Y", "9Y", "10Y")
)

# Qualitative palette for the G10+ country panel: the seven distinct brand
# colours plus four in-family variants, with the US in indigo as the
# reference market.
country_palette <- c(
  US = "#3333AB", DE = "#008493", GB = "#005242", FR = "#AE97FF",
  JP = "#4D9F8B", IT = "#324B4F", CA = "#79B5BF", CH = "#8893D6",
  SE = "#1F2566", NL = "#63B0A0", BE = "#54668E"
)
