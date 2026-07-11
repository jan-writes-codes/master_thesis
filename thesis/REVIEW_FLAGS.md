# Flags for author — decisions I made where the playbook was ambiguous

These are edits where two remarks conflicted, or where a change needed a
judgment call. I picked the reading that loses the least information; please
confirm or overrule.

## F-1 · `02_literature.tex` — Randl passage (R-052 vs R-053)
- **R-052** said only reword the opener ("On the asset-class side," → "From
  an asset-pricing perspective,").
- **R-053** said REMOVE the whole Randl passage ("On the asset-class
  side … the question we pose in this thesis"), with the note "(clarify
  unconditional vs conditional)".
- **Conflict:** R-052 gives a specific replacement opener, which would be
  pointless if the passage were deleted. Randl is also load-bearing for the
  gap argument in the literature review.
- **What I did:** kept the passage, applied R-052's opener, softened
  "fundamentally distinct" → "distinct" (consistent with R-021/R-176), and
  clarified the *unconditional* vs *conditional* distinction (R-053's note).
- **Decide:** keep as clarified (current), or delete the passage entirely.

## F-2 · `04_data.tex` — Core CPI source (R-077/R-078)
- You said the core-CPI data is from **FRED, not LSEG Refinitiv**. I changed
  the provider label to FRED and "seasonally relevant" → "seasonally
  adjusted".
- The old example ticker `aUSCCORF/C` is a Datastream/Refinitiv mnemonic, so
  it can't be right if the source is FRED. I replaced it with **`CPILFESL`**
  (FRED's US core-CPI, all items less food & energy, seasonally adjusted).
- **Confirm:** (a) FRED is the source for *all eleven* countries' core CPI
  (the GDP and yield items still read Bloomberg/LSEG — I left those); (b)
  `CPILFESL` is the actual US series you used; (c) the series really are
  seasonally adjusted (if NSA, drop the word).

## F-3 · `07_results.tex` — exchange-rate exposure explanation (R-100/R-101)
- You asked for a short explanation of why dollar predictability "survives
  only where exchange-rate exposure is small or itself cyclical," to be
  **verified with you**.
- **What I wrote:** "In these cases the currency return is either absent (the
  United States carries no currency leg) or tends to move with the domestic
  rate cycle, so that part of it is already captured by the bond factor rather
  than adding independent noise; for the euro bloc, Switzerland, and Japan, by
  contrast, the exchange rate moves largely independently of the bond cycle and
  its volatility swamps the signal."
- **Verify:** is the "CAD/SEK/GBP exchange rate co-moves with the domestic rate
  cycle" mechanism something you're comfortable asserting? I did not compute a
  formal FX–cycle correlation to back it; if you want, I can add one in R.

## F-4 · `08_robustness.tex` — core-vs-headline FX argument needs a source (R-165)
- I split the sentence as you asked ("We could argue that the energy-price
  component … also moves exchange rates …"). You wanted a "Like in (source)"
  citation for this claim. **I have no source** and did not invent one — the
  clause currently stands uncited. Supply a reference or I'll leave it as our
  own conjecture.

## F-5 · `08_robustness.tex` — 2008 "no macro factor can forecast" (R-159)
- You flagged "the one regime in which no slow-moving macro factor can be
  expected to forecast the panic-driven repricing of 2008" as possibly needing
  a source. I reframed it as our own expectation ("a regime in which we would
  not expect a slow-moving macro factor to forecast …") so it no longer reads
  as a citable fact. Confirm that framing is acceptable.

## F-6 · `08b_strategy.tex` — transaction-cost source (R-138)
- You asked to "cite a reliable microstructure source" for the 1 bp
  half-spreads / 10 bp cost on 10Y G10 bond futures. **I have no source to
  hand** and did not invent one. The claim stands uncited. Supply a reference
  (e.g. a bid–ask/liquidity study of Treasury/Bund futures) and I'll insert it.

## Answer · "What is `strategy_ext.R`?" (author todo)
- It is the **extended performance-analytics** script for the Portfolio
  Construction chapter. It `source()`s `strategy.R` (which builds the backtest
  objects `bt`/`btu` and the baseline exhibits) and adds: (1) subperiod
  performance (halves of the OOS window + the 2022 episode), (2) turnover and
  net-of-transaction-cost performance, (3) maximum drawdown on the
  non-overlapping annual wealth curves, (4) rolling five-year Sharpe ratios.
  It produces `strat_t4_subperiod`, `strat_t5_costs`, `strat_f3_drawdown`, and
  `strat_f4_rolling_sharpe`.

## Answer · R-089 — what GCF correlates with ("who else? check weights")
Computed `corr(CF_i, GCF)` per country (bu_gdp) against the mean GDP weight:

| Country | corr(CF_i, GCF) | mean GDP weight |
|---------|-----------------|-----------------|
| US | 0.96 | 0.477 |
| DE | 0.94 | 0.099 |
| SE | 0.93 | 0.013 |
| CA | 0.89 | 0.039 |
| BE | 0.84 | 0.013 |
| GB | 0.83 | 0.074 |
| NL | 0.80 | 0.022 |
| FR | 0.75 | 0.070 |
| JP | 0.73 | 0.199 |
| CH | 0.66 | 0.016 |
| IT | 0.20 | 0.056 |

**Finding:** the US (largest weight, 0.48) does have the highest correlation
and Germany is second — but it is **not** mainly a weight story. The
cross-country correlation between `corr(CF_i,GCF)` and the GDP weight is only
**0.24**: Sweden and Canada correlate highly (0.93, 0.89) despite tiny weights,
because their cycles co-move with the global business cycle, while Japan (2nd
largest weight) sits at only 0.73. **Italy is the clear outlier (0.20)**,
consistent with its idiosyncratic sovereign-crisis predictability. So GCF
tracks the common business cycle, which the large core economies dominate by
weight, rather than being mechanically pinned to the biggest economies.
The full lower-triangle CF×CF table you asked for is ready to build on request
(it needs a manual `.tex` transcription, so I left it for your review first).

## R-122 — resolved by the Q-2 move (no separate figure change)
You asked to add `rx_usd ~ GCF` and `rx_usd ~ FXGCF` OOS bars to the
per-country OOS figure (`mr_f5_oos_r2`). The Q-2 restructure already brings the
`s8-oos-usd` figure (USD unadjusted vs FX-adjusted, per country) into the same
`sec:res-oos` section, alongside `mr_f5` (local vs global). All four OOS specs
are now shown per country across two clean figures, so cramming four bars into
one chart is unnecessary. The value-labels enhancement was done earlier.

## R-exhibit work — ALL DONE (2026-07-11)
- **R-092 · DONE** — G10-panel (country-FE) row added to the Phase-II table
  (`mr_t2_phase2.tex`) + reading sentence; computation in `main_results.R`.
- **R-089 · DONE** — lower-triangle CF×CF correlation table with corr-to-GCF and
  GDP weights (`mr_t2b_gcf_corr.tex`, appendix) + discussion in results;
  computation in `main_results.R`.
- **R-081 · DONE** — non-yield input summary stats (core inflation, FX return,
  GDP weight) in `dh_t1b_inputs.tex` (appendix) + pointer in the data chapter;
  computation in `main_results.R`.
- **R-167 · DONE** — v/M sensitivity exhibit (`rob_t8_vm_sens.tex`) + paragraph
  in the construction-sensitivity section; new script `R/sensitivity_vm.R`.
- **R-133 / R-139 · DONE** — `strat_f1_cumret` and `strat_f3_drawdown`
  regenerated on a monthly 1-month-holding basis (`strategy.R`/`strategy_ext.R`);
  captions + drawdown prose updated (max DD 21.7% / 26.3% / 32.8%); a footnote
  notes the figures use 1-month holding while the headline Sharpe/CER stay on
  12-month returns.
- **R-122 · RESOLVED** by the Q-2 move (see above).

### Reproducibility note
The thesis `.tex` tables carry the verified numbers and the pipeline scripts
were updated to generate matching output. Regenerating the `main_results.R`
grob PDFs (references only; the thesis inputs the `.tex`) requires the slow
recursive `oos.R` run and can be done in a batch when convenient. The figure
`figures/s8_r2_oos_local.pdf` is now unused (role filled by `mr_f5_oos_r2`);
harmless, can be pruned later.

### Japan inflation reminder (author todo)
Japan's core inflation (mean 0.34%, SD 1.11% over the sample) is the lowest in
the panel — worth a sanity check that the FRED Japanese core-CPI series and the
consumption-tax episodes are handled as you intend.
