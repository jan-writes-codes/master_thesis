# Thesis Review — Implementation Playbook (decided edits)

**This file is the execution plan.** Each entry resolves a remark from
`REVIEW_REMARKS.md` into a concrete, decided edit. **Nothing here is applied to
the thesis `.tex` yet** — on the author's explicit "go", this file is executed
top to bottom.

**Legend for entry status**
- **EDIT** — concrete `OLD → NEW` text replacement, ready to apply.
- **DELETE** — remove the quoted text.
- **MOVE** — relocate content (with source + destination).
- **VERIFY** — a fact-check that needs a source I can't confirm from the repo;
  the claim to check is stated.
- **AUTHOR** — needs author-supplied content or a personal choice; cannot be
  auto-drafted.
- **OBSOLETE** — the restructure already handled it; no action.
- Structural decisions from Q-1…Q-4 are applied where relevant.

Global decisions (from the questions):
- **Q-2:** Robustness stays a chapter; **§6.1 OOS moves to Ch. 4**, Ch. 6 keeps a pointer.
- **Q-3:** **Remove the Italy treatment everywhere.**
- **Q-4:** **Delete the AI Disclaimer.**

---

## Front matter

### `00_titlepage.tex`
- **R-141 · AUTHOR** — title/subtitle is the author's creative call. Default:
  **keep** *"Expected Returns in International Government Bond Markets"*.
  If a subtitle is wanted, the brainstormed option that best fits the thesis's
  cycle theme is *"Breaking the Cycle? Expected Returns in International
  Government Bond Markets"*. **Awaiting author's pick; no change unless chosen.**

### `00_abstract.tex`
- **R-001 / R-002 / R-003 · EDIT** (word-choice polish + foreground the main
  finding). Replace the block from *"and an average in-sample $R^{2}$ of $25\%$."*
  through the end:
  - **OLD:** "…and an average in-sample $R^{2}$ of $25\%$. Furthermore, we find that the global factor subsumes the local factors in most markets and that it beats the historical mean out of sample in ten of eleven markets. For the dollar investor, currency conversion erodes most of the predictability; the FX-adjusted factor recovers much of it in sample, nearly doubling the dollar-investor fit, although its real-time edge is small and conditional. Ultimately, a timing strategy based on the global factor raises the Sharpe ratio of a hedged global bond portfolio from $0.31$ to $0.38$."
  - **NEW:** "…and an average in-sample $R^{2}$ of $25\%$. The global cycle factor subsumes the local factors in most markets and, most importantly, is the only factor that survives out of sample: it beats the recursive historical mean in ten of eleven markets, whereas the local factor does so in only two. For an unhedged dollar investor, currency conversion erodes most of the predictability; the FX-adjusted factor recovers much of it in sample but retains only a small, conditional edge in real time. Converting the surviving signal into a strategy, a timing rule on the global factor raises the Sharpe ratio of a hedged global bond portfolio from $0.31$ to $0.38$."
  - *Rationale:* addresses R-003 ("more detail / main finding" — the real-time survival is the thesis's headline result), tightens "it beats" and "dollar investor" (R-001), reworks the closing block (R-002).
- **R-004 · AUTHOR/VERIFY** — word count. Current abstract ≈ 235 words. Confirm
  the program's limit (typically 250–300). No change unless it must shrink.

### `00_acknowledgements.tex`
- **R-005 / R-142 · AUTHOR** — the ✗ marks this placeholder for rework. The
  content is personal (names, thanks). **Author to supply final text.** Current
  minimal version stays until then; flag as "do not submit as-is".

---

## `01_introduction.tex` — Chapter 1  *(pre-restructure batch; reconciled to current source)*

**Heading cleanup (R-007, R-022, R-025):** the author struck the informal
`\section*` sub-headings *Motivation*, *Research Question*, *Contribution*.
- **DELETE** `\section*{Motivation}` (line ~10).
- **DELETE** `\section*{Research Question}` (line ~102).
- **DELETE** `\section*{Contribution}` (line ~149).
- **CONFIRM:** *Main Findings and Structure* was **not** struck. Recommend
  removing it too (all four) for a clean, flowing intro — or keep all four as
  real `\section`s. Flagging the inconsistency; default = remove the three
  struck, keep the fourth.

- **R-008 · DELETE** the opening sentence: *"In this chapter, we motivate and
  introduce our research question."* (paragraph then opens on "Investors earn…").
- **R-009 · AUTHOR (no thesis edit)** — *"i need a proof for this (personally)"* is
  a note-to-self about the EH equation; no change to the thesis required. Optional:
  add a one-line footnote citing a standard derivation. Default: no edit.
- **R-010 · VERIFY → KEEP** — the `\approx` in the EH equation is appropriate: it
  abstracts from the constant term premium and Jensen/convexity terms. No change.
- **R-011 · EDIT**:
  - **OLD:** "We can therefore say that bond risk premia are large, time-varying, and countercyclical."
    **NEW:** "Bond risk premia are therefore large, time-varying, and countercyclical."
  - **OLD:** "provide the sharpest economic mechanism to date."
    **NEW:** "provide the clearest economic mechanism to date." *(matches the abstract's wording)*
  - "Treasuries", "The natural follow-up question", "over and above": read fine; **no change** (confirm).
- **R-012 · VERIFY → OK** — the four literature claims (Campbell–Shiller wrong-signed
  slopes; CP tent shape, $R^2$ 0.35–0.44; Ludvigson–Ng macro factors; Cieslak–Povala
  cycle subsumes CP) are all standard and stated accurately. No change.
- **R-013 · EDIT** (condense):
  - **OLD:** "They decompose nominal yields into a slow-moving \emph{trend-inflation} component, a discounted moving average of past core inflation that anchors the level of interest rates at long horizons, and transitory \emph{cycles}, which are the deviations of yields from this anchor."
  - **NEW:** "They decompose nominal yields into a slow-moving \emph{trend-inflation} component—a discounted moving average of past core inflation—and transitory \emph{cycles}, the deviations of yields from this anchor."
- **R-014 / R-015 · EDIT** (clarify the falling-stars sentence; R-015 "which one is not"):
  - **OLD:** "The structural counterpart of this view is the ``falling stars'' evidence of \citet{bauer2020}, who show that accounting for the drifting long-run anchors $\pi^{*}$ and $r^{*}$ is precisely what uncovers the predictable component of returns."
  - **NEW:** "The structural counterpart of this view is the ``falling stars'' evidence of \citet{bauer2020}: once the slow drift in the long-run inflation and real-rate anchors ($\pi^{*}$ and $r^{*}$) is accounted for, the predictable component of returns emerges."
  - **CONFIRM:** if "which one is not" meant something other than "clarify which anchor is which", tell me.
- **R-016 · VERIFY → OK** — "almost exclusively evidence about the United States" is
  defensible; the following sentences acknowledge Zhang et al. No change.
- **R-017 · EDIT** (kill the "truly…truly" repetition):
  - **OLD:** "If trend inflation truly anchors yields and cycles truly carry the risk premium, the same mechanism should also operate in other developed bond markets, and a failure to do so would cast doubt on the economic interpretation."
  - **NEW:** "If the trend–cycle mechanism is real—if trend inflation anchors yields and the cycles carry the risk premium—the same mechanism should also operate in other developed bond markets, and a failure to do so would cast doubt on the economic interpretation."
  - "and thus about one market, one monetary history, and one disinflation.", "direct evidence", "strongest claim to": **no change** (read fine; confirm).
- **R-018 · EDIT** (tighten the transition):
  - **OLD:** "The international literature gives us reason for optimism, although it has pursued a different predictor."
  - **NEW:** "The international literature is encouraging, though it has pursued a different predictor."
- **R-019 · EDIT** (clarify the FX/currency sentence):
  - **OLD:** "An unhedged US-dollar investor earns the foreign bond return plus a volatile currency return, which erodes the predictability, and because of this they build an FX-adjusted global factor to recover it."
  - **NEW:** "An unhedged US-dollar investor earns the foreign bond return plus a volatile currency return. Because this currency component erodes predictability, \citet{dahlquist2013} build an FX-adjusted global factor to recover it."
- **R-020 · VERIFY** — check against Zhang et al. (2021): claim = "they add raw
  inflation trends to yield-curve regressions in four markets, do not construct the
  cycle factor itself, and build no global or currency-adjusted aggregate."
  Consistent with the thesis's repeated characterisation; confirm from the paper.
- **R-021 · EDIT** (soften the "Dangerous!!" Randl claim; keep consistent with the
  Ch. 7 Randl cuts R-176/R-186):
  - **OLD:** "By deriving a stochastic discount factor for currency-hedged G10 bond portfolios, they show that the priced risks of international bonds are fundamentally distinct from those of currencies. This gives independent support for studying the hedged (local-currency) bond premium separately from the currency overlay, as we do in our thesis."
  - **NEW:** "By deriving a stochastic discount factor for currency-hedged G10 bond portfolios, they show that the priced risks of international bonds are distinct from those of currencies, which motivates studying the hedged (local-currency) bond premium separately from the currency overlay, as we do."
- **R-023 · OBSOLETE** — the third sub-question is already present (the
  interest-rate vs currency-inclusive premium item). No action.
- **R-024 · OBSOLETE/minor** — the Phase III sentence was reworded in the
  restructure and now reads acceptably. No change (confirm).
- **R-026 · DELETE** " (1994--2026 for most markets)" → "…GDP spanning 1989--2026.
  One level up,".
- **R-027 · EDIT** (per Q-3, decouple from the Italy "natural experiment"):
  - **OLD:** "we cover the full G10 cross-section of eleven markets, including the euro-area periphery, whose sovereign-debt crisis provides a natural experiment on the limits of integration."
  - **NEW:** "we cover the full G10 cross-section of eleven markets, including the euro-area periphery."
  - "$\FXGCF_{t}$ is, to the best of our knowledge, new": **no change** (standard hedging; confirm).
- **R-028 · EDIT** (remove "that is," filler):
  - **OLD:** "It fits a USD cycle factor per country, that is, the country's \emph{dollar} excess return projected on its own cycles, and aggregates these with GDP weights,"
  - **NEW:** "It fits a USD cycle factor per country—the country's \emph{dollar} excess return projected on its own cycles—and aggregates these with GDP weights,"
- **R-029 · DELETE** the Monte-Carlo clause:
  - **OLD:** "We complement this with an expectations-hypothesis Monte Carlo that calibrates how much in-sample $R^{2}$ overlapping returns can produce under the null, a crisis-subsample analysis, a horse race against the global forward-rate factor, a core-versus-headline-inflation reconstruction, and a market-timing strategy that converts the statistical evidence into economic value."
  - **NEW:** "We complement this with a crisis-subsample analysis, a horse race against the global forward-rate factor, a core-versus-headline-inflation reconstruction, and a market-timing strategy that converts the statistical evidence into economic value."
- **R-030 · DELETE/EDIT (per Q-3, Italy)** — trim the Italy-exception elaboration
  in Main Findings:
  - **OLD:** "Once it is included, genuinely local content survives in only three markets (Italy, the Netherlands, Belgium). The Italian exception is informative, as its local predictability concentrates in the 2010--2012 sovereign-debt crisis, when redenomination risk priced locally what no global factor could capture. We would therefore suggest that integration is the rule, although this rule weakens under severe sovereign stress."
  - **NEW:** "Once it is included, genuinely local content survives in only three markets (Italy, the Netherlands, Belgium). Integration is therefore the rule, although it weakens under severe sovereign stress."
- **R-031 · EDIT**:
  - **OLD:** "currency risk is the binding constraint for the dollar investor."
    **NEW:** "currency risk is the dominant obstacle for the dollar investor."
  - "core", the 0.31→0.38 timing sentence: **no change** (confirm).
- **R-032 · DELETE** "A top-down variant is nearly collinear with the unadjusted
  factor (correlation $0.99$) and adds almost nothing, so where the FX-relevant
  information sits, namely in the cross-section rather than the aggregate, is a
  finding in itself." (paragraph continues at "The two factors are, moreover, distinct only…").
- **R-033 · KEEP (minor)** — "the expectations-hypothesis Monte Carlo," in the
  roadmap sentence is an accurate pointer; keep as long as the MC stays in the
  methodology chapter. (Note the de-emphasis theme R-029/R-184.)

---

## `02_literature.tex` — Chapter 2, Related Literature  *(pre-restructure batch; the §2.2 framework moved to `05_methodology.tex`)*

> **Reconciliation note:** the old Ch. 2 "Theoretical Framework" (§2.2, remarks
> R-058–R-076) is now in `05_methodology.tex` with equations renumbered 2.x→3.x;
> those are handled in the methodology section below, not here.

- **R-034 · VERIFY → OK** — "A fourth, methodological strand… shapes our research
  design" is self-referential framing, accurate. No change.
- **R-035 · VERIFY → OK** — Fama–Bliss (1987) did introduce both the forward–spot
  result and the zero-coupon ("Fama–Bliss") data that became standard. Accurate.
- **R-036 · VERIFY → OK** — Ludvigson–Ng (2009) macro factors forecast returns
  beyond the curve. Accurate.
- **R-037 · EDIT** (clarify "unspanned"):
  - **OLD:** "…forecast excess returns over and above forward rates and yields, which is the empirical origin of ``unspanned'' macro risk."
  - **NEW:** "…forecast excess returns over and above forward rates and yields. This is the empirical origin of ``unspanned'' macro risk—predictive information that the current yield curve does not reveal."
- **R-038 · EDIT** (clarify the hidden-factor idea):
  - **OLD:** "A state variable can move expected short rates and term premia in offsetting directions, leaving yields nearly unchanged while still forecasting returns."
  - **NEW:** "A state variable can move expected short rates and term premia in offsetting directions, leaving the yield curve nearly unchanged while still forecasting returns—a ``hidden'' factor."
- **R-039 · EDIT** (clarify the Stambaugh bias):
  - **OLD:** "Persistent regressors, overlapping returns, and the endogeneity highlighted by \citet{stambaugh1999} make standard tests over-reject the spanning null,"
  - **NEW:** "Persistent regressors, overlapping returns, and the small-sample bias that \citet{stambaugh1999} identified for predictive regressions with a persistent, predetermined regressor make standard tests over-reject the spanning null,"
- **R-040 · EDIT** (de-duplicate "this critique … this critique"):
  - **OLD:** "…are, therefore, in large part a response to this critique."
  - **NEW:** "…are, therefore, in large part a response to it."
- **R-041 · VERIFY → OK** — cross-refs resolve correctly (replicate in
  \Cref{ch:replication}, compare in \Cref{ch:robustness}). No change.
- **R-042 · KEEP (minor)** — "with monthly decay $v=0.987$ over a ten-year window"
  reads fine. No change (confirm).
- **R-043 · VERIFY → OK** — Kozicki–Tinsley (2001) shifting-endpoint origin.
  Accurate.
- **R-044 · EDIT** (minor):
  - **OLD:** "subsume the CP factor in head-to-head comparisons."
    **NEW:** "subsume the CP factor in direct comparisons."
- **R-045 · KEEP** — "reduces the near-unit-root persistence… because the cycle is
  stationary while the yield is not" already self-explains. No change (confirm).
- **R-046 · EDIT** (gloss "structural"):
  - **OLD:** "The structural counterpart to this reduced-form approach is \citet{bauer2020}."
    **NEW:** "The structural (model-based) counterpart to this reduced-form approach is \citet{bauer2020}."
- **R-047 · EDIT**:
  - **OLD:** "captures something real rather than a fortunate parameterisation."
    **NEW:** "captures something real rather than an artefact of a fortunate parameter choice."
- **R-048 / R-049 · VERIFY** ("Can we also mirror his finding?") — the thesis does
  mirror Zhu (2015): the global cycle factor is OOS-positive where the local factor
  fails (Ch. 4 / Ch. 6). Sentence stands. **Check `zhu2015` exists in
  `references.bib` and is correctly characterised.**
- **R-050 · EDIT** (tighten):
  - **OLD:** "The FX-adjusted cycle factor we build in this thesis is the direct analogue to this construction, and the contrast between the FX adjustments of the two factor families turns out to be one of our findings (\Cref{sec:res-phase3})."
  - **NEW:** "The FX-adjusted cycle factor we build is the direct analogue of this construction, and the contrast between how the FX adjustment behaves for the two factor families is one of our findings (\Cref{sec:res-phase3})."
- **R-051 · EDIT** (clarify "synthesis on the factor level"):
  - **OLD:** "However, they stop short of a synthesis on the factor level."
    **NEW:** "However, they stop short of combining the trends into a single macro-anchored \emph{factor}."
- **R-052 · EDIT** (minor):
  - **OLD:** "On the asset-class side, \citet{randl2025}"
    **NEW:** "From an asset-pricing perspective, \citet{randl2025}"
- **R-053 · EDIT** (clarify unconditional vs conditional):
  - **OLD:** "Their work prices the asset class unconditionally. However, it does not ask which observable state variable tracks the conditional premium in real time, and this is the question we pose in this thesis."
  - **NEW:** "Their work characterises the \emph{average} (unconditional) pricing of the asset class. It does not ask which observable state variable tracks the \emph{time-varying} (conditional) premium in real time, and this is the question we pose."
- **R-054 + R-055 · DELETE (Q-1 resolved)** — remove the whole paragraph *"A final
  strand of the literature disciplines how such a question should be answered. …
  and a simulated no-predictability benchmark."* (the Welch–Goyal / Campbell–Thompson
  / Thornton paragraph).
  - **KNOCK-ON (must handle on apply):**
    1. Chapter-intro sentence (lines ~19–22) still promises "A fourth,
       methodological strand… we review each strand in turn." Trim to *"A fourth,
       methodological concern—the out-of-sample and small-sample scrutiny of
       predictive regressions—cuts across all three and shapes our research
       design (\Cref{ch:methodology})."* and drop "we review each strand in turn".
    2. Check citations `welch2008`, `thornton2012`: if used only in the deleted
       paragraph, they drop from the bibliography (acceptable). `campbellthompson2008`
       and `bauerhamilton2018` are still cited elsewhere, so they stay.
    3. The final gap paragraph's OOS-discipline reference still stands.
- **R-056 · OBSOLETE** — part of the R-054+R-055 deletion.
- **R-057 · EDIT** (tighten; MC de-emphasis theme):
  - **OLD:** "scored against the prevailing mean \citep{campbellthompson2008}, with bootstrap and Monte-Carlo inference calibrated to the overlapping-return environment."
  - **NEW:** "scored against the prevailing mean \citep{campbellthompson2008}, with bootstrap and Monte-Carlo inference suited to overlapping returns."

---

## `05_methodology.tex` — old §2.2 framework  *(R-058–R-076; equations renumbered, e.g. old (2.3)→`eq:decomp`, (2.7)→`eq:cf`, (2.15)→`eq:h-horse`)*

> **Note:** the restructure added a *"Deviations from the Original Studies"*
> section (`sec:meth-deviations`) that already collects the proposal/paper
> departures, so several old "Implementation note" asides are now redundant.
> **G-4 (remove "proposal")** is executed here.

- **R-058 · VERIFY (G-9)** — "fact-check everything here" over the framework. The
  file header states notation is kept consistent with `data_preparation.R`,
  `cp_inference.R`, `oos.R`. Spot-check on apply: eqs `eq:eh`, `eq:rx`,
  `eq:decomp`, `eq:trendinf` ($v=0.987$, $M=120$), `eq:rxbar` ($D^{(n)}=n$),
  `eq:rx-usd` against the code. All look standard and internally consistent.
- **R-059 · EDIT (→ global sweep)** — "operationalise" reads as jargon; add to the
  **global word-swap sweep** (replace "operationalise/operationalises" with "put
  into practice"/"translate … into" at each occurrence: intro l.135,
  `02_literature` l.10). "menu" (maturity menu) is standard — keep.
- **R-060 · KEEP** — $N=\{1,2,4,5,9,10\}$ is defined at first use ("empirical
  maturity menu … dictated by data availability"). Adequate. No change (confirm).
- **R-061 · KEEP (minor)** — "dictated by data availability (\Cref{sec:data-coverage})"
  reads fine.
- **R-062 · EDIT** (gloss the constant-expected-return restriction):
  - **OLD:** "should therefore satisfy $\E_{t}\!\left[\rx^{(n)}_{t+12}\right]=\text{const}$."
  - **NEW:** "should therefore satisfy $\E_{t}\!\left[\rx^{(n)}_{t+12}\right]=\text{const}$—the expected excess return is the same at every date."
- **R-063 · DELETE** the sentence "Forward rates \citep{cochrane2005} and, even
  more powerfully, macro-anchored cycles \citep{cieslak2015} predict
  $\rx^{(n)}_{t+12}$ with economically large $R^{2}$." (paragraph then reads
  "…rejects this restriction. In the remainder of this chapter, we build…").
- **R-064 · EDIT** (tighten):
  - **OLD:** "In the remainder of this chapter, we build the predictors that we use to document and interpret this predictability in an international setting."
  - **NEW:** "The remainder of this chapter builds the predictors we use to document and interpret this predictability internationally."
  - The "we return to the EH itself in \Cref{sec:meth-ehmc}…" clause reads fine — keep.
- **R-065 · KEEP** — the cycle term $\cyc^{(n)}_{i,t}$ is defined ("transitory
  cycles"; "the cycle is, by definition, the residual"). No change.
- **R-066 · KEEP + explain (confirm)** — "shouldn't $\alpha,\beta$ have hats?"
  Current notation is **internally consistent**: defining projections
  (`eq:decomp`, `eq:cf-reg`) use plain Greek (population coefficients); only the
  *fitted factor* carries hats (`eq:cf` $\hat\gamma$). Hatting $\alpha,\beta$ in
  `eq:decomp` would force hats in `eq:cf-reg` too and break the fitted-value
  definition. **Recommend keep**; optionally add a footnote "empirically the cycle
  is the OLS residual $\hat\varepsilon^{(n)}_{i,t}$." Confirm your preference.
- **R-067 / R-071 · EDIT (drop the "Implementation note." device)** — remove the
  `\paragraph{Implementation note.}` labels at l.80 and (the surviving one) so the
  content flows as normal prose; keep the substance (local estimation; $v=0.987$
  follows CP; sensitivity examined in \Cref{ch:robustness}).
- **R-068 · KEEP (minor)** — "The cycles at different maturities are highly
  collinear but not identical." reads fine.
- **R-069 · KEEP (minor)** — "Equation \eqref{eq:cf} is the empirical analogue of
  the single return-forecasting factor of \citet{cochrane2005}…" reads fine.
- **R-070 · DELETE** the "Implementation note" block "The average cycle in
  \eqref{eq:cbar} excludes the one-year maturity … mirror the role of the average
  forward rate in the \citet{cochrane2005} factor." (redundant: `eq:cbar` already
  shows $n\neq1$).
- **R-072 · EDIT** (specify the currency):
  - **OLD:** "We convert nominal GDP to a common currency before weighting."
    **NEW:** "We convert nominal GDP to US dollars before weighting."
  - "even when coverage is unbalanced": keep.
- **R-073 · DELETE + PRESERVE (G-4)** — remove the proposal framing "Our proposal
  specified a yield-adjusted duration $D^{(n)}_{i,t}=n/(1+y^{(n)}_{i,t})$. However,
  under continuous compounding …"; the duration choice is already in the
  Deviations section. **Keep** the insensitivity sentence (R-074) as plain prose:
  "As \citet{cieslak2015} note, the results are insensitive to this convention,
  and a simple (unstandardised) average leaves our conclusions unchanged."
- **R-074 · VERIFY → OK, RETAIN** — CP do note the standardisation is not critical.
  Keep the sentence (see R-073).
- **R-075 · DELETE (G-4)** — remove "A third specification, which our proposal
  wrote as $\rxbar^{\mathrm{USD}}_{t+12}=\delta_0+\delta_1\GCF_t+\varepsilon_{t+12}$,
  would make $\FXGCF_t$ an affine transform of $\GCF_t$ … we do not pursue it."
  Also drop the `\paragraph{Implementation note.}` label on that paragraph; keep
  the first/second design-choice content (bottom-up mirrors GCF; top-down 0.99
  collinear).
- **R-076 · EDIT (notation consistency — confirm; touches an equation)** — the
  horse-race `eq:h-horse` writes $\beta_i\,\CF_{i,t}$, but the text and the
  results (Table 4.2, "$CF^{\perp}$") use the **orthogonalised** local factor.
  Change $\beta_i\,\CF_{i,t}\rightarrow\beta_i\,\CF^{\perp}_{i,t}$ in `eq:h-horse`
  (and correspondingly note it in `eq:h-usd-local`), so the equation matches the
  reported regressor. Flagged because it edits an equation.

---

## `04_data.tex` — Chapter (Data and Methodology), data sections  *(R-077–R-083)*

- **R-077 / R-078 · VERIFY (AUTHOR) + EDIT** — *"Core CPI (LSEG Refinitiv). … monthly
  seasonally relevant core consumer price indices … (e.g. `aUSCCORF/C`)."* The red
  note *"that's not true is it?"* targets the source/descriptor. Two parts:
  1. **EDIT (recommend):** "seasonally relevant" is not standard — change to
     **"seasonally adjusted"** (OLD: "monthly seasonally relevant core consumer
     price indices" → NEW: "monthly seasonally adjusted core consumer price
     indices"), *unless the series are actually NSA*, in which case drop the word.
  2. **AUTHOR/VERIFY:** confirm the provider is **LSEG Refinitiv** and that the
     ticker `aUSCCORF/C` is correct for US core CPI. Cannot verify from the repo.
- **R-079 · R-CODE (figure)** — *"Yield panel coverage should start at first
  availability."* Regenerate `figures/s1_coverage.pdf` (in `R/plots.R`) so the
  x-axis begins at first data availability (~1989) instead of ~1980's blank
  pre-sample. **Fig 3.1 / `fig:coverage`.** *(G-15 cluster.)*
- **R-080 · R-CODE (figure)** — clarify the coverage-plot legend: the *"Share of
  maturities observed"* colourbar is unclear (author's gloss: dark = all
  maturities observed, light = not all). Relabel the legend/scale in `R/plots.R`.
- **R-081 · R-CODE (table) + AUTHOR** — *"also include other summary statistics"*
  for Table 3.2 (`tables/dh_t1_summary`, generated by `R/empirical.R`). Currently
  mean + SD only. **Recommend adding** min, max, and AR(1) persistence (or N per
  cell). Confirm which stats you want; then regenerate the table.
- **R-082 · EDIT (minor)**:
  - **OLD:** "in the style of \citet{dahlquist2013}, Table~1."
    **NEW:** "following \citet{dahlquist2013}, Table~1."
- **R-083 · FACT-CHECK FAIL → EDIT (two places)** — the claim *"short-maturity
  yields are more volatile than long-maturity yields"* is **false for 7 of 11
  countries**. Verified against `tables/dh_t1_summary.tex`: SD(1y) < SD(10y)
  (long end more volatile) for Belgium, Germany, France, Netherlands, Switzerland,
  Sweden, Canada; short end more volatile only for US, UK, Italy, Japan.
  1. **Body text** `04_data.tex` l.161–162:
     - **OLD:** "Second, short-maturity yields are more volatile than long-maturity yields."
     - **NEW:** "Second, volatility is broadly flat across the maturity spectrum: the short end is somewhat more volatile in the United States, the United Kingdom, Italy, and Japan, whereas in much of the euro area the long end is marginally more volatile."
  2. **Table note** `tables/dh_t1_summary.tex` (`\tabnotes{…}`):
     - **OLD:** "Yields tend to rise and grow less volatile with maturity."
     - **NEW:** "Average yields rise with maturity; volatility is broadly flat across the curve."

---

## `07_results.tex` — Chapter 4, Empirical Findings  *(R-084–R-122, post-restructure)*

> This chapter also **receives the OOS content moved from Ch. 6 §6.1** (Q-2):
> §`sec:res-oos` is expanded with the per-country detail; see the `08_robustness`
> MOVE entry. And **R-104** folds the dynamics subsection into §4.3 (below).

**Well-written chapter — most yellow flags are "revisit tone" and resolve to
KEEP (confirm). Concrete edits and tasks below; everything else is KEEP.**

- **R-084 · KEEP** (intro phrases read fine) — *except* "estimation engine" →
  **global sweep** (see R-143; replace "estimation/empirical engine" with
  "estimation pipeline" everywhere).
- **R-085, R-086, R-091, R-094, R-096, R-098, R-102, R-103, R-106, R-109 (partial),
  R-112–R-121 · KEEP** — these yellow phrases read well; no change unless you flag
  a specific issue. (R-109 optional: "sit awkwardly together" → "be hard to
  reconcile".)
- **R-087 · KEEP / minor** — optionally soften the MC reference: "…lie far above
  what the expectations hypothesis can generate in a sample of this length
  (\Cref{sec:meth-ehmc})."
- **R-088 · VERIFY → OK** — "holds at each individual maturity" is supported by
  Table `mr_t1_phase1_mat` (positive & significant loadings in 10/11). No change.
- **R-089 · R-CODE (figure)** — Fig 4.1 subtitle says "Indigo: GCF_t. Grey:…";
  reword "Indigo" → "Heavy line" (or the actual colour) in `R/plots.R` (`s5_gcf`).
- **R-090 · EDIT** (clarify "single factor"):
  - **OLD:** "This is the signature of a \emph{single} return-forecasting factor that prices the whole curve rather than one maturity segment, exactly as in the United States."
  - **NEW:** "This is the signature of a \emph{single} return-forecasting factor—one common factor priced across all maturities, with loadings that differ only in scale—rather than maturity-specific premia, exactly as in the United States."
- **R-092 · R-CODE (table) + text** — *"Pooled result?"* on Table 4.2: add a
  **G10-panel (country-FE) row** to `tables/mr_t2_phase2` (mirroring Table 4.1's
  panel row), via `main_results.R`; add one sentence reading it off.
- **R-093 · KEEP** — Table 4.2 note ("A significant GCF together with an
  insignificant CF⊥ signals…") reads fine (in `mr_t2_phase2` table file).
- **R-095 · EDIT** (the "28.4% → 28.4%" looks like a typo):
  - **OLD:** "(for example, Germany from $28.4\%$ to $28.4\%$ and Sweden from $29.1\%$ to $29.3\%$)."
  - **NEW:** "(for example, Germany is essentially unchanged at $28.4\%$ and Sweden rises only from $29.1\%$ to $29.3\%$)."
- **R-097 · KEEP (Q-3 check)** — the "euro-area members… sovereign-spread and
  redenomination dynamics" sentence explains the Phase-II exceptions; it is general
  (not the dedicated Italy treatment), so it stays. Confirm it's consistent with
  the Italy cut.
- **R-099 · VERIFY → OK** — "currency risk is the dominant influence" supported by
  the $R^2$ collapse. No change.
- **R-100 · EDIT** (clarify "itself cyclical"):
  - **OLD:** "only where the exchange-rate exposure is small or itself cyclical:"
    **NEW:** "only where the currency exposure is small or where the currency return is itself cyclical (co-moving with the bond signal):"
- **R-101 · EDIT** (punctuation):
  - **OLD:** "in Canada ($t=2.9$), and, more marginally, in Sweden and the United Kingdom"
    **NEW:** "in Canada ($t=2.9$) and, more marginally, in Sweden and the United Kingdom"
- **R-104 · STRUCTURAL (fold subsection)** — remove
  `\subsection{Properties and Dynamics of the Two Global Factors}` (l.278) and let
  the content run on within §4.3 (Phase III). If a visual break is wanted, use an
  unnumbered lead-in sentence, not a numbered subsection.
- **R-105 · VERIFY → OK** — wedge SD/AR(1) support "slow-moving second factor". No change.
- **R-107 · EDIT** (light):
  - **OLD:** "This timing is not accidental, and it points to a clean economic reason why the distinction between the two factors is interesting."
    **NEW:** "This timing is not accidental; it reflects a clear economic reason the distinction matters."
- **R-108 · EDIT (add citation — "Source ???")** — the UIP-failure/carry claim
  ("the classic source of that predictability is the cross-country interest-rate
  differential through the failure of uncovered interest parity") needs a cite. Add
  \citep{fama1984} (and/or the carry literature already cited, `lustig2019`).
  **Check `fama1984` is in `references.bib`; add if missing.**
- **R-110 + R-111 · EDIT (condense the long Dahlquist-contrast sentence):**
  - **OLD:** "It explains why our full-sample FX adjustment recovers less than the one \citet{dahlquist2013} report, since their forward-rate factor retains the rate-level information that drives carry even after aggregation and their sample is weighted more towards the high-differential decades, whereas our detrended cycle factor removes the level and our sample is dominated by the post-2008 low-rate regime in which the currency component is nearly redundant."
  - **NEW:** "It explains why our full-sample FX adjustment recovers less than \citet{dahlquist2013} report: their forward-rate factor retains the rate-level information that drives carry, and their sample is weighted towards the high-differential decades, whereas our detrended cycle factor removes the level and our sample is dominated by the post-2008 low-rate regime, in which the currency component is nearly redundant."
- **R-122 · R-CODE (figure)** — *"the graph with more detail"* for Fig 4.7
  (`mr_f5_oos_r2.pdf`, `fig:mr-oos`). Enhance in `R/plots.R` (e.g. value labels,
  or add the CP/GCP comparison bars). Confirm what detail you want.

---

## `08b_strategy.tex` — Chapter 5, Portfolio Construction  *(R-123–R-140, post-restructure)*

- **R-123, R-124, R-125, R-126, R-130, R-131, R-132, R-134, R-136, R-137 · KEEP** —
  read fine (R-126 optional: "naive" → "simple"; R-137 already glossed with "one
  full portfolio turn per year").
- **R-127 · DELETE** "Because both the factor and the regression are recursive,
  the exposure is ``doubly out-of-sample''." (already explained in methodology).
- **R-128 · EDIT** (clarify; remove "as is"):
  - **OLD:** "We report the Sharpe ratio, which is invariant to a constant rescaling of $w_{t}$, as is. The certainty-equivalent (CER) return, in contrast, is reported at equal average exposure across strategies so that the variance penalty is comparable."
  - **NEW:** "The Sharpe ratio is invariant to a constant rescaling of $w_{t}$, so we report it directly. The certainty-equivalent (CER) return is not scale-invariant, so we report it at equal average exposure across strategies, which makes the variance penalty comparable."
- **R-129 · EDIT (condense the 5-step list "considerably")** — replace the whole
  `\begin{enumerate}…\end{enumerate}` (l.68–101) with a compact single paragraph:
  - **NEW:** "Each month $t$, using only information available at $t$: \emph{(i)} we re-estimate the full generated-regressor chain—trend inflation \eqref{eq:trendinf}, the yield--cycle decomposition \eqref{eq:decomp}, the local-factor regressions \eqref{eq:cf-reg}, and the GDP aggregation \eqref{eq:gcf}—on outcomes realised by $t$ (a twelve-month lag), with a sixty-month minimum training history (\Cref{sec:meth-oos}); \emph{(ii)} we form the forecast $\widehat{\E}_{t}[\rx_{t+12}]=\hat a_{t}+\hat b_{t}\,\GCF^{\mathrm{oos}}_{t}$ from the recursive regression; \emph{(iii)} we estimate the variance $\widehat{\sigma}^{2}_{t}$ on an expanding, lag-respecting window; \emph{(iv)} we set the target weight to the mean--variance exposure \eqref{eq:strat-weight}, truncated at zero (long-only) and rescaled to unit average exposure for reporting; and \emph{(v)} we rebalance monthly, with one-way turnover $|w_{t}-w_{t-1}|$."
  - Keep the following "two implementation details" paragraph (l.103–112) as-is.
- **R-133 + R-139 · R-CODE (figures, G-12) + AUTHOR decision** — *"monthly instead
  of yearly"* / *"also monthly?"* for Fig 5.1 (`strat_f1_cumret`) and Fig 5.3
  (`strat_f3_drawdown`). Currently non-overlapping **annual** (a deliberate choice
  to avoid overlapping-return artefacts in the wealth path). A monthly version
  needs a modelling choice: **monthly-rebalanced 1-month-holding wealth** vs a
  rolling 12-month construct. **Recommend** monthly-rebalanced cumulative excess
  return; confirm, then regenerate both figures in `strategy.R`. Captions update to
  drop "non-overlapping annual".
- **R-135 · EDIT**:
  - **OLD:** "the timed strategy preserves a higher mean and the least-bad Sharpe ratio,"
    **NEW:** "the timed strategy preserves a higher mean and the highest (least negative) Sharpe ratio,"
- **R-138 · VERIFY → OK** — "$\sim$1 bp half-spreads for 10Y G10 bond futures" is
  reasonable for the liquid contracts (Bund/UST/JGB); the $10$ bp cost is indeed
  conservative. No change; optionally cite a microstructure source.
- **R-140 · EDIT (condense the Caveats paragraph)** — replace l.304–331:
  - **NEW:** "We read this result as a proof of concept rather than a tradable system, and note three limitations. First, the magnitude is modest—a Sharpe-ratio improvement of about $0.07$ and a certainty-equivalent gain below one percent a year—and the edge is defensive and episodic, earned in the poor bond decade and the 2021--2022 drawdown rather than in the calm years. Second, the forecasts use overlapping twelve-month returns, so the supporting precision is overstated and the subperiod statistics are descriptive; transaction costs (\Cref{tab:strat-costs}) erode but do not eliminate the advantage. Third, because the global cycle factor is a single series, the strategy can only time aggregate exposure; a cross-sectional strategy would need country-specific predictability, which the local factor does not deliver out of sample. The ceiling for richer constructions is nonetheless higher: \citet{randl2025} show that a mean--variance-efficient portfolio across hedged developed markets attains a Sharpe ratio above one (against $0.46$ for individual markets), with the expected-return forecast the crucial input—so a stable real-time signal of the kind documented here is a natural input to cross-sectionally optimised portfolios. With these caveats, the predictability of \Cref{ch:results} carries genuine, if moderate, economic value for a currency-hedged global bond investor. We take up the broader interpretation in \Cref{ch:discussion}."

## `08_robustness.tex` — Chapter 6, Robustness  *(R-143–R-170, post-restructure; Q-2 + Q-3 apply)*

### Structural (do first)
- **Q-2 · MOVE (OOS → Ch. 4)** — move the **base OOS development** §`sec:rob-oos`
  (l.28–116: pooled Fig `s8-oos`, per-country `s8-oos-local`, convergence
  `s8-gcf-conv`, dollar `s8-oos-usd`, and their prose) into `07_results.tex`
  §`sec:res-oos`, expanding that section from summary to full. **Keep in Ch. 6**
  the estimation-scheme robustness (§`sec:rob-oos-scheme`, "Expanding vs Rolling")
  as its own top-level section — it is a robustness *test*, not the base OOS.
  - **Companion:** rewrite the Ch. 6 intro (l.5–26) so the "tests" list is:
    estimation-scheme sensitivity, subsample stability, CF-vs-CP, core-vs-headline,
    construction sensitivity (OOS full development now lives in Ch. 4). Replace the
    §`sec:rob-oos` cross-ref with a one-line pointer: "The out-of-sample evidence
    is developed in \Cref{sec:res-oos}; here we test its robustness to the
    estimation scheme, the sample period, the predictor family, the inflation
    measure, and the construction choices."
  - **CONFIRM the boundary:** I'm moving the base OOS but keeping scheme-sensitivity
    in Ch. 6. Say if you'd rather move that too.
- **Q-3 · DELETE (Italy)** — delete the whole subsection §`sec:rob-italy`
  *"The Euro-Area Crisis and Italy"* (l.282–312) **and** its Table `tab:rob-italy`
  (`rob_t3`). Update the intro (l.16–17): drop "and we give the euro-area crisis
  and Italy a dedicated treatment". This also resolves R-160 (lone subsubsection)
  and R-161 (the crossed-out Italy paragraph is inside this subsection).

### Line-level
- **R-143 · KEEP** — "a sceptical reader will want to see tested."; "in place of
  the core measure," read fine.
- **R-145 · G-17 (handled elsewhere)** — the note "they did not invent R²_oos" is
  resolved by the R-054 lit deletion and R-189 (discussion strikethrough). In this
  file l.38–39 ("the \citet{campbellthompson2008} out-of-sample statistic") is a
  fair attribution of the *specific statistic form* — **no change**.
- **R-146 · VERIFY → OK** — the "Figure A.7" cross-ref now resolves to
  `\Cref{fig:s8-gcf-conv}`. OK.
- **R-147, R-151, R-154, R-156, R-159, R-165, R-166, R-168 · KEEP** — read fine.
- **R-148 · KEEP** — the "Each scheme scores its factor…" block reads fine.
- **R-149 · VERIFY → OK** — supported by the scheme table (FXGCF +0.019 at
  baseline, negative under 3y/7y/rolling). No change.
- **R-150 · EDIT** (drop the filler):
  - **OLD:** "The window shape, by contrast, matters a great deal, and we have to be clear about this point: the out-of-sample advantage of every specification depends on the expanding window."
  - **NEW:** "The window shape, by contrast, matters a great deal: the out-of-sample advantage of every specification depends on the expanding window."
- **R-152 / R-153 · VERIFY → OK (confirm)** — subsample datings (pre-crisis
  →2007-06; GFC 2007-07–2009-12; euro crisis 2010–2012; post-crisis 2013–) are
  standard and defensible. Confirm they match your preferred windows.
- **R-155 · R-CODE (figure) + caption** — *"which one is the baseline?"* Annotate
  the baseline scheme (expanding/5-year) in Fig `rob_f2_oos_scheme` and add to the
  caption "the baseline is the expanding-window, five-year-minimum scheme."
- **R-157 · KEEP** — the "pre-2008 phenomenon" sentence reads clearly.
- **R-158 · EDIT** (soften to a suspicion, per the note):
  - **OLD:** "We see this as a genuine limitation of the FX-adjusted factor, and the subsample evidence states it more sharply than the pooled regression can."
  - **NEW:** "We read this as a likely limitation of the FX-adjusted factor rather than a firm conclusion, and the subsample evidence states it more sharply than the pooled regression can."
- **R-160 / R-161 · DONE via Q-3** (Italy subsection + paragraph deleted above).
- **R-162 · EDIT** (make the contribution vs Dahlquist explicit):
  - **OLD:** "The integration finding of \Cref{ch:results} is, if anything, stronger for the cycle factor than for the forward factor on which \citet{dahlquist2013} originally established it."
  - **NEW:** "The integration finding of \Cref{ch:results} is, if anything, stronger for the cycle factor than for the forward factor: \citet{dahlquist2013} established global integration in-sample for four markets with the forward-rate factor, whereas we establish it out-of-sample across the G10 with the macro-anchored cycle."
- **R-163 · EDITORIAL (minor)** — "the in-sample is more telling here": optionally
  present the in-sample core-vs-headline table before the OOS one. Low priority;
  keep the OOS finding (it is the section's point). Default: no reorder unless you
  want it.
- **R-164 · DELETE** the struck sentence "While the measure barely matters in
  sample, out of sample it makes the difference between a result and none."
  (the paragraph then opens "The out-of-sample comparison is where the choice of
  inflation measure becomes important…").
- **R-167 · R-CODE / NEW ANALYSIS (§6.5 Sensitivity)** — the section currently
  *argues* robustness to $v,M$ without showing it. Add a small sensitivity
  exhibit re-running the factor over the grid the author specifies: **$M\in\{60,120,180\}$
  months and $v\in\{0.859,0.975,0.987\}$**, reporting in-sample and OOS $R^2$.
  Needs R work (new table/figure); recommend a compact table. Confirm the grid.
- **R-169 · KEEP** — Table `rob_t7` note ("'Mean IS R²' is the cross-country mean
  in-sample fit") already clarifies. No change.
- **R-170 · EDIT (minor)** + KEEP:
  - **OLD:** "deliver only small pooled gains ($+0.00$ to $+0.03$), and no construction dominates."
    **NEW:** "deliver only small pooled gains (between zero and $+0.03$), and no construction dominates."
  - "It is equally important to state clearly what is fragile." — KEEP.

## `09_discussion.tex` — Chapter 7, Discussion  *(R-171–R-191, post-restructure)*

> **Q-3 interpretation (confirm):** "remove Italy everywhere" = remove the
> **dedicated Italy narrative/treatment** (the §6.2.1 subsection + Table A.4 +
> the risk-management/periphery implication + the extended Italy decomposition
> stats). Italy still appears as a **named data point** where it is simply a
> result (e.g. "local content survives in three markets: Italy, the Netherlands,
> Belgium"). Tell me if you want Italy scrubbed from those factual mentions too.

- **R-171 · VERIFY → OK** — "single premium that prices the whole curve":
  interpretive, supported. No change.
- **R-172 · KEEP**. *(Note: "we would suggest/advise/expect" recurs across the
  discussion — see global sweep: optionally reduce this hedging.)*
- **R-173 · EDIT** (gloss "four candidate factors"):
  - **OLD:** "Of the four candidate factors, only the global cycle factor beats the recursive historical mean (\Cref{sec:rob-cf-cp})."
  - **NEW:** "Of the four candidate factors—the local and global cycle factors and their forward-rate counterparts—only the global cycle factor beats the recursive historical mean (\Cref{sec:rob-cf-cp})."
- **R-174 · KEEP** — reads well.
- **R-175 · VERIFY → OK** — the integration-story claims (synchronised inputs,
  aggregation de-noises) are supported. No change.
- **R-176 · DELETE** the paragraph "A recent asset-class perspective adds an
  important qualification … rather than of return co-movement in general."
  (l.68–82). *(Randl-trim theme; consistent with R-186.)*
- **R-177 · EDIT (Q-3 trim + verify Randl)** — condense the exceptions paragraph
  (l.84–106): drop the dedicated Italy stats (horse-race $t=10$, $R^2_{oos}=+0.21$)
  and the `\Cref{sec:rob-italy}` ref (that subsection is deleted); keep the general
  exceptions point and the Randl crisis-timing:
  - **NEW:** "We consider the exceptions as informative as the rule. The local factor retains incremental content in Italy, the Netherlands, and Belgium, concentrated in periods of sovereign stress, which suggests that integration is conditional on the prevailing regime rather than a universal property. When redenomination and sovereign-credit risk reprice a peripheral market, the compensation becomes local again, and a GDP-weighted factor dominated by the core economies cannot price it. We read this conditionality as a refinement of \citet{dahlquist2013} rather than a contradiction. The timing is in line with independent evidence: \citet{randl2025} estimate that the market price of hedged international bond risk peaks in the financial crisis, the 2010--2012 euro-area crisis, and the 2022 inflation shock, and is related to trend inflation and, after 2008, to cross-market inflation dispersion—the same windows in which the cycle factors' explanatory power concentrates in our analysis (\Cref{sec:rob-subsample})." **VERIFY the Randl market-price-of-risk claim against the paper.**
- **R-178 · VERIFY → OK + citation** — the FX/level/UIP interpretation is sound;
  add the same UIP citation as R-108 (`\citep{fama1984}`) at "the failure of
  uncovered interest parity" (l.130–131). Otherwise no change.
- **R-179 · KEEP**.
- **R-180, R-181 · KEEP** — read fine.
- **R-182 · EDIT (Q-3: drop the Italy-result reference)**:
  - **OLD:** "We see the two universes as complementary. Theirs avoids the euro-bloc redundancy, while ours is what makes the periphery (Italy) result observable at all."
  - **NEW:** "We see the two universes as complementary: theirs avoids the euro-bloc redundancy, while ours retains the full euro-area cross-section."
- **R-183 · EDIT (G-4, drop "proposal")** + KEEP:
  - **OLD:** "the FX-adjusted factor is built bottom-up as the GDP-weighted average of per-country USD cycle factors rather than as the projection in the original proposal;"
  - **NEW:** "the FX-adjusted factor is built bottom-up as the GDP-weighted average of per-country USD cycle factors rather than top-down or as a projection on $\GCF_{t}$;"
  - "only for" — KEEP.
- **R-184 · DELETE** the "The EH Monte Carlo calibration gap." limitation paragraph
  (l.226–234). **Companion:** change "five limitations" → "four limitations"
  (l.174).
- **R-185 · KEEP**.
- **R-186 · DELETE** "This prescription does not rest on the cycle evidence alone.
  \citet{randl2025} reach it from the pricing side … best harvested separately."
  (l.260–266). *(paragraph then flows "…adds risk without adding compensation.
  Second, we would advise timing the aggregate…".)*
- **R-187 · DELETE (Q-3)** the whole `\paragraph{For risk management and the
  periphery.}` (l.277–285).
- **R-188 · VERIFY → OK** — Bauer–Rudebusch / Zhang framing accurate. No change.
- **R-189 · EDIT (G-17, drop the C&T "invented" attribution)**:
  - **OLD:** "The out-of-sample discipline of \citet{campbellthompson2008}, which we apply to the full generated-regressor chain and not only to the final regression, reverses this verdict."
  - **NEW:** "Out-of-sample evaluation—applied here to the full generated-regressor chain, not only to the final regression—reverses this verdict."
- **R-190 · KEEP**.
- **R-191 · KEEP** — the "natural next step" (no-arbitrage model) reads clearly.

## `10_conclusion.tex` — Chapter 8, Conclusion  *(R-192–R-193)*

- **R-192 · EDIT (Q-3 Italy trim) + KEEP**:
  - The Bauer falling-stars sentence (l.31–33): KEEP.
  - **OLD:** "Once the global factor is included, genuinely local content survives only in Italy, the Netherlands, and Belgium, and the Italian predictability concentrates in the 2010--2012 sovereign-debt crisis, when redenomination risk was priced locally. Similar to the findings of \citet{dahlquist2013}…"
  - **NEW:** "Once the global factor is included, genuinely local content survives only in Italy, the Netherlands, and Belgium, concentrated in periods of sovereign stress. Similar to the findings of \citet{dahlquist2013}…"
  - "although our results also show that severe sovereign stress marks the limit of this integration": KEEP.
- **R-193 · KEEP** — both flagged sentences read fine. *(Note: the deleted
  EH-MC-gap limitation (R-184) is not listed here, so this stays consistent.)*
- **Also (global "novel"):** l.16 "a novel FX-adjusted global cycle factor" — apply
  the same decision as the abstract R-001 ("novel" drop/keep) for consistency.

## `A_appendix.tex` — Appendix A  *(R-194–R-198)*

- **R-194 · EDIT (Q-3)** — remove the Italy item from the §A.1 intro list:
  - **OLD:** "…the in-sample subsample and inflation-measure estimates, and the Italy crisis decomposition."
    **NEW:** "…and the in-sample subsample and inflation-measure estimates."
- **R-195 · DELETE (Q-3)** — delete the Table block "Italy across subsamples"
  (`tab:rob-italy` / `rob_t3_italy`, l.31–36). *(Same table flagged in Robustness.)*
- **R-196 · R-CODE (G-15, broad)** — *"The ggplot Tables do not have Latex style."*
  Apply a consistent LaTeX-matching `ggplot2` theme (serif font e.g. via
  `showtext`/`extrafont`, matched sizes, muted palette) to **all** generated
  figures in `R/plots.R` (and `main_results.R`, `fxgcf_dynamics.R`,
  `robustness.R`, `strategy.R`). This is a one-pass styling change across the
  figure pipeline. *(Ties to G-10 figure naming, R-089/R-197 subtitles.)*
- **R-197 · R-CODE (figure subtitle)** — Fig A.7 (`s8_oos_is_corr`) right-panel
  subtitle "cor(CF, CF_oos) per country / Closer to 1 means full-sample look-ahead
  added little to the local factor" → reword to plainer language in `R/plots.R`.
  The `.tex` caption (l.106–110) is fine.
- **R-198 · DELETE (Q-4)** — delete the entire `\section{AI Disclaimer}`
  (l.114–138). **Companion check (important):** the acknowledgements and the
  disclaimer comment both point to a *"Statement on the use of generative AI
  tools"* in the **Declaration of Authorship** (`00_declaration.tex`). Before
  deleting, **verify `00_declaration.tex` carries the AI-use statement**; if not,
  move the essential content there rather than losing it. (Programs typically
  require the AI statement somewhere.)

> **R-198 companion — RESOLVED:** `00_declaration.tex` already carries a full
> *"Statement on the use of generative AI tools"* (l.21–35). Deleting the appendix
> §A.3 disclaimer loses nothing required. ✅ Safe to delete.

## `06_replication.tex` — Appendix B, Replication and Validation  *(R-199–R-208)*

- **R-199 · EDIT (G-16, condense the whole appendix)** — replace each table's
  paragraph-length walk-through with a 1–2 sentence summary + pointer. Keep all
  section headings, tables, and figures. Drafted condensed prose:
  - **§B.1 (CP) Panel A** (l.30–43): "In \Cref{tab:cp-t1} we reproduce Table~1 of \citet{cieslak2015}. Panel~A regresses each US yield on trend inflation \eqref{eq:decomp}: the slope is large and significant at every maturity ($1.63$–$1.88$, HAC $t$ from $5.8$ to $12.8$), and the share of yield variation the trend explains rises from $58\%$ (one year) to $84\%$ (ten). \Cref{fig:s2-yield-decomp} shows the split for the US."
  - **§B.1 Panel B** (l.59–71): "Panel~B confirms a single cycle factor: adjacent-maturity cycle correlations are near unity ($0.99$) and fall to $0.74$ between the one- and ten-year cycles, and the cycles are far less persistent than the yields (half-life $55\to10$ months versus $\sim46$–$56$)."
  - **§B.1 CF** (l.73–80, absorbs R-200): "The fitted factor $\CF_{t}$ \eqref{eq:cf} correlates $0.69$ with the average cycle in our US sample, close to the $0.61$ of \citet{cieslak2015} (\Cref{fig:s3-cbar-cf})."
  - **§B.1 Table 2** (l.90–105, absorbs R-201): "In \Cref{tab:cp-t2a} the forward curve alone explains $25\%$ of return variation and adding trend inflation lifts this to $46\%$ (trend loading $t=-3.6$); the two-predictor cycle representation recovers $27\%$ with the opposite-signed loadings that define the mechanism, and the BIC places essentially all posterior weight on the yields-plus-trend specification."
  - **§B.1 Monte Carlo** (l.114–131, absorbs R-202): "Read against a simulated expectations-hypothesis null (\Cref{tab:cp-t2b}, \Cref{sec:meth-ehmc}), whose $95$th percentile reaches $15\%$–$19\%$ at our $300$-month window, the realised $27\%$–$46\%$ sits far in the right tail. Our Monte Carlo reproduces the shape of the null but not the exact published percentiles—a gap we document rather than close."
  - **§B.1 Table 4** (l.140–154, absorbs R-203): "Finally, \Cref{tab:cp-t4} shows the single cycle factor loading positively and significantly at every maturity ($0.69$/$1.37$/$1.42$ at two/five/ten years), with the opposite-signed cycle structure and the long end most predictable ($R^{2}=32\%$ at ten years); block-bootstrap bands \citep{politis1994} exclude zero throughout. We thus reproduce the US evidence in its essentials."
  - **§B.2 (DH)** (l.167–271): condense each of the four table paragraphs to one
    sentence + pointer analogously (Table 3 correlations $0.76$–$0.97$; Table 4
    CP dominates FB; Table 6 global subsumes local; Table 7 FX-adjustment restores
    dollar predictability). Keep the closing "engine validated" paragraph, tightened.
  - *This is the single largest rewrite; apply carefully and recompile.*
- **R-204 · VERIFY → OK (soften)** — *"did we actually double check this?"* The
  reproduced CP numbers (slopes, $R^2$ rising to $84\%$, corr $0.69$ vs $0.61$,
  predictive $27\%$–$46\%$, per-maturity loadings) are consistent with
  Cieslak–Povala (2015). Soften "reproduce … in full" → "reproduce … in its
  essentials" (done in the R-199 condensation).
- **R-205 · EDIT** (gloss Fama–Bliss):
  - **OLD:** "the single-forward Fama--Bliss regression \citep{famabliss1987}"
    **NEW:** "the single forward--spot-spread regression of \citet{famabliss1987}"
- **R-206 · VERIFY** — check "$R^2$ up to $69\%$ in Japan … that they note as well"
  against `tables/dh_t4_fb_cp` (should show Japan ≈ 69%) and the Dahlquist–Hasseltoft
  (2013) paper. Plausible; confirm from the source.
- **R-207 · KEEP** — "very pattern", "cycle" read fine; "engine" → global swap
  (estimation pipeline, R-084/G global).
- **R-208 · R-CODE / table edit** — delete the *"Bootstrap t [5%, 95%]"* row from
  Table B.4 (`tables/cp_t4`, generated by `R/empirical.R`).

---

## Global sweeps & cross-cutting tasks

- **G-1** — every claim needs a source: covered case-by-case via the VERIFY items;
  no blanket action beyond those.
- **G-3** — WU-library availability of cited papers: **AUTHOR** (I can't check WU's
  catalogue). List of key cites to confirm: `randl2025`, `zhu2015`, `zhang2022`,
  `weiwright2013`, `hodrick1992`, `politis1994`.
- **G-4 · DONE (4 sites, verified by grep)** — "proposal" removed at
  `05_methodology` l.181 & l.248 (R-073/R-075), `09_discussion` l.220 (R-183),
  **and `01_introduction` l.113** (newly found): change "we take three
  sub-questions from our research proposal:" → "we pose three sub-questions:".
  Re-grep on apply to confirm zero body-text hits.
- **G-8 · SWEEP (punctuation/italics)** — on apply, sweep for consistency:
  `;` usage, `--`/`---` (en/em dash) usage, and italic (`\emph`) usage of the
  factor names (`CF`, `GCF`, `FXGCF`) — make first-use italic, later uses roman,
  consistently.
- **"operationalise" / "engine" / "novel" / "we would suggest" · SWEEP** —
  - replace "operationalise/operationalises" → "put into practice"/"translate…into"
    (intro l.135, `02_literature` l.10);
  - replace "estimation engine"/"empirical engine" → "estimation pipeline" (intro
    l.8, `07_results` l.8, `06_replication` closing);
  - decide "novel" (abstract R-001, conclusion l.16, replication l.236) —
    recommend dropping it (reads as self-promotional) — apply consistently;
  - optionally thin the "we would suggest/advise/expect" hedging in the discussion.
- **G-9 · DONE via R-058** — framework equations spot-checked; consistent.
- **G-10 / G-13 · R-CODE** — figure short names/"crazy names" and "more detail":
  rename figure files/labels to descriptive names is risky (breaks `\includegraphics`
  paths); instead **improve captions/titles** and add detail per R-089, R-122,
  R-155, R-197. Confirm scope.
- **G-11 · AUTHOR** — abstract/thesis word & page limit: confirm against WU
  guidelines (abstract ≈ 235 words).
- **G-12 · R-CODE** — monthly strategy figures (R-133, R-139), pending your
  compounding choice.
- **G-15 · R-CODE** — restyle all ggplot figures to LaTeX style (R-196): one pass
  over `R/plots.R`, `main_results.R`, `fxgcf_dynamics.R`, `robustness.R`,
  `strategy.R`.
- **G-16 · DONE in playbook** — replication appendix condensed (R-199).
- **G-17 · DONE** — C&T "invented R²_oos" softened (discussion R-189; lit mention
  removed with R-054).
- **G-18 · DONE** — Italy removed everywhere (robustness §rob-italy + table,
  appendix table + list, discussion trims, results/intro/conclusion trims).

### Bibliography checks (verified by grep)
- **`fama1984` — CONFIRMED MISSING from `references.bib`.** Add it for the UIP
  citation (R-108/R-178), or cite an available carry/UIP reference instead.
- **`welch2008` / `thornton2012` — used ONLY in `02_literature.tex`** (the R-054
  paragraph being deleted). After the deletion they are **orphaned** → remove both
  entries from `references.bib` (or keep only if you re-cite them elsewhere).
- Present & OK: `zhu2015`, `randl2025`, `thornton2012`/`welch2008` (until deleted).
- Still to confirm from sources: `randl2025` market-price claim (R-177), Zhang
  (2021) characterisation (R-020), DH Japan 69% (R-206).

### R-code / exhibit tasks (need an R run; separate from the .tex edits)
R-079, R-080, R-081 (data figs/table); R-089, R-092, R-122 (results figs/table);
R-133, R-139 (monthly strat figs); R-155 (scheme fig), R-167 (v/M sensitivity —
new exhibit); R-196, R-197 (figure restyle/subtitle); R-208 (drop table row).
**These are listed but NOT drafted as text**; they run when you green-light the
exhibit regeneration.

---

## Status: PLAYBOOK COMPLETE — confirmations resolved (2026-07-10)

All 208 remarks + 18 global items resolved. **Text edits still not applied**
(awaiting the author's per-item exception review + final "go"). R-code exhibits
greenlit and in progress. Author confirmations:
1. **Intro headings — REMOVE ALL FOUR** `\section*` (Motivation, Research Question,
   Contribution, Main Findings and Structure) per the program guideline. The intro
   becomes a flowing chapter with no sub-headings. *(updates R-007/R-022/R-025 →
   also delete `\section*{Main Findings and Structure}`.)*
2. **Q-3 — remove only the DEDICATED Italy treatment**; Italy stays as a named
   data point in factual result lists. (My interpretation confirmed.)
3. **Q-2 boundary — OK**: base OOS → Ch. 4; estimation-scheme robustness stays Ch. 6.
4. **Notation — YES, apply $\CF^{\perp}$ in `eq:h-horse` AND define it in the
   methodology.** Add to §`sec:fw-hypotheses` Phase II a defining line:
   $\CF^{\perp}_{i,t}$ is the residual of the construction regression
   $\CF_{i,t}=a_i+b_i\,\GCF_{t}+\CF^{\perp}_{i,t}$ (orthogonalisation of the local
   factor on the global factor), so $\beta_i$ in `eq:h-horse` measures incremental
   local content. Update `eq:h-horse` (and `eq:h-usd-local`) to use $\CF^{\perp}_{i,t}$.
5. **Word swaps — ON HOLD** (author's deeper review pending). Do **not** apply the
   "novel"/"engine"/"operationalise"/hedging swaps yet (G-8 punctuation sweep also
   waits). Everything else in the sweeps section is unaffected.
6. **R-code exhibits — GO NOW.** Using recommended defaults where a modelling choice
   was flagged (monthly-rebalanced cumulative excess return for R-133/R-139; add
   min/max/AR(1) for R-081; grid $M\in\{60,120,180\}$, $v\in\{0.859,0.975,0.987\}$
   for R-167). Flag any that can't run in this environment.
7. **Author-supplied — author will do:** title/subtitle (R-141), acknowledgements
   (R-005), word/page limit (G-11), WU-library check (G-3). **⏰ REMIND before final
   compile.**
