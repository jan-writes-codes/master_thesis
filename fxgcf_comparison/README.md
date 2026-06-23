# FXGCF Construction Comparison

A standalone slide deck (and the R analysis behind it) responding to the
supervisor's concern that the thesis's **FX-adjusted global cycle factor
(FXGCF)** is almost perfectly correlated with the **global cycle factor (GCF)**
— ρ ≈ **0.99** in our sample, against the ≈ **0.50** that Dahlquist–Hasseltoft
(2013) report for their FX-adjusted factor.

The deck builds the FXGCF three ways (plus one control that completes a 2×2
design) and compares them on (a) correlation with the GCF and with each other,
and (b) in-sample and fully-recursive out-of-sample predictive power.

## The constructions compared

All four use the **same** cycle predictors — the 1-year cycle `c⁽¹⁾` and the
average cycle `c̄` — and predict the **US-dollar** excess return
`rx_USD_{i,t+12}`. They differ only in *construction* (top-down vs bottom-up) and
*weighting* (GDP vs 1/n):

| # | Construction | Weights | Definition |
|---|--------------|---------|------------|
| **M1** | top-down *(current)* | GDP | `FXGCF = fitted( Σ wᵢ·rx_USDᵢ ~ Σ wᵢ·c⁽¹⁾ᵢ + Σ wᵢ·c̄ᵢ )` |
| **M2** | top-down | 1/n | as M1 with `wᵢ → 1/n` in all aggregates |
| **M3** | bottom-up | GDP | `FXCFᵢ = fitted(rx_USDᵢ ~ c⁽¹⁾ᵢ + c̄ᵢ)`; `FXGCF = Σ wᵢ·FXCFᵢ` |
| **M4** | bottom-up | 1/n | `FXGCF = (1/n) Σ FXCFᵢ` (control) |

**M1–M3 are the three methods requested.** M3 is exactly the GCF recipe
(`GCF = Σ wᵢ·CFᵢ`) with the US-dollar return on the left instead of the
local-currency return — `FXCFᵢ` is the `CF_USD` already built per country in
`R/data_preparation.R`. **M4** completes the construction × weighting grid so the
GCF-correlation can be attributed to one axis or the other.

## Key findings

| Construction | Weights | cor(·, GCF) | mean IS R² | \|t\|>1.96 | pooled OOS R² | OOS⁺ |
|---|---|---|---|---|---|---|
| top-down *(current)* | GDP | **0.99** | 0.095 | 4/11 | +0.002 | 9/11 |
| top-down | 1/n | 0.94 | 0.106 | 7/11 | **+0.027** | 8/11 |
| bottom-up | GDP | **0.78** | **0.143** | **10/11** | +0.019 | 6/11 |
| bottom-up | 1/n | 0.73 | 0.141 | 9/11 | +0.015 | 6/11 |
| *GCF (reference)* | GDP | 1.00 | 0.080 | 3/11 | −0.071 | 2/11 |

1. **Construction is the lever, not weighting.** Going bottom-up cuts the
   GCF-correlation from 0.99 to ~0.78; equal-weighting alone only reaches 0.94.
2. **No trade-off in sample.** The bottom-up factor is *both* less collinear with
   the GCF *and* more predictive (mean R² 14.3% vs 9.5%, significant in 10/11
   markets vs 4/11).
3. **All four beat the unadjusted GCF out of sample** (−0.071). The current
   top-down factor is the *weakest* of the four OOS; top-down/equal and
   bottom-up/GDP lead. The OOS ranking is sample-dependent (bottom-up wins the
   euro area; top-down/equal wins CA/SE/CH).
4. **None reaches DH's 0.50** — all reuse the same bond-cycle predictors. Truly
   decoupling the FX factor would need a *currency-specific* predictor (e.g. the
   short-rate differential / carry); that is the recommended extension.

**Recommendation:** replace the top-down FXGCF with the **bottom-up,
GDP-weighted** version (M3) — symmetric with the GCF, much less collinear, and
more powerful — with the carry-augmented factor as the follow-up.

## Reproduce

Run from the **repository root** (sources `R/oos.R`, which sources
`R/data_preparation.R`):

```sh
Rscript fxgcf_comparison/build_comparison.R     # -> figures/*.pdf, tables/*.tex, console summary
cd fxgcf_comparison && latexmk -pdf main.tex    # -> main.pdf
```

`build_comparison.R` is deterministic; the console "HEADLINE SUMMARY" block
prints every number quoted in the deck. In-sample metrics use the common
412-month panel; out-of-sample metrics are scored on a common
(country, month) sample so the recursive burn-ins cannot confound the ranking. Figures are written as PDFs and tables as
native LaTeX (`tables/*.tex`, `\input` into the deck) to match the style of
`final_presentation/`.

## Files

```
build_comparison.R   the analysis: builds M1–M4 (in- and out-of-sample),
                     correlations, predictive power, and all exhibits
main.tex             the Beamer deck (Madrid theme, thesis colours)
references.bib       bibliography (shared with the other decks)
figures/             fx_f1_timeseries, fx_f2_corr_gcf, fx_f3_corr_heatmap,
                     fx_f4_is_r2, fx_f5_oos_r2  (.pdf)
tables/              fx_t1_summary, fx_t2_corr, fx_t3_is_r2, fx_t4_oos_r2 (.tex)
```

The compiled `main.pdf` and LaTeX logs are git-ignored (rebuild from source).
