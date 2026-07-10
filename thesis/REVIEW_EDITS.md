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

*Playbook in progress — remaining files: `02_literature`, `04_data`,
`05_methodology`, `07_results`, `08b_strategy`, `08_robustness`,
`09_discussion`, `10_conclusion`, `A_appendix`, `06_replication`. Global sweeps
(G-4 proposal, G-8 punctuation/italics, G-10/G-15 figures, etc.) collected at the
end.*
