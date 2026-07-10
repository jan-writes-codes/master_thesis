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

*Playbook in progress — done: batch-1 + Ch.4 Results. Remaining: `08b_strategy`,
`08_robustness`, `09_discussion`, `10_conclusion`, `A_appendix`, `06_replication`
(R-123–R-208). Global sweeps collected at the end.*
