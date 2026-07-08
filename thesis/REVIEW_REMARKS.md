# Thesis Review — Remarks Log

**Status:** GATHERING. Do **not** edit thesis `.tex` files based on this log
until the author explicitly says review is finished. This file is an
append-only staging area; the editing pass happens as one deliberate action at
the end.

Remarks are extracted from author-annotated PDFs (highlight colour + highlighted
text + attached comment), then located in the source `.tex`.

---

## Colour legend

| Colour | Meaning / action | Confirmed? |
|-------|------------------|------------|
| 🟡 Yellow | **Rewrite** — reword / improve the passage | ✅ |
| 🟣 Purple / lavender | **Too long** — condense, tighten, cut filler | ✅ |
| 🩷 Pink / rose | **Understanding** — unclear; clarify so the reader follows | ✅ |
| 🟢 Green | **Fact-check** — verify the fact / number / citation / claim | ✅ |
| 🔵 Blue | **Definition** — a term needs defining or defining earlier | ✅ |
| 🔴 Red pen (handwriting) | Author's own marks: **strikethrough / big ✗ = delete or rework**; **margin text = an instruction or question** | ✅ |

---

## Cross-cutting / global to-do

These apply across the whole thesis (from the margin notes on the Ch. 1 opening
page and elsewhere). Handle once, globally, in Phase 2.

- **G-1** — Check *every* claim for a source/citation (top of p.9). 🔴
- **G-2** — Open to-do: work out the **implications of the FX** (adjustment). 🔴
- **G-3** — Check whether cited papers are available in the **WU library**. 🔴
- **G-4** — **Remove every mention of "proposal"** ("our proposal…", the
  "Implementation note." blocks that reference it). 🔴  *(recurs on p.19, 20, 21, 22, 23)*
- **G-5** — Handle **inference carefully** throughout. 🔴
- **G-6** — **Randl et al. (2025)** claims must be verified (and see the
  "Dangerous!!" flag, R-018). 🔴
- **G-7** — Provide an **overview of sources** (abstract → path/where cited). 🔴
- **G-8** — Global style sweep: **find all `;` (semicolons), `--`/em-dashes, and
  italics** and make them consistent. 🔴
- **G-9** — **Fact-check everything** in §2.2 Theoretical Framework (note at the
  heading, p.18). 🔴
- **G-10** — Figure short names/captions are "**very crazy**" — rename figures to
  clearer names (List of Figures, p.6). 🔴
- **G-11** — Check the **word-count / page limit** for the abstract/thesis (p.1). 🔴

---

## Remarks

Each item: **[colour] location — "quoted text" → action.**
Page numbers are the **printed** page (PDF page in parentheses where useful).
`[ ]` = pending (all pending until Phase 2).

### Front matter

#### `00_abstract.tex` — Abstract (p.1)
- [ ] **R-001** 🟡 Rewrite — word/phrase flags: "novel", "protocol.",
  "average … in-sample *R²* of 25%", "it beats", "dollar investor". → tighten
  word choices.
- [ ] **R-002** 🟡 Rewrite — closing block: *"…nearly doubling the
  dollar-investor fit, although its real-time edge is small and conditional.
  Ultimately, a timing strategy based on the global factor raises the Sharpe
  ratio of a hedged global bond portfolio from 0.31 to 0.38."* → rework.
- [ ] **R-003** 🔴 Note (arrow to closing sentence): *"more detail or main
  finding"* → expand / foreground the main finding.
- [ ] **R-004** 🔴 Note: *"Word count limit?"* → see G-11.

#### `00_acknowledgements.tex` — Acknowledgements (p.2)
- [ ] **R-005** 🔴 Large ✗ across the whole page → rework/replace the
  acknowledgements (currently a placeholder).

#### List of Figures (p.6, auto-generated)
- [ ] **R-006** 🔴 Note: *"These have very crazy names…"* → see G-10 (rename
  figure captions/short titles).

### `01_introduction.tex` — Chapter 1, Introduction

#### §Motivation (p.9)
- [ ] **R-007** 🔴 "Motivation" subheading struck through → remove the heading.
- [ ] **R-008** 🔴 First sentence struck through: *"In this chapter, we motivate
  and introduce our research question."* → delete.
- [ ] **R-009** 🔴 Margin note at the EH equation: *"i need a proof for this
  (personally)"* → author wants the EH/no-predictability step derived/justified.
- [ ] **R-010** 🔴 Note at the EH equation: *"check if ≈ should be used"* →
  verify the approximation symbol is appropriate.
- [ ] **R-011** 🟡 Rewrite: "Treasuries"; *"We can therefore say that bond risk
  premia are large, time-varying, and countercyclical."*; "The natural follow-up
  question"; "over and above"; "sharpest".
- [ ] **R-012** 🟢 Fact-check: *"whose slope coefficients carry the wrong sign
  relative to the EH benchmark"*; *"tent-shaped"*; "Ludvigson and Ng (2009)";
  *"factors extracted from a large macro panel forecast bond returns"*; *"A
  single cycle factor built from these detrended yields predicts US Treasury
  excess returns more strongly than the CP factor and, in their sample, subsumes
  it."*
- [ ] **R-013** 🟣 Too long: *"They decompose nominal yields into a slow-moving
  trend-inflation component, a discounted moving average of past core inflation
  that anchors the level of interest rates…"* and *"of yields from this anchor"*
  → condense.

#### §Motivation cont. (p.10)
- [ ] **R-014** 🩷 Understanding: *"The structural counterpart of this view is
  the 'falling stars' evidence of Bauer and Rudebusch (2020), who show that
  accounting for the drifting long-run anchors π* and r* is precisely what
  uncovers the predictable component of returns."*
- [ ] **R-015** 🔴 Note at R-014: *"which one is not"* → clarify the ambiguous
  reference (which anchor is which / which is *not*).
- [ ] **R-016** 🟢 Fact-check: *"almost exclusively evidence about the United
  States"*.
- [ ] **R-017** 🟡 Rewrite: *"and thus about one market, one monetary history,
  and one disinflation."*; *"truly anchors yields and cycles truly carry"*
  (repeated "truly … truly"); "direct evidence"; "strongest claim to".
- [ ] **R-018** 🟣 Too long: "global" (in "GDP-weighted global CP factor"); the
  passage around *"interpretation. The international literature…"* → condense.
- [ ] **R-019** 🩷 Understanding: *"plus a volatile currency return,"*; *"and
  because of this they build an FX-adjusted global factor to recover it."*;
  "falling-stars trends".
- [ ] **R-020** 🟢 Fact-check: *"Zhang et al. (2021) come closest. However, they
  add raw inflation trends to yield-curve regressions in four markets rather than
  constructing the cycle factor itself, and they build no global or
  currency-adjusted aggregate."*
- [ ] **R-021** 🔴 Bracket + *"Dangerous!!"* next to the Randl et al. (2025)
  passage (*"…This gives independent support for studying the hedged
  (local-currency) bond premium separately from the currency overlay, as we do in
  our thesis."*) → risky claim; re-examine/soften (see G-6).
- [ ] **R-022** 🔴 "Research Question" heading struck through → reconsider/remove
  heading.

#### §Research Question + §Contribution (p.11)
- [ ] **R-023** 🔴 Brace over the sub-questions + note: *"I have 3 subquestions,
  where is the third?"* → only two sub-questions are listed; add the third.
- [ ] **R-024** 🟣 Too long: *"return, and we ask"* (surrounding clause) →
  condense.
- [ ] **R-025** 🔴 "Contribution" heading struck through → reconsider/remove
  heading.
- [ ] **R-026** 🔴 Struck through: parenthetical *"(1994–2026 for most markets)"*
  → delete.
- [ ] **R-027** 🟡 Rewrite: *"is, to the best of our knowledge, new. It"*;
  *"including the euro-area periphery, whose sovereign-debt crisis provides a
  natural experiment on the limits of integration."*
- [ ] **R-028** 🟣 Too long: *"that is,"* → cut.

#### §Main Findings and Structure (p.12)
- [ ] **R-029** 🔴 Struck through: *"We complement this with an expectations
  hypothesis Monte Carlo that calibrates how much in-sample R² overlapping
  returns can produce under the null"* → delete.
- [ ] **R-030** 🟢 Fact-check: *"The Italian exception is informative, as its
  local predictability concentrates in the 2010–2012 sovereign-debt crisis, when
  redenomination risk priced locally what no global factor could capture."*
- [ ] **R-031** 🟡 Rewrite: "binding constraint"; *"core"*; *"A timing strategy
  based on it raises the Sharpe ratio of a hedged global bond portfolio from 0.31
  to 0.38 with a positive certainty-equivalent gain."*
- [ ] **R-032** 🔴 Struck through: *"A top-down variant is nearly collinear with
  the unadjusted factor (correlation 0.99) and adds almost nothing, so where the
  FX-relevant information sits, namely in the cross-section rather than the
  aggregate, is a finding in itself."* → delete.

#### §Structure (p.13)
- [ ] **R-033** 🟡 Rewrite: *"the expectations-hypothesis Monte Carlo,"*.

### `02_literature.tex` — Chapter 2, Literature Review & Theoretical Framework

#### §2.1 / §2.1.1 (p.14)
- [ ] **R-034** 🟢 Fact-check: *"A fourth, methodological strand, namely the
  out-of-sample and small-sample scrutiny of predictive regressions, cuts across
  all three and shapes our research design."*
- [ ] **R-035** 🟢 Fact-check: *"Their paper introduces both the founding result
  and the zero-coupon data construction that became the standard in the field."*
  (Fama & Bliss 1987).

#### §2.1.1 / §2.1.2 (p.15)
- [ ] **R-036** 🟢 Fact-check: "Ludvigson and Ng (2009)".
- [ ] **R-037** 🩷 Understanding: *"which is the empirical origin of 'unspanned'
  macro risk."*
- [ ] **R-038** 🩷 Understanding: *"A state variable can move expected short rates
  and term premia in offsetting directions, leaving yields nearly unchanged"*.
- [ ] **R-039** 🩷 Understanding: *"endogeneity highlighted by Stambaugh (1999)"*.
- [ ] **R-040** 🟡 Rewrite: "This critique" / "this critique." (repeated close
  together) → reword one.
- [ ] **R-041** 🟢 Fact-check: *"We therefore replicate it in Chapter B and
  compare its global version with the global cycle factor in Chapter 7."*

#### §2.1.3 (p.16)
- [ ] **R-042** 🟡 Rewrite: *"with monthly decay v = 0.987 over a ten-year
  window."*
- [ ] **R-043** 🟢 Fact-check: *"This construction goes back to Kozicki and
  Tinsley (2001),"*.
- [ ] **R-044** 🟡 Rewrite: *"in head-to-head comparisons"*.
- [ ] **R-045** 🩷 Understanding: *"reduces the near-unit-root persistence"*.
- [ ] **R-046** 🩷 Understanding: *"structural counterpart"*.
- [ ] **R-047** 🟡 Rewrite: *"rather than a fortunate parameterisation."*

#### §2.1.4 / §2.1.5 (p.17)
- [ ] **R-048** 🟢 Fact-check: *"We will later mirror this finding for the cycle
  family."*
- [ ] **R-049** 🔴 Note at R-048: *"Can we also mirror his finding?"* → confirm
  the mirrored finding actually holds.
- [ ] **R-050** 🟡 Rewrite: *"The FX-adjusted cycle factor we build in this thesis
  is the direct analogue to this construction, and the contrast between the FX
  adjustments of the two factor families turns out to be one of our findings
  (Section 5.3)."*
- [ ] **R-051** 🩷 Understanding: *"However, they stop short of a synthesis on the
  factor level."*
- [ ] **R-052** 🩷 Understanding: *"On the asset-class side, Randl et al. (2025)"*.
- [ ] **R-053** 🩷 Understanding: *"Their work prices the asset class
  unconditionally. However, it does not ask which observable state variable
  tracks the conditional premium in real time, and this is the question we pose
  in this thesis."*
- [ ] **R-054** 🟣 Too long: *"A final strand of the literature"* (paragraph) →
  condense.
- [ ] **R-055** 🔴 Large ✗ spanning the bottom of p.17 into the top of p.18, over
  the out-of-sample-discipline paragraph (Welch & Goyal 2008; Campbell & Thompson
  2008; Thornton & Valente 2012). **Intent ambiguous** (delete vs. flag) —
  **confirm with author in Phase 2.**

#### §2.1.5 tail + §2.2 opening (p.18)
- [ ] **R-056** 🟣 Too long: *"a simulated no-predictability benchmark."*
- [ ] **R-057** 🟡 Rewrite: *"with bootstrap and Monte-Carlo inference calibrated
  to the overlapping-return environment."*
- [ ] **R-058** 🔴 Note at §2.2 heading: *"Fact check everything here"* → see G-9.
- [ ] **R-059** 🟡 Rewrite: "operationalise"; "menu".
- [ ] **R-060** 🔵 Definition: *"N = {1, 2, 4, 5, 9, 10}"* → define the maturity
  set explicitly.
- [ ] **R-061** 🟡 Rewrite: *"which is dictated by data availability (Chapter 3)."*

#### §2.2.1 – §2.2.3 (p.19)
- [ ] **R-062** 🩷 Understanding: *"E_t[rx^(n)_{t+12}] = const."* (restriction) →
  clarify.
- [ ] **R-063** 🔴 Struck through: *"Forward rates (Cochrane and Piazzesi, 2005)
  and, even more powerfully, macro-anchored cycles (Cieslak and Povala, 2015)
  predict rx^(n)_{t+12} with economically large R²."* → delete.
- [ ] **R-064** 🟡 Rewrite: *"we build the predictors that we use to document and
  interpret this predictability in an international setting."*; *"EH itself in
  Section 4.4, where it serves as a simulated benchmark for the magnitude of
  predictive R²."*
- [ ] **R-065** 🔵 Definition: the *c^(n)_{i,t}* (cycle) term in Eq (2.3) → define.
- [ ] **R-066** 🔴 Note at Eq (2.3) (with hat sketch): *"shouldn't α and β have
  hats?"* → estimated coefficients should carry hats (notation fix).
- [ ] **R-067** 🟡 Rewrite: "Implementation note." lead-in (see G-4).
- [ ] **R-068** 🟡 Rewrite: *"The cycles at different maturities are highly
  collinear but not identical."*

#### §2.2.4 – §2.2.5 (p.20)
- [ ] **R-069** 🟡 Rewrite: *"Equation (2.7) is the empirical analogue of the
  single return-forecasting factor of Cochrane and Piazzesi (2005),"*.
- [ ] **R-070** 🔴 Large ✗ over the "Implementation note." block (*"The average
  cycle in (2.5) excludes the one-year maturity… mirror the role of the average
  forward rate in the Cochrane and Piazzesi (2005) factor."*) → delete (see G-4).
- [ ] **R-071** 🟡 Rewrite: "Implementation note." lead-in.
- [ ] **R-072** 🟡 Rewrite: *"even when coverage is unbalanced"*; *"We convert
  nominal GDP to a common currency before weighting."*

#### §2.2.5 – §2.2.6 (p.21)
- [ ] **R-073** 🟡 Rewrite: "Implementation note." lead-in + *"Our proposal
  specified a yield-adjusted duration D^(n)_{i,t} = n/(1+y^(n)_{i,t})."* →
  remove proposal reference (see G-4).
- [ ] **R-074** 🟢 Fact-check: *"As Cieslak and Povala (2015) note, the results
  are insensitive to this convention, and a simple (unstandardised) average
  leaves our conclusions unchanged."*

#### §2.2.6 – §2.2.7 (p.22)
- [ ] **R-075** 🔴 Struck through (equation circled): *"A third specification,
  which our proposal wrote as rx^USD_{t+12} = δ0 + δ1 GCF_t + ε_{t+12}, would make
  FXGCF_t an affine transform of GCF_t and, hence, statistically
  indistinguishable from it; we do not pursue it."* → delete (proposal ref, G-4).
- [ ] **R-076** 🟡 Rewrite: the *CF_{i,t}* term in Eq (2.15).

### `04_data.tex` — Chapter 3, Data

#### §3.1 Universe and Sources (p.24)
- [ ] **R-077** 🟡 Rewrite: "Core CPI (LSEG Refinitiv)." lead-in.
- [ ] **R-078** 🔴 Note at R-077: *"that's not true is it?"* → fact-check the CPI
  data source / the "seasonally relevant core CPI" claim (verify provider &
  wording).

#### §3.3 Cleaning and Variable Construction — Figure 3.1 (p.26)
- [ ] **R-079** 🔴 Note: *"Yield panel coverage should start at first
  availability."* → the coverage figure should begin at first data availability
  (trim the empty pre-sample region). *(figure regenerated in `R/plots.R`)*
- [ ] **R-080** 🔴 Note on the legend: *"Blue = observed (all); light blue = not
  all observed (part of the colour palette)"* → clarify the "Share of maturities
  observed" colourbar legend.

#### §3.4 Summary Statistics — Table 3.2 (p.27)
- [ ] **R-081** 🔴 Note: *"also include other summary statistics"* → Table 3.2
  should report more than mean/SD. *(table from `R/empirical.R` / `R/plots.R`)*
- [ ] **R-082** 🟡 Rewrite: *"in the style of Dahlquist and Hasseltoft (2013),
  Table 1"*.
- [ ] **R-083** 🟢 Fact-check: *"Second, short-maturity yields are more volatile
  than long-maturity yields."* → verify the claim holds across all countries in
  Table 3.2.

---

## Open questions for the author (resolve before/at Phase 2)

- **Q-1 (R-055):** the large ✗ over the out-of-sample-discipline paragraph
  (p.17–18) — delete the paragraph, or just a flag to revisit?

---

## Review sessions

| Date | Source PDF(s) | Chapters covered | Remarks added |
|------|---------------|------------------|---------------|
| 2026-07-08 | `master_thesis_first_proof_read.pdf` | Front matter, Ch. 1 (Intro), Ch. 2 (Lit. + Framework), Ch. 3 (Data) | R-001 – R-083, G-1 – G-11 |
