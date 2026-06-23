# Final (Results) Presentation

Beamer deck for the MTS **final presentation** (June 2026), mirroring the style
of the proposal presentation (Madrid theme, per-section table of contents).

This deck presents the FX-adjusted global cycle factor (FXGCF) built
**bottom-up (GDP-weighted)**: a local USD cycle factor is estimated per country
and GDP-weighted into the global factor (the GCF recipe with the US-dollar
return on the left-hand side). It is the promoted, canonical version of
`../final_presentation_bu_gdp/` — the two folders share content; this one drops
the "mock variant" label. The thesis itself still uses the top-down FXGCF.

## Build

```sh
cd final_presentation && latexmk -pdf main.tex
```

Figures are **PDF copies** of the pipeline exhibits (real files, no symlinks, so
the folder imports cleanly into Overleaf). Tables are **native LaTeX**
(`tables/*.tex`, `\input` into the appendix slides) so they render with the deck
fonts and stay sharp on a projector.

## Regenerate

The FXGCF-sensitive exhibits and the deck-only Phase III / OOS / strategy
figures — `pres_usd_drop`, `pres_usd_r2`, `pres_oos_r2`, `pres_usd_cumret` — are
produced by the shared generator under `FXGCF_METHOD=bu_gdp`, which writes into
`final_presentation_bu_gdp/`. Mirror them here (run from the repository root):

```sh
FXGCF_METHOD=bu_gdp Rscript tools/build_variant_presentation.R   # -> final_presentation_bu_gdp/{figures,tables}
cp final_presentation_bu_gdp/figures/*.pdf final_presentation/figures/
cp final_presentation_bu_gdp/tables/*.tex  final_presentation/tables/
```

The FXGCF-independent exhibits (Phase I/II, data and factor-construction
figures, the hedged strategy curve, appendix) are the thesis figures; refresh
them from `thesis/figures/` if the pipeline changes:

```sh
cp thesis/figures/{mr_f1_r2_phase1,mr_f2_hr_tstats,mr_f2_r2_ladder,s5_gcf,strat_f1_cumret}.pdf final_presentation/figures/
cp thesis/figures/{s1_yield_ts,s1_yield_curve_avg,s2_inflation_trend,s2_yield_decomp,s2_cycles_by_country,s4_local_cf}.pdf final_presentation/figures/  # appendix data slides
# tables: keep tables/{mr_t1_phase1,mr_t2_phase2,strat_t1_performance,cp_t4}.tex in sync with thesis/tables/*.tex
```

The compiled `main.pdf` and LaTeX logs are git-ignored.

## MTS requirements checklist

Format: **20 minutes + 10 minutes discussion**; upload to Canvas **1 day
before** the presentation. Audience: Profs. Hornik, Jankowitsch, Pichler and
the supervisor.

- [x] Slide 1: (preliminary) thesis title — *often forgotten!*
- [x] Slide 1: supervisor's name (Giorgia Simion, Ph.D.)
- [x] Motivation slide opens the deck (mirrors the proposal), leading into the
      research question — **stated clearly on slide 5**
- [x] One slide outlining the research design
- [ ] Set the exact presentation date on the title slide once the schedule is
      announced (`\date{...}` in `main.tex`)
- [ ] Rehearse to 20 minutes; check time allocation across phases
      (evaluation: "sufficient time allocated to relevant aspects?")

## Evaluation criteria mapped to slides

| Criterion | Where covered |
|---|---|
| Research question: defined, motivated, in literature | Motivation slide + RQ slide + framework recap |
| Research design: defined, adequate, state-of-the-art, data | Research Design + Data slides |
| Results: sufficient, contribution clear, interpretation clear | Phase I/II/III, OOS, economic value, robustness, conclusion |
| Presentation: stringent logic, terminology, timing | three-phase narrative; rehearse |
