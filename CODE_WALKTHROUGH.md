# Code Walkthrough

A guided tour of the R analysis pipeline behind *Expected Returns in International
Government Bond Markets* (Heissenberger, WU Vienna). This is the companion to
[`README.md`](README.md): the README is the map, this document is the tour. It
explains **what each script does, how the pieces connect, and why the code is
written the way it is**, tying every step back to the thesis equations and
chapters.

Read it top to bottom the first time; afterwards use the
[factor glossary](#factor-glossary) and the [equation → code map](#equation--code-map)
as quick reference.

---

## 1. The big idea in one picture

The project takes the Cieslak–Povala (2015, "CP") *cycle factor* of US bond
return predictability and carries it to the **G10** government-bond cross-section,
then builds two aggregates: a GDP-weighted **global cycle factor (GCF)** and a
**novel FX-adjusted global cycle factor (FXGCF)** for a US-dollar investor.

Everything in the codebase is the construction and evaluation of one **factor
chain**. Each arrow is a regression or an aggregation:

```
                 CPI ──► trend inflation π̄          (Eq 3, EWMA 120m)
                          │
        yields y⁽ⁿ⁾ ──────┤
                          ▼
        cycles c⁽ⁿ⁾ = resid( y⁽ⁿ⁾ ~ π̄ )            (Eq 1–2, per country×maturity)
                          │  pick c⁽¹⁾ and  c̄ = mean of c⁽ⁿ⁾, n≠1
                          ▼
   local CF = fitted( rx ~ c⁽¹⁾ + c̄ )               (Eq 6)   ── per country
                          │  GDP-weight across countries (Eq 7–8)
                          ▼
        global GCF = Σ wᵢ · CFᵢ
                          │  redo for a USD investor (FX-adjusted returns)
                          ▼
        FXGCF = fitted( r̄x^USD ~ avg cycle predictors )   (DH top-down)   ◄── novel
```

Running alongside this *cycle-based* chain is a *forward-based* comparator chain
— the classic CP (2005) / Dahlquist–Hasseltoft (2013) factor **CP** and its
global aggregate **GCP** — so the thesis can show what the macro-anchored cycle
adds over the standard forward-rate factor.

Every factor exists in two flavours:

* **in-sample** (full-sample coefficients) — built in `data_preparation.R`;
* **out-of-sample** (`_oos`, fully recursive, no look-ahead) — built in `oos.R`.

If you understand the chain above, the rest of the codebase is just (a) building
it carefully, (b) building a real-time version of it, and (c) drawing tables,
figures and a trading strategy from it.

---

## 2. How the scripts fit together

Eleven scripts in `R/`, in dependency order:

```
                        ┌───────────────────────┐
                        │  data_preparation.R   │  the estimation backbone
                        │  (builds the chain)   │  → reg_data, gcf, gcp, fxgcf
                        └───────────┬───────────┘
                                    │ source()
        ┌──────────────┬───────────┼──────────────────────────┐
        ▼              ▼            ▼                           ▼
 ┌────────────┐ ┌────────────┐ ┌────────┐              (helpers, sourced
 │cp_inference│ │cp_montecar.│ │ oos.R  │  recursive     everywhere)
 │  .R        │ │  lo.R      │ │ _oos   │  factors +     ┌──────────────────┐
 └─────┬──────┘ └─────┬──────┘ │  + CT  │  Campbell–     │ thesis_utils.R   │
       │              │        │   R²   │  Thompson R²    │ thesis_palette.R │
       │              │        └───┬────┘                └──────────────────┘
       ▼              ▼            │
 ┌──────────────────────┐         │
 │     empirical.R      │◄────────┘   replication tables (CP, DH)
 └──────────────────────┘
       the exhibit layer also includes (each source()s oos.R or data_preparation.R):
       main_results.R · plots.R · robustness.R · strategy.R
```

**Key conventions used throughout**

* Each script `source()`s its own dependencies, *guarded by an `exists()` check*,
  so any one script can be run standalone and nothing is rebuilt twice.
* The **estimation scripts run on `source()`** (they leave data frames in the
  workspace). The **exhibit scripts build their plots/tables into a list on
  `source()` but only write files when you call their `save_*()` function**
  (`save_all_tables()`, `save_all_plots()`, `save_main_results()`,
  `save_robustness()`, `save_strategy()`). This lets you inspect an exhibit
  interactively before committing it to disk.
* Everything is **deterministic** — every bootstrap / Monte-Carlo carries an
  explicit `seed`, so a clean run reproduces every number.
* Exhibits are written as real files into `thesis/figures` and `thesis/tables`
  (no symlinks) so the project imports cleanly into Overleaf.

---

## 3. Data inputs

One workbook, `data.xlsx`, read in `data_preparation.R`. Monthly series are
end-of-month (EOM), 1999–2026, G10 + a few extras (BE, NL, CH, SE …).

| Sheet | Contents | Used for |
|-------|----------|----------|
| `curve_translation` | maps Bloomberg indicator codes → `country`, `currency` | renaming yield columns; currency lookup |
| `fx` | FX rates (USD per unit foreign ccy), EOM | USD excess returns; GDP conversion |
| `yields` | zero-coupon yields, columns like `…I123 10Y…` | the whole curve; cycles, returns, forwards |
| `inflation` | **core** CPI by country | trend inflation π̄ |
| `inflation_reg` | **headline** CPI by country | robustness check (core vs headline) |
| `gdp` | nominal GDP, local currency, end-of-year | GDP weights (after FX conversion to USD) |

The maturity menu is **non-contiguous**: `{1, 2, 4, 5, 9, 10}` years. This single
fact explains several pieces of otherwise-odd code (e.g. how forwards are built
in §4.6 and which maturities the cycle average skips).

Two open data caveats are flagged in the source as `@todo`: a possible offset in
the Belgian inflation column, and the desire for a longer inflation history.

---

## 4. The estimation backbone — `data_preparation.R`

This is the heart of the project (419 lines). It reads `data.xlsx` and builds the
entire in-sample factor chain, leaving these objects in the workspace for everyone
downstream: **`reg_data`** (the country-month panel with every factor), **`gcf`**,
**`gcp`**, **`fxgcf`**, plus `cycle`, `cycle_avg`, `inflation_long`, `yields_long`,
`fx_long`, `gdp`.

We'll walk it in the order it executes.

### 4.1 Load & tidy (lines 11–80)

Reads each sheet, builds a `ym` integer key (`YYYYMM`) used for all later joins,
and renames the wide yield columns from Bloomberg codes to `Country_Maturity`
(e.g. `CA_1`) via a regex + `curve_map` lookup, then pivots long
(`yields_long`: one row per country×maturity×month).

GDP gets special handling: it arrives in local currency, so it is converted to
USD using **year-end** FX (`fx_eoy`) before being used for weights — a country's
weight should reflect its economic size in a common numéraire, not its exchange
rate's drift.

### 4.2 Trend inflation π̄ — Equation 3 (lines 83–122)

The macro anchor. Trend inflation is an exponentially-weighted moving average of
year-over-year inflation over a 10-year window:

```r
v <- 0.987          # decay
M <- 120            # 10-year window (months)
weights <- v^(0:(M-1))
weights_norm <- (1 - v) / (1 - v^M) * weights   # normalised to sum to 1
```

`cp_trend()` applies these weights to each country's YoY inflation vector (most
recent month gets weight `j=0`). Two real-time details matter:

* **Publication lag.** At month-end *t* the latest CPI print is for month *t−1*
  (February's CPI is released in March). The code therefore lags CPI one month
  (`cpi_rt = lag(cpi, 1)`) and computes YoY from that, so π̄ uses only
  information actually known at *t*.
* π̄ is **backward-looking by construction**, which is why `oos.R` can reuse it
  as-is without re-deriving it recursively.

### 4.3 Yield cycles — Equations 1–2 (lines 125–141)

The cycle is the part of each yield orthogonal to trend inflation. For every
`country × maturity`:

```r
fit   <- lm(yield ~ trend_inf, ...)
cycle <- residuals(fit)            # c⁽ⁿ⁾_{i,t}
```

The intercept `alpha` and slope `beta` (the yield's loading on π̄) are kept too —
`plots.R` charts the β loadings by maturity.

### 4.4 Excess returns — Equations 10–11 (lines 144–200)

Yields are pivoted wide (`y_1 … y_10`). 12-month holding-period **log excess
returns** on an *n*-year zero, using the log-price identity `p⁽ⁿ⁾ = −n·y⁽ⁿ⁾`:

```r
rx_2_t12  = 2  * y_2  - 1 * y1_lead  - y_1     # Eq 10
rx_5_t12  = 5  * y_5  - 4 * y4_lead  - y_1
rx_10_t12 = 10 * y_10 - 9 * y9_lead  - y_1
```

`*_lead` are the yields 12 months ahead (`lead(·,12)`); the suffix `_t12`
marks a *forward-looking* return known only at *t+12*. The lagged columns
(`rx_2 = lag(rx_2_t12, 12)`) line a realized return up with the date it was
*earned by*, which is what the predictive regressions need.

For the **USD investor** (Eq 11) the same returns are converted with the 12-month
log FX return and financed at the US short rate:

```r
s = log(fx_USD); fx_ret_t12 = (lead(s,12) - s) * 100
rx_10_USD_t12 = rx_10_t12 + y_1 + fx_ret_t12 - y1_US
```

i.e. *local excess return + own short rate + currency move − US short rate.*

### 4.5 Duration-standardised, maturity-averaged returns — Equations 12–14 (lines 206–238)

To make a 2-year and a 10-year bond comparable, each return is divided by its
duration (`D_n = n` for a zero) and averaged across the K=3 maturities:

```r
rx_t12 = (1/3) * (rx_2_t12/2 + rx_5_t12/5 + rx_10_t12/10)   # local
rx_USD_t12 = (1/3) * (rx_2_USD/2 + rx_5_USD/5 + rx_10_USD/10)  # USD investor
```

`rx_t12` (local) and `rx_USD_t12` (USD) are the dependent variables for the cycle
factor. The maturity-specific `rx_2_t12 … rx_10_t12` are kept for the CP Table-4
"predict each maturity individually" exhibits.

### 4.6 Forwards for the CP (2005) / DH (2013) factor (lines 241–256)

The comparator factor regresses returns on a menu of **forward rates**. Because
the maturity grid is non-contiguous, the code uses a 1-year forward where
maturities are adjacent and a per-annum forward where they are not:

```r
f_2  = 2*y_2 - 1*y_1                 # 1y forward, year 1→2
f_4  = (4*y_4 - 2*y_2) / 2           # per-annum forward, year 2→4
f_5  = 5*y_5 - 4*y_4                 # 1y forward, year 4→5
f_9  = (9*y_9 - 5*y_5) / 4           # per-annum forward, year 5→9
f_10 = 10*y_10 - 9*y_9               # 1y forward, year 9→10
```

### 4.7 Assembling the panel and the **local cycle factor CF** — Equation 6 (lines 259–319)

The per-maturity cycles are pivoted to columns (`cycle_1y … cycle_10y`), the
average cycle `c_bar` is the mean over maturities ≠ 1, and everything (cycles,
returns, forwards, GDP) is joined into **`reg_data`**.

Time-varying **GDP weights** are computed *within the estimation panel each month*
so they always sum to 1 (Eq 8):

```r
group_by(ym) %>% mutate(w = gdp_val / sum(gdp_val))
```

Then, per country, four predictive regressions produce four fitted factors:

```r
CF     = fitted( rx_t12     ~ cycle_1y + c_bar )          # Eq 6 — local cycle factor
CF_USD = fitted( rx_USD_t12 ~ cycle_1y + c_bar )          # USD analog
CP     = fitted( rx_t12     ~ y_1 + f_2+f_4+f_5+f_9+f_10) # CP 2005 / DH 2013 forward factor
CP_USD = fitted( rx_USD_t12 ~ y_1 + f_2+f_4+f_5+f_9+f_10) # USD analog
```

> **CF vs CP** is the central methodological contrast of the thesis: the
> two-regressor *cycle* factor (macro-anchored) against the six-regressor
> *forward* factor (the established benchmark).

### 4.8 Global aggregates GCF and GCP — Equations 7–8 (lines 322–344)

GDP-weighted cross-country averages of the local factors:

```r
GCF = Σ wᵢ · CFᵢ      # global cycle factor
GCP = Σ wᵢ · CPᵢ      # global forward (CP) factor
```

### 4.9 The novel **FXGCF** — DH-faithful top-down (lines 347–388)

This is the thesis's own contribution, and the construction is deliberate. The
FX-adjusted global factor is **not** a regression on GCF (that would just be an
affine rescaling of GCF). Following Dahlquist–Hasseltoft, it is the **fitted
value of the GDP-weighted average USD excess return on the GDP-weighted average
cycle predictors**:

```r
rx_USD_bar_t12 ~ cyc1_bar + cbar_bar      # top-down regression
FXGCF = fitted(...)                       # then read off for every month
```

A sanity line prints `cor(GCF, FXGCF)`; DH report ≈ 0.50, confirming FXGCF
carries genuinely different (currency-driven) information rather than being
collinear with GCF.

### 4.10 Tail of the file (lines 401–419)

A small inline CP-2015 sanity replication for the US (e.g. `cor(c_bar, CF) ≈
0.61`, matching the paper's Figure 2). These are quick checks, not exhibits.

---

## 5. Shared helpers

### 5.1 `thesis_utils.R` — inference & table plumbing

One copy of the machinery every chapter reuses:

| Function | What it does |
|----------|--------------|
| `hac_fit(df, fml, h=12)` | OLS predictive regression with **Newey–West HAC** SEs (bandwidth `L = ⌈max(1.5h, 1.3√T)⌉`); returns a tidy row per coefficient with estimate, HAC SE, *t*, R², n. The standard fix for overlapping-return regressions. |
| `run_by_country(df, fml)` | runs `hac_fit` per country, stacks the G10 cross-section into one frame. |
| `hac_fit_full(df, fml)` | like `hac_fit` but returns the fitted model + HAC vcov + bandwidth, for joint tests. |
| `wald_p(fit, V, terms)` | joint HAC **Wald** p-value that the given slopes are all zero. |
| `theme_thesis` | one `ggplot2` theme so every figure looks identical. |
| `table_to_grob(df, title, note, …)` | renders a data frame as a styled, PDF-able table grob (bold title, right-aligned cells, grey footnote). |

### 5.2 `thesis_palette.R` — colours

Single source of truth for colour: four role colours (`col_pri` indigo = headline
series, `col_sec` sage = contrast/benchmark, `col_ter` lavender, `col_qua`
forest), a luminance-ordered `mat_palette` for the six maturities, and a
`country_palette` for the G10+ panel (US in indigo as the reference market).

---

## 6. Inference & simulation

### 6.1 `cp_inference.R` — the inference primitives (for `empirical.R`)

The predictive regressions forecast 12-month *overlapping* returns, so plain OLS
SEs are badly biased. This file supplies robust inference:

| Function | Purpose |
|----------|---------|
| `hac_inf(fit, lag=18)` | Hansen–Hodrick / Newey–West HAC SEs + a joint **Wald χ²** on the slopes (CP's 18-lag convention for h=12). |
| `bic_relprob(fits)` | BIC relative model probabilities (best model → 1.0), the CP Table-2 model-comparison statistic. |
| `block_boot_t(rx, cf, …)` | stationary (Politis–Romano) **block bootstrap** of the predictive *t*-statistic — the CP Table-4 small-sample [5%, 95%] interval. |
| `block_boot_r2_ci(y, X, …)` | block-bootstrap 90% CI for adjusted R² (DH Tables 4/6/7 convention). |

> **Honest caveat, documented in the file header.** CP (2015) report *t*-stats from
> a reverse-regression delta method (Wei–Wright) that needs one-period return
> innovations; `reg_data` only stores the 12-month overlapping returns, so that
> exact estimator is not identified here. The code uses HAC instead — the standard
> robust choice — and says so. Signs, magnitudes, and the R²/Wald/BIC structure
> are faithful; the exact reverse-regression *t*-values would require the CP
> appendix.

### 6.2 `cp_montecarlo.R` — the expectations-hypothesis Monte Carlo

Generates CP Table 2 Panel B: the finite-sample distribution of the predictive R²
**under the null of no risk premia** (so you can see how big an R² is "just luck").

It simulates a stylized CP economy — two AR(1) states, trend inflation `τ` and a
real factor `r`, driving an affine term structure — and under the
expectations hypothesis computes EH yields, forms the same duration-standardised
maturity-averaged return as the data, and records the predictive R².

| Function | Role |
|----------|------|
| `geo_mean_load(phi, N)` | geometric-mean AR(1) loading `(1−φᴺ)/((1−φ)N)`. |
| `eh_yield_loadings(...)` | affine loadings of an *n*-year yield on `(τ, r)`. |
| `predictor_factors / _cycle / _sixyields` | pluggable predictor menus (Panel-B factors; cycle; six yields). |
| `simulate_eh_once(...)` | one Monte-Carlo draw → adjusted R². |
| `eh_r2_distribution(...)` | P5/P50/P95 of R² over `n_sims` draws. |
| `run_eh_grid(...)` | the `(φ_τ, φ_r)` grid tabulated in CP Table 2B. |

Calibration targets `sd(τ)=1.90%` and `sd(c⁽¹⁾)=1.74%`; the header notes the
implied P95 lands a bit below the paper's ~19–23% — a documented calibration gap,
not a bug.

---

## 7. Out-of-sample — `oos.R`

Rebuilds the **entire chain recursively** so nothing uses information from the
future. This is what makes the predictability claims credible. It `source()`s
`data_preparation.R`, then re-derives every layer with data ≤ *t*.

Two generic engines do the work:

```r
recursive_resid(df, fml, min_train=60, train_window=Inf)
#   at each t, fit fml on rows 1..t (expanding) and return the residual AT t.
#   used for the yield-cycle decomposition (regressor & outcome both known at t).

oos_predict(df, fml, min_train=120, h=12, train_window=Inf)
#   1-step expanding-window OLS forecast that respects the h-month outcome lag:
#   ŷ[t] uses only rows whose outcome is already realized by date[t]
#   (training = rows with date[s] + h months ≤ date[t]).  No look-ahead.
```

Both take an optional `train_window` so the same code does **expanding** (`Inf`)
or **rolling** (finite *W*) windows — `robustness.R` exploits this.

The recursive chain mirrors §4 exactly:

1. **`cycle_oos`** — recursive `yield ~ trend_inf` residual per country×maturity.
2. **`cycle_1y_oos`, `c_bar_oos`** — the 1-year cycle and the average cycle.
3. **`CF_oos`, `CP_oos`** — recursive predictive forecasts (the cycle factor and
   the forward factor), via `oos_predict`. (Forwards are contemporaneous
   transforms of yields, so only the *regression* needs to respect *t*.)
4. **`GCF_oos`, `GCP_oos`** — GDP-weighted across the OOS-eligible countries.
5. **`FXGCF_oos`** — recursive DH top-down (`rx_USD_bar ~ cyc1_bar_oos +
   cbar_bar_oos`, refit each *t*).
6. **`panel_oos`** — the country-month panel with every OOS factor side by side.

Diagnostics print the correlation of each recursive factor with its in-sample
twin (a high `cor(CF, CF_oos)` means the recursion has "converged").

**Campbell–Thompson OOS R²** (lines ~343–433). The payoff metric:

```
R²_oos = 1 − Σ(y − ŷ_factor)² / Σ(y − ŷ_benchmark)²
```

where `ŷ_benchmark` is the recursive **prevailing mean** (`y ~ 1`). Both forecasts
go through `oos_predict`, so they share the same outcome-lag cutoff. Because the
*factor itself* is already OOS, this is **doubly out-of-sample** — both the factor
construction *and* the predictive regression respect *t*. Six specifications
(`rx~CF_oos`, `rx~CP_oos`, `rx~GCF_oos`, `rx~GCP_oos`, `rx_USD~GCF_oos`,
`rx_USD~FXGCF_oos`) are scored per country and **pooled** by summing the
SS-forecast / SS-benchmark components across countries.

---

## 8. The exhibit layer

These five scripts consume the objects above and emit the thesis's tables and
figures. Each builds its exhibits into a list on `source()` and writes files only
when you call its `save_*()` function.

### 8.1 `empirical.R` — replication tables (Ch. 6)

Reproduces the headline tables of the two anchor papers so the thesis can show the
machinery is faithful before applying it internationally. Outputs render to
`thesis/tables/*.pdf`; call `save_all_tables()` to write them.

| Block | Replicates | Produces |
|-------|------------|----------|
| CP 2015 **Table 1** | cycle properties (yields on π̄; AR(1) half-lives, cycle corr) | `cp_t1_panelA.pdf`, `cp_t1_panelB.pdf` |
| CP 2015 **Table 2** | predictive regressions (5 specs) + EH-null R² | `cp_t2_panelA.pdf`, `cp_t2_panelB.pdf` |
| CP 2015 **Table 4** | predicting each maturity's return with CF | `cp_t4.pdf` |
| DH 2013 **Table 1** | yield summary stats; 10y cross-country corr | `dh_t1_summary.pdf`, `dh_t1_corr10y.pdf` |
| DH 2013 **Tables 3/4/6/7** | CP-factor corr; Fama–Bliss vs CP; local vs global; USD returns | `dh_t3_cp_corr.pdf`, `dh_t4_fb_cp.pdf`, `dh_t6_local_global.pdf`, `dh_t7_usd.pdf` |

Statistical machinery: `hac_inf` (NW, 18 lags for CP / 12 for DH), `bic_relprob`,
`block_boot_t`, and `run_eh_grid` for the Monte-Carlo panel. Helper `ar1_halflife`
turns an AR(1) coefficient into a half-life; `dh_reg` is the per-row DH regression
with HAC inference.

### 8.2 `main_results.R` — the three-phase in-sample results (Ch. 7)

The thesis's core argument, in three phases. `save_main_results()` writes to
`thesis/tables/` and `thesis/figures/`.

| Phase | Question | Specification | Key exhibits |
|-------|----------|---------------|--------------|
| **I — local** (Eq 18) | Does CF predict returns in each G10 market? | `rx_t12 ~ cycle_1y + c_bar`, per country (HAC, joint Wald) + a 2/5/10y maturity ladder | `mr_t1_phase1`, `mr_t1b_maturity`, `mr_f1_r2_phase1` |
| **II — global subsumption** (Eq 19–20) | Does the *global* factor subsume the *local* one? | horse race `rx_t12 ~ CF_perp + GCF`, where `CF_perp = resid(CF ~ GCF)`; Benjamini–Hochberg FDR across markets | `mr_t2_phase2`, `mr_f2_r2_ladder`, `mr_f2_hr_tstats` |
| **III — USD investor** (Eq 21–23) | How much does currency erode predictability, and does FXGCF restore it? | `rx_USD ~ GCF` vs `rx_USD ~ FXGCF` | `mr_t3_phase3`, `mr_f3_usd_r2`, `mr_f4_gcf_fxgcf` |
| **OOS summary** | Do the IS results survive recursion? | sources `oos.R`; contrasts mean IS R² with pooled Campbell–Thompson R²_oos | `mr_t4_oos`, `mr_f5_oos_r2` |

The "orthogonalise the local factor against the global one, then race them" design
in Phase II is the cleanest way to ask whether the local factor still adds
anything once the global factor is in the regression.

### 8.3 `plots.R` — all the figures (Ch. all)

~40 figures organised in sections **s1–s10**, each saved as
`thesis/figures/<name>.pdf` by `save_all_plots()`. It `source()`s `oos.R`, so both
IS and OOS objects are available.

| Section | Theme |
|---------|-------|
| s1 | data & sample (yield time series, curves, coverage heatmap) |
| s2 | the CP mechanism (trend inflation, yield decomposition, cycles, β loadings) |
| s3 | US replication (CF vs c̄, the rx-on-CF scatter) |
| s4 | local CF across the G10 (factors, scatters, R² by country × maturity) |
| s5 | global integration (GCF, GDP weights, CF correlation heatmap, horse race) |
| s6 | FX-adjusted global (GCF vs FXGCF, USD-investor horse race) |
| s8 | OOS factors (IS vs `_oos` overlays, Campbell–Thompson R² bars) |
| s9 | the DH horse race (HAC *t*-stats, R² ladder, Wald) |
| s10 | cycle vs forward (CF/GCF vs CP/GCP, IS and OOS) |

### 8.4 `robustness.R` — does it hold up? (Ch. 8)

Stress-tests every headline result. `save_robustness()` writes the exhibits.

* **Crisis subsamples** — the four headline specs over five windows (pre-crisis,
  GFC, euro crisis, post-crisis, full), IS (`rob_t1`) and OOS (`rob_t2`).
* **Italy focus** (`rob_t3`) — where the residual local predictability from Phase
  II concentrates, especially through the euro crisis.
* **OOS scheme robustness** (`rob_t4`, `rob_f2`) — rebuilds the whole chain under
  expanding vs rolling (120/180m) windows and different training minimums
  (36/60/84m), and *asserts* the expanding-60m rebuild matches the `oos.R`
  baseline (a self-consistency gate).
* **Core vs headline CPI** (`rob_t5`, `rob_t6`, `rob_f3`) — rebuilds trend
  inflation from headline CPI (`inflation_reg`) and re-runs IS and OOS, to show the
  results don't hinge on the choice of inflation series.

It leans on the parameterised `train_window` argument in `oos.R`'s engines, plus
local builders `build_cycle_base`, `add_oos_factors`, `pooled_r2_oos`,
`build_cf_chain_is`.

### 8.5 `strategy.R` — economic value (Ch. 8)

Turns the statistics into money: a **real-time bond-timing strategy**. `source()`s
`oos.R`; `save_strategy()` writes the exhibits.

* **Asset.** GDP-weighted 10-year global government-bond portfolio (local
  currency; and a USD-investor version).
* **Signal.** The fully-recursive `GCF_oos` forecast of next-year excess return
  (USD investor uses `FXGCF_oos`) — *doubly out-of-sample*, investable from
  ~2005 after the 5-year burn-in.
* **Sizing.** Long-only mean–variance, `w_t = max( (1/γ)·Ê[rx]/σ̂², 0 )`, with a
  recursive variance `σ̂²` and weights rescaled to **equal average exposure** so
  the certainty-equivalent comparison is apples-to-apples.
* **Benchmarks.** GCF-timed vs recursive-mean timing vs buy-and-hold.
* **Metrics.** Annualised mean/vol, **Sharpe**, **certainty-equivalent return
  (CER)** at γ=5 and γ=10, and asset-level Campbell–Thompson R².
* **Exhibits.** `strat_t1_performance`, `strat_t2_usd`, `strat_t3_example` (a
  worked May–Jul 2022 de-risking episode), and figures `strat_f1_cumret`,
  `strat_f2_exposure`.

---

## 9. Factor glossary

| Symbol | Name | Built where | Definition (one line) |
|--------|------|-------------|------------------------|
| `π̄` / `trend_inf` | trend inflation | `data_preparation.R` §4.2 | EWMA(120m, v=0.987) of YoY CPI (Eq 3) |
| `c⁽ⁿ⁾` / `cycle` | yield cycle | §4.3 | residual of `yield ~ π̄` (Eq 1–2) |
| `c̄` / `c_bar` | average cycle | §4.7 | mean of `c⁽ⁿ⁾` over n ≠ 1 |
| **CF** | local cycle factor | §4.7 | fitted `rx ~ c⁽¹⁾ + c̄` (Eq 6) |
| **GCF** | global cycle factor | §4.8 | `Σ wᵢ·CFᵢ`, GDP-weighted (Eq 7–8) |
| **FXGCF** | FX-adjusted global cycle factor *(novel)* | §4.9 | fitted `r̄x^USD ~ avg cycle predictors` (DH top-down) |
| **CP** | forward (CP 2005/DH 2013) factor | §4.7 | fitted `rx ~ y₁ + forwards` |
| **GCP** | global forward factor | §4.8 | `Σ wᵢ·CPᵢ` |
| `*_USD` | USD-investor analog | §4.4–4.9 | same, on FX-adjusted returns (Eq 11) |
| `*_oos` | recursive version | `oos.R` | the same factor rebuilt with data ≤ t |

---

## 10. Equation → code map

| Eq | Meaning | Where |
|----|---------|-------|
| 1–2 | yield cycle = resid(`yield ~ π̄`) | `data_preparation.R:127–141`; recursive in `oos.R` |
| 3 | trend inflation (EWMA 120m) | `data_preparation.R:83–122` (`cp_trend`) |
| 4–5 | `cycle_1y`, `c̄` selection | `data_preparation.R:259–274`; `oos.R:117–125` |
| 6 | local cycle factor CF | `data_preparation.R:300–317` |
| 7–8 | GDP-weighted GCF / weights | `data_preparation.R:292–296, 322–331` |
| 10 | local 12m excess returns | `data_preparation.R:166–185` |
| 11 | USD-investor excess returns | `data_preparation.R:188–198` |
| 12–14 | duration standardise + maturity average | `data_preparation.R:206–238` |
| 17 | FXGCF top-down (DH) | `data_preparation.R:347–388`; recursive in `oos.R:202–256` |
| 18 | Phase I: `rx ~ cycle_1y + c̄` | `main_results.R` Phase I |
| 19–20 | Phase II: global subsumption horse race | `main_results.R` Phase II |
| 21–23 | Phase III: USD investor & FXGCF | `main_results.R` Phase III |

---

## 11. Running and verifying

```sh
# from the repository root
Rscript -e 'source("R/empirical.R");    save_all_tables()'    # -> thesis/tables/*.pdf
Rscript -e 'source("R/plots.R");        save_all_plots()'     # -> thesis/figures/*.pdf
Rscript -e 'source("R/main_results.R"); save_main_results()'
Rscript -e 'source("R/robustness.R");   save_robustness()'
Rscript -e 'source("R/strategy.R");     save_strategy()'
```

> Note: sourcing an exhibit script only *builds* the tables/figures into a list
> (`tables`, `plots`, `mr_tables`/`mr_plots`, …) — the `save_*()` call is what
> writes the PDFs. (The README shows `Rscript R/empirical.R` for brevity, but that
> alone defines `save_all_tables()` without calling it.)

Required packages: `readxl, dplyr, tidyr, purrr, stringr, tibble, ggplot2,
gridExtra, scales, sandwich, lmtest, broom, plm` (and optionally `latex2exp` for
formatted figure labels — `plots.R` falls back to plain text without it).

Because the pipeline is deterministic (fixed RNG seeds), a clean run reproduces
every number. To **prove a refactor is result-preserving**, use the fingerprint
harness in `tools/`:

```sh
tools/make_snapshot.sh snapshots/before     # baseline on a clean commit
# ... make changes ...
tools/make_snapshot.sh snapshots/after
tools/compare_snapshots.sh snapshots/before snapshots/after   # must report EQUIVALENT
```

It compares per-column numeric fingerprints as sets (so a harmless column-reorder
doesn't register) while requiring full result-table values, every PDF's text
layer, and all console output to match exactly.

---

*See also: [`README.md`](README.md) (project overview & repository layout) and
[`thesis/ROADMAP.md`](thesis/ROADMAP.md) (chapter structure and the phase
mapping).*
