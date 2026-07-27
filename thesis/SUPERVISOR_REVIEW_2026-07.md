# Supervisor Review — Revision Checklist (2026-07)

**Source:** `master_thesis_preliminary_Heissenberger_GS1.pdf` (82 pp., 86 annotations
by `gsimion`) + covering email from Giorgia Simion, 2026-07.

**Status:** OPEN — not yet started. Work top to bottom; tick items as they are done.

**Overall verdict (email):** *"The thesis is well executed and the analyses are
sophisticated and comprehensive, but in some places the writing can be made clearer
and more academic. I also suggested some minor changes in the structure, especially
for the appendices."* No re-analysis is required — this is a writing, structure and
consistency pass.

**Caveat from the supervisor:** he flagged issues *where he happened to notice them*
and may have overlooked others. Every `G-` item below must therefore be swept
**systematically across the whole thesis**, not only at the flagged locations.

**Also:** he read **Chapter 8 (Robustness) more quickly** than the rest due to time,
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
      → **Scope: ~296 occurrences** (`we` 191, `We` 105) across `chapters/`.
      Per file (we/We): results 35/14, robustness 28/9, intro 27/6, methodology 21/24,
      strategy 19/10, data 14/21, conclusion 14/4, replication 13/3, discussion 11/5,
      literature 8/6, abstract 1/3. Also sweep table notes and figure captions.
      ⚠️ Not a blind find-replace — verb agreement ("we are" → "I am") and possessives.

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

- [ ] **G-4 · Rename the FX-adjusted factor.** "FX-adjusted" is easily misread as
      **"FX-hedged", which is the opposite** of what is meant. Rename to
      **"dollar-return global cycle factor"** or **"USD global cycle factor"**.
      He also notes the term "FX-adjusted" does **not** appear in Dahlquist–Hasseltoft.
      *(S-48, S-49, p.23)*
      → **Scope: 80 occurrences** of "FX-adjusted" — `07_results.tex` 19,
      `08_robustness.tex` 14, `01_introduction.tex` 6, `05_methodology.tex` 6,
      `06_replication.tex` 5, `08b_strategy.tex` 5, `10_conclusion.tex` 4,
      `02_literature.tex` 4, `00_abstract.tex` 3, `09_discussion.tex` 2, `tables/` 10,
      `preamble.tex` 1 (likely a macro — change it there first).
      → Decide the new name once (**Q-3**), then sweep prose, the symbol `FXGCF_t`,
      section headings (`sec:fw-fxgcf`, `07_results.tex:183`), table/figure captions and
      notes, and the R scripts' exhibit labels.

- [ ] **G-5 · "Chapter B" → "Appendix B".** *(S-7 p.5; S-22, S-26 strikeouts p.10–11;
      S-52 p.26)*
      ⚠️ **Root cause is `cleveref`, not the prose.** All five references already use
      `\Cref{ch:replication}` — `01_introduction.tex:163,209`, `02_literature.tex:99`,
      `07_results.tex:8`, `10_conclusion.tex:19`. Because the chapter sits after
      `\appendix`, cleveref still renders the *word* "Chapter". **Fix it once in
      `preamble.tex`** (e.g. `\crefalias{chapter}{appendix}` after `\appendix`, or the
      `\appendixname` route) rather than hard-coding "Appendix B" at five call sites.
      Then re-check the compiled PDF.

- [ ] **G-6 · Progressive numbering.** Do **not** number by chapter (Table 3.1).
      Number **Table 1, Table 2, …** from 1 onward, and the **same for figures and
      equations**. *(S-39, p.18)*
      ⚠️ `preamble.tex` has **no** `\counterwithin` / `\numberwithin` — the per-chapter
      numbering is the **`report` class default**. So this is an *addition*, not a
      removal: add `\counterwithout{table}{chapter}`, likewise `figure` and `equation`
      (package `chngcntr`), keeping the appendix numbering (A.1/B.1) intact if desired.
      Do this **early** — it moves every number in the text, then let LaTeX resolve refs.

- [ ] **G-7 · Spell out forward references.** A bare "(3.9)" is ambiguous when both
      *Section* 3.9 and *Equation* (3.9) exist. Write "the dollar-investor excess
      return defined in **Equation (3.9)** below" or "…defined in **Section 3.9**".
      *(S-40 p.18; S-58 p.28)*

- [ ] **G-8 · Introduce every exhibit before discussing it.** On first mention, state
      briefly what the table/figure reports, *then* discuss. Model sentence:
      *"Figure X plots the GDP-weighted global cycle factor over 1990–2024, together
      with the eleven country-level local factors. We can see…"* *(S-59, p.28)*

- [ ] **G-9 · Notes for ALL tables and figures.** Required for every exhibit in the
      thesis, appendices included. Double-check completeness. *(email; S-38, p.18)*

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

- [ ] **STR-1 · Consolidate Chapter 3 (Data and Methodology), 13 → ~5 subsections.**
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
      | 3.10 | The FX-Adjusted Global Cycle Factor | `05_methodology.tex:179` |
      | 3.11 | Hypotheses and Predictive Specifications | `05_methodology.tex:221` |
      | 3.12 | Estimation and Inference | `05_methodology.tex:286` |
      | 3.13 | Deviations from the Original Studies | `05_methodology.tex:313` |

      Proposed merge:
      1. Merge **3.1–3.4** into a single **"Data and Variable Construction"**.
      2. Merge **3.5 and 3.9** (defining excess returns together with the EH null —
         this also removes the forward reference from 3.7 to 3.9).
      3. Merge **3.6–3.8 and 3.10** into one **"Cycle-Factor Hierarchy"** section,
         with *unnumbered paragraph headings* for the individual factors.
      4. Keep **3.11** as its own section.
      5. Fold **3.13 into 3.12**.
      > **Rule of thumb (his):** a subsection shorter than half a page should be a
      > paragraph heading, not a numbered unit. — Apply this rule everywhere.

- [ ] **STR-2 · Split the literature review into two sections, not five.**
      *(S-5 p.4; S-36 p.16)* Five subsections is too fine for a four-page review.
      All in `02_literature.tex`:
      - **"Bond Return Predictability in the United States"** = current 2.1–2.3
        (EH rejection → forward-rate benchmark → macro-anchored mechanism)
        → `:22` EH and Bond Return Predictability; `:77` Forward-Rate Predictors:
          Cochrane and Piazzesi (2005); `:104` The Macro-Anchored Cycle Factor:
          Cieslak and Povala (2015)
      - **"International Evidence and the Gap"** = current 2.4–2.5
        → `:145` Global Integration: Dahlquist and Hasseltoft (2013);
          `:192` International Macro-Anchored Predictability and the Gap

- [ ] **STR-3 · Two separate appendices, and consider swapping their order.**
      *(S-7, p.5)* Both are already separate `\chapter`s after `\appendix`
      (`main.tex:53–55`) — the real defect is the **titles and the ordering**:
      - `A_appendix.tex:2` is titled generically **`\chapter{Appendix}`** → retitle
        **"Supplementary Tables and Figures"** (A.1 Tables, A.2 Figures).
      - `06_replication.tex:5` is already **`\chapter{Replication and Validation}`** ✔
      - **Consider swapping the `\input` order in `main.tex`** so the replication comes
        first — it validates the pipeline and is conceptually prior. *(→ Q-4)*
      - Correct all in-text references (see **G-5** — a cleveref config fix).

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
      → `07_results.tex:183` — `\section{The Global Investor and the FX-Adjusted Factor}`
      (note it also carries the G-4 rename). The heading
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
- [ ] **S-4** (p.4) Chapter 3 fragmentation. *(STR-1)*
- [ ] **S-5** (p.4) Literature review too finely split. *(STR-2)*
- [ ] **S-6** (p.4) "G10" → **"G10 markets"**.
- [ ] **S-7** (p.5) Two appendices, own titles, fix refs, consider swapping order. *(STR-3)*

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
      each across the G10."* (adjust the factor name per G-4)
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
- [ ] **S-36** (p.16) Literature structure. *(STR-2)*

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
- [ ] **S-51** (p.24) **Bold question-headings** for the Phases — make them short and
      declarative instead. *(STR-6)*

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

- [ ] **Q-1** He read **Chapter 8 (Robustness)** more quickly and offered to look at anything
      more closely. → Decide what to send back: candidates are the **OOS estimation-scheme
      stress test**, the **core-vs-regional CPI variants**, and the **FXGCF construction
      alternatives**.
- [ ] **Q-2** S-84: confirm whether **dropping the local factor from the contribution
      statement** is intentional.
- [ ] **Q-3** G-4: confirm the preferred replacement name — **"dollar-return global cycle
      factor"** vs **"USD global cycle factor"** — before the global rename.
- [ ] **Q-4** STR-3: confirm whether to **swap the appendix order** (Replication first).
- [ ] **Q-5** STR-7: confirm the preferred new section title for the dollar-investor section.
- [ ] **Q-6** Offer a **follow-up meeting**, as he suggested, once the structural items
      (STR-1..4) are drafted.

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
