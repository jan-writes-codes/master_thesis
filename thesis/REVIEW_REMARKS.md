# Thesis Review — Remarks Log

**Status:** GATHERING. Do **not** edit thesis `.tex` files based on this log
until the author explicitly says review is finished. This file is an
append-only staging area; the editing pass happens as one deliberate action at
the end.

Remarks are extracted from author-annotated PDFs (highlight colour + highlighted
text + attached comment), then located in the source `.tex`.

> ⚠️ **Staleness caveat (batch of 2026-07-08 / `first_proof_read`):** this PDF
> was proof-read **before the structure changes made on 2026-07-07**. Section
> numbers, page numbers, and even which `.tex` file a passage lives in may have
> shifted. In Phase 2, **re-locate every remark by its quoted text against the
> current source** before editing; do not trust the page/section anchors below.
> If a quoted passage no longer exists, flag it rather than force-fitting.

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
- **G-12** — Strategy performance figures are on a **non-overlapping annual**
  basis; author wants a **monthly** version (Fig 5.1 wealth → R-133; Fig 5.3
  drawdown → R-139). Regenerate from the strategy R script. 🔴
- **G-13** — Several exhibits need **"more detail"** (Fig 4.7 → R-122); relates
  to G-10 (figure naming). 🔴
- **G-14** — **Structural:** the author questions whether **Chapter 6
  (Robustness)** should stay a dedicated chapter or be moved/merged, since Ch. 4
  already carries the OOS analysis (R-142, "Scratch this chapter" R-158). → **Q-2.** 🔴
- **G-15** — The **ggplot figures/tables don't match the LaTeX style** — restyle
  them for visual consistency (R-194). Relates to G-10/G-13. 🔴
- **G-16** — **Appendix B (Replication) prose is too long** — condense to a
  summary that points to the tables rather than narrating each one (R-197). 🔴
- **G-17** — **Attribution:** do not credit Campbell–Thompson (2008) with
  *inventing* the OOS R²; check and soften the wording (R-143, R-187). 🔴
- **G-18** — **Italy theme:** the author marks the dedicated Italy treatment for
  removal in several places (§6.2.1, R-159, R-185, Table A.4 R-193, appendix
  mention R-192). Treat as one coordinated cut. → **Q-3.** 🔴

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
- [ ] **R-054 + R-055** 🔴 **DELETE** the whole passage from *"A final strand of
  the literature"* through *"…a simulated no-predictability benchmark."*
  (the out-of-sample-discipline paragraph: Welch & Goyal 2008; Campbell &
  Thompson 2008; Thornton & Valente 2012; Bauer & Hamilton 2018). ✅ *Q-1
  resolved by author — the large ✗ means drop it.* Supersedes the earlier
  "too long / condense" reading and absorbs R-056.

#### §2.1.5 tail + §2.2 opening (p.18)
- [ ] **R-056** 🟣 Too long: *"a simulated no-predictability benchmark."* →
  **absorbed into R-054+R-055 (deleted).**
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

### `07_results.tex` — Chapter 4, Empirical Findings

*(Batch of 2026-07-08 / `master_thesis_6_2` — **post-restructure**, maps to
current files directly.)*

#### Intro (p.28)
- [ ] **R-084** 🟡 Rewrite (phrases): "estimation engine"; *"the international
  evidence of Dahlquist and Hasseltoft (2013)."*; *"which is the natural test of
  international market integration"*; *"In Phase III, we ask whether currency risk
  overturns the predictability for a US-dollar investor and, if so, whether the
  purpose-built FX-adjusted global factor restores it."*; *"; the
  reverse-regression caveat stated there applies throughout."*; *"We read the
  magnitudes of the predictive R² against the expectations-hypothesis Monte Carlo
  of Section 3.12, whose 95th percentile under the null lies well below the R² we
  document here."*
- [ ] **R-085** 🟡 Rewrite: *"with a remarkably uniform structure."*

#### §4.1 Local cycle factor + Table 4.1 (p.29)
- [ ] **R-086** 🟡 Rewrite: *"economic magnitude of this predictability is
  large."*; *"leave little cyclical variation for the factor to explain."*
- [ ] **R-087** 🟡 Rewrite: *"Seven of the eleven markets exceed an R² of 24%.
  These values lie far above the 95th percentile of the predictive R² that the
  expectations hypothesis generates in a sample of this length (Section 3.12)."*
- [ ] **R-088** 🟢 Fact-check: *"each individual maturity and not only for the
  maturity-averaged return."*

#### §4.1 / §4.2 + Figure 4.1 (p.30)
- [ ] **R-089** 🟡 Rewrite: Figure 4.1 subtitle wording — *"Indigo: GCF_t. Grey:
  country-level local CFs."* (reword "Indigo"). *(figure from R)*
- [ ] **R-090** 🩷 Understanding: *"This is the signature of a single
  return-forecasting factor that prices the whole curve rather than one maturity
  segment, exactly as in the United States."*
- [ ] **R-091** 🟡 Rewrite: "common" (in "a common source of risk").

#### §4.2 + Table 4.2 (p.31)
- [ ] **R-092** 🔴 Note (arrow to Table 4.2): *"Pooled result?"* → consider
  adding/showing a pooled result.
- [ ] **R-093** 🟡 Rewrite (table note): *"A significant GCF together with an
  insignificant CF⊥ signals that the global factor subsumes the local factor."*
- [ ] **R-094** 🟡 Rewrite: *"and an essentially identical 25% for the global
  factor"*; *", and is statistically indistinguishable from zero in the other
  eight, where it sometimes even enters with the wrong sign."*
- [ ] **R-095** 🟡 Rewrite: *"(for example, Germany from 28.4% to 28.4% and Sweden
  from 29.1% to 29.3%)."*
- [ ] **R-096** 🟡 Rewrite: *"This confirms that the combined cycle information is
  genuinely priced everywhere."*

#### §4.2 / §4.3 + Figure 4.2 (p.32)
- [ ] **R-097** 🟡 Rewrite: *"For the euro-area members, this residual plausibly
  reflects sovereign-spread and redenomination dynamics that are local in origin
  yet absent from the common factor."*
- [ ] **R-098** 🟡 Rewrite: *"dollar excess return"*.
- [ ] **R-099** 🟢 Fact-check: *"find that currency risk is the dominant influence
  on the dollar investor's returns"*.
- [ ] **R-100** 🩷 Understanding: *"exchange-rate exposure is small or itself
  cyclical"* (spans p.32→33).

#### §4.3 + Table 4.3 (p.33)
- [ ] **R-101** 🩷 Understanding: *"Canada (t = 2.9), and,"*.
- [ ] **R-102** 🟡 Rewrite: "HAC" (in "lifts the HAC t-statistic in nine").
- [ ] **R-103** 🟡 Rewrite: *"why the adjustment has room to work:"*.

#### §4.3.1 + Figure 4.3 (p.34)
- [ ] **R-104** 🔴+🟡 Note over the §4.3.1 heading (*"Properties and Dynamics of
  the Two Global Factors"*): *"This should not be a subsection → it's part of the
  research question."* → fold this material into the main flow rather than a
  numbered subsection.

#### §4.3.1 cont. + Figure 4.4 (p.35)
- [ ] **R-105** 🟢 Fact-check: *"so the FX component is a slow-moving second factor
  in its own right rather than measurement noise."*
- [ ] **R-106** 🟡 Rewrite: *"0.78, hides pronounced time variation."*
- [ ] **R-107** 🟡 Rewrite: *"This timing is not accidental, and it points to a
  clean economic reason why the distinction between the two factors is
  interesting."*
- [ ] **R-108** 🔴 Note (margin brace): *"Source ???"* → the uncovered-interest-
  parity / carry-channel paragraph needs a citation.
- [ ] **R-109** 🟡 Rewrite: *"otherwise sit awkwardly together."*
- [ ] **R-110** 🟣 Too long: the passage *"…recovers less than the one Dahlquist
  and Hasseltoft (2013) report, since their forward-rate factor…"* → condense
  (spans p.35→36).

#### Table 4.4 + §4.4 (p.36)
- [ ] **R-111** 🟣 Too long: *"since their forward-rate factor retains the
  rate-level information that drives carry even after aggregation and their sample
  is weighted more towards the high-differential decades, whereas our detrended
  cycle factor removes the level and our sample is dominated by the post-2008
  low-rate regime in which the currency component is nearly redundant."*
- [ ] **R-112** 🟡 Rewrite: *"We now turn to that test."*
- [ ] **R-113** 🟡 Rewrite: *"could have exploited"*.
- [ ] **R-114** 🟡 Rewrite: *"This statistic compares the squared forecast errors
  of the recursive factor with those of a competing real-time forecast, the
  recursive prevailing mean, i.e. the historical average return updated each
  period using only past data, so that R²_oos = 1 − SSE_factor/SSE_mean."*
- [ ] **R-115** 🟡 Rewrite: *"The OOS R² is therefore measured against a far more
  demanding benchmark than the in-sample R², which is the variance explained
  around the full-sample mean using full-sample coefficients."*

#### Figure 4.5 + text (p.37)
- [ ] **R-116** 🟡 Rewrite: *"not comparable in level:"*.
- [ ] **R-117** 🟡 Rewrite: *"The strong in-sample fit of Section 4.1 is, for most
  countries, the in-sample over-fit of a generated regressor"*.
- [ ] **R-118** 🟡 Rewrite: *"We consider this the strongest evidence in our thesis
  for integration:"*.

#### Figure 4.6 + §4.5 (p.38)
- [ ] **R-119** 🟡 Rewrite: *"is far more modest than"*.
- [ ] **R-120** 🟡 Rewrite: *"which is well beyond what the expectations hypothesis
  can produce."*

#### Table 4.5 + text (p.39)
- [ ] **R-121** 🟡 Rewrite: *"we should take seriously is"* (…"the global one.").

#### Figure 4.7 (p.40)
- [ ] **R-122** 🔴 Note: *"the graph with more detail"* → Figure 4.7 needs more
  detail. *(regenerate from R; see G-13)*

### `08b_strategy.tex` — Chapter 5, Portfolio Construction

#### Intro + §5.1 Strategy Design (p.41)
- [ ] **R-123** 🟡 Rewrite: *"is precisely the"* (in "A positive out-of-sample R²
  is precisely the condition…").
- [ ] **R-124** 🟡 Rewrite: *"we take no position that an investor could not have
  taken in real time,"*.
- [ ] **R-125** 🟡 Rewrite: *"We therefore run the strategy for a currency-hedged
  global investor and analyse the unhedged US-dollar investor separately in
  Section 5.5."*
- [ ] **R-126** 🟡 Rewrite: *"Even this naive weighting already captures
  substantial diversification benefits from imperfectly correlated term-structure
  movements across markets (Randl et al., 2025)."*

#### §5.2 Implementation (p.42)
- [ ] **R-127** 🔴 Strikethrough: *"Because both the factor and the regression are
  recursive, the exposure is 'doubly out-of-sample'."* → delete.
- [ ] **R-128** 🩷 Understanding: *"We report the Sharpe ratio, which is invariant
  to a constant rescaling of w_t, as is. The certainty-equivalent (CER) return, in
  contrast, is reported at equal average exposure across strategies so that the
  variance penalty is comparable."*
- [ ] **R-129** 🟡+🔴 Rewrite + margin note *"Shorten considerably"*: the whole
  five-step enumerated Implementation list (i)–(v) → shorten considerably.
- [ ] **R-130** 🟡 Rewrite: *"rather than tuned"*.

#### Table 5.1 + §5.3 Performance (p.43)
- [ ] **R-131** 🟡 Rewrite: *"and not to construction complexity."*
- [ ] **R-132** 🟡 Rewrite: *"The global bond portfolio itself has an out-of-sample
  R² of 0.125 against the recursive mean. This is higher than the pooled panel
  figure of Section 4.4 because aggregating the eleven national cycles into one
  global signal averages away estimation noise."*
- [ ] **R-133** 🔴 Note (margin, Fig 5.1): *"I would like to see monthly instead of
  yearly"* → show performance monthly, not non-overlapping annual. *(see G-12)*

#### Figure 5.1 + §5.4 Subperiods, Turnover, Costs (p.44)
- [ ] **R-134** 🟡 Rewrite: *"When premia are persistently high, the best a timing
  rule can do is stay invested, and any variation in exposure adds volatility."*
- [ ] **R-135** 🟡 Rewrite: *"least-bad Sharpe ratio,"*.
- [ ] **R-136** 🟡 Rewrite: *"Across all windows, the timed portfolio is on top in
  barely half."*
- [ ] **R-137** 🩷 Understanding: *"one-way turnover of the timed portfolio is 9.2%
  of notional per month (mean-timing: 1.3%),"*.

#### Figure 5.2 + §5.5 US-Dollar Investor (p.45)
- [ ] **R-138** 🟢 Fact-check: *"conservative for ten-year G10 government bond
  futures,"* (the ~1 bp half-spread assumption).

#### Figure 5.3 + §5.6 Caveats (p.46)
- [ ] **R-139** 🔴 Note: *"also monthly?"* → Figure 5.3 (drawdown, annual) — also
  produce a monthly version. *(see G-12)*
- [ ] **R-140** 🟡 Rewrite: the whole §5.6 Caveats opening paragraph (*"We would
  suggest reading this result as a proof of concept … the strategy can only time
  aggregate"*) → rewrite/condense.

### `00_titlepage.tex` — Title page  *(from `master_thesis_6_3`)*
- [ ] **R-141** 🔵 Note (blue ink): title/subtitle brainstorm playing on "cycle":
  *"Circling back on: Expected returns…"*, *"Breaking the cycle? Expected
  returns…"*, *"Stuck in a cycle: Expected returns…"* → consider a catchier
  title/subtitle (author's decision in Phase 2).

### `00_acknowledgements.tex`  *(from `master_thesis_6_3`)*
- [ ] **R-142** 🔴 Large ✗ over the whole page again — **reaffirms R-005**
  (rework/replace the acknowledgements).

### `08_robustness.tex` — Chapter 6, Robustness  *(from `master_thesis_6_4`, post-restructure)*

#### Intro + §6.1 Out-of-Sample Predictability (p.50)
- [ ] **R-143** 🟡 Rewrite: *"a sceptical reader will want to see tested."*; *"of
  the core measure,"*.
- [ ] **R-144** 🔴 Note (margin, §6.1): *"I feel like this chapter should move… we
  already have OOS analysis in Chapter 4?"* → **Q-2 / G-14.**
- [ ] **R-145** 🔴 Note + underline on "Campbell and Thompson (2008)": *"they did
  not invent the R²_oos ??"* → check/soften attribution. **G-17.**

#### §6.1.1 Expanding vs Rolling Windows (p.52)
- [ ] **R-146** 🟢 Fact-check: "Figure A.7)" (cross-ref).
- [ ] **R-147** 🟡 Rewrite: "entire"; "from scratch".

#### §6.1.1 cont. (p.53)
- [ ] **R-148** 🟡 Rewrite: *"Each scheme scores its factor against the prevailing
  mean constructed under the same scheme, so the comparison is internally
  consistent. Table 6.1 and Figure 6.4 report the pooled out-of-sample R². The
  expanding/five-year column reproduces the baseline of Table 6.2 exactly, which
  serves as a check on the rebuilt machinery."*
- [ ] **R-149** 🟢 Fact-check: *"the FX-adjusted factor's real-time edge exists at
  the baseline but is not a robust feature of every reasonable scheme."*
- [ ] **R-150** 🟡 Rewrite: *"we have to be clear about this point:"*.

#### Table 6.1 + §6.2 Subsample Stability (p.54)
- [ ] **R-151** 🟡 Rewrite: *"sharpens those loadings."*; "correspondingly"; *"It
  is positive only under the baseline five-year expanding minimum and, marginally,
  the fifteen-year rolling window, so its real-time edge should be read as
  conditional on the estimation scheme."*
- [ ] **R-152** 🔴 Note (margin, §6.2): *"are the time frames ok?"* → verify the
  subsample date ranges.
- [ ] **R-153** 🟢 Fact-check: subsample dates *"global financial crisis (July
  2007–December 2009)"*; *"euro-area sovereign-debt crisis (2010–2012)"*.
- [ ] **R-154** 🟡 Rewrite: "HAC".

#### Figure 6.4 + text (p.55)
- [ ] **R-155** 🔴 Note (arrow to x-axis): *"which one is the baseline?"* →
  label/clarify the baseline scheme in Figure 6.4.
- [ ] **R-156** 🟡 Rewrite: "the flight-to-quality"; "exposes a"; "conceals".
- [ ] **R-157** 🩷 Understanding: *"Section 4.3 is therefore largely a pre-2008
  phenomenon. Once the post-crisis currency regime of near-zero rate differentials
  and synchronised monetary policy sets in, the cyclical signal in dollar returns
  disappears."*
- [ ] **R-158** 🔴 Note (margin arrow): *"would rather present this as a suspicion
  than a fact + source"* → soften *"We see this as a genuine limitation…"* to a
  conjecture and add a citation.

#### Table 6.2 + §6.2.1 (p.56)
- [ ] **R-159** 🟡 Rewrite: *", the one regime in which no slow-moving macro factor
  can be expected to forecast the panic-driven repricing of 2008."*; *"It is the
  only specification that stays positive through the financial crisis (+0.08)…"*;
  *"and it breaks down only in the financial crisis of 2008 itself."*
- [ ] **R-160** 🔴 §6.2.1 heading *"The Euro-Area Crisis and Italy"* struck
  through + notes *"Scratch this chapter"* and *"no subsubsection if it is only
  one"* → remove the lone subsubsection (fold into §6.2). **Q-2 / Q-3.**

#### Figure 6.5 + §6.3 (p.57)
- [ ] **R-161** 🔴 Large ✗ over the Italy paragraph (*"driven by redenomination and
  sovereign-spread dynamics… reasserts local predictability exactly when it
  matters most."*) → delete. **Q-3 / G-18.**

#### Figure 6.6 + §6.4 (p.58)
- [ ] **R-162** 🔴 Note (arrow, end §6.3): *"how much do we differ from
  Dahlquist?"* → clarify/quantify the contribution vs Dahlquist & Hasseltoft (2013).

#### Table 6.3 + §6.4 Core vs Headline Inflation (p.59)
- [ ] **R-163** 🔴 Note (arrow to Table 6.3): *"I think the in-sample is more
  telling here"* → lead with in-sample for the core-vs-headline comparison.
- [ ] **R-164** 🔴 Strikethrough: *"While the measure barely matters in sample, out
  of sample it makes the difference between a result and none."* → delete.
- [ ] **R-165** 🟡 Rewrite: *"), plausibly because the energy-price component that
  contaminates the headline trend also moves exchange rates and is therefore not
  pure noise for a dollar-return factor (Table 6.3)."*

#### §6.4 tail + §6.5 Sensitivity + §6.5.1 (p.60)
- [ ] **R-166** 🟡 Rewrite: *"The use of core CPI is therefore not merely a
  convention inherited from Cieslak and Povala (2015). It is material to the
  headline real-time result, and the global cycle factor's out-of-sample
  predictability is a property of the macro anchor measured cleanly."*
- [ ] **R-167** 🔴 Note (§6.5 heading): *"robustness check with M=60, M=180,
  v=0.859, v=0.975"* → add EWMA window/decay robustness checks.
- [ ] **R-168** 🟡 Rewrite: "afresh"; *"because it is the one choice that changes a
  result."*; "weighting:".

#### Table 6.4 + §6.5 tail (p.61)
- [ ] **R-169** 🩷 Understanding: table note *"'Mean IS R²' is the cross-country
  mean in-sample fit,"*.
- [ ] **R-170** 🟡 Rewrite: *"(+0.00 to +0.03), and"*; *"It is equally important to
  state clearly what is fragile."*

### `09_discussion.tex` — Chapter 7, Discussion

#### §7.1 Economic Interpretation (p.62)
- [ ] **R-171** 🟢 Fact-check: *"expect from a single premium that prices the whole
  curve"*.
- [ ] **R-172** 🟡 Rewrite: "which we would expect from".
- [ ] **R-173** 🩷 Understanding: "four candidate factors,".
- [ ] **R-174** 🟡 Rewrite: *"the choice of state vector. Between prices (forwards)
  and macro-anchored cycles, the cycle performs better where it matters most,
  namely in real time."*

#### §7.1 The integration story (p.63)
- [ ] **R-175** 🟢 Fact-check (green margin bracket) on *"The integration story"*
  paragraph (*"Economically, the inputs to the factor are themselves
  synchronised…"*) → verify claims.
- [ ] **R-176** 🔴 Large ✗ over the *"A recent asset-class perspective adds an
  important qualification… rather than of return co-movement in general."*
  paragraph → delete.
- [ ] **R-177** 🟢 Fact-check: *"Randl et al. (2025) estimate that the market price
  of risk of the hedged international bond asset class peaks in the financial
  crisis, the 2010–2012 euro-area crisis, and the 2022 inflation shock,"*.

#### §7.1 cont. — FX adjustment / What ultimately survives (p.64)
- [ ] **R-178** 🟢 Fact-check: "in our analysis (Section 6.2),"; *"the level and
  shape of the forward curve,"*; *"removes the level by construction"*; *"which is
  why it shows up strongly in the in-sample cross-section, weakly in real time,
  and hardly at all in the aggregate"*.
- [ ] **R-179** 🟡 Rewrite: "almost nothing ("; "ultimately survives".

#### §7.2 Limitations (p.65)
- [ ] **R-180** 🟡 Rewrite: *"The block-bootstrap intervals (Politis and Romano,
  1994) and the expectations-hypothesis Monte Carlo mitigate this problem…"*;
  *"which is immune to the over-rejection problem, since a recursive forecast
  either beats the prevailing mean or it does not"*.
- [ ] **R-181** 🟡 Rewrite: *"the equivalent of only about thirty non-overlapping
  annual observations per country, spanning one secular disinflation, one
  zero-lower-bound decade, and one inflation shock."*
- [ ] **R-182** 🟡 Rewrite: *"An alternative design, adopted by Randl et al. (2025),
  represents the euro area by German Bunds alone and includes Australia, New
  Zealand, and Norway instead… ours is what makes the periphery (Italy) result
  observable at all."*

#### §7.2 cont. + §7.3 Implications (p.66)
- [ ] **R-183** 🟡 Rewrite: "only for"; *"rather than as the projection in the
  original proposal"* (proposal ref → **G-4**).
- [ ] **R-184** 🔴 Large ✗ over *"The EH Monte Carlo calibration gap."* limitation
  paragraph → delete.
- [ ] **R-185** 🟡 Rewrite: *"We do not regard these results as minor details,
  because"*.
- [ ] **R-186** 🔴 Strikethrough: *"This prescription does not rest on the cycle
  evidence alone. Randl et al. (2025) reach it from the pricing side… best
  harvested separately."* → delete.

#### §7.3 cont. (p.67)
- [ ] **R-187** 🔴 Large ✗ over the *"For risk management and the periphery."*
  paragraph → delete. **G-18 / Q-3.**
- [ ] **R-188** 🟢 Fact-check: *"This is the international counterpart of the
  falling-stars mechanism of Bauer and Rudebusch (2020) and a factor-level
  complement to the trend-augmented forecasting of Zhang et al. (2021):"*.
- [ ] **R-189** 🔴 Strikethrough: *"of Campbell and Thompson (2008),"* → remove/soften
  attribution. **G-17.**
- [ ] **R-190** 🟡 Rewrite: *"the full generated-regressor chain"*.
- [ ] **R-191** 🩷 Understanding: *"A natural next step, which lies beyond the scope
  of this thesis, would be to embed the global cycle in a no-arbitrage term
  structure model with a shared international trend. This would close the gap
  between the reduced-form evidence we assemble here and the structural
  falling-stars framework."*

### `10_conclusion.tex` — Chapter 8, Conclusion

#### (p.68)
- [ ] **R-192** 🟡 Rewrite: *"This is in line with the falling-stars evidence of
  Bauer and Rudebusch (2020), according to which the predictable component of bond
  returns appears once the slow-moving macro anchors are accounted for."*; *"and
  the Italian predictability concentrates in the 2010–2012 sovereign-debt crisis,
  when redenomination risk was priced locally."*; *"although our results also show
  that severe sovereign stress marks the limit of this integration."*

#### (p.69)
- [ ] **R-193** 🟡 Rewrite: *"We also find, however, that this recovery depends on
  the construction (a top-down variant is nearly collinear with the unadjusted
  factor, at 0.99) and that it translates into only a small, scheme-sensitive
  real-time edge that does not help in timing the aggregate dollar portfolio."*;
  *"7, in particular the inference under overlapping returns, the single macro
  regime covered by our sample, and the dependence of the real-time result on
  expanding-window estimation and core inflation."*

### `A_appendix.tex` — Appendix A

#### §A.1 Additional Tables (p.72)
- [ ] **R-194** 🟡 Rewrite: *"and the Italy crisis decomposition."* (in the §A.1
  intro list) → update if the Italy content is removed. **G-18 / Q-3.**

#### Table A.4 (p.74)
- [ ] **R-195** 🔴 Large ✗ over Table A.4 *"Italy across subsamples"* → delete the
  table. **G-18 / Q-3.**

#### Figures A.3 / A.4 (p.76)
- [ ] **R-196** 🔴 Note: *"The ggplot Tables do not have Latex style"* → restyle
  the ggplot figures to match. **G-15.**

#### Figure A.7 + §A.3 AI Disclaimer (p.78)
- [ ] **R-197** 🟡 Rewrite: Figure A.7 right-panel subtitle *"cor(CF, CF_oos) per
  country / Closer to 1 means full-sample look-ahead added little to the local
  factor"* → reword.
- [ ] **R-198** 🔴 Large ✗ over §A.3 *AI Disclaimer* → rework/reconsider.
  **Intent ambiguous** (delete vs revise; a disclaimer is usually required) → **Q-4.**

### `06_replication.tex` — Appendix B, Replication and Validation

#### Appendix B intro + §B.1 (p.79)
- [ ] **R-199** 🔴 Note (top): *"The text here is kind of too long. I think it
  would be sufficient to summarise and point to the tables"* → condense Appendix B
  prose to a summary + table pointers. **G-16.**

#### Table B.1 + text (p.80)
- [ ] **R-200** 🟡 Rewrite: *", if anything, slightly stronger"*.

#### Figure B.1 + text (p.81)
- [ ] **R-201** 🟡 Rewrite: *"the Bayesian information criterion, expressed as a
  relative posterior probability"*; *"places essentially all the weight on the
  yields-plus-trend specification."*
- [ ] **R-202** 🟡 Rewrite: *"We note, consistent with the scope set out in Section
  3.12, that our Monte Carlo reproduces the shape and tail behaviour of the null
  but is not calibrated to match the exact percentiles that Cieslak and Povala
  (2015) report."*; *"which we document rather than close."*

#### Figure B.2 + §B.2 Dahlquist–Hasseltoft (p.82)
- [ ] **R-203** 🟡 Rewrite: *"which is the signature of a single return-forecasting
  factor that prices the whole term structure rather than one segment."*;
  *"(Politis and Romano, 1994)"*.
- [ ] **R-204** 🔴 Note (arrow, end §B.1): *"did we actually double check this?"* →
  verify the replication claim (*"we thus reproduce the United States evidence in
  full…"*).

#### Table B.2 + §B.2 text (p.83)
- [ ] **R-205** 🩷 Understanding: *"Fama–Bliss regression"*.
- [ ] **R-206** 🟢 Fact-check: *"up to 69%) that they note as well."* (the Japan
  R²≈69% claim, and that DH note it).

#### Table B.3 + §B.2 tail (p.84)
- [ ] **R-207** 🟡 Rewrite: "very pattern"; "cycle"; "engine validated".

#### Table B.4 (p.85)
- [ ] **R-208** 🔴 Strikethrough: the *"Bootstrap t [5%, 95%]"* row in Table B.4 →
  delete the row. *(table from `R/empirical.R`)*

---

## Open questions for the author (resolve before/at Phase 2)

- ✅ **Q-1 (R-054+R-055) — RESOLVED:** delete the passage *"A final strand of the
  literature → … → a simulated no-predictability benchmark."*
- ❓ **Q-2 (R-144, R-160 / G-14):** should **Chapter 6 (Robustness)** remain a
  dedicated chapter, or be moved/merged given that Ch. 4 already carries the OOS
  analysis? Big structural call — needs your decision before Phase 2.
- ❓ **Q-3 (G-18):** confirm the scope of the **Italy cut** — the ✗ marks on
  §6.2.1, R-161, R-187, and Table A.4 (R-195) read as *delete*; R-194 (appendix
  list) then needs updating too. Remove the dedicated Italy treatment everywhere?
- ❓ **Q-4 (R-198):** the big ✗ over **§A.3 AI Disclaimer** — delete it entirely,
  or just rework/update it? (A disclaimer is usually required by the program, so I
  read this as "revise" unless you say otherwise.)

---

## Review sessions

| Date | Source PDF(s) | Chapters covered | Remarks added |
|------|---------------|------------------|---------------|
| 2026-07-08 | `master_thesis_first_proof_read.pdf` *(pre-restructure — proof-read before the 2026-07-07 structure changes; see staleness caveat at top)* | Front matter, Ch. 1 (Intro), Ch. 2 (Lit. + Framework), Ch. 3 (Data) | R-001 – R-083, G-1 – G-11 |
| 2026-07-08 | `master_thesis_6_2.pdf` *(post-restructure — maps to current files)* | Ch. 4 (Empirical Findings → `07_results.tex`), Ch. 5 (Portfolio Construction → `08b_strategy.tex`) | R-084 – R-140, G-12 – G-13 |
| 2026-07-10 | `master_thesis_6_3.pdf` | Title page (`00_titlepage.tex`), Acknowledgements (reaffirms R-005) | R-141 – R-142 |
| 2026-07-10 | `master_thesis_6_4.pdf` *(post-restructure — maps to current files)* | Ch. 6 (Robustness → `08_robustness.tex`), Ch. 7 (Discussion → `09_discussion.tex`), Ch. 8 (Conclusion → `10_conclusion.tex`), Appendix A (`A_appendix.tex`), Appendix B (Replication → `06_replication.tex`) | R-143 – R-208, G-14 – G-18, Q-2 – Q-4 |
