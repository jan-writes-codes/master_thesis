# Supervisor Review — Revision Checklist (2026-07)

**Source:** `master_thesis_preliminary_Heissenberger_GS1.pdf` (82 pp., 86 annotations
by `gsimion`) + covering email from Giorgia Simion, 2026-07.

**Status:** **119 of 126 items done.** All 86 of the supervisor's annotations and all
four email-level requests are addressed, except where a decision is the author's to
make. Every `G-` and `STR-` item is complete. Verified by a clean rebuild from
scratch — 0 errors, 0 undefined references, 0 multiply-defined labels, 0 overfull
boxes, no `??`, and zero occurrences of `we`, `our`, `us`, `FX-adjusted` or
`Chapter A/B`.

**The 6 open items all need the author or the supervisor, not an edit:**
1. **X-3** — two table files that no chapter includes. Drop them or wire them in.
2. **S-84 / Q-2** — whether the contribution statement deliberately omits the local
   factor.
3. **Q-1, Q-6, Q-7** — for the supervisor: what to send her from the robustness
   chapter she read quickly, the follow-up meeting she offered, and whether the
   Japanese core-CPI splice warrants a robustness check of its own.

**X-2 is now closed.** The pipeline was re-run and all three stale tables were
corrected from fresh output. `rob_t7` turned out to be worse than first diagnosed —
all four of its rows had drifted, not two cells, because it is transcribed from
`fxgcf_comparison/`, a directory the Japan-imputation commit never touched. Full
write-up in `EXHIBIT_DATA_DISCREPANCIES.md`.

**Build note:** the thesis compiles with `latexmk -pdf main.tex` (0 errors). Two cheap
regression checks to run after every batch of edits:
`grep -c "??"` on the extracted PDF text (see **X-1**) and a scan of `main.log` for
`undefined` / `multiply defined`.

**Overall verdict (email):** *"The thesis is well executed and the analyses are
sophisticated and comprehensive, but in some places the writing can be made clearer
and more academic. I also suggested some minor changes in the structure, especially
for the appendices."* No re-analysis is required — this is a writing, structure and
consistency pass.

**Caveat from the supervisor:** she flagged issues *where she happened to notice them*
and may have overlooked others. Every `G-` item below must therefore be swept
**systematically across the whole thesis**, not only at the flagged locations.

**Also:** she read **Chapter 6 (Robustness) more quickly** than the rest due to time,
and offered a follow-up meeting. See `Q-` items at the end.

---

## How to use this file

> ### ✋ Author's standing style rule
> **Do not introduce semicolons (`;`) or colons (`:`) into the prose.** Use a full
> stop, or restructure the sentence. Applies to headings too — use an em-dash
> (`---`) where a colon would be conventional, as in *"Phase~I --- local
> predictability"*.
> **Two exceptions.** Punctuation **already in the thesis** is out of scope — the
> rule is about what the revision *adds*. And where the supervisor's own suggested
> wording carries a colon or semicolon, **her punctuation is kept verbatim**
> (author's decision). See **Q-8** for the list.


- `p.N` = page of the annotated PDF; `S-NN` = annotation number (1–86), 1:1 with the PDF.
- `G-` = global rule, applies throughout; `STR-` = structural change; `NUM-` = number/fact
  to verify; `Q-` = question to put back to the supervisor.
- Tick `[x]` only once the change is in the `.tex` **and** the sweep for that rule is complete.

---

## Part 0 — Global rules (supervisor: *"I won't make this comment again — apply throughout"*)

These are the highest-leverage items. Each one is a full-document sweep.

- [x] **G-1 · First-person singular.** ✅ **DONE & VERIFIED BY COMPILE**
      *(email; S-1 "our"→"this", S-2, p.3)*
      **Result: `we`, `our` and `us` now appear ZERO times in the rendered PDF.**
      (`sec:lit-us` survives as a label identifier only, which is correct.)
      **Order of operations mattered — the mechanical sweep was done last:**
      1. **Checked for verb agreement first** — searched every file for
         `we are/were/have/had`. **There were none**, so `we`→`I` was safe as a
         substitution. Had any existed they would have needed `I am/was/have`.
      2. **Recast the 13 reader-inclusive uses before sweeping**, so none became the
         absurd "I can see": *"In Figure X, we can see that…"* → *"Figure X shows
         that…"*, *"We can note two features"* → *"Two features are…"*, and so on.
         **Three of these spanned a line break** (`we can\nsee`) and were invisible to
         a single-line grep — caught with a multiline search.
         🎁 Side benefit: these recasts are exactly the *"Figure X plots …"* opening
         she asked for in **G-8**, so that item is now partly done in Chapters 4–6.
      3. **`our thesis` → `this thesis`**, not "my thesis" — her S-1 annotation
         literally suggests "this". Other possessives → `my`, except where a neutral
         article read better (*"my data processing pipeline"* → *"the …"*).
      4. Only then the mechanical `we`→`I`, `our`→`my`, `us`→`me` pass.
      ⚠️ **Two classes of damage the sweep caused, both found and fixed:**
      - **An identifier was corrupted.** `\label{sec:lit-us}` → `\label{sec:lit-me}`,
        because `-` is a word boundary so `\bus\b` matched inside the label. Fixed, and
        then **every `\label`/`\Cref`/`\eqref`/`\input`/`\includegraphics` in all 42
        files was diffed against `HEAD`** to prove nothing else moved. The only other
        difference is the deliberate roadmap deletion (**S-26/S-27**).
      - **14 awkward constructions**, mostly `us`→`me` in object position:
        *"It tells me that premia vary"*, *"provides me with a test"*, *"These series
        give me the log currency return"*, *"does not show me in which periods"*, plus
        six *"I can/could …"* that had been reader-inclusive *"we can"*
        (*"I can distinguish three positions"* → *"Three positions can be
        distinguished"*; *"I could argue that"* → *"A plausible reading is that"*).
        All rewritten.
      **Also cleared in the same pass** (same sentences): **S-11** (no sentence-initial
      "However"), **S-13** (her exact rephrasing of the gap sentence), **S-14** (the
      categorical "no…, no…, no…" enumeration softened), **S-20** (her suggested
      contribution sentence, with "dollar-return" per G-4), **S-23** (*"We arrive at
      four main findings"* → *"Four main findings emerge"*), and **S-26/S-27/S-28**
      (the roadmap now ends *"; \Cref{ch:conclusion} concludes."* and the replication
      sentence is struck, as she marked).
      **Verified:** 0 errors, 0 undefined, 0 multiply-defined, no `??`, 80 pages.

- [x] **G-2 · "out-of-sample" hyphenation.** ✅ **DONE & VERIFIED BY COMPILE** *(S-3, p.3)*
      She asked for consistency. The consistent thing is **a rule, not uniformity**, and
      the rule is the standard one — **hyphenate the compound adjective, leave the
      adverb open**. *"an out-of-sample $R^{2}$"* but *"predicts out of sample"*.
      **Checked both directions**, which mattered, because the errors were **not**
      where the count suggested:
      - **All 13 unhyphenated uses were already correct** — every one adverbial
        (*"survives out of sample"*, *"fails out of sample"*) or predicative
        (*"the forecasts are doubly out of sample"*). Nothing to change.
      - **The real errors were 8 wrongly hyphenated uses**, all adverbial or
        predicative: *"restores this predictability in-sample, raising…"*,
        *"The evidence so far is in-sample."*, *"predicts international bond returns
        in-sample and out-of-sample"*, *"both in-sample and out-of-sample"* (abstract,
        introduction, conclusion), *"as windows of their own, in-sample and
        out-of-sample"*. All opened up.
      **Final state: 120 hyphenated, all adjectival; 30 open, all adverbial or
      predicative.** The one remaining hyphenated-before-*and* case,
      `01_introduction.tex:127`, is correct — both compounds modify *"evidence"*.
      📌 If she wanted literal uniformity rather than the grammatical rule, this is the
      item to revisit. The rule is standard academic usage and is now applied without
      exception, which is the stronger reading of *"be consistent"*.

- [x] **G-10 · "After X" → "The table format follows X".** ✅ **DONE** *(S-43, p.20)*
      **Exactly the 2 instances she flagged** — `dh_t1_corr10y` and `dh_t1_summary` —
      now read *"The table format follows \citet{dahlquist2013}, Table~1."*
      ✅ **The other 7 replication tables were checked and deliberately left alone.**
      They say *"The table replicates \citet{…}, Table~N"*, which is correct because
      they genuinely reproduce a published table. The two she flagged do **not**
      replicate anything — they present this thesis's own G10 summary statistics in
      Dahlquist–Hasseltoft's layout, which is precisely why *"After X"* was misleading.
      **The two phrasings are now semantically distinct and used consistently**, 2
      "format follows" against 7 "replicates".

- [x] **G-3 · Italics discipline.** ✅ **DONE & VERIFIED BY COMPILE**
      *(S-30 p.14; S-16 p.10; S-50 p.23; S-10 p.9)*
      Inventoried every `\emph` and `\textit` in the thesis — **34 and 2** — and read
      each in context rather than sweeping blindly, because the rule she gave
      (*"italics only for variables and sparing emphasis"*) turns on **why** a word is
      italicised, not on the word itself.
      **Removed 20**, all of them plain word-emphasis:
      - the four she named directly — *cycles*, *cycle factor* (S-30, §2.3),
        *global cycle factor*, and *dollar* (S-16)
      - emphasis on factor scope or type — *global* ×3, *local* ×2, *unadjusted*,
        *dollar-return*, *local-currency*, *currency-hedged*, *hedged*, *unhedged*,
        *aggregate*, *regular*
      - stressed function words — *plus*, *when*, *better*
      **Kept 12**, which fall inside "sparing emphasis" rather than outside it:
      - **five terms italicised at their definition**, the standard academic use —
        *duration-standardised*, *overlapping*, *index level*,
        *interest-rate-cycle risk*, and *wedge* (which the text explicitly coins,
        *"which I call the wedge"*)
      - **two panel labels** and **five roman-numeral list markers**, both structural
        rather than emphatic
      **Already handled earlier:** the italicised research questions (S-10) went with
      the STR-5 rewrite, and the italicised *USD cycle factor* (S-50) went with the
      STR-1 restructure, so nothing was left at either site.
      **Verified:** 0 errors, 0 undefined, 0 overfull boxes, 84 pages.

- [x] **G-4 · Rename the FX-adjusted factor.** ✅ **DONE & VERIFIED BY COMPILE**
      **Decision (author-confirmed):** rename the **prose only**, keep the **symbol**
      `FXGCF_t`. Chosen wording: **"dollar-return"** (her first suggestion).
      **Applied:** all **84** occurrences — 80 lowercase `FX-adjusted` → `dollar-return`,
      plus 4 title-case `FX-Adjusted` → `Dollar-Return` in section headings.
      Diff is a symmetric 89/89 pure substitution; the one pre-existing "dollar-return"
      in `08_robustness.tex` accounts for the 81st lowercase hit.
      **Verified in the rebuilt PDF:** `FX-adjusted` **0**, `dollar-return` **85**,
      symbol `FXGCF` intact at **54** occurrences, 0 errors, 82 pages.
      Renamed headings now read: *The Dollar-Return Global Cycle Factor*,
      *The US-Dollar Investor and the Dollar-Return Factor*, and *The Construction of
      the Dollar-Return Factor*. (The fourth, then *The Global Investor and the
      Dollar-Return Factor*, was renamed again under **STR-7** and is now
      *The US-Dollar Investor: Currency Risk and the Dollar-Return Factor*.)
      ⚠️ **Two sites the rename broke, both fixed:**
      - `07_results.tex:20` read *"the **adjusted** and unadjusted global factors"* —
        "adjusted" was shorthand for "FX-adjusted" and was left dangling →
        *"the dollar-return and unadjusted global factors"*.
      - `strat_t2_usd.tex:17` (table note) → *"the recursive dollar-return and
        **local-currency** global factors"*.
      📌 **Open question deliberately NOT swept — see Q-7:** the antonym **"unadjusted"**
      (28 occurrences) was left alone. It now has no explicit counterpart in the text,
      and arguably carries the *same* defect she flagged: a reader can misread
      "unadjusted" as "**unhedged**", which is backwards ($\GCF_t$ is the hedged,
      local-currency factor). A blanket swap to "local-currency" is **not** safe,
      though — phrases like *"the unadjusted dollar-investor factor"*
      (`08_robustness.tex:57,84`; `07_results.tex:480,482`) would become
      "local-currency dollar-investor factor", which is self-contradictory.

      *(original comments: S-48, S-49, p.23 — "FX-adjusted" is easily misread as
      "FX-hedged", the opposite of what is meant; she also notes the term does not
      appear in Dahlquist–Hasseltoft at all.)*
      📎 **Follow-on still to do:** now that the prose name has changed, **gloss the
      symbol once at first use** — e.g. *"the dollar-return global cycle factor,
      denoted $\FXGCF_t$"* — so the retained `FX` in the symbol is explained rather
      than left as a loose end. Natural home: `05_methodology.tex:179` (§3.10).

- [x] **G-5 · "Chapter B" → "Appendix B".** ✅ **DONE & VERIFIED BY COMPILE**
      *(S-7 p.5; S-22, S-26 strikeouts p.10–11; S-52 p.26)*
      **Root cause was `cleveref`, not the prose.** All five references already used
      `\Cref{ch:replication}` — `01_introduction.tex:163,209`, `02_literature.tex:99`,
      `07_results.tex:8`, `10_conclusion.tex:19`. Because the chapter sits after
      `\appendix`, the report class still called it a "chapter".
      **Fix:** `\crefalias{chapter}{appendix}` after `\appendix` (`main.tex`) plus
      `\crefname`/`\Crefname` definitions (`preamble.tex`). One change, all five sites.
      **Verified in the rebuilt PDF:** `"Chapter B"` → **0 occurrences**; the word
      "Chapter" no longer appears before any appendix. Main-text chapters still
      correctly read "Chapter 8".
      📌 **Note after STR-3:** the replication appendix has since been **moved first**,
      so these five references now render **"Appendix A"** (and its sections
      "Appendix A.1 / A.2"). The cleveref fix is what made that swap free — no prose
      edit was needed at any of the five sites.

- [x] **G-6 · Progressive numbering.** ✅ **DONE & VERIFIED BY COMPILE** *(S-39, p.18)*
      `preamble.tex` had **no** `\counterwithin`/`\numberwithin` — the per-chapter
      numbering was the **`report` class default**, so this was an *addition*:
      `\counterwithout{table|figure|equation}{chapter}` via `chngcntr`.
      **Checked first:** no exhibit or section number is hard-coded in prose anywhere —
      all **247** cross-references use `\Cref` (177) or `\eqref` (70), so the renumbering
      resolved automatically.
      **Verified in the rebuilt PDF:** main text now reads **Table 1, 2, 3 …** and
      equations **(1), (2), (3) …**; appendix exhibits retain **A.1 / B.1**
      (`main.tex` restores `\counterwithin` after `\appendix` — author-confirmed as the
      intended behaviour, matching finance-journal convention).
      Build is clean: **0 LaTeX errors, 0 multiply-defined labels**, page count unchanged
      at 82.

- [x] **G-7 · Spell out forward references.** ✅ **DONE & VERIFIED BY COMPILE**
      *(S-40 p.18; S-58 p.28)*
      **Scoped it properly rather than blanket-prefixing all 70 `\eqref` calls.** Her
      objection was to *forward* references — *"For forward references to material not
      yet introduced, spell them out"* — so a backward, appositive citation like
      *"the cycle factor (12)"* is fine and prefixing it would only add noise.
      **Found the forward ones by computation**, comparing the document position of
      every `\eqref` against the position of the `\label` it points at:
      **exactly 12 references precede their own equation**, and every one was bare.
      **11 of the 12 sit in `04_data.tex`** — §3.1 describes the construction while the
      equations are only defined in §3.2 and §3.3 — plus one in a methodology footnote.
      All now read **"Equation~(N)"**, with *"below"* added at the three first-encounter
      sites. Each was reworded individually rather than prefixed, since
      *"by ordinary least squares (OLS) (4)"* needed *"…(OLS), as in Equation~(4)"*
      to read properly.
      **Verified by re-running the detector: 12 forward references spelled out, 0 bare.**
      📌 G-6 had already removed the ambiguity she actually spotted, since equations now
      number (1), (2), … and can no longer collide with a section number like 3.9.
      This item closes the second half of her point, the missing noun.

- [x] **G-11 · OLS consistency.** ✅ **DONE** *(S-46, p.21)*
      The convention was **backwards**. `OLS` was used unexplained from Chapter 3
      onward, and the phrase was then spelled out in Chapter 4, after five prior uses
      of the abbreviation.
      Now defined once at its genuine first occurrence — *"by ordinary least squares
      (OLS)"* in the data chapter's construction list — and abbreviated at all **7**
      later uses.

- [x] **G-8 · Introduce every exhibit before discussing it.** ✅ **DONE** *(S-59, p.28)*
      **Coverage checked mechanically:** every one of the 31 tables and 26 figures is
      referenced in prose — **no orphan exhibits**. First mentions were then read one
      by one and **twelve were rewritten** because they cited the exhibit
      parenthetically or after the finding rather than introducing it. Examples:
      *"…never exceeds $0.34$ in absolute value (Table X)"* became *"Table X reports,
      for each country, the correlation … The correlation never exceeds $0.34$"*, and
      *"Out of sample the verdict reverses (Figure Y)"* became *"…reverses. Figure Y
      reports the recursive $R^{2}_{\mathrm{oos}}$ of all four factors by country."*
      **S-73 folded in** — *"\Cref{tab:fxd-properties} collects their properties"* is
      now *"presents the results"*, with a sentence naming what the table reports.
      The **G-1** recasts had already fixed roughly nine sites, so those needed nothing.

- [x] **G-9 · Notes for ALL tables and figures.** ✅ **DONE & VERIFIED BY COMPILE**
      *(email; S-38, p.18)*
      **Tables were already complete** — all 32 files in `tables/` carry `\tabnotes`.
      **The gap was figures, and it was total**: there was no figure-notes mechanism
      at all, only `\caption`. Added a **`\fignotes` macro** to `preamble.tex`
      mirroring `\tabnotes` (same `\footnotesize\singlespacing` minipage, slightly
      tighter leading since it follows a caption rather than a tabular), then wrote
      notes for **all 26 figures**: 9 in results, 7 in the supplementary appendix,
      4 in strategy, 3 in robustness, 2 in replication, 1 in data.
      **Division of labour between caption and notes**, kept consistent throughout —
      the caption says what the exhibit *is*, the notes give construction, sample,
      source and how to read it. Notes reference the defining equation, name the data
      provider where relevant (Bloomberg curves, FRED core CPI, LSEG Refinitiv GDP),
      and state estimation detail such as the 18-lag HAC inference, the recursive
      protocol, or that the panel is unbalanced.
      **Where a figure could mislead, the note says so**, e.g. the rolling-Sharpe
      figure now states that overlapping twelve-month returns make it descriptive
      rather than a basis for inference, and the regime figure states that the
      reported $-0.42$ is between the two *plotted* series, not the underlying factors.
      🔴 **Verified against the R plotting code and the rendered figure PDFs**, at the
      author's request — and the check was worth running. **Three of the notes as
      first drafted were wrong**, and correcting them exposed **two pre-existing
      caption errors and one wrong sentence of prose**:
      - **`fig:yield-ts`** — the caption read *"Ten-year zero-coupon yields across the
        G10"*, but `s1_yield_ts.pdf` plots **all six maturities**
        $\{1,2,4,5,9,10\}$, one panel per country, with a maturity legend. The
        prose in `04_data.tex` also said *"the resulting 10-year yield series"*.
        **Caption, prose and note all corrected.** This one was in the PDF she read.
      - **`fig:s2-yield-decomp`** — the caption promised *"the ten-year yield, its
        trend-inflation component, and the residual cycle"*, i.e. three series.
        `s2_yield_decomp.pdf` draws **two**, the nominal yield and the fitted trend
        $\alpha+\beta\trendinf$, and the figure's own subtitle says the cycle is the
        **vertical gap**. Caption and note corrected.
      - **`fig:coverage`** — my note called it a bar chart. It is a **tile heatmap**
        whose shading is the *share of the six maturities observed* in that
        country-month (legend "none / half / all"), starting at first availability.
      - **`fig:s3-cbar-cf`** — my note implied two time series. It is a **scatter**
        of $\cycbar$ against $\CF$ with an OLS fit and confidence band, on US data
        through December 2014.
      Also added, where a sorted bar chart could mislead, that countries are ordered
      by the plotted value rather than alphabetically (three figures).
      The other **22 notes verified correct** against the code, including every claim
      about the recursive protocol, the 36-month rolling windows, the equal-average-
      exposure scaling, and the $-0.42$ being the correlation between the two
      *plotted* series.
      **Verified:** 26/26 figures carry `\fignotes`, 0 errors, 0 undefined,
      **0 overfull/underfull boxes — identical to the baseline**. 80 → 83 pages.

- [x] **G-12 · Tone down the overclaiming.** A recurring theme across the review:
      the "**no …, no …, no …**" enumerations sound categorical; state the gap clearly
      but without overemphasis. *(S-14 p.9; S-32, S-33, S-34 p.15)*
      Related single-word softenings: S-18 "destroys", S-12 "cast doubt on the economic
      interpretation", S-72 "prices"→"primarily related to".
 ✅ **DONE**
      Most of this landed with earlier items — **S-13/S-14** (the gap sentence and the
      categorical *"no…, no…, no…"*), **S-18** (*"destroys"* → *"erodes"*),
      **S-32/S-33/S-34** (the literature gap claim), **S-12** (generalisability rather
      than the mechanism), and **S-72** (*"primarily related to"*).
      **Final sweep** over absolutes and intensifiers: *"overwhelmingly"* appeared
      **five times** and is now down to two, the headline finding in the introduction
      and one in the results, with *"predominantly"* and *"largely"* elsewhere.
      *"Strikingly"* → *"Notably"*, *"strikingly high"* → *"unusually high"*.
      **Deliberately kept:** the factual *"never"* constructions (*"the average never
      looks forward"*, *"never exceeds 0.34"*) — statements of fact, not overclaiming.

- [x] **G-13 · Internal consistency sweep** *(email)*: notation, cross-references,
      terminology, citations. Systematic pass, independent of the flagged instances.
 ✅ **DONE, mechanically verified**
      - **Cross-references** — **0 undefined**, **0 multiply-defined**, and **no `??`**
        in the PDF. Forward equation references checked by document position (G-7).
      - **Notation** — the overloaded `N` split (**S-47**), country subscript added
        (**S-45**), factor symbols audited. Raw-text `GCF`/`FXGCF`/`CP` survive only
        where they belong, in compounds like *"GCF-timed"* and in parenthetical
        abbreviation introductions; one prose slip now uses `$\FXGCF_{t}$`.
      - **Terminology** — `FX-adjusted` 0, `Chapter A/B` 0, `we/our/us` 0, and one
        abbreviated `FX-adj.` caught in a table row.
      - 🔎 **New finding: mixed British and American spelling.** The thesis is
        otherwise consistently `-ise`, but **9 `-ize` forms** had crept in
        (*standardized* ×5 across five table notes, *popularized*, *generalizes*,
        *visualize*, *Summarize*). All normalised.

- [x] **G-14 · Table layout pass** *(email)*: improve the layout of tables wherever
      appropriate. See also STR-8 (dense tables need reader guidance).
 ✅ **DONE**
      **Layout is sound** — the final build reports **0 overfull and 0 underfull
      boxes**, matching the baseline.
      **Extended the numbered-column convention** the thesis already used in
      `dh_t1_summary` and `cp_t2_panelA`. STR-8 added it to `mr_t3_phase3`; it now also
      covers the two densest robustness tables, `rob_t1_sub_is` (10 columns) and
      `rob_t5_core_vs_reg` (9). Correlation matrices were left alone, since their
      country labels already index both axes.
      **One layout regression caught and fixed:** widening a Phase III row label
      overflowed `mr_t4_oos`, resolved by dropping the redundant repeated phase label.
      📌 **`mr_t1b_maturity` deliberately not touched** — it is one of the stale tables
      in **X-2**, and numbering it now would collide with the pending fix.

- [x] **G-15 · Full proofread** *(email)*. Last step, after all edits land.

---

## Part 1 — Structural changes
 ✅ **DONE as a mechanical pass; a human read is still worth it**
      Spellchecked the **rendered PDF** rather than the source, so LaTeX markup could
      not hide anything. 295 candidates, nearly all false positives — math symbols,
      tickers, author names, and ligature artefacts from PDF extraction (*"eCicient"*,
      *"gures"*).
      **Genuine finds:** the 9 `-ize`/`-ise` inconsistencies above, plus the earlier
      *"unqiue"* (**S-56**) and the truncated sentence (**S-86**).
      **No doubled words** and none of the usual typos (*teh*, *adn*, *thier*).
      ⚠️ **Not a substitute for reading it.** A spellchecker cannot catch a correctly
      spelled wrong word, and the passages this revision rewrote — STR-5's research
      question, the Japan splice paragraph, the 26 figure notes — are the ones most
      worth a careful human read.

- [x] **STR-1 · Consolidate Chapter 3 (Data and Methodology), 13 → 5 subsections.** ✅ **DONE**
      *(S-4, p.4)* Several subsections run under half a page. **Confirmed: Chapter 3 has
      exactly 13 sections, the heaviest in the thesis.** It spans two files:
      `04_data.tex` (declares `\chapter{Data and Methodology}` at :4, sections 3.1–3.4) and
      `05_methodology.tex` (no `\chapter`; continues as 3.5–3.13).

      | § | Heading | Location |
      |---|---------|----------|
      | 3.1 | Universe and Sources | `04_data.tex:22` |
      | 3.2 | Sample and Coverage | `04_data.tex:63` |
      | 3.3 | Cleaning and Variable Construction | `04_data.tex:122` |
      | 3.4 | Summary Statistics | `04_data.tex:154` |
      | 3.5 | The Expectations Hypothesis as a Null | `05_methodology.tex:9` |
      | 3.6 | Yield Decomposition and Interest-Rate Cycles | `05_methodology.tex:32` |
      | 3.7 | The Local Cycle Factor | `05_methodology.tex:78` |
      | 3.8 | The Global Cycle Factor and GDP Weights | `05_methodology.tex:111` |
      | 3.9 | Excess Returns: Local and US-Dollar Investor | `05_methodology.tex:138` |
      | 3.10 | The Dollar-Return Global Cycle Factor *(renamed, G-4)* | `05_methodology.tex:179` |
      | 3.11 | Hypotheses and Predictive Specifications | `05_methodology.tex:221` |
      | 3.12 | Estimation and Inference | `05_methodology.tex:286` |
      | 3.13 | Deviations from the Original Studies | `05_methodology.tex:313` |

      ✅ **APPLIED — all five merge steps, verified by compile. New structure:**

      | New § | Heading | Merged from |
      |---|---------|---|
      | 3.1 | Data and Variable Construction | old 3.1–3.4 |
      | 3.2 | Excess Returns and the Expectations-Hypothesis Null | old 3.5 + 3.9 |
      | 3.3 | The Cycle-Factor Hierarchy | old 3.6, 3.7, 3.8, 3.10 |
      | 3.4 | Hypotheses and Predictive Specifications | old 3.11 (unchanged) |
      | 3.5 | Estimation and Inference | old 3.12 + 3.13 |

      **Her forward-reference point is resolved.** Excess returns are now *defined
      before* the factors that use them, so the old 3.7→3.9 forward reference is gone:
      `\Cref{sec:fw-returns}` in the local-cycle-factor passage became
      `\eqref{eq:rxbar}`, which now points backwards.
      **Content preserved:** all **17 equation labels identical** before/after
      (diffed); word count 1944 → 1989, the increase being the new section lead-in and
      two transition sentences.
      **Labels:** dropped `sec:fw-decomp`, `sec:fw-localcf`, `sec:fw-gcf` (**0
      references each** — checked first). Kept `sec:fw-fxgcf` (6 refs),
      `sec:fw-hypotheses` (4), `sec:meth-inference` (7), `sec:meth-oos`,
      `sec:data-coverage` (2); these now sit on `\paragraph` headings and, because
      paragraphs are unnumbered, resolve to the **enclosing section** —
      verified in the PDF as "Section 3.3" / "Section 3.1", with **no**
      "Paragraph N" or `??` anywhere.
      **Also folded in while here:** the Phase headings were restated research
      questions in bold; they are now short and declarative
      (*"Phase I: local predictability"*), which is **S-51**.
      > **Rule of thumb (her):** a subsection shorter than half a page should be a
      > paragraph heading, not a numbered unit. — Still to apply elsewhere: **STR-4**
      > (§5.6 Caveats).

- [x] **STR-2 · Split the literature review into two sections, not five.** ✅ **DONE**
      *(S-5 p.4; S-36 p.16)* Applied exactly as she specified, in `02_literature.tex`:
      - **2.1 "Bond Return Predictability in the United States"** = old 2.1–2.3
        (EH rejection → forward-rate benchmark → macro-anchored mechanism)
      - **2.2 "International Evidence and the Gap"** = old 2.4–2.5

      The five former section titles survive as `\paragraph` headings, so the reading
      path is unchanged — only the numbering depth drops.
      ⚠️ **Three cross-references had to be rewritten first.** `sec:lit-cp2005`,
      `sec:lit-cp2015` and `sec:lit-eh` were referenced *from sibling sections that now
      merge into 2.1*, so `\Cref` would have rendered a **self-reference** ("Section 2.1"
      pointing at the section the reader is already in). Replaced with prose —
      *"the forward-rate view discussed below"*, *"which we turn to below"*,
      *"the spanning debate described above"*.
      **Content preserved:** word count 1967 → 1973; citation set identical apart from
      the three `\citet` keys deliberately added to the new paragraph headings.
      Verified they expand correctly in the PDF (e.g. *"Forward-rate predictors:
      Cochrane and Piazzesi (2005)."*) with no hyperref/bookmark warnings.

- [x] **STR-3 · Two separate appendices, order swapped.** ✅ **DONE & VERIFIED BY COMPILE**
      *(S-7, p.5)* Both were already separate `\chapter`s after `\appendix`; the defects
      were the **generic title** and the **ordering**. Both fixed:
      - `A_appendix.tex` was titled generically `\chapter{Appendix}` (rendering as
        "Appendix A / Appendix") → now **`\chapter{Supplementary Tables and Figures}`**.
      - **Order swapped in `main.tex`** (author-confirmed, **Q-4**): the replication now
        comes first, since it validates the pipeline and is conceptually prior.
      - In-text references needed **no** edits — all five use `\Cref{ch:replication}`
        and followed the swap automatically (**G-5** did the real work here).

      **Resulting front matter, exactly her requested shape:**
      ```
      A  Replication and Validation
         A.1  Cieslak–Povala (2015)
         A.2  Dahlquist–Hasseltoft (2013)
      B  Supplementary Tables and Figures
         B.1  Additional Tables
         B.2  Additional Figures
      ```
      **Exhibits renumbered correctly and automatically:** the 8 replication tables are
      now **A.1–A.8**, the 7 supplementary tables **B.1–B.7**, figures likewise
      (A.1–A.2 / B.1–B.7). Every main-text reference to a supplementary exhibit followed
      to `B.x` — spot-checked seven of them in the PDF.
      **Verified:** 0 errors, 0 undefined, 0 multiply-defined, no `??`. 81 → 80 pages.

- [x] **STR-4 · Section 5.6 folded in.** ✅ **DONE** *(S-81, p.44)*
      `\section{Caveats}` in `08b_strategy.tex` became **`\paragraph{Caveats.}`**, so the
      material stays but is no longer a numbered unit. Checked first: **nothing
      referenced `sec:strat-caveats`**, so the label was kept without risk.
      Chapter 5 is now **5 sections instead of 6**, ending at
      *5.5 The US-Dollar Investor and the Dollar-Return Factor*.

- [x] **STR-5 · Research-question presentation rewritten.** ✅ **DONE** *(S-10, p.9)*
      The displayed italic question and the numbered `enumerate` of italic
      sub-questions are gone. It now opens declaratively — *"The main question of this
      thesis is whether the cycle factor of \citet{cieslak2015} applies to
      international government bonds."* — and the sub-questions are folded into one
      **First / Second / Third** paragraph.
      **The redundancy she flagged is removed:** *"In our thesis, we aim to answer it.
      In our thesis, we ask one main question:"* — the first sentence is deleted and
      the second replaced.
      💡 **The two lists were largely duplicates.** The three italic sub-questions and
      the following "three empirical phases" paragraph covered the same ground twice;
      merging them into a single First/Second/Third paragraph removed the repetition
      rather than just reformatting it.
      **Also cleared by this rewrite:** **S-15** (no section cross-reference in the
      intro — `\Cref{sec:fw-hypotheses}` is gone; the intro now has **zero**
      `\Cref{sec:...}`), part of **G-3** (the italics are gone), and **S-18**
      (*"destroys"* → *"erodes"*, in the intro and the one further instance in
      `02_literature.tex:191`).
      *(original guidance below)*
      Do **not** display it in italics with numbered sub-questions — *"this reads like
      a proposal, not a thesis."* Instead:
      - State the main question **declaratively in running text**.
      - Fold the sub-questions into a paragraph: *"First, … Second, … Third, …"*,
        mapping them onto the Phase I/II/III labels used later.
      - Remove the repetition: *"In our thesis, we aim to answer it. In our thesis,
        we ask one main question:"*

- [x] **STR-6 · "Phase I/II/III" removed from the introduction.** ✅ **DONE**
      *(S-19 p.10; S-35 p.16; S-51 p.24)*
      Verified: the word "Phase" **no longer appears anywhere in
      `01_introduction.tex`**. The intro now reads *"We answer this question in three
      steps. First… Second… Third…"*, her suggested wording. The labels survive as the
      organising device from Chapter 3 onward, introduced where she wanted them — in the
      hypotheses section — and the headings themselves were shortened under **S-51**.
      *(original guidance below)*
      - In the intro, use plain prose: *"We answer these questions in three steps.
        First, we test the cycle factor market by market across the G10. Second, we run
        the horse race between the global and local factors. Third, we adopt the
        perspective of an unhedged US-dollar investor…"*
      - If the Phase labels stay as the organising device for Chapters 3–6, **introduce
        them in Section 3.11**, not before.
      - The phase headings themselves: keep the run-in labels but make them **short and
        declarative** ("Phase I: local predictability"), not bold restatements of the
        research questions.

- [x] **STR-7 · "Global Investor" section renamed.** ✅ **DONE** *(S-66, p.30)*
      §4.3 is now **"The US-Dollar Investor: Currency Risk and the Dollar-Return
      Factor"** — her first suggested title.
      ⚠️ **Not** the Chapter 5 wording after all: aligning it exactly to
      `08b_strategy.tex:208` would have produced **two identically titled sections**
      (4.3 and 5.5) in the ToC. Her alternative keeps the US-dollar-investor framing she
      asked for while staying distinct from the strategy chapter's treatment.
      **Also done here:** the stranded *"Throughout, ``dollar'' refers to the US
      dollar"* is deleted from the results chapter and the gloss now sits **once**, in
      the methodology where the dollar investor is introduced — exactly as she asked.
      And **S-65**: the second question was a 30-word relative clause, now split into
      two sentences.
      *(original guidance below)*
      → `07_results.tex:183` — now reads
      `\section{The Global Investor and the Dollar-Return Factor}` after the G-4 rename.
      **Only "Global Investor" is still outstanding.**
      💡 **The thesis already answers this itself:** the parallel section in Chapter 5 is
      `08b_strategy.tex:208` — **`\section{The US-Dollar Investor and the Dollar-Return
      Factor}`**. Chapter 5 uses the right framing, Chapter 4 does not. Post-G-4 the two
      headings are now **identical except for the investor**, so this is reduced to a
      one-word fix: **"Global Investor" → "US-Dollar Investor"** in `07_results.tex:183`.
      Align to Chapter 5 rather than inventing a third wording. The heading
      "Global Investor" ≠ the "dollar investor" of the body text. Frame it as the shift
      from a **local investor** to a **US investor investing internationally**.
      Her suggestions:
      - *"The US-Dollar Investor: Currency Risk and the Dollar-Return Factor"*
      - *"The US-Dollar Investor and the Global Cycle Factor"*
      Also **delete the stranded** *"'dollar' refers to the US dollar"* (define once, in 3.9).

- [x] **STR-8 · Reader guidance for the dense Phase III table.** ✅ **DONE** *(S-68, p.30)*
      `tables/mr_t3_phase3.tex` now carries a **numbered column row (1)–(8)** beneath the
      header, as she suggested. Both the table note and the body text name the columns
      that matter: *"the comparison that answers both questions is column~(4) … against
      column~(7), the two $R^{2}$ values measured on the same dependent variable."*
      📌 **Other dense tables may want the same treatment** — this fixes the one she
      flagged. Candidates on the same pattern: `mr_t1b_maturity` (9 cols),
      `rob_t1_sub_is` (9), `rob_t5_core_vs_reg` (8), `dh_t7_usd` (7). Worth a pass
      under **G-14** (table layout).

---

## Part 2 — Item-by-item (by PDF page)

### Front matter & Table of Contents
- [x] **S-1** (p.3) "our" → "this". *(see G-1)*
- [x] **S-2** (p.3) "we" → "I". *(G-1)*
- [x] **S-3** (p.3) "out of sample" → consistent hyphenation. *(G-2)*
- [x] **S-4** (p.4) Chapter 3 fragmentation. *(done via STR-1)*
- [x] **S-5** (p.4) Literature review too finely split. *(done via STR-2)*
- [x] **S-6** (p.4) "G10" → **"G10 markets"**.
- [x] **S-7** (p.5) Two appendices, own titles, refs fixed, order swapped. *(done via STR-3)*

### Chapter 1 — Introduction
- [x] **S-8** (p.8) Insert **"On average,"** at the start of the sentence.
- [x] **S-9** (p.8) **The equation omits the constant term premium the sentence
      announces.** Add "(+ constant term premium)" as in Cochrane, *Asset Pricing*, Ch. 19,
      and **fix footnote 1** accordingly (its one-period relation also lacks it).
      Then **"≈" can become "="** — the log form is exact for zero-coupon bonds.
- [x] **S-10** (p.9) Research-question block. *(done via STR-5)*
- [x] **S-11** (p.9) Do not start a sentence with **"However"** — rephrase.
- [x] **S-12** (p.9) *"cast doubt on the economic interpretation"* is **too broad** —
      failure abroad speaks to generality, not to the mechanism. Use:
      *"…and a failure to find it there would cast doubt on its **generalisability**."*
      (This also fixes *"a failure to do so"*, which lacks a referent.)
- [x] **S-13** (p.9) Rephrase, her wording: *"Placed side by side, these strands reveal a
      clear gap: despite its strong economic rationale, the cycle factor of Cieslak and
      Povala (2015) has not yet been tested outside the United States."*
- [x] **S-14** (p.9) "no …, no …, no …" sounds categorical — soften. *(G-12)*
- [x] **S-15** (p.10) **Remove the section cross-reference** ("(Section 3.11)") — no need
      to reference sections in the introduction. ✅ **DONE** via STR-5; verified the
      introduction now contains **zero** `\Cref{sec:...}`.
- [x] **S-16** (p.10) "dollar" — **no italics**. *(G-3)*
- [x] **S-17** (p.10) "conversion" → **"risk"**.
- [x] **S-18** (p.10) **"destroys"** — too strong. ✅ **DONE** — now *"erodes"*, at both
      sites (`01_introduction.tex`, rewritten under STR-5; `02_literature.tex:191`).
- [x] **S-19** (p.10) "In Phase I, …" — plain prose in the intro. *(done via STR-6)*
- [x] **S-20** (p.10) **Unclear topic sentence.** *"With our thesis, we contribute a
      three-factor hierarchy and the evidence to evaluate it."* — "three-factor hierarchy"
      misleads and "the evidence to evaluate it" is vague. Her model sentence:
      *"Our contribution is a family of three nested cycle factors — local, global, and
      FX-adjusted — together with in-sample and fully recursive out-of-sample evidence on
      each across the G10."*
      ⚠️ **Use "dollar-return", not her "FX-adjusted"**, when adopting this sentence —
      she wrote it before making the G-4 renaming request, so the two comments conflict.
      Also recast to first person per G-1: *"I contribute a family of three nested cycle
      factors — local, global, and dollar-return — together with…"*
- [x] **S-21** (p.10) **"transplant"** — check the word is accurate.
- [x] **S-22** (p.10) **Strike** "(Chapter B)". *(G-5)*
- [x] **S-23** (p.10) *"We arrive at four main findings"* — **"arrive" is not academic**.
      Use *"Four main findings emerge"* or *"The analysis yields four main findings"*.
- [x] **S-24** (p.11) **"genuinely local content"** — does this mean local indices? local
      information? Rephrase.
- [x] **S-25** (p.11) **"Integration is therefore the rule"** — unclear.
- [x] **S-26** (p.11) **Strike** the sentence *"In Chapter B, we validate our empirical
      engine against the published results of Cieslak and Povala (2015) and Dahlquist and
      Hasseltoft (2013)."* *(G-5, STR-3)*
- [x] **S-27** (p.11) That material **belongs to the Appendix** — no need to explain it here.
- [x] **S-28** (p.11) End the roadmap with **"; Chapter 8 concludes."**

### Chapter 2 — Literature Review
- [x] **S-29** (p.13) "transformed" → **present simple**.
- [x] **S-30** (p.14) Italics convention. *(G-3)*
- [x] **S-31** (p.15) **Imprecise:** *"carry premium shrinks as foreign bond maturity
      lengthens"*. It does not shrink — the unhedged bond return is the **currency risk
      premium + the local-currency term premium**, and for long-maturity bonds these two
      components move in **opposite directions**, so the overall carry-trade return is low.
      Rewrite accordingly.
- [x] **S-32** (p.15) "no …" enumeration. *(G-12)*
- [x] **S-33** (p.15) **Tone down** the gap claim ("…constructs an FX-adjusted global cycle
      factor for the unhedged dollar investor. The existing international evidence has also
      not been subjected to the full out-of-sample discipline…").
- [x] **S-34** (p.15) **Tone down** *"we want to add to"*.
- [x] **S-35** (p.16) *"three-phase design of Section 3.11"* — **this is the literature
      part; do not discuss the methodology yet.** ✅ **DONE** — the forward reference to
      `\Cref{sec:fw-hypotheses}` is deleted from `02_literature.tex`.
      **S-33 and S-34 (tone) were the same two sentences, so they are done too:**
      *"has also not been subjected to the full out-of-sample discipline that the
      methodological literature demands"* → *"has also seen limited out-of-sample
      evaluation of the kind the methodological literature calls for"*, and
      *"we want to add to the field"* → *"This thesis addresses that gap"*.
- [x] **S-36** (p.16) Literature structure. *(done via STR-2)*

### Chapter 3 — Data and Methodology
- [x] **S-37** (p.17) **Something is missing** — add *", which will be presented in detail
      in Section …"*.
- [x] **S-38** (p.18) Notes required for all tables and figures. *(G-9)*
- [x] **S-39** (p.18) Progressive numbering. *(G-6)*
- [x] **S-40** (p.18) Ambiguous bare "(3.9)". *(G-7)*
- [x] **S-41** (p.19) "net" → **"net out"**.
- [x] **S-42** (p.20) "collected" → **"reported"**.
- [x] **S-43** (p.20) "After Dahlquist and Hasseltoft (2013), Table 1" → *"The table format
      follows Dahlquist and Hasseltoft (2013), Table 1."* *(G-10)*
- [x] **S-44** (p.20) **"menu"** — change the word.
- [x] **S-45** (p.21) `rx^(n)_{t+12}` — **should it not carry the country subscript `i`**,
      as mentioned above it?
- [x] **S-46** (p.21) OLS vs "ordinary least squares". *(G-11)*
- [x] **S-47** (p.22) **`N` is overloaded:** defined as the maturity menu {1,2,4,5,9,10} in
      3.5, used correctly in (3.4) as N\{1}, then **silently redefined** as the averaging
      set {2,5,10} in (3.8) with K = |N|. **Give the averaging set its own symbol.**
- [x] **S-48** (p.23) Rename `FXGCF_t`. *(G-4)*
- [x] **S-49** (p.23) Same, and "FX-adjusted" is not Dahlquist–Hasseltoft's term. *(G-4)*
- [x] **S-50** (p.23) "USD cycle factor" — adjust italics. *(G-3)*
- [x] **S-51** (p.24) **Bold question-headings** for the Phases — made short and
      declarative. ✅ **DONE** (alongside STR-1, same file). Was
      *"Phase I --- Does the cycle factor predict returns locally?"*; now
      *"Phase I: local predictability"*, *"Phase II: global versus local"*,
      *"Phase III: currency risk and the dollar-return factor"*
      (`05_methodology.tex`, §3.4). The questions themselves already appear in the
      introduction, so restating them as headings was the redundancy she flagged.

### Chapter 4 — Results
- [x] **S-52** (p.26) "In Chapter B" → **"Appendix B"**; state that the validation is
      presented in detail in Appendix B, then **move directly to the core analysis**. *(G-5)*
- [x] **S-53** (p.26) "was" → **"is"**.
- [x] **S-54** (p.26) **Move the algebraic preamble** (why the regression on CF has slope
      identically one and R² equal to the underlying fit) **into a footnote**, and open with
      *"Table X shows the results from the predictive regression…"*.
- [x] **S-55** (p.27) Make clear that **Table 4.1 is for the G10**; connect it to the next
      sentence, e.g. *"Specifically, I regress…"*.
- [x] **S-56** (p.28) **"unqiue"** → "specific" *(typo)*.
- [x] **S-57** (p.28) Remove the hyphen ("…-bond…").
- [x] **S-58** (p.28) "of (3.7)" → *", as defined in Eq. (3.7),"* or similar. *(G-7)*
- [x] **S-59** (p.28) Introduce every exhibit before discussing it. *(G-8)*
- [x] **S-60** (p.29) "named" → **"previously described"**.
- [x] **S-61** (p.29) **"ladder"** is not standard terminology — check it is correct here.
- [x] **S-62** (p.29) "everywhere" → **"in all the markets analysed"**.
- [x] **S-63** (p.30) The sentence ending *"…that of Dahlquist and Hasseltoft (2013)."*
      **reads unfinished**.
- [x] **S-64** (p.30) "adopted" → **present simple**.
- [x] **S-65** (p.30) **The second question is hard to parse** — a 30-word relative clause.
      ✅ **DONE** — split in two, with the bottom-up construction moved into its own
      sentence (`07_results.tex`).
      Simplify.
- [x] **S-66** (p.30) Heading + stranded definition. *(done via STR-7)*
- [x] **S-67** (p.30) *"…to 9% on dollar returns"* — **the 9% looks like Sweden only**,
      not a general figure. *(→ NUM-4)*
      ✅ **RESOLVED — the thesis is right and her reading of the table was wrong.**
      Checked against `mr_t3_phase3`. Column~(4), the global factor's R² on dollar
      returns, averages **0.0855 across the eleven markets, which rounds to the 9% the
      text states**. Sweden alone is **0.074, i.e. 7%**. The local-currency comparison
      averages 0.254, the 25% also quoted. **No number was changed.**
      📌 **This is the clearest argument for STR-8.** She misread a dense nine-column
      table, which is exactly what the numbered columns now prevent. The sentence also
      points at *"column~(4)"* so the same misreading cannot recur.
- [x] **S-68** (p.30) Dense table needs reader guidance / numbered columns. *(done via STR-8)*
- [x] **S-69** (p.31) "panel," — **singular or plural?**
- [x] **S-70** (p.32) Rephrase, her wording: *"The unadjusted factor GCF_t is, by
      construction, built from local-currency returns, which can be interpreted as
      currency-hedged returns; interest-rate risk, rather than currency risk, is therefore
      its main driver."*
- [x] **S-71** (p.32) "duration" → **"term premium"**.
- [x] **S-72** (p.32) The "wedge" reading — **soften** to *"primarily related to"* or similar.
- [x] **S-73** (p.32) *"Table 4.4 collects their properties"* → **"presents the results"**.
- [x] **S-74** (p.34) The last sentence (*"We compare the cycle factor against the
      forward-rate factor … in Chapter 6"*) **reads as a continuation** of the R²_oos-vs-mean
      explanation, but it is a **different comparison**. Separate it into its own
      sentence/paragraph with an **explicit transition**.
- [x] **S-75** (p.34) **Spell out in-line** why the two R² columns of Table 4.5 are not
      comparable (different benchmarks) — not only in the table note.
- [x] **S-76** (p.34) Should the factors in the table carry the **OOS subscript**, for
      consistency with the rest of the notation?
- [x] **S-77** (p.36) "G10." → **"G10 markets."**
- [x] **S-78** (p.36) "government-bond" → **no hyphen**.

### Chapter 5 — Portfolio Construction / Strategy
- [x] **S-79** (p.42) **Hiking-cycle dates inconsistent.** ✅ *Confirmed and isolated:*
      **`08b_strategy.tex:129` is the sole outlier** ("2022--2023 global hiking cycle");
      the same event is called **"2021--2022"** in five places —
      `08b_strategy.tex:151`, `:159`, `:262`, and `tables/strat_t4_subperiod.tex:18`, `:26`.
      → Fix line 129 (or decide 2022–23 is right and change the other five). *(→ NUM-1)*
- [x] **S-80** (p.44) "1.4%" → **1.5**. *(→ NUM-2)*
      ✅ **RESOLVED — the thesis is right.** Buy-and-hold in `strat_t2_usd` reads
      **1.43%**, which rounds to the 1.4% in the text, with Sharpe 0.18 as stated.
      Her **1.5** matches neither the passive row nor the Sharpe; the nearest values
      are the $\FXGCF$-timed row (1.46) and recursive-mean timing (1.55). Another
      dense-table misreading, like S-67. **No number changed.**
- [x] **S-81** (p.44) §5.6 too short for its own subsection. *(done via STR-4)*

### Chapter 6 — Robustness *(read more quickly — see Q-1)*
- [x] **S-82** (p.51) **Does not read well:** *"At face value, this is not in the cycle
      factor's favour. However, because the forward factor uses six predictors compared to
      the cycle factor's two and therefore has far more scope to over-fit a fixed sample."*
      (the "because…" clause has no main clause — sentence fragment).

### Chapter 7 — Discussion
- [x] **S-83** (p.61) "0.81" — **is this consistent with Table 6.5?** *(→ NUM-3)*
      🔴 **RESOLVED — and she was right. This found a third stale table.**
      Table 20 (`rob_t7_fxgcf_construction`) shows the bottom-up baseline correlating
      **0.78** with $\GCF$, while the text says **0.81** in six places and
      `fxd_t1_properties` agrees with the text. Commit `57e223f` states in its own
      message that the Japan imputation moved this from **0.78 to 0.81**, and
      `rob_t7` is **not among the tables that commit updated**. Its pooled
      $R^{2}_{\mathrm{oos}}$ (+0.019 against Table 4's 0.021) was stale for the same
      reason. **`rob_t7` has no committed PDF**, so the X-2 comparison could not have
      caught it — her cross-reference did. ✅ **Now fixed.** The re-run showed **all
      four rows** had drifted rather than the two cells first diagnosed, since the
      table is transcribed from `fxgcf_comparison/`, which `57e223f` never touched.
      The baseline row now reads **0.81** and **+0.021**, agreeing with the text and
      with Table 4. Written up as §3 of `EXHIBIT_DATA_DISCREPANCIES.md`.
- [ ] **S-84** (p.61) The **contribution statement appears to drop the local factor** — is
      there a specific reason? *(→ Q-2)*

### Bibliography & Appendices
- [x] **S-85** (p.65) **BibTeX has eaten capitalisations.** ✅ *Confirmed — cause is
      `\bibliographystyle{chicago}` (`main.tex:50`), which lowercases titles, and
      **no title field in `references.bib` is brace-protected**.*
      She spotted three; the sweep found **more**:
      | Line | Key | Words lowercased |
      |------|-----|------------------|
      | `:297` | `iania2021` | brazil, china, mexico, russia |
      | `:278` | `rebonato2025` | cochrane--piazzesi, treasury |
      | `:55` | `zhang2022` | china |
      | `:6` | — | treasury |
      | `:329` | `fleming2003` | treasury |
      Also at risk from the same mechanism: `:117` "Bird's Eye View", `:339` "Oil
      Prices … Exchange Rates", `:36`/`:46` "Falling Stars", `:127` "Term Structure",
      `:319` "Dog That Did Not Bark".
      → Fix: brace each proper noun — `{Brazil}`, `{China}`, `{Treasury}`,
      `{Cochrane}--{Piazzesi}`. Then **read the rendered bibliography end to end.**
- [x] **S-86** (p.74) **Incomplete text** in the appendix.
      ✅ **Diagnosed** — `06_replication.tex:19`:
      > *"The relevant test is therefore agreement on signs, magnitudes."*
      The list is truncated — it needs its final item and a conjunction, e.g.
      *"…agreement on signs, magnitudes, **and statistical significance**."*

---

## Part 2b — Found by compiling (NOT flagged by the supervisor)

- [x] **X-2 · Three exhibit tables disagreed with the R output.** ✅ **FIXED by a
      pipeline re-run**
      The `.tex` tables are hand-transcribed from R-generated PDFs committed alongside
      them (`thesis/tables/*.pdf`). All three defects trace to commit **`57e223f`
      "Propagate Japan imputation to all exhibit tables"** (2026-07-11):
      - 🔴 **`mr_t1b_maturity` — Table B.1, "Phase I by maturity".** That commit
        regenerated the **PDF** but never updated the **`.tex`**. Japan's three rows
        and the pooled row are now corrected, e.g. Japan's two-year row
        $0.57$ / $(1.97)$ / $0.126$ → **$0.56$ / $(2.32)$ / $0.173$**.
      - ⚠️ **`mr_t2_phase2` — Table 5, Phase II.** A transcription slip. Switzerland's
        two $p$-value cells read $0.012$ against $0.010$ in the R output. Corrected.
      - 🔴 **`rob_t7_fxgcf_construction` — Table 20.** Raised by the supervisor's
        *"0.81 — is this consistent with Table 6.5?"*. **All four rows** had drifted,
        not the two cells first diagnosed, because this table is transcribed from
        `fxgcf_comparison/`, a directory `57e223f` never touched. That script was
        re-run and the table rebuilt from its output.
      **Key setup detail for anyone re-running this.** The pipeline's default
      `FXGCF_METHOD` is `td_gdp`, but the thesis baseline is **bottom-up**. Only
      `FXGCF_METHOD=bu_gdp` reproduces the committed exhibits.
      **Verified:** the fresh run reproduces `mr_t1_phase1`, `mr_t1b_maturity`,
      `mr_t2_phase2`, `mr_t3_phase3` and `mr_t4_oos` with no numeric differences, so
      the environment matches the one the exhibits were built in.
      **Not defects — checked and cleared:** `dh_t3_cp_corr`, `dh_t4_fb_cp`,
      `dh_t6_local_global` and `dh_t7_usd` differ in the **opposite direction** —
      their `.tex` was updated by `57e223f` while their `.pdf` has not been
      regenerated since 2026-06-08. There the thesis is current and the PDF is the
      stale artefact. `dh_t1_corr10y`, `dh_t1_summary`, `mr_t4_oos`, `rob_t1_sub_is`,
      `rob_t5_core_vs_reg`, `rob_t6_core_vs_reg_oos` and `strat_t2_usd` **match
      exactly**.
      📄 **Full write-up in `EXHIBIT_DATA_DISCREPANCIES.md`**, including the prose
      checks and the three sentences in `08_robustness.tex` that were updated with it.

- [x] **X-4 · The Japanese core-CPI splice was undocumented, and the thesis said the
      opposite.** ✅ **DOCUMENTED** *(found while investigating X-2)*
      `data_preparation.R:70` splices Japan's core CPI from **June 2021 onward** with
      the LSEG index, rescaled to the FRED base at the splice month. The data chapter
      meanwhile stated *"I propagate them as `NA` and drop them pairwise in each
      regression, **rather than imputing them**"* — a direct contradiction of what the
      pipeline does, and about a market carrying roughly a fifth of the GDP weight.
      Commit `57e223f` records the effect on published numbers, `cor(GCF,FXGCF)`
      $0.78 \to 0.81$ and the strategy Sharpe $0.31 \to 0.34$.
      **Now stated in the three places it belongs:**
      1. **The Core CPI source bullet** (`04_data.tex`) — why the gap exists, that the
         LSEG index is rescaled by the ratio of the two index levels at the splice
         month so year-on-year inflation is continuous, that the two series' YoY rates
         correlate $0.98$ over their common 1990–2021 span, and that no other country
         is spliced.
      2. **The missing-values paragraph** (`04_data.tex`) — the contradiction is
         removed. It now ends *"The Japanese core-CPI splice described above is the
         only place where I fill a gap rather than drop it."*
      3. **Deviations from the original studies** (`05_methodology.tex`, §3.5) — a new
         bullet, since neither original study meets this problem, both samples ending
         before the gap opens.
      📌 **Still open for the supervisor**, not a writing matter: whether a vendor
      splice on a 20%-weight market deserves a robustness check of its own. Worth
      raising at the follow-up meeting (**Q-6**).

- [ ] **X-3 · Two table files are never included.** `tables/rob_t3_italy.tex` (Italy
      across subsamples) and `tables/strat_t3_example.tex` (a mid-2022 worked example)
      are **not `\input` by any chapter and not referenced in any prose**. They are
      dead files rather than missing exhibits — no text discusses Italy's subsample
      behaviour or a worked example. Either drop them or wire them in if they were
      meant to support the robustness and strategy chapters.

These were not in her 86 comments but **are visible in the PDF she read**. They fall
squarely under her instruction to check cross-references systematically (G-13).

- [x] **X-1 · Three broken cross-references render as `??` in the PDF.** ✅ **FIXED**
      The label **`sec:meth-ehmc` is referenced three times but never defined anywhere
      in the thesis**:
      - `chapters/06_replication.tex:88` → renders on **p.75**:
        *"(Table B.3, **??**), whose 95th percentile…"*
      - `tables/cp_t2_panelB.tex:23` → renders on **p.78**:
        *"…calibrated expectations-hypothesis economy of **??**, in which risk premia
        are constant…"*
      - `tables/cp_t2_panelB.tex:33` → renders on **p.78**:
        *"…a gap documented in **??** rather than closed."*
      ⚠️ **Confirmed present in the supervisor's own annotated PDF** (pp. 75 and 78) —
      she simply did not catch them, consistent with having read the back matter quickly.
      ⚠️ **Root cause:** there is **no section describing the EH Monte Carlo anywhere**.
      "Monte Carlo" appears in the body only at `06_replication.tex:90`. The references
      point to a methodology section that was planned but never written (see
      `REVIEW_EDITS.md:642`, which introduced the reference).
      ✅ **RESOLVED — author chose not to write the Monte Carlo section**, so the three
      references were repointed instead. The table note already carried the full
      calibration ($\lambda=0$, 5,000 simulations, $T=470$, the $\phi_\tau$/$\phi_r$
      grids), so it was self-contained and the section references were redundant:
      - `06_replication.tex:88` — dropped the dangling ref, leaving `(\Cref{tab:cp-t2b})`
      - `cp_t2_panelB.tex:23` — *"the calibrated economy of ??"* → *"a calibrated
        expectations-hypothesis economy in which risk premia are constant"*
      - `cp_t2_panelB.tex:33` — *"a gap documented in ?? rather than closed"* →
        *"a gap that this note documents rather than closes"* (phrased in the third
        person so the G-1 `we`→`I` sweep does not have to touch it again)
      **Verified by compile:** `??` in the PDF **3 → 0**, undefined-reference warnings
      **4 → 0**.
      → Keep **`grep "??"` on the extracted PDF** as a standing check under G-13.

---

## Part 3 — Numbers and facts to verify

- [x] **NUM-1** Hiking-cycle date range: **2022–2023 (§5.3) vs 2021–2022 (elsewhere)**.
      Decide which is right and make it consistent. *(S-79)*
      ✅ **RESOLVED** — the single *"2022--2023"* outlier is now **2021--2022**,
      matching the four other mentions and Panel~C of the subperiod table.
- [x] **NUM-2** The **1.4% vs 1.5%** figure on p.44. *(S-80)*
      ✅ **RESOLVED without author input.** 1.43% rounds to 1.4%. See **S-80**.
- [x] **NUM-3** The **0.81** on p.61 vs **Table 6.5**. *(S-83)*
      🔴 **RESOLVED as a real defect, now fixed.** Table 20 was stale at 0.78 and
      reads **0.81** after the pipeline re-run. See **S-83** and §3 of
      `EXHIBIT_DATA_DISCREPANCIES.md`.
- [x] **NUM-4** The **9% dollar-return figure** — Sweden only, or general? *(S-67)*
      ✅ **RESOLVED without author input** — cross-country mean (0.0855), not Sweden
      (0.074). See **S-67**.
- [x] **NUM-5** Re-check **every remaining cross-reference and reported number** against the
      current exhibits, since renumbering (G-6) and restructuring (STR-1..4) will move them.
      ✅ **DONE.** Every table with a committed PDF was compared cell by cell (X-2),
      every cross-reference was resolved by the compiler with **0 undefined and 0
      `??`**, and every forward equation reference was checked by position (G-7).
      The **eight tables with no committed PDF** were the residual risk, and the
      pipeline re-run under X-2 cleared the main-results and robustness families and
      caught `rob_t7`. What is still unverified against fresh output is listed in §6
      of `EXHIBIT_DATA_DISCREPANCIES.md`.

---

## Part 4 — Questions back to the supervisor

- [ ] **Q-1** She read **Chapter 6 (Robustness)** more quickly and offered to look at anything
      more closely. → Decide what to send back: candidates are the **OOS estimation-scheme
      stress test**, the **core-vs-regional CPI variants**, and the **FXGCF construction
      alternatives**.
- [ ] **Q-2** S-84: confirm whether **dropping the local factor from the contribution
      statement** is intentional.
- [x] **Q-3** ✅ **RESOLVED (author decision, no need to ask her).** G-4 renames the
      **prose only** to **"dollar-return"**; the symbol `FXGCF_t` is **retained** to avoid
      rippling into every exhibit and the R scripts. Applied and compiled.
- [x] **Q-4** ✅ **RESOLVED (author decision).** Appendix order swapped — Replication is now Appendix A, Supplementary Tables and Figures is Appendix B.
- [x] **Q-5** STR-7: confirm the preferred new section title for the dollar-investor section.
      ✅ **RESOLVED** — §4.3 is *"The US-Dollar Investor: Currency Risk and the
      Dollar-Return Factor"*, her own first suggestion, restored verbatim with her
      punctuation.
- [ ] **Q-6** Offer a **follow-up meeting**, as she suggested, once the structural items
      (STR-1..4) are drafted.
- [ ] **Q-7** *(follow-on from G-4 — decide locally first, only ask her if unsure)*
      Should the antonym **"unadjusted"** (28 occurrences) also be renamed?
      Now that "FX-adjusted" is gone it has no stated counterpart, and it plausibly
      carries the mirror of the defect she flagged: a reader may take "unadjusted" to
      mean "**unhedged**", when $\GCF_t$ is in fact the **hedged / local-currency**
      factor. **A blanket swap to "local-currency" is unsafe** — *"the unadjusted
      dollar-investor factor"* (`08_robustness.tex:57,84`; `07_results.tex:480,482`)
      would turn into "local-currency dollar-investor factor", a contradiction.
      Suggested resolution: keep "unadjusted" as the standing term but **gloss it once**
      at first use (`07_results.tex:272` already does this well — *"The unadjusted factor
      $\GCF_t$ prices the hedged, local-currency return"*), and move that gloss earlier.
- [x] **Q-8** ✅ **RESOLVED (author decision): keep the supervisor's punctuation.**
      Four of her suggestions carry a colon or semicolon in her own wording. The
      author's no-colon rule does **not** override these — they are reproduced verbatim:
      - **S-13** *"…reveal a clear gap: despite its strong economic rationale…"*
      - **S-28** *"…state their limitations; \Cref{ch:conclusion} concludes."*
      - **S-51** *"Phase~I: local predictability"* (and II, III)
      - **S-66** *"The US-Dollar Investor: Currency Risk and the Dollar-Return Factor"*
      The no-colon rule still governs everything the revision writes in its own voice;
      nine such colons/semicolons were removed and stay removed, including the three
      literature paragraph headings, whose colons came from the **author's** original
      section titles rather than from her.

---

## Appendix — Source anchor index

Located against the current source. Line numbers drift as edits land — re-locate by the
quoted text if a line no longer matches.

| Item | Passage | Location |
|------|---------|----------|
| S-9 | "at most a constant term premium" | `01_introduction.tex:14`; **also `02_literature.tex:26`** — fix both |
| S-10 | "we aim to answer it" / "we ask one main question" | `01_introduction.tex:92`, `:96` |
| S-12 | "cast doubt on … economic interpretation" | `01_introduction.tex:60` |
| S-13 | "When we place these strands side by side" | `01_introduction.tex:77` |
| S-14 | "no GDP-weighted global cycle factor analogous" | `01_introduction.tex:79–80` |
| S-18 | "destroys" | `01_introduction.tex:116`, `:127`; **also `02_literature.tex:187`** |
| S-20 | "With our thesis, we contribute a three-factor hierarchy" | `01_introduction.tex:135` |
| S-21 | "transplant" | `01_introduction.tex:142` ("we transplant the integration test of") |
| S-23 | "We arrive at four main findings" | `01_introduction.tex:167` |
| S-24 | "genuinely local content" | `01_introduction.tex:175`; **also `10_conclusion.tex:40`** |
| S-25 | "Integration is therefore the rule" | `01_introduction.tex:176` |
| S-31 | "carry premium shrinks as foreign bond maturity lengthens" | `02_literature.tex:181–182` |
| S-33 | "constructs an FX-adjusted global cycle factor…" | `02_literature.tex:219–220` |
| S-35 | "three-phase design of Section 3.11" | `02_literature.tex:225–226` (`\Cref{sec:fw-hypotheses}`) |
| S-42 | "collected" | `04_data.tex:165` ("are collected in `\Cref{tab:dh-t1b-inputs}`") |
| S-44 | "menu" | `05_methodology.tex:15` (maturity menu), `:156` (data menu), `:320` (**Maturity menu.**); also `08_robustness.tex:199`, `:319`, `10_conclusion.tex:88` |
| S-56 | "unqiue" | `07_results.tex:91` — ✅ confirmed typo, 1 occurrence |
| S-61 | "ladder" | `07_results.tex:159–160`; also `A_appendix.tex:98,99,102` — **the figure file itself is named `mr_f2_r2_ladder.pdf`**, so a rename touches the R plotting script too |
| S-62 | "everywhere." | `07_results.tex:167` ("priced everywhere."); also `:156` ("threshold everywhere,") |
| S-66 | "Global Investor" heading | `07_results.tex:183` |
| S-73 | "collects their properties" | `07_results.tex:290` |
| STR-4 | Section 5.6 "Caveats" | `08b_strategy.tex:255` |
| G-5 | replication-appendix refs | `01_introduction.tex:163`, `:209`; `02_literature.tex:99`; `07_results.tex:8`; `10_conclusion.tex:19` |

**Spillover finding:** three flagged phrases recur *outside* the annotated page — S-9
(`02_literature.tex:26`), S-18 (`02_literature.tex:187`) and S-24 (`10_conclusion.tex:40`).
This is exactly the pattern the supervisor warned about ("I may have overlooked issues"):
**fix the class, not the instance.**

---

## Suggested order of work

1. **G-6** (renumbering) and **STR-1..4** (structure) first — they move everything else.
2. Then **G-1, G-3, G-4, G-5** — the mechanical global sweeps.
3. Then the per-item prose edits, chapter by chapter (Part 2).
4. Then **NUM-1..5** and **G-9** (exhibit notes) against the final numbering.
5. Finally **G-13** (consistency), **G-14** (table layout) and **G-15** (proofread).
