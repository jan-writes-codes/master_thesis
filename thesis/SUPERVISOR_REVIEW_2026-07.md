# Supervisor Review — Revision Checklist (2026-07)

**Source:** `master_thesis_preliminary_Heissenberger_GS1.pdf` (82 pp., 86 annotations
by `gsimion`) + covering email from Giorgia Simion, 2026-07.

**Status:** IN PROGRESS. Done and verified by a clean compile:
**G-4, G-5, G-6, STR-1, STR-2, STR-3, S-4, S-5, S-7, S-36, S-51, X-1.**
Next up: **STR-4** (§5.6) and **STR-5** (research-question presentation), then the **G-1**
`we`→`I` sweep — do the structural items first so the sweep is not repeated on moved
text. Work top to bottom; tick items as they are done.

**Build note:** the thesis compiles with `latexmk -pdf main.tex` (0 errors). Two cheap
regression checks to run after every batch of edits:
`grep -c "??"` on the extracted PDF text (see **X-1**) and a scan of `main.log` for
`undefined` / `multiply defined`.

**Overall verdict (email):** *"The thesis is well executed and the analyses are
sophisticated and comprehensive, but in some places the writing can be made clearer
and more academic. I also suggested some minor changes in the structure, especially
for the appendices."* No re-analysis is required — this is a writing, structure and
consistency pass.

**Caveat from the supervisor:** he flagged issues *where he happened to notice them*
and may have overlooked others. Every `G-` item below must therefore be swept
**systematically across the whole thesis**, not only at the flagged locations.

**Also:** he read **Chapter 6 (Robustness) more quickly** than the rest due to time,
and offered a follow-up meeting. See `Q-` items at the end.

---

## How to use this file

- `p.N` = page of the annotated PDF; `S-NN` = annotation number (1–86), 1:1 with the PDF.
- `G-` = global rule, applies throughout; `STR-` = structural change; `NUM-` = number/fact
  to verify; `Q-` = question to put back to the supervisor.
- Tick `[x]` only once the change is in the `.tex` **and** the sweep for that rule is complete.

---

## Part 0 — Global rules (supervisor: *"I won't make this comment again — apply throughout"*)

These are the highest-leverage items. Each one is a full-document sweep.

- [ ] **G-1 · First-person singular.** Replace **"we/our/us" with "I/my/me"** throughout.
      Single-author thesis; no "we". *(email; S-1 "our"→"this", S-2, p.3)*
      → **Scope: ~387 occurrences** across `chapters/`, verified by count:
      **`we` 191 + `We` 105 = 296**, plus **`our` 77 + `Our` 14 = 91**.
      Per file (we/We): results 35/14, robustness 28/9, intro 27/6, methodology 21/24,
      strategy 19/10, data 14/21, conclusion 14/4, replication 13/3, discussion 11/5,
      literature 8/6, abstract 1/3. Also sweep table notes and figure captions.
      ⚠️ **Not a blind find-replace.** Three traps:
      (a) verb agreement — "we are/were/have" → "I am/was/have";
      (b) **not every "we" is authorial** — "we can see", "we know that" is the reader-
      inclusive *we*, which some supervisors accept but he asked for consistency, so
      prefer recasting ("the figure shows") over "I can see";
      (c) `\emph`/citation contexts and any "we" inside quoted material must stay.

- [ ] **G-2 · "out-of-sample" hyphenation.** *(S-3, p.3)*
      **Scope: 13 unhyphenated vs 53 hyphenated.** Note that **most unhyphenated uses are
      adverbial and therefore correct** ("predicts out of sample") — the rule is hyphenate
      the *adjective*, not the adverb. Check each: `00_abstract.tex:25`;
      `02_literature.tex:169,171`; `07_results.tex:368,408,413,478`;
      `08_robustness.tex:171,388`; `08b_strategy.tex:22`; `09_discussion.tex:106,170`;
      `tables/mr_t4_oos.tex:24`.

- [ ] **G-3 · Italics discipline.** Follow the Cieslak–Povala (2015) convention:
      italics **only** for mathematical symbols/variables (`CF_t`, `GCF_t`, `y_t^(n)`)
      and sparing emphasis. **No** italics for "cycle" / "cycle factor" (§2.3), **no**
      italicised research questions in the introduction, **no** italicised "dollar".
      *(S-30 p.14; S-16 p.10; S-50 p.23; S-10 p.9)*

- [x] **G-4 · Rename the FX-adjusted factor.** ✅ **DONE & VERIFIED BY COMPILE**
      **Decision (author-confirmed):** rename the **prose only**, keep the **symbol**
      `FXGCF_t`. Chosen wording: **"dollar-return"** (his first suggestion).
      **Applied:** all **84** occurrences — 80 lowercase `FX-adjusted` → `dollar-return`,
      plus 4 title-case `FX-Adjusted` → `Dollar-Return` in section headings.
      Diff is a symmetric 89/89 pure substitution; the one pre-existing "dollar-return"
      in `08_robustness.tex` accounts for the 81st lowercase hit.
      **Verified in the rebuilt PDF:** `FX-adjusted` **0**, `dollar-return` **85**,
      symbol `FXGCF` intact at **54** occurrences, 0 errors, 82 pages.
      Renamed headings now read: *The Dollar-Return Global Cycle Factor* (3.10),
      *The Global Investor and the Dollar-Return Factor*, *The US-Dollar Investor and
      the Dollar-Return Factor*, *The Construction of the Dollar-Return Factor*.
      ⚠️ **Two sites the rename broke, both fixed:**
      - `07_results.tex:20` read *"the **adjusted** and unadjusted global factors"* —
        "adjusted" was shorthand for "FX-adjusted" and was left dangling →
        *"the dollar-return and unadjusted global factors"*.
      - `strat_t2_usd.tex:17` (table note) → *"the recursive dollar-return and
        **local-currency** global factors"*.
      📌 **Open question deliberately NOT swept — see Q-7:** the antonym **"unadjusted"**
      (28 occurrences) was left alone. It now has no explicit counterpart in the text,
      and arguably carries the *same* defect he flagged: a reader can misread
      "unadjusted" as "**unhedged**", which is backwards ($\GCF_t$ is the hedged,
      local-currency factor). A blanket swap to "local-currency" is **not** safe,
      though — phrases like *"the unadjusted dollar-investor factor"*
      (`08_robustness.tex:57,84`; `07_results.tex:480,482`) would become
      "local-currency dollar-investor factor", which is self-contradictory.

      *(original comments: S-48, S-49, p.23 — "FX-adjusted" is easily misread as
      "FX-hedged", the opposite of what is meant; he also notes the term does not
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

- [ ] **G-7 · Spell out forward references.** A bare "(3.9)" is ambiguous when both
      *Section* 3.9 and *Equation* (3.9) exist. Write "the dollar-investor excess
      return defined in **Equation (3.9)** below" or "…defined in **Section 3.9**".
      *(S-40 p.18; S-58 p.28)*
      📌 **G-6 partly solves this for free:** once equations number (1), (2), … they can
      no longer collide with section numbers like 3.9, so the specific ambiguity he
      caught disappears. **The rest of his point stands** — the 70 `\eqref` calls still
      render a bare "(9)" with no noun. Wrap them as "Equation~\eqref{…}" where the
      reference is a forward one or the reader may lose the thread.

- [ ] **G-8 · Introduce every exhibit before discussing it.** On first mention, state
      briefly what the table/figure reports, *then* discuss. Model sentence:
      *"Figure X plots the GDP-weighted global cycle factor over 1990–2024, together
      with the eleven country-level local factors. We can see…"* *(S-59, p.28)*

- [ ] **G-9 · Notes for ALL tables and figures.** *(email; S-38, p.18)*
      ✅ **Audited — tables are already fine:** all **32** files in `tables/` carry a
      `\tabnotes{…}` block. Nothing to do there.
      ⚠️ **The gap is figures — all 26 of them.** There is **no figure-notes mechanism at
      all**: no `\fignotes` macro in `preamble.tex`, and every figure carries only a
      `\caption{}`. The captions *are* descriptive (they name the series and the
      equation), but they are captions, not notes — which is what he asked for.
      Count by file: `07_results.tex` 9, `A_appendix.tex` 7, `08b_strategy.tex` 4,
      `08_robustness.tex` 3, `06_replication.tex` 2, `04_data.tex` 1.
      → Suggested fix: define a `\fignotes` macro mirroring `\tabnotes`
      (`preamble.tex:30`) so the styling matches, then add sample/estimation/source
      detail to each of the 26. This is the single biggest mechanical item on the list.

- [ ] **G-10 · "After X" → "The table format follows X".** The *"After Dahlquist and
      Hasseltoft (2013), Table 1"* convention is legitimate but risks being read as a
      **data source**. State it explicitly. *(S-43, p.20)*
      → Exactly **2 instances**: `tables/dh_t1_corr10y.tex:26` and
      `tables/dh_t1_summary.tex:31`. **Bonus finding:** the other seven replication tables
      already use a *different* phrasing — *"The table replicates \citet{…}, Table N"*
      (`cp_t1.tex:31`, `cp_t2_panelA.tex:45`, `cp_t4.tex:39`, `dh_t3_cp_corr.tex:27`,
      `dh_t4_fb_cp.tex:63`, `dh_t6_local_global.tex:71`, `dh_t7_usd.tex:44`).
      **Unify all nine**, and keep "replicates" vs "format follows" semantically distinct.

- [ ] **G-11 · OLS consistency.** Sometimes "OLS", sometimes "ordinary least squares".
      Define once at first use, then use the abbreviation. *(S-46, p.21)*
      → Spelled-out form at `05_methodology.tex:51`, `05_methodology.tex:289`,
      `07_results.tex:26`.

- [ ] **G-12 · Tone down the overclaiming.** A recurring theme across the review:
      the "**no …, no …, no …**" enumerations sound categorical; state the gap clearly
      but without overemphasis. *(S-14 p.9; S-32, S-33, S-34 p.15)*
      Related single-word softenings: S-18 "destroys", S-12 "cast doubt on the economic
      interpretation", S-72 "prices"→"primarily related to".

- [ ] **G-13 · Internal consistency sweep** *(email)*: notation, cross-references,
      terminology, citations. Systematic pass, independent of the flagged instances.

- [ ] **G-14 · Table layout pass** *(email)*: improve the layout of tables wherever
      appropriate. See also STR-8 (dense tables need reader guidance).

- [ ] **G-15 · Full proofread** *(email)*. Last step, after all edits land.

---

## Part 1 — Structural changes

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

      **His forward-reference point is resolved.** Excess returns are now *defined
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
      > **Rule of thumb (his):** a subsection shorter than half a page should be a
      > paragraph heading, not a numbered unit. — Still to apply elsewhere: **STR-4**
      > (§5.6 Caveats).

- [x] **STR-2 · Split the literature review into two sections, not five.** ✅ **DONE**
      *(S-5 p.4; S-36 p.16)* Applied exactly as he specified, in `02_literature.tex`:
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

      **Resulting front matter, exactly his requested shape:**
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

- [ ] **STR-4 · Section 5.6 is too short** (~6 sentences) to be its own numbered
      subsection. *(S-81, p.44)*
      → It is **`\section{Caveats}` at `08b_strategy.tex:255`** (`sec:strat-caveats`),
      the 6th section of Chapter 5 (Portfolio Construction). Fold it concisely into the
      preceding material — and check whether anything `\ref`s that label.

- [ ] **STR-5 · Rewrite the research-question presentation.** *(S-10, p.9)*
      Do **not** display it in italics with numbered sub-questions — *"this reads like
      a proposal, not a thesis."* Instead:
      - State the main question **declaratively in running text**.
      - Fold the sub-questions into a paragraph: *"First, … Second, … Third, …"*,
        mapping them onto the Phase I/II/III labels used later.
      - Remove the repetition: *"In our thesis, we aim to answer it. In our thesis,
        we ask one main question:"*

- [ ] **STR-6 · Keep "Phase I/II/III" out of the introduction.** *(S-19 p.10; S-35 p.16;
      S-51 p.24)*
      - In the intro, use plain prose: *"We answer these questions in three steps.
        First, we test the cycle factor market by market across the G10. Second, we run
        the horse race between the global and local factors. Third, we adopt the
        perspective of an unhedged US-dollar investor…"*
      - If the Phase labels stay as the organising device for Chapters 3–6, **introduce
        them in Section 3.11**, not before.
      - The phase headings themselves: keep the run-in labels but make them **short and
        declarative** ("Phase I: local predictability"), not bold restatements of the
        research questions.

- [ ] **STR-7 · Rename the "Global Investor" section.** *(S-66, p.30)*
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
      His suggestions:
      - *"The US-Dollar Investor: Currency Risk and the Dollar-Return Factor"*
      - *"The US-Dollar Investor and the Global Cycle Factor"*
      Also **delete the stranded** *"'dollar' refers to the US dollar"* (define once, in 3.9).

- [ ] **STR-8 · Guide the reader through the dense tables.** *(S-68, p.30)*
      The table is dense; say **which columns to look at**, and **consider numbering the
      columns** (standard practice in papers). *"Otherwise it is easy to get lost."*

---

## Part 2 — Item-by-item (by PDF page)

### Front matter & Table of Contents
- [ ] **S-1** (p.3) "our" → "this". *(see G-1)*
- [ ] **S-2** (p.3) "we" → "I". *(G-1)*
- [ ] **S-3** (p.3) "out of sample" → consistent hyphenation. *(G-2)*
- [x] **S-4** (p.4) Chapter 3 fragmentation. *(done via STR-1)*
- [x] **S-5** (p.4) Literature review too finely split. *(done via STR-2)*
- [ ] **S-6** (p.4) "G10" → **"G10 markets"**.
- [x] **S-7** (p.5) Two appendices, own titles, refs fixed, order swapped. *(done via STR-3)*

### Chapter 1 — Introduction
- [ ] **S-8** (p.8) Insert **"On average,"** at the start of the sentence.
- [ ] **S-9** (p.8) **The equation omits the constant term premium the sentence
      announces.** Add "(+ constant term premium)" as in Cochrane, *Asset Pricing*, Ch. 19,
      and **fix footnote 1** accordingly (its one-period relation also lacks it).
      Then **"≈" can become "="** — the log form is exact for zero-coupon bonds.
- [ ] **S-10** (p.9) Research-question block. *(STR-5)*
- [ ] **S-11** (p.9) Do not start a sentence with **"However"** — rephrase.
- [ ] **S-12** (p.9) *"cast doubt on the economic interpretation"* is **too broad** —
      failure abroad speaks to generality, not to the mechanism. Use:
      *"…and a failure to find it there would cast doubt on its **generalisability**."*
      (This also fixes *"a failure to do so"*, which lacks a referent.)
- [ ] **S-13** (p.9) Rephrase, his wording: *"Placed side by side, these strands reveal a
      clear gap: despite its strong economic rationale, the cycle factor of Cieslak and
      Povala (2015) has not yet been tested outside the United States."*
- [ ] **S-14** (p.9) "no …, no …, no …" sounds categorical — soften. *(G-12)*
- [ ] **S-15** (p.10) **Remove the section cross-reference** ("(Section 3.11)") — no need
      to reference sections in the introduction.
- [ ] **S-16** (p.10) "dollar" — **no italics**. *(G-3)*
- [ ] **S-17** (p.10) "conversion" → **"risk"**.
- [ ] **S-18** (p.10) **"destroys"** — too strong.
- [ ] **S-19** (p.10) "In Phase I, …" — plain prose in the intro. *(STR-6)*
- [ ] **S-20** (p.10) **Unclear topic sentence.** *"With our thesis, we contribute a
      three-factor hierarchy and the evidence to evaluate it."* — "three-factor hierarchy"
      misleads and "the evidence to evaluate it" is vague. His model sentence:
      *"Our contribution is a family of three nested cycle factors — local, global, and
      FX-adjusted — together with in-sample and fully recursive out-of-sample evidence on
      each across the G10."*
      ⚠️ **Use "dollar-return", not his "FX-adjusted"**, when adopting this sentence —
      he wrote it before making the G-4 renaming request, so the two comments conflict.
      Also recast to first person per G-1: *"I contribute a family of three nested cycle
      factors — local, global, and dollar-return — together with…"*
- [ ] **S-21** (p.10) **"transplant"** — check the word is accurate.
- [ ] **S-22** (p.10) **Strike** "(Chapter B)". *(G-5)*
- [ ] **S-23** (p.10) *"We arrive at four main findings"* — **"arrive" is not academic**.
      Use *"Four main findings emerge"* or *"The analysis yields four main findings"*.
- [ ] **S-24** (p.11) **"genuinely local content"** — does this mean local indices? local
      information? Rephrase.
- [ ] **S-25** (p.11) **"Integration is therefore the rule"** — unclear.
- [ ] **S-26** (p.11) **Strike** the sentence *"In Chapter B, we validate our empirical
      engine against the published results of Cieslak and Povala (2015) and Dahlquist and
      Hasseltoft (2013)."* *(G-5, STR-3)*
- [ ] **S-27** (p.11) That material **belongs to the Appendix** — no need to explain it here.
- [ ] **S-28** (p.11) End the roadmap with **"; Chapter 8 concludes."**

### Chapter 2 — Literature Review
- [ ] **S-29** (p.13) "transformed" → **present simple**.
- [ ] **S-30** (p.14) Italics convention. *(G-3)*
- [ ] **S-31** (p.15) **Imprecise:** *"carry premium shrinks as foreign bond maturity
      lengthens"*. It does not shrink — the unhedged bond return is the **currency risk
      premium + the local-currency term premium**, and for long-maturity bonds these two
      components move in **opposite directions**, so the overall carry-trade return is low.
      Rewrite accordingly.
- [ ] **S-32** (p.15) "no …" enumeration. *(G-12)*
- [ ] **S-33** (p.15) **Tone down** the gap claim ("…constructs an FX-adjusted global cycle
      factor for the unhedged dollar investor. The existing international evidence has also
      not been subjected to the full out-of-sample discipline…").
- [ ] **S-34** (p.15) **Tone down** *"we want to add to"*.
- [ ] **S-35** (p.16) *"three-phase design of Section 3.11"* — **this is the literature
      part; do not discuss the methodology yet.**
- [x] **S-36** (p.16) Literature structure. *(done via STR-2)*

### Chapter 3 — Data and Methodology
- [ ] **S-37** (p.17) **Something is missing** — add *", which will be presented in detail
      in Section …"*.
- [ ] **S-38** (p.18) Notes required for all tables and figures. *(G-9)*
- [ ] **S-39** (p.18) Progressive numbering. *(G-6)*
- [ ] **S-40** (p.18) Ambiguous bare "(3.9)". *(G-7)*
- [ ] **S-41** (p.19) "net" → **"net out"**.
- [ ] **S-42** (p.20) "collected" → **"reported"**.
- [ ] **S-43** (p.20) "After Dahlquist and Hasseltoft (2013), Table 1" → *"The table format
      follows Dahlquist and Hasseltoft (2013), Table 1."* *(G-10)*
- [ ] **S-44** (p.20) **"menu"** — change the word.
- [ ] **S-45** (p.21) `rx^(n)_{t+12}` — **should it not carry the country subscript `i`**,
      as mentioned above it?
- [ ] **S-46** (p.21) OLS vs "ordinary least squares". *(G-11)*
- [ ] **S-47** (p.22) **`N` is overloaded:** defined as the maturity menu {1,2,4,5,9,10} in
      3.5, used correctly in (3.4) as N\{1}, then **silently redefined** as the averaging
      set {2,5,10} in (3.8) with K = |N|. **Give the averaging set its own symbol.**
- [ ] **S-48** (p.23) Rename `FXGCF_t`. *(G-4)*
- [ ] **S-49** (p.23) Same, and "FX-adjusted" is not Dahlquist–Hasseltoft's term. *(G-4)*
- [ ] **S-50** (p.23) "USD cycle factor" — adjust italics. *(G-3)*
- [x] **S-51** (p.24) **Bold question-headings** for the Phases — made short and
      declarative. ✅ **DONE** (alongside STR-1, same file). Was
      *"Phase I --- Does the cycle factor predict returns locally?"*; now
      *"Phase I: local predictability"*, *"Phase II: global versus local"*,
      *"Phase III: currency risk and the dollar-return factor"*
      (`05_methodology.tex`, §3.4). The questions themselves already appear in the
      introduction, so restating them as headings was the redundancy he flagged.

### Chapter 4 — Results
- [ ] **S-52** (p.26) "In Chapter B" → **"Appendix B"**; state that the validation is
      presented in detail in Appendix B, then **move directly to the core analysis**. *(G-5)*
- [ ] **S-53** (p.26) "was" → **"is"**.
- [ ] **S-54** (p.26) **Move the algebraic preamble** (why the regression on CF has slope
      identically one and R² equal to the underlying fit) **into a footnote**, and open with
      *"Table X shows the results from the predictive regression…"*.
- [ ] **S-55** (p.27) Make clear that **Table 4.1 is for the G10**; connect it to the next
      sentence, e.g. *"Specifically, I regress…"*.
- [ ] **S-56** (p.28) **"unqiue"** → "specific" *(typo)*.
- [ ] **S-57** (p.28) Remove the hyphen ("…-bond…").
- [ ] **S-58** (p.28) "of (3.7)" → *", as defined in Eq. (3.7),"* or similar. *(G-7)*
- [ ] **S-59** (p.28) Introduce every exhibit before discussing it. *(G-8)*
- [ ] **S-60** (p.29) "named" → **"previously described"**.
- [ ] **S-61** (p.29) **"ladder"** is not standard terminology — check it is correct here.
- [ ] **S-62** (p.29) "everywhere" → **"in all the markets analysed"**.
- [ ] **S-63** (p.30) The sentence ending *"…that of Dahlquist and Hasseltoft (2013)."*
      **reads unfinished**.
- [ ] **S-64** (p.30) "adopted" → **present simple**.
- [ ] **S-65** (p.30) **The second question is hard to parse** — a 30-word relative clause.
      Simplify.
- [ ] **S-66** (p.30) Heading + stranded definition. *(STR-7)*
- [ ] **S-67** (p.30) *"…to 9% on dollar returns"* — **the 9% looks like Sweden only**,
      not a general figure. *(→ NUM-4)*
- [ ] **S-68** (p.30) Dense table needs reader guidance / numbered columns. *(STR-8)*
- [ ] **S-69** (p.31) "panel," — **singular or plural?**
- [ ] **S-70** (p.32) Rephrase, his wording: *"The unadjusted factor GCF_t is, by
      construction, built from local-currency returns, which can be interpreted as
      currency-hedged returns; interest-rate risk, rather than currency risk, is therefore
      its main driver."*
- [ ] **S-71** (p.32) "duration" → **"term premium"**.
- [ ] **S-72** (p.32) The "wedge" reading — **soften** to *"primarily related to"* or similar.
- [ ] **S-73** (p.32) *"Table 4.4 collects their properties"* → **"presents the results"**.
- [ ] **S-74** (p.34) The last sentence (*"We compare the cycle factor against the
      forward-rate factor … in Chapter 6"*) **reads as a continuation** of the R²_oos-vs-mean
      explanation, but it is a **different comparison**. Separate it into its own
      sentence/paragraph with an **explicit transition**.
- [ ] **S-75** (p.34) **Spell out in-line** why the two R² columns of Table 4.5 are not
      comparable (different benchmarks) — not only in the table note.
- [ ] **S-76** (p.34) Should the factors in the table carry the **OOS subscript**, for
      consistency with the rest of the notation?
- [ ] **S-77** (p.36) "G10." → **"G10 markets."**
- [ ] **S-78** (p.36) "government-bond" → **no hyphen**.

### Chapter 5 — Portfolio Construction / Strategy
- [ ] **S-79** (p.42) **Hiking-cycle dates inconsistent.** ✅ *Confirmed and isolated:*
      **`08b_strategy.tex:129` is the sole outlier** ("2022--2023 global hiking cycle");
      the same event is called **"2021--2022"** in five places —
      `08b_strategy.tex:151`, `:159`, `:262`, and `tables/strat_t4_subperiod.tex:18`, `:26`.
      → Fix line 129 (or decide 2022–23 is right and change the other five). *(→ NUM-1)*
- [ ] **S-80** (p.44) "1.4%" → **1.5**. *(→ NUM-2)*
- [ ] **S-81** (p.44) §5.6 too short for its own subsection. *(STR-4)*

### Chapter 6 — Robustness *(read more quickly — see Q-1)*
- [ ] **S-82** (p.51) **Does not read well:** *"At face value, this is not in the cycle
      factor's favour. However, because the forward factor uses six predictors compared to
      the cycle factor's two and therefore has far more scope to over-fit a fixed sample."*
      (the "because…" clause has no main clause — sentence fragment).

### Chapter 7 — Discussion
- [ ] **S-83** (p.61) "0.81" — **is this consistent with Table 6.5?** *(→ NUM-3)*
- [ ] **S-84** (p.61) The **contribution statement appears to drop the local factor** — is
      there a specific reason? *(→ Q-2)*

### Bibliography & Appendices
- [ ] **S-85** (p.65) **BibTeX has eaten capitalisations.** ✅ *Confirmed — cause is
      `\bibliographystyle{chicago}` (`main.tex:50`), which lowercases titles, and
      **no title field in `references.bib` is brace-protected**.*
      He spotted three; the sweep found **more**:
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
- [ ] **S-86** (p.74) **Incomplete text** in the appendix.
      ✅ **Diagnosed** — `06_replication.tex:19`:
      > *"The relevant test is therefore agreement on signs, magnitudes."*
      The list is truncated — it needs its final item and a conjunction, e.g.
      *"…agreement on signs, magnitudes, **and statistical significance**."*

---

## Part 2b — Found by compiling (NOT flagged by the supervisor)

These were not in his 86 comments but **are visible in the PDF he read**. They fall
squarely under his instruction to check cross-references systematically (G-13).

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
      he simply did not catch them, consistent with having read the back matter quickly.
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

- [ ] **NUM-1** Hiking-cycle date range: **2022–2023 (§5.3) vs 2021–2022 (elsewhere)**.
      Decide which is right and make it consistent. *(S-79)*
- [ ] **NUM-2** The **1.4% vs 1.5%** figure on p.44. *(S-80)*
- [ ] **NUM-3** The **0.81** on p.61 vs **Table 6.5**. *(S-83)*
- [ ] **NUM-4** The **9% dollar-return figure** — Sweden only, or general? *(S-67)*
- [ ] **NUM-5** Re-check **every remaining cross-reference and reported number** against the
      current exhibits, since renumbering (G-6) and restructuring (STR-1..4) will move them.

---

## Part 4 — Questions back to the supervisor

- [ ] **Q-1** He read **Chapter 6 (Robustness)** more quickly and offered to look at anything
      more closely. → Decide what to send back: candidates are the **OOS estimation-scheme
      stress test**, the **core-vs-regional CPI variants**, and the **FXGCF construction
      alternatives**.
- [ ] **Q-2** S-84: confirm whether **dropping the local factor from the contribution
      statement** is intentional.
- [x] **Q-3** ✅ **RESOLVED (author decision, no need to ask him).** G-4 renames the
      **prose only** to **"dollar-return"**; the symbol `FXGCF_t` is **retained** to avoid
      rippling into every exhibit and the R scripts. Applied and compiled.
- [x] **Q-4** ✅ **RESOLVED (author decision).** Appendix order swapped — Replication is now Appendix A, Supplementary Tables and Figures is Appendix B.
- [ ] **Q-5** STR-7: confirm the preferred new section title for the dollar-investor section.
- [ ] **Q-6** Offer a **follow-up meeting**, as he suggested, once the structural items
      (STR-1..4) are drafted.
- [ ] **Q-7** *(follow-on from G-4 — decide locally first, only ask him if unsure)*
      Should the antonym **"unadjusted"** (28 occurrences) also be renamed?
      Now that "FX-adjusted" is gone it has no stated counterpart, and it plausibly
      carries the mirror of the defect he flagged: a reader may take "unadjusted" to
      mean "**unhedged**", when $\GCF_t$ is in fact the **hedged / local-currency**
      factor. **A blanket swap to "local-currency" is unsafe** — *"the unadjusted
      dollar-investor factor"* (`08_robustness.tex:57,84`; `07_results.tex:480,482`)
      would turn into "local-currency dollar-investor factor", a contradiction.
      Suggested resolution: keep "unadjusted" as the standing term but **gloss it once**
      at first use (`07_results.tex:272` already does this well — *"The unadjusted factor
      $\GCF_t$ prices the hedged, local-currency return"*), and move that gloss earlier.

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
