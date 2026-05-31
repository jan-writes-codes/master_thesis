# Master's Thesis — Roadmap & Structure

**Title:** *Expected Returns in International Government Bond Markets*
**Author:** Jan Heissenberger · **Supervisor:** Giorgia Simion, Ph.D.
**Sprint:** 2026-05-31 → 2026-06-14 (14 days)

---

## Contribution

Take the Cieslak–Povala (2015) macro-anchored **cycle factor** to **G10**
government bonds, build a GDP-weighted **global cycle factor (GCF)**, and
introduce a **novel FX-adjusted global cycle factor (FXGCF)** for a USD
investor. Tested in three phases: local → global subsumption → FX-adjusted
global investor.

**Research question.** Does the CP (2015) cycle factor apply to international
bonds? Sub-questions: (1) local vs GDP-weighted global CF; (2) does a global CF
subsume the predictive power of the local CF?

## State of the empirical engine (built & verified)

| File | Provides |
|------|----------|
| `data preperation.R` | trend inflation, cycles, local CF, global GCF, FXGCF, GDP weights, CP/GCP |
| `oos.R` | fully-recursive OOS CF/GCF/FXGCF/CP/GCP + Campbell–Thompson R² |
| `empirical.R` | 11 rendered result tables (CP 1/2/4, DH 1/3/4/6/7) → `save_all_tables()` → `tables/*.pdf` |
| `plots.R` | 42 figures (sections s1–s10) → `save_all_plots()` → `figures/*.pdf` |
| `cp_inference.R` | `hac_inf`, `bic_relprob`, `block_boot_t`, `block_boot_r2_ci` |
| `cp_montecarlo.R` | EH Monte-Carlo R² grid |

Remaining work is **writing** (LaTeX, ~70–90 pp) plus targeted analysis
gap-filling and a dedicated robustness chapter.

---

## Thesis structure (~70–90 pp)

| # | Chapter | Pages | Key exhibits |
|---|---------|-------|--------------|
| 1 | Introduction | 6–8 | — |
| 2 | Literature Review | 8–10 | — |
| 3 | Theoretical Framework | 8–10 | Eq 1–23 |
| 4 | Data | 6–8 | Table 1A/1B (`dh_t1_*`), `s1_*` |
| 5 | Methodology | 8–10 | inference, OOS, EH-MC |
| 6 | Replication & Validation | 6–8 | CP 1/2/4, DH 3/4/6/7; `s2_*`, `s3_*` |
| 7 | Main Results (3 phases) | 12–15 | `s4_*`, `s5_*`, `s6_*`, `s9_*` |
| 8 | Robustness (dedicated) | 8–10 | `s7_*`, `s8_*`, `s10_*`, `r2_oos_tab` |
| 9 | Discussion | 5–7 | — |
| 10 | Conclusion | 3–4 | — |
| — | Appendix + front matter | — | full per-country tables, derivations |

**Phase mapping in Ch.7:** §I local CF (Eq 18, `s4_*`); §II global subsumption
(Eq 19–20 horse race, `s5_*`/`s9_*`); §III USD investor & FXGCF (Eq 21–23,
`s6_*`, DH Table 7).

---

## 14-Day plan

Each day pairs an **analysis/infra** task with a **writing** target. Chapters
are drafted in dependency order (framework/data/method → results → framing),
then revised.

| Day | Date | Focus |
|-----|------|-------|
| 1 | 05-31 | Scaffold `thesis/` LaTeX skeleton; lock sample window; **Ch.4 Data** |
| 2 | 06-01 | **Ch.3 Theoretical Framework** (Eq 1–23, cross-checked vs code) |
| 3 | 06-02 | **Ch.5 Methodology** + inference caveats; finalize EH-MC presentation |
| 4 | 06-03 | **Ch.6 Replication**; freeze a results snapshot (clean `empirical.R`+`plots.R` pass) |
| 5 | 06-04 | **Ch.7 §I** local CF; finalize `s4_*`, per-country R² |
| 6 | 06-05 | **Ch.7 §II** global subsumption; lock `s5_*`/`s9_*` |
| 7 | 06-06 | **Ch.7 §III** USD investor & FXGCF; finalize `s6_*`, DH-T7 |
| 8 | 06-07 | **Robustness analysis**: OOS, subsamples, alt weights, top-down/bottom-up + leave-own-out, EWMA-`v`/maturity sensitivity |
| 9 | 06-08 | **Ch.8 Robustness** write-up |
| 10 | 06-09 | **Ch.2 Literature Review** |
| 11 | 06-10 | **Ch.1 Introduction** + **Ch.9 Discussion** |
| 12 | 06-11 | **Ch.10 Conclusion** + Appendix + front matter |
| 13 | 06-12 | Full revision pass (flow, notation, refs, equation numbering) |
| 14 | 06-13 | Polish, format to program guidelines, final compile; buffer (06-14 submission) |

---

## Build

```sh
# Regenerate exhibits (run from repo root; output goes under thesis/)
Rscript empirical.R                                  # thesis/tables/*.pdf
Rscript -e 'source("plots.R"); save_all_plots()'     # thesis/figures/*.pdf

# Compile the thesis
cd thesis && latexmk -pdf main.tex
```

> **Note:** exhibits are written directly into `thesis/figures` and
> `thesis/tables` (real files, no symlinks) so the project imports cleanly into
> Overleaf, which does not support symbolic links.

## Definition of done

- `thesis/main.tex` compiles with **zero undefined refs/citations**; all
  figures/tables resolve.
- Every numbered exhibit reproduces from a clean R run (snapshot frozen Day 4,
  re-checked Day 13).
- ~70–90 pp main text; all chapters present; every research sub-question
  explicitly answered in Ch.7 and Ch.10.
- Consistent notation between text and code; `references.bib` complete.

## Out of scope

- New data collection or new factors beyond CF/GCF/FXGCF/CP/GCP.
- Re-deriving the affine model; the EH-MC calibration gap is documented, not
  closed.
