# Flags for author — decisions I made where the playbook was ambiguous

These are edits where two remarks conflicted, or where a change needed a
judgment call. I picked the reading that loses the least information; please
confirm or overrule.

## F-1 · `02_literature.tex` — Randl passage (R-052 vs R-053)
- **R-052** said only reword the opener ("On the asset-class side," → "From
  an asset-pricing perspective,").
- **R-053** said REMOVE the whole Randl passage ("On the asset-class
  side … the question we pose in this thesis"), with the note "(clarify
  unconditional vs conditional)".
- **Conflict:** R-052 gives a specific replacement opener, which would be
  pointless if the passage were deleted. Randl is also load-bearing for the
  gap argument in the literature review.
- **What I did:** kept the passage, applied R-052's opener, softened
  "fundamentally distinct" → "distinct" (consistent with R-021/R-176), and
  clarified the *unconditional* vs *conditional* distinction (R-053's note).
- **Decide:** keep as clarified (current), or delete the passage entirely.

## F-2 · `04_data.tex` — Core CPI source (R-077/R-078)
- You said the core-CPI data is from **FRED, not LSEG Refinitiv**. I changed
  the provider label to FRED and "seasonally relevant" → "seasonally
  adjusted".
- The old example ticker `aUSCCORF/C` is a Datastream/Refinitiv mnemonic, so
  it can't be right if the source is FRED. I replaced it with **`CPILFESL`**
  (FRED's US core-CPI, all items less food & energy, seasonally adjusted).
- **Confirm:** (a) FRED is the source for *all eleven* countries' core CPI
  (the GDP and yield items still read Bloomberg/LSEG — I left those); (b)
  `CPILFESL` is the actual US series you used; (c) the series really are
  seasonally adjusted (if NSA, drop the word).

## Deferred (needs R / author input, not yet applied)
- **R-081** — you want summary stats for the *other* inputs (inflation, FX,
  GDP), possibly in the appendix. Needs a new R table; not yet built.
