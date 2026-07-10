# Sourcing To-Do — literature search (WU catalogue)

Working list for finding/verifying sources to strengthen the thesis. Ties
together the review items **G-1** (every claim needs a source), **G-3** (WU-library
availability), **G-17** (attribution), and the scattered **VERIFY** items in
`REVIEW_EDITS.md`.

**Catalogue:** WU Primo — <https://katalog.wu.ac.at/primo-explore/search?vid=WUW&tab=wuw_nur_pc&search_scope=Artikel&lang=en_US>
(scope = *Artikel*). Search by **author surname + phrase in quotes**, e.g.
`Cochrane Piazzesi "bond risk premia"`. If no full text, try the
Peer-reviewed/Available-online filters or the NBER/SSRN working-paper version.

**How to hand results back:** paste the citation (or PDF) under the relevant item,
or just tell me. I'll slot each into the right sentence in `REVIEW_EDITS.md`,
resolve the VERIFY items, and add the `.bib` entries so it folds into the "go" pass.

---

## A. Claims that currently need a citation (highest priority)

- [ ] **A-1 · UIP failure / carry** *(R-108, R-178 — "Source ???")*
  The sentence "the classic source of that predictability is the cross-country
  interest-rate differential through the failure of uncovered interest parity"
  (§Phase III dynamics and the discussion) is **uncited**. `fama1984` is **missing
  from `references.bib`.**
  → Search: `Fama "forward and spot exchange rates"` · `forward premium puzzle` ·
  `uncovered interest parity failure`. Also carry: `Lustig Roussanov Verdelhan carry` ·
  `Menkhoff carry volatility`.
- [ ] **A-2 · Bond–currency at long horizons** (supports the FX-adjustment framing)
  → `Lustig Stathopoulos Verdelhan` (long-horizon currency/bond) ·
  `term premium exchange rate`.
- [ ] **A-3 · "hidden factor" / unspanned macro risk** (§2.1.1, the Duffee material)
  optional reinforcement → `Duffee "information in the yield curve"` ·
  `Joslin Priebsch Singleton unspanned macro` · `Cochrane "dog that did not bark"`.

## B. Existing citations to VERIFY against the source

- [ ] **B-1 · Zhu (2015)** *(R-048/R-049)* — you cite it for "global CP factor
  predicts **out of sample** where local predictors fail." **Tension:** your own
  §CF-vs-CP result *reverses* this for the forward factor (global forward
  R²_oos = −0.01). Confirm Zhu's exact OOS claim, factor, sample and window, so the
  "mirror this finding" sentence is precise (you mirror the *pattern* with the
  **cycle** family, not Zhu's forward result).
  → `Zhu global bond risk premia out-of-sample`.
- [ ] **B-2 · Zhang et al. (2021)** *(R-020)* — confirm it is **reduced-form**
  (trend-augmented predictive regressions), how the "estimated real-rate trend" is
  built, and the four markets (Canada, Germany, Japan, UK).
  → `Zhang trend inflation international bond return predictability`.
- [ ] **B-3 · Randl et al. (2025)** *(R-177)* — verify: market price of hedged
  international bond risk "peaks in the financial crisis, the 2010–2012 euro-area
  crisis, and the 2022 inflation shock," related to trend inflation and (post-2008)
  cross-market inflation dispersion; and the "German Bunds + AUS/NZ/NOR" universe
  (discussion R-182). → `Randl international government bonds` / the paper directly.
- [ ] **B-4 · Dahlquist–Hasseltoft Table 4, Japan** *(R-206)* — confirm the "R² up
  to 69% in Japan … that they note as well" against `tables/dh_t4_fb_cp` **and** the
  DH (2013) paper.
- [ ] **B-5 · Campbell–Thompson attribution** *(G-17)* — confirm the phrasing that
  they *popularised* (not *invented*) the out-of-sample R². Optional: an earlier
  OOS-evaluation cite (Diebold–Mariano; Goyal–Welch) if you want to hedge.

## C. WU-library availability of already-cited papers (G-3)

Confirm each is accessible via WU (you flagged this). Tick if available:
- [ ] `randl2025`  · [ ] `zhu2015`  · [ ] `zhang2022`  · [ ] `weiwright2013`
- [ ] `hodrick1992`  · [ ] `politis1994`  · [ ] `lustig2019`  · [ ] `campbellviceira2010`
- [ ] rest of `references.bib` (spot-check the less common ones)

*(Note: `welch2008` and `thornton2012` are used only in the paragraph being deleted
per Q-1 — they'll be dropped from the `.bib` unless you re-cite them, so no need to
check those unless you keep that paragraph.)*

## D. Keyword clusters for broader strengthening (by chapter)

**EH rejection (Ch. 2):** `Fama Bliss forward rates` · `Campbell Shiller yield
spread` · `Cochrane Piazzesi bond risk premia` · `expectations hypothesis term
structure rejection`.

**Macro-anchored / trend inflation:** `Cieslak Povala expected returns bonds` ·
`Kozicki Tinsley shifting endpoint` · `Bauer Rudebusch falling stars` ·
`trend inflation term structure`.

**Unspanned macro risk:** `Ludvigson Ng macro factors bond` · `Duffee hidden yield
curve` · `Joslin Priebsch Singleton unspanned macro`.

**International / global bond premia (Ch. 2, Ch. 6):** `Dahlquist Hasseltoft
international bond risk premia` · `Ilmanen international bond returns` ·
`global bond return predictability` · `international term premia common factor`.

**Currency / FX:** `Fama forward spot exchange rates` · `Lustig Roussanov Verdelhan
carry` · `Menkhoff carry volatility` · `Lustig Stathopoulos Verdelhan bond`.

**Out-of-sample & small-sample econometrics (Ch. 4/6):** `Welch Goyal equity
premium out of sample` · `Campbell Thompson predictability` · `Stambaugh predictive
regression bias` · `Bauer Hamilton spanning small sample` · `Newey West HAC
overlapping returns` · `Hodrick overlapping returns`.

## E. `.bib` entries to add (once sources found)

- [ ] `fama1984` — Fama (1984), *Forward and spot exchange rates*, JME. **(needed
  now; missing)**
- [ ] any new carry/UIP/long-horizon-FX references from A-1/A-2.
- [ ] anything from D you decide to cite.

---

*Everything else (the text edits, the R exhibits) is tracked in
`REVIEW_EDITS.md`. This file is only the literature-search task.*
