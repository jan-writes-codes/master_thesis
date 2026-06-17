# Expected Returns in International Government Bond Markets

Master's thesis (WU Vienna). Author: Jan Heissenberger · Supervisor: Giorgia Simion, Ph.D.

This project takes the Cieslak–Povala (2015) macro-anchored **cycle factor** of US
bond-return predictability to the **G10** government-bond cross-section, builds a
GDP-weighted **global cycle factor (GCF)** and a novel **FX-adjusted global cycle
factor (FXGCF)** for a US-dollar investor, and evaluates all factors in-sample,
out-of-sample (Campbell–Thompson R²), and in a real-time bond-timing strategy.

## Repository layout

```
R/                   analysis pipeline (see below)
data.xlsx            input data: G10 yields, inflation, FX, GDP (1999–2026)
thesis/              LaTeX thesis — chapters/, figures/, tables/, ROADMAP.md
final_presentation/  Beamer slide deck
tools/               verification harness (make_snapshot.sh, compare_snapshots.sh, snapshot.R)
literature/          literature notes
```

## Analysis pipeline (`R/`)

Run from the repository root. Each script `source()`s its own dependencies, so any
one can be run on its own.

| Script | Role | Thesis |
|--------|------|--------|
| `data_preparation.R` | trend inflation, yield cycles, local cycle factor CF (Eq 6), GDP-weighted GCF (Eq 7–8), FX-adjusted FXGCF, CP/GCP | Ch. 3–4 |
| `oos.R` | fully-recursive out-of-sample factors + Campbell–Thompson R² | Ch. 5, 7–8 |
| `cp_inference.R` | HAC (Newey–West) inference, block bootstrap, BIC weights | Ch. 5 |
| `cp_montecarlo.R` | expectations-hypothesis Monte-Carlo R² grid | Ch. 5–6 |
| `thesis_utils.R` | **shared** helpers: `hac_fit`, `run_by_country`, `hac_fit_full`, `wald_p`, `theme_thesis`, `table_to_grob` | — |
| `thesis_palette.R` | shared figure colour scheme | — |
| `empirical.R` | replication tables — CP 2015 (T1/2/4), DH 2013 (T1/3/4/6/7) → `thesis/tables/` | Ch. 6 |
| `plots.R` | the figures (sections s1–s10) → `thesis/figures/` | all |
| `main_results.R` | three-phase in-sample results (Eq 18–23) → tables + figures | Ch. 7 |
| `robustness.R` | crisis-subsample IS/OOS, Italy focus, core-vs-headline CPI | Ch. 8 |
| `strategy.R` | economic value: real-time GCF bond-timing strategy | Ch. 8 (strategy) |

Dependency order: `data_preparation.R` → `cp_inference.R` / `cp_montecarlo.R` → `oos.R`
→ the results scripts (`empirical`, `plots`, `main_results`, `robustness`, `strategy`).

## Reproducing the exhibits

Requires R (developed on 4.3.3) with: `readxl`, `dplyr`, `tidyr`, `purrr`, `stringr`,
`tibble`, `ggplot2`, `gridExtra`, `scales`, `sandwich`, `lmtest`, `broom`, `plm`
(and, optionally, `latex2exp` for formatted figure labels — `plots.R` falls back to
plain text if it is absent).

```sh
# from the repository root
Rscript R/empirical.R                                      # -> thesis/tables/*.pdf
Rscript -e 'source("R/plots.R");        save_all_plots()'  # -> thesis/figures/*.pdf
Rscript -e 'source("R/main_results.R"); save_main_results()'
Rscript -e 'source("R/robustness.R");   save_robustness()'
Rscript -e 'source("R/strategy.R");     save_strategy()'

cd thesis && latexmk -pdf main.tex                         # build the thesis PDF
```

The pipeline is deterministic (fixed RNG seeds), so a clean run reproduces every
number and exhibit. Exhibits are written as real files into `thesis/figures` and
`thesis/tables` so the project imports cleanly into Overleaf.

## Verifying that a change keeps the results identical

`tools/` fingerprints every numeric result object and every regenerated exhibit, so
a refactor can be proven result-preserving:

```sh
tools/make_snapshot.sh snapshots/before     # baseline (e.g. on a clean commit)
# ... make changes ...
tools/make_snapshot.sh snapshots/after
tools/compare_snapshots.sh snapshots/before snapshots/after   # must report EQUIVALENT
```

`compare_snapshots.sh` compares the per-column numeric fingerprints as sets (so a
harmless change in a data frame's column order does not register) while requiring
the full result-table values, every PDF's text layer, and all console output to
match exactly.

## Use of AI tools

A statement on the use of AI-based tools is given in the thesis Declaration of
Authorship (`thesis/chapters/00_declaration.tex`).
