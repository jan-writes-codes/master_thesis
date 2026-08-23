# Exhibit data discrepancies — for author review

**Date:** 2026-08 · **Status:** OPEN, needs a decision · **Checklist item:** X-2

## What was checked and how

Every table in `thesis/tables/*.tex` is **transcribed by hand** from an R-generated
PDF committed beside it (each `.tex` header says so, e.g. *"Numbers transcribed from
`tables/mr_t1_phase1.pdf`"*). That makes the two directly comparable.

Every decimal value in each `.tex` was extracted and compared against the same
table's `.pdf`. 25 of the 32 table files have a committed PDF to check against.

**Result: 3 tables in the thesis disagree with the R output** (two found by this
comparison, one found by the supervisor's own cross-reference question). All three
involve the same commit, `57e223f` *"Propagate Japan imputation to all exhibit
tables"* (2026-07-11) — **two tables it missed entirely**, and one it updated but
where a value was mistranscribed.

> **Note on direction.** A `.tex`/`.pdf` mismatch does *not* by itself mean the
> thesis is wrong — for four tables it is the **PDF** that is stale. What matters is
> which side was written last. That is established per table from git history below.

---

## 1. `mr_t1b_maturity` → **Table B.1**, "Phase I by maturity" 🔴

**The thesis is stale here.** Commit `57e223f` regenerated this table's **PDF** but
never updated its **`.tex`**, which was last touched on 2026-06-11 in a commit
labelled *"Add maturity-ladder table (conversion in progress)"*. The Japan-imputation
propagation missed this one table.

**6 of 36 data cells differ**, and they are exactly the cells the Japan imputation
would move — Japan's three rows and the pooled row. The other nine countries are
identical.

| Row | Maturity | Thesis (β, *t*, R²) | R output (β, *t*, R²) |
|---|---|---|---|
| Japan | 2Y | 0.57, (1.97), 0.126 | **0.56, (2.32), 0.173** |
| Japan | 5Y | 1.23, (2.60), 0.167 | **1.23, (3.10), 0.238** |
| Japan | 10Y | 1.20, (3.20), 0.203 | **1.21, (3.81), 0.283** |
| G10 panel | 2Y | 0.78, (14.32), 0.253 | **0.78, (14.33), 0.254** |
| G10 panel | 5Y | 1.16, (17.25), 0.271 | **1.16, (17.26), 0.274** |
| G10 panel | 10Y | 1.06, (15.44), 0.243 | **1.06, (15.56), 0.246** |

Japan's fit rises materially — R² from 0.126 to 0.173 at two years, 0.167 to 0.238 at
five, 0.203 to 0.283 at ten — and its *t*-statistics rise with it. The pooled row
moves only in the last digit.

### Effect on the surrounding prose (`07_results.tex`)

Checked sentence by sentence. **Almost nothing changes**, which is worth knowing
before deciding how much to redo:

| Claim in the text | Still true after the update? |
|---|---|
| *"significantly so in ten of the eleven"* | ✅ Japan's 2Y *t* was already 1.97, above 1.96; it becomes 2.32 |
| *"pooled values of 0.78, 1.16 and 1.06"* | ✅ unchanged |
| *"near 0.6–0.9 at two years"* | ✅ Japan 0.57 → 0.56, still rounds into the stated range |
| *"1.1–1.3 at five"* | ✅ unchanged |
| *"1.0–1.2 at ten"* | ⚠️ Japan 1.20 → **1.21**, so the upper bound becomes 1.22 (Canada is 0.99 at the bottom). Consider *"1.0–1.2"* → *"about 1.0 to 1.2"* |
| *"reaching 35% at ten years for the United States and 36% at five years for the Netherlands"* | ✅ US 10Y 0.347, NL 5Y 0.358, neither is a Japan cell |

---

## 2. `mr_t2_phase2` → **Table 5**, "Phase II: global versus local" ⚠️

Here **both sides were touched by the same commit**, so this is not staleness — it
looks like a transcription slip. **2 of 77 data cells differ**, both in Switzerland's
row:

| Row | Column | Thesis | R output |
|---|---|---|---|
| Switzerland | Wald *p* | 0.012 | **0.010** |
| Switzerland | *p* (BH) | 0.012 | **0.010** |

Every other cell in the table matches exactly. Neither value changes a significance
statement — both are below 0.05 — but the printed number is wrong.

---

## 3. `rob_t7_fxgcf_construction` → **Table 20**, "The dollar-return factor under alternative constructions" 🔴

**Found by the supervisor, not by the PDF comparison.** Her annotation on page 61
asks *"0.81 — is this consistent with Table 6.5?"*. It is not.

| Cell | Table (`.tex`) | Everywhere else in the thesis |
|---|---|---|
| Bottom-up baseline, `Corr(·, GCF)` | **0.78** | **0.81** |
| Bottom-up baseline, pooled `R²_oos` | **+0.019** | **0.021** (Table 4) |

**Same root cause, third table.** Commit `57e223f` states in its own message that the
Japan imputation moved `cor(GCF,FXGCF)` **from 0.78 to 0.81** — and
`rob_t7_fxgcf_construction` is **not in the list of tables that commit updated**, nor
was it touched by it. It still carries the pre-imputation values. Its mean in-sample
R² (0.143) and its OOS+ count (6/11) do match Table 4, so only the two cells above
are stale.

⚠️ **This table has no committed PDF**, so the comparison in §1 could not have caught
it. It is exactly the blind spot flagged at the end of this document, and it is now a
demonstrated one rather than a hypothetical: **two of the three stale tables were
missed by the same commit, and one of them was invisible to the automated check.**
That strengthens the case for re-running the pipeline over transcribing from the
committed PDFs.

---

## 4. Checked and cleared — no action needed

**Four tables where the PDF is the stale side.** Their `.tex` was updated by
`57e223f` while their `.pdf` has not been regenerated since 2026-06-08
(*"Lag all inflation (core + headline) by one month for real-time correctness"*).
The thesis is current; the committed PDF is the old artefact.

- `dh_t3_cp_corr` · `dh_t4_fb_cp` · `dh_t6_local_global` · `dh_t7_usd`

**Seven tables that match exactly**, cell for cell:

- `dh_t1_corr10y` · `dh_t1_summary` · `mr_t4_oos` · `rob_t1_sub_is`
- `rob_t5_core_vs_reg` · `rob_t6_core_vs_reg_oos` · `strat_t2_usd`

**Two tables that differ but are never included in the thesis** (see X-3), so they
have no effect on the document:

- `rob_t3_italy` · `strat_t3_example`

**Nine tables with no committed PDF to check against**, so they could not be verified
this way. One of them, `rob_t7_fxgcf_construction`, **turned out to be stale** (§3),
which is why the remaining eight matter:

- `cp_t1` · `dh_t1b_inputs` · `fxd_t1_properties` · `mr_t2b_gcf_corr`
- `mr_t2c_fx_cycle` · `rob_t8_vm_sens` · ~~`rob_t7_fxgcf_construction`~~ **(stale, §3)**
- `strat_t4_subperiod` · `strat_t5_costs`

---

## The decision you need to make

**For `mr_t1b_maturity`** — two options:

1. **Re-run the pipeline** and transcribe fresh. Safest, and it would also confirm
   that nothing else drifted since June. The committed PDF is over a month old.
2. **Transcribe from the committed PDF**, which is the output `57e223f` intended to
   propagate. Cheap, and I can do it in one edit — it is six cells.

**For `mr_t2_phase2`** — the fix is two cells, 0.012 → 0.010, unless you believe the
`.tex` and the PDF disagrees for a reason.

**Worth considering either way:** the same commit was supposed to propagate the Japan
imputation to *all* exhibit tables and demonstrably missed **two**, one of which
(`rob_t7`) has **no committed PDF** and so was invisible to this check — it surfaced
only because the supervisor happened to cross-reference a number. The remaining eight
tables with no committed PDF cannot be checked by either route. **Re-running the
pipeline is the only way to rule that out**, and the evidence now says the risk is
real rather than theoretical.

**Third fix needed:** `rob_t7_fxgcf_construction`, two cells, 0.78 → 0.81 and
+0.019 → 0.021, subject to the same re-run-or-transcribe decision.

I have deliberately **not** changed any reported number. That is a call about your
results, not a copy-edit.
