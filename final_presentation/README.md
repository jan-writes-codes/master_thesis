# Final (Results) Presentation

Beamer deck for the MTS **final presentation** (June 2026), mirroring the style
of the proposal presentation (Madrid theme, per-section table of contents).

## Build

```sh
cd final_presentation && latexmk -pdf main.tex
```

Figures are **PDF copies** of the thesis exhibits (real files, no symlinks, so
the folder imports cleanly into Overleaf). Tables are **native LaTeX**
(`tables/*.tex`, `\input` into the appendix slides) so they render with the deck
fonts and stay sharp on a projector; their numbers mirror the thesis tables. If
the R pipeline is re-run, refresh the figures and re-transcribe any changed
table numbers from `thesis/tables/*.tex`:

```sh
cp thesis/figures/{mr_f1_r2_phase1,mr_f2_hr_tstats,mr_f2_r2_ladder,mr_f3_usd_r2,mr_f4_gcf_fxgcf,mr_f5_oos_r2,s5_gcf,strat_f1_cumret,rob_f1_oos_sub,rob_f2_oos_scheme}.pdf final_presentation/figures/
# tables: keep tables/{mr_t1_phase1,mr_t2_phase2,mr_t3_phase3,mr_t4_oos,strat_t1_performance}.tex
#         in sync with the corresponding thesis/tables/*.tex
```

## MTS requirements checklist

Format: **20 minutes + 10 minutes discussion**; upload to Canvas **1 day
before** the presentation. Audience: Profs. Hornik, Jankowitsch, Pichler and
the supervisor.

- [x] Slide 1: (preliminary) thesis title — *often forgotten!*
- [x] Slide 1: supervisor's name (Giorgia Simion, Ph.D.)
- [x] Research question stated clearly, **by slide 3 at the latest**
- [x] One slide outlining the research design
- [ ] Set the exact presentation date on the title slide once the schedule is
      announced (`\date{...}` in `main.tex`)
- [ ] Rehearse to 20 minutes; check time allocation across phases
      (evaluation: "sufficient time allocated to relevant aspects?")

## Evaluation criteria mapped to slides

| Criterion | Where covered |
|---|---|
| Research question: defined, motivated, in literature | Slide 3 + framework recap |
| Research design: defined, adequate, state-of-the-art, data | Research Design + Data slides |
| Results: sufficient, contribution clear, interpretation clear | Phase I/II/III, OOS, economic value, robustness, conclusion |
| Presentation: stringent logic, terminology, timing | three-phase narrative; rehearse |
