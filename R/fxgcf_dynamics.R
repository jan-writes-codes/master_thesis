# =============================================================================
# R/fxgcf_dynamics.R
# -----------------------------------------------------------------------------
# Properties and dynamics of the two global factors (thesis sub-question 3).
#
# The global cycle factor GCF prices the hedged, local-currency bond premium
# (duration / interest-rate-cycle risk); the FX-adjusted global cycle factor
# FXGCF prices the unhedged US-dollar premium (that same duration risk plus the
# currency leg). The object that isolates the FX component is therefore the
# WEDGE  w_t = FXGCF_t - GCF_t = sum_i w_i (CF_USD_i - CF_i).
#
# This script documents WHEN the two factors play different roles and WHY. It
# produces:
#   fxd_f1_rollcorr  -- 36-month rolling correlation of GCF and FXGCF over time
#   fxd_f2_regime    -- the rolling correlation against the G10 short-rate level
#                       (the two factors decouple in the high-rate regime and
#                        collapse onto each other at the synchronised ZLB)
#   fxd_t1_properties (numbers only; the .tex is hand-set from the console block)
#
# Run from the repository root, under the thesis-baseline (bottom-up) FXGCF:
#   FXGCF_METHOD=bu_gdp Rscript -e 'source("R/fxgcf_dynamics.R"); save_fxgcf_dynamics()'
# The console "HEADLINE SUMMARY" block prints every number quoted in the deck
# and in thesis/tables/fxd_t1_properties.tex.
# =============================================================================

suppressMessages({
  library(dplyr)
  library(ggplot2)
  library(zoo)
})

if (!exists("reg_data")) source("R/data_preparation.R")
source("R/thesis_palette.R")   # col_pri / col_sec / col_ter / col_qua
source("R/thesis_utils.R")     # theme_thesis

if (!identical(.FXGCF_METHOD, "bu_gdp"))
  warning("fxgcf_dynamics.R: thesis baseline is the bottom-up FXGCF; re-run with ",
          "FXGCF_METHOD=bu_gdp for numbers consistent with Chapter 7 (got '",
          .FXGCF_METHOD, "').")

ROLL <- 36L                          # rolling-window length in months
SPLIT <- as.POSIXct("2008-01-01")    # global-financial-crisis / ZLB regime break

# --- Series -----------------------------------------------------------------
# The two factors and the FX wedge, plus the GDP-weighted G10 one-year yield
# (the "level of rates", weighted exactly as the factors are) and the
# cross-country dispersion of one-year yields (how far monetary cycles are apart).
rates <- reg_data %>%
  dplyr::group_by(ym) %>%
  dplyr::summarise(
    short_lvl  = sum(w * y_1, na.rm = TRUE) / sum(w * is.finite(y_1), na.rm = TRUE),
    short_disp = stats::sd(y_1, na.rm = TRUE),
    .groups = "drop")

dyn <- fxgcf %>%
  dplyr::filter(!is.na(GCF), !is.na(FXGCF)) %>%
  dplyr::arrange(ym) %>%
  dplyr::mutate(wedge = FXGCF - GCF) %>%
  dplyr::left_join(rates, by = "ym")

# 36-month trailing correlation and trailing mean short-rate level.
dyn <- dyn %>%
  dplyr::mutate(
    roll_cor = zoo::rollapplyr(
      seq_len(dplyr::n()), ROLL,
      function(ix) stats::cor(GCF[ix], FXGCF[ix]), fill = NA_real_),
    roll_lvl = zoo::rollapplyr(short_lvl, ROLL, mean, na.rm = TRUE, fill = NA_real_))

# --- Scalar statistics for the properties table -----------------------------
ar1 <- function(x) { x <- x[!is.na(x)]; stats::cor(x[-1], x[-length(x)]) }
half_life <- function(rho) if (rho > 0 && rho < 1) log(0.5) / log(rho) else NA_real_

pre  <- dplyr::filter(dyn, date <  SPLIT)
post <- dplyr::filter(dyn, date >= SPLIT)

props <- tibble::tibble(
  factor  = c("GCF", "FXGCF", "Wedge"),
  mean    = c(mean(dyn$GCF),  mean(dyn$FXGCF),  mean(dyn$wedge)),
  sd      = c(sd(dyn$GCF),    sd(dyn$FXGCF),    sd(dyn$wedge)),
  ar1     = c(ar1(dyn$GCF),   ar1(dyn$FXGCF),   ar1(dyn$wedge)),
  hl      = c(half_life(ar1(dyn$GCF)), half_life(ar1(dyn$FXGCF)), half_life(ar1(dyn$wedge))),
  sd_pre  = c(sd(pre$GCF),    sd(pre$FXGCF),    sd(pre$wedge)),
  sd_post = c(sd(post$GCF),   sd(post$FXGCF),   sd(post$wedge)))

cor_full <- cor(dyn$GCF,  dyn$FXGCF)
cor_pre  <- cor(pre$GCF,  pre$FXGCF)
cor_post <- cor(post$GCF, post$FXGCF)
lvl_pre  <- mean(pre$short_lvl,  na.rm = TRUE)
lvl_post <- mean(post$short_lvl, na.rm = TRUE)
disp_pre  <- mean(pre$short_disp,  na.rm = TRUE)
disp_post <- mean(post$short_disp, na.rm = TRUE)
rc <- dplyr::filter(dyn, !is.na(roll_cor))
cor_rc_lvl <- cor(rc$roll_cor, rc$roll_lvl, use = "complete.obs")

# =============================================================================
# Figures
# =============================================================================
fxd_plots <- list()

# fxd_f1: the rolling correlation over time -- the "dynamics" exhibit.
fxd_plots$fxd_f1_rollcorr <- ggplot2::ggplot(
    dplyr::filter(dyn, !is.na(roll_cor)), ggplot2::aes(date, roll_cor)) +
  ggplot2::geom_hline(yintercept = cor_full, linetype = "dashed", colour = "grey55") +
  ggplot2::geom_vline(xintercept = as.numeric(SPLIT), linetype = "dotted", colour = "grey40") +
  ggplot2::geom_line(colour = col_pri, linewidth = 0.6) +
  ggplot2::annotate("text", x = SPLIT, y = min(dyn$roll_cor, na.rm = TRUE),
                    label = "  2008", hjust = 0, vjust = 0, size = 3, colour = "grey40") +
  ggplot2::annotate("text", x = min(dyn$date), y = cor_full,
                    label = sprintf("full-sample %.2f  ", cor_full),
                    hjust = 0, vjust = -0.5, size = 3, colour = "grey45") +
  ggplot2::scale_y_continuous(limits = c(min(0, min(dyn$roll_cor, na.rm = TRUE)), 1)) +
  ggplot2::scale_x_datetime(date_breaks = "5 years", date_labels = "%Y") +
  ggplot2::labs(
    title = "Dynamics of the two global factors: 36-month rolling correlation",
    subtitle = sprintf("cor(GCF, FXGCF): %.2f before 2008, %.2f after", cor_pre, cor_post),
    x = NULL, y = expression(rho[36](GCF, FXGCF))) +
  theme_thesis

# fxd_f2: the same rolling correlation against the GDP-weighted G10 short rate.
# Two stacked panels share the date axis: the factors decouple exactly when the
# level of rates is high (wide differentials, active carry channel) and converge
# as rates fall to the synchronised zero lower bound.
p_cor <- ggplot2::ggplot(dplyr::filter(dyn, !is.na(roll_cor)),
                         ggplot2::aes(date, roll_cor)) +
  ggplot2::geom_vline(xintercept = as.numeric(SPLIT), linetype = "dotted", colour = "grey40") +
  ggplot2::geom_line(colour = col_pri, linewidth = 0.6) +
  ggplot2::scale_y_continuous(limits = c(min(0, min(dyn$roll_cor, na.rm = TRUE)), 1)) +
  ggplot2::scale_x_datetime(date_breaks = "5 years", date_labels = "%Y",
                            limits = range(dyn$date)) +
  ggplot2::labs(
    title = sprintf("The FX premium decouples in the high-rate regime (corr = %.2f)", cor_rc_lvl),
    subtitle = "36-month rolling correlation of GCF and FXGCF",
    x = NULL, y = expression(rho[36])) +
  theme_thesis +
  ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                 axis.ticks.x = ggplot2::element_blank())

p_lvl <- ggplot2::ggplot(dplyr::filter(dyn, !is.na(roll_lvl)),
                         ggplot2::aes(date, roll_lvl)) +
  ggplot2::geom_vline(xintercept = as.numeric(SPLIT), linetype = "dotted", colour = "grey40") +
  ggplot2::geom_line(colour = col_sec, linewidth = 0.6) +
  ggplot2::scale_y_continuous(labels = function(x) paste0(x, "%")) +
  ggplot2::scale_x_datetime(date_breaks = "5 years", date_labels = "%Y",
                            limits = range(dyn$date)) +
  ggplot2::labs(subtitle = "GDP-weighted G10 one-year yield (36-month mean)",
                x = NULL, y = "Short rate") +
  theme_thesis

fxd_plots$fxd_f2_regime <- gridExtra::arrangeGrob(
  p_cor, p_lvl, ncol = 1, heights = grid::unit(c(1.35, 1), "null"))

# =============================================================================
# Console summary -- every number quoted in the thesis text and the .tex table.
# =============================================================================
cat("\n===== FXGCF DYNAMICS -- HEADLINE SUMMARY [", .FXGCF_METHOD, "] =====\n", sep = "")
cat(sprintf("sample: %s to %s  (%d months)\n",
            format(min(dyn$date)), format(max(dyn$date)), nrow(dyn)))
cat("\n-- Properties of GCF, FXGCF and the wedge --\n")
print(as.data.frame(props %>% dplyr::mutate(dplyr::across(where(is.numeric), ~round(.x, 3)))),
      row.names = FALSE)
cat(sprintf("\n-- Correlation by regime (break at %s) --\n", format(SPLIT, "%Y")))
cat(sprintf("cor(GCF, FXGCF): full = %.3f | pre-2008 = %.3f | post-2008 = %.3f\n",
            cor_full, cor_pre, cor_post))
cat(sprintf("mean G10 short rate (GDP-wtd): pre-2008 = %.2f%% | post-2008 = %.2f%%\n",
            lvl_pre, lvl_post))
cat(sprintf("mean cross-country yield dispersion: pre-2008 = %.2f | post-2008 = %.2f\n",
            disp_pre, disp_post))
cat(sprintf("cor(36m rolling correlation, 36m short-rate level) = %.3f\n", cor_rc_lvl))
cat(sprintf("36m rolling correlation: min = %.2f | mean = %.2f | max = %.2f\n",
            min(rc$roll_cor), mean(rc$roll_cor), max(rc$roll_cor)))

# =============================================================================
# Write the figures to disk as vector PDFs (tables are hand-set from the block).
# =============================================================================
save_fxgcf_dynamics <- function(fig_dir = "thesis/figures") {
  dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(file.path(fig_dir, "fxd_f1_rollcorr.pdf"),
                  fxd_plots$fxd_f1_rollcorr, width = 9, height = 5.0)
  ggplot2::ggsave(file.path(fig_dir, "fxd_f2_regime.pdf"),
                  fxd_plots$fxd_f2_regime, width = 9, height = 6.0)
  invisible(file.path(fig_dir, c("fxd_f1_rollcorr.pdf", "fxd_f2_regime.pdf")))
}
