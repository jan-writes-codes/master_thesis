# Exhibit data discrepancies — resolved

**Date:** 2026-08 · **Status:** ✅ RESOLVED by a pipeline re-run · **Checklist item:** X-2

The three stale tables recorded here have been corrected from a fresh run of the R
pipeline. This document now records what was found, what was changed, and how the
result was verified. The original open-question version is in the git history.

---

## How the numbers were regenerated

The pipeline was re-run from `data.xlsx` on the current source tree.

> **One setup detail that matters.** The pipeline's default `FXGCF_METHOD` is
> `td_gdp` (top-down, GDP-weighted), and `data_preparation.R` calls that the
> baseline. **The thesis baseline is bottom-up.** A first run on the default
> produced a Phase III block that did not match the committed
> `mr_t3_phase3.tex`. Re-running with `FXGCF_METHOD=bu_gdp` reproduced that table
> cell for cell, which establishes `bu_gdp` as the mode the thesis exhibits were
> built under. Anyone re-running this pipeline needs to set that variable.

**Validation before any number was changed.** The fresh run reproduces
`mr_t1_phase1` (Table 3), `mr_t4_oos` (Table 4) and `mr_t3_phase3` (Table 6)
exactly, and it reproduces the committed R-generated PDFs `mr_t1b_maturity.pdf`
and `mr_t2_phase2.pdf` exactly. The environment therefore matches the one the
exhibits were originally produced in, and the only stale artefacts were the
hand-transcribed `.tex` files.

---

## 1. `mr_t1b_maturity` → **Table B.1**, "Phase I by maturity" ✅ FIXED

Commit `57e223f` *"Propagate Japan imputation to all exhibit tables"* (2026-07-11)
regenerated this table's **PDF** but never updated its **`.tex`**. The propagation
missed it.

Japan's three rows and the pooled row were corrected. The other nine countries were
already right.

| Row | Maturity | Was (β, *t*, R²) | Now (β, *t*, R²) |
|---|---|---|---|
| Japan | 2Y | 0.57, (1.97), 0.126 | **0.56, (2.32), 0.173** |
| Japan | 5Y | 1.23, (2.60), 0.167 | **1.23, (3.10), 0.238** |
| Japan | 10Y | 1.20, (3.20), 0.203 | **1.21, (3.81), 0.283** |
| G10 panel | 2Y | 0.78, (14.32), 0.253 | **0.78, (14.33), 0.254** |
| G10 panel | 5Y | 1.16, (17.25), 0.271 | **1.16, (17.26), 0.274** |
| G10 panel | 10Y | 1.06, (15.44), 0.243 | **1.06, (15.56), 0.246** |

Japan's fit rises materially. The pooled row moves only in the last digit.

### Effect on the surrounding prose — no edit needed

Every claim was re-checked against the new numbers and all of them still hold.

| Claim in `07_results.tex` | Verdict |
|---|---|
| *"significantly so in ten of the eleven"* | ✅ Japan's 2Y *t* rises 1.97 → 2.32, which strengthens it |
| *"pooled values of 0.78, 1.16 and 1.06"* | ✅ the pooled betas did not move |
| *"near 0.6–0.9 at two years"* | ✅ Japan 0.57 → 0.56, still rounds into range |
| *"1.1–1.3 at five"* | ✅ unchanged |
| *"1.0–1.2 at ten"* | ✅ left as written. Japan goes 1.20 → 1.21, but France was already 1.22 in the committed table, so this was always a rounded characterisation rather than a strict bound. The sentence opens with *"near"*, which governs all three ranges |
| *"35% at ten years for the US and 36% at five for the Netherlands"* | ✅ 0.347 and 0.358 are still the maxima, and neither is a Japan cell |

---

## 2. `mr_t2_phase2` → **Table 5**, "Phase II" ✅ FIXED

A transcription slip rather than staleness — both sides were touched by the same
commit. Switzerland's two $p$-value cells read `0.012` against `0.010` in the R
output. Every other cell in the table already matched.

Corrected to **0.010** in both cells. No significance statement changes, and the
prose quotes neither number.

---

## 3. `rob_t7_fxgcf_construction` → **Table 20** ✅ FIXED — larger than first thought

Found by the supervisor, whose annotation on page 61 asked *"0.81 — is this
consistent with Table 6.5?"*. It was not.

**The earlier version of this document was wrong about the scope.** It reasoned that
because the baseline row's mean in-sample R² (0.143) and OOS+ count (6/11) matched
Table 4, only two cells were stale. That inference does not hold — **all four rows
moved.**

The reason is that `rob_t7` is not produced by the main pipeline at all. It was
transcribed from `fxgcf_comparison/tables/fx_t1_summary.tex`, built by
`fxgcf_comparison/build_comparison.R`, and **that file was itself stale** — commit
`57e223f` never touched the `fxgcf_comparison/` directory. Re-running
`build_comparison.R` regenerated it, and the thesis table was then transcribed from
the fresh output.

| Construction | Corr(·,GCF) | Mean IS R² | \|t\|>1.96 | pooled R²ₒₒₛ | OOS+ |
|---|---|---|---|---|---|
| Bottom-up GDP (baseline) | 0.78 → **0.81** | 0.143 | 10/11 | +0.019 → **+0.021** | 6/11 |
| Bottom-up 1/n | 0.73 → **0.76** | 0.141 → **0.140** | 9/11 → **10/11** | +0.015 → **+0.016** | 6/11 |
| Top-down GDP | 0.99 | 0.095 → **0.101** | 4/11 → **5/11** | +0.002 → **+0.010** | 9/11 |
| Top-down 1/n | 0.94 → **0.95** | 0.106 → **0.109** | 7/11 → **6/11** | +0.027 → **+0.033** | 8/11 |

The baseline row now reconciles the two things that never lined up. **0.81** agrees
with the Table 6 note and with the prose in Chapters 5, 7 and 8, and **+0.021**
agrees with Table 4's pooled `rx_USD ~ FXGCF`.

### Effect on the surrounding prose — three edits

`08_robustness.tex` was already quoting the *fresh* values in three places (*"0.10
for the top-down ones"*, *"rises from five to ten"*, *"+0.010 to +0.033"*), which is
independent confirmation that the re-run is the right target and that only the table
lagged. Two ranges were stale and one needed tightening.

- *"top-down variants correlate 0.94–0.99"* → **0.95–0.99**
- *"bottom-up variants correlate only 0.73–0.78"* → **0.76–0.81**
- *"against 0.10 for the top-down ones"* → **0.10–0.11**, because the top-down 1/n
  variant is 0.109 and rounds up

---

## 4. Also corrected while re-running

**`mr_f3_usd_r2.pdf`** still carried an *"FX-adjusted"* axis title from before the
G-4 rename, because the earlier rename touched the R sources but no figure had been
regenerated since. Rebuilt from the same workspace. The figure uses `expression()`
rather than `latex2exp::TeX()`, so it regenerates faithfully in an environment
without CRAN access.

**A figure note that misdescribed its own figure.** The Phase III paragraph read
*"the dark blue bars for the foreign markets are only a fraction of their
local-currency heights."* `mr_f3_usd_r2` plots **two US-dollar series only**
(`rx_USD ~ GCF` and `rx_USD ~ FXGCF`). There are no local-currency bars in it. The
sentence now reads *"run from four to thirteen percent, far below the
local-currency fits of \Cref{tab:mr-phase2},"* which is what the figure shows and
attributes the local-currency comparison to the table that actually carries it.
This is the same class of error found earlier in three other figure notes under G-9.

**`mr_t3_phase3.pdf` and `mr_t4_oos.pdf`** were refreshed. Their numbers were already
correct — they differed from the fresh run only in carrying the pre-rename
*"FX-adjusted"* label, so the reference artefacts now match the R source.

---

## 5. Verification

- Fresh run reproduces `mr_t1_phase1`, `mr_t1b_maturity`, `mr_t2_phase2`,
  `mr_t3_phase3` and `mr_t4_oos` with **no numeric differences**.
- Clean rebuild — 0 errors, 0 undefined references, 0 multiply-defined labels,
  0 overfull boxes, no `??`, 83 pages.
- Zero occurrences of `FX-adjusted` or `FX-adj` anywhere in the rendered PDF,
  figures included.
- Every corrected row was read back out of `main.pdf` to confirm it renders as
  intended.

## 6. What this does not cover

`strategy.R` and `empirical.R` were not re-run, so `strat_t4_subperiod`,
`strat_t5_costs`, `cp_t1`, `dh_t1b_inputs`, `fxd_t1_properties`, `mr_t2b_gcf_corr`
and `mr_t2c_fx_cycle` remain unverified against fresh output. None of them has a
committed PDF, so they cannot be checked the cheap way either. They were not
implicated in any of the three defects found, but the lesson of §3 is that a table
outside the main pipeline can go stale silently, and `fxd_t1_properties` and
`mr_t2c_fx_cycle` are the ones most exposed to the Japan splice.
