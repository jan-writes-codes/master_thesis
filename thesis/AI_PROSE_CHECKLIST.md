# AI-Prose Editing Checklist — Master's Thesis

Prioritized worklist of stylistic patterns that read as AI-generated. Work top-down: Tier 4 and Item 1 are fastest wins; Tiers 1–2 carry the most detection risk. Goal is reducing **density and regularity**, not zero instances.

---

## Tier 1 — Structural patterns (highest risk, pervasive)

### 1. Verbatim phrase recycling across chapters
Reword all but one instance of each:
- "namely the yield decomposition, the three-factor hierarchy, the excess-return definitions, and the predictive specifications" — Ch. 1, Ch. 2 opening, Ch. 3 opening
- "erodes roughly two-thirds" — Abstract, Ch. 1, §4.3, §4.5, §7.3, Ch. 8
- "provided one aggregates across markets, measures the inflation anchor cleanly, and does not require the factor to forecast exchange rates" — Ch. 8 vs. near-identical sentence closing §7.1
- "the worst bond-market episode in the sample" — §5.3, Table 5.2 note, §6.2
- "fitted on the very/same sample over which they are (then) evaluated" — Ch. 1, §4.4, §3.7
- "not a US idiosyncrasy" — §2.3, Ch. 8; also "not a US-specific phenomenon" (§4.1)

### 2. Enumerative meta-sentences ("Two X deserve comment")
Keep one or two, integrate the rest:
- "Four of our construction steps deserve a note" (§3.3)
- "Two design choices deserve comment" (§3.10)
- "Two readings of the three exceptions..." (§4.2)
- "Two observations help us interpret the result" (§5.5)
- "Two patterns stand out" (§6.5)
- "Two qualifications separate the cycle family..." (§7.1)
- "Three features distinguish our evidence" (Ch. 1)
- "two properties make this construction attractive" (§2.3)
- "Two features of the CP factor are important" (§2.2)

### 3. "Not X but Y" antithesis overuse (~12 instances)
- "not a uniform edge but a defensive one" (§5.4)
- "not the artefact of a single benign regime" (§6.2)
- "not a contradiction of Phase III but a reflection of" (§5.5)
- "a proof of concept rather than a tradable system" (§5.6)
- "not a mechanical re-run" (App. B)
- "generated in a small number of episodes rather than accrued steadily" (§5.4)
- "earned mainly in the 2008 repricing, not accrued steadily" (§6.2 — "accrued steadily" recycled)
- "compensation for global rather than local risk"
- "It answers whether premia vary but not why they do" (§2.2)

### 4. Cleft / reflexive emphasis constructions
- "It is this mechanism-based character that leads to..." (§2.3)
- "The cross-country dispersion is itself informative" (§4.1)
- "is thus itself the answer to why" (§7.1)
- "is therefore a part of the question itself" (Ch. 1)
- "This is precisely the empirical regularity that motivates..." (§3.4)
- "This is precisely the behaviour we would expect" (§5.3)
- "It is what gives the global factor its real-time stability" (§6.3)

### 5. Anthropomorphized finance verbs
- "the currency component has little left to say..." (§4.3)
- "gives currency returns something predictable to say" (§7.1)
- "the two dollar signals part ways" (§5.5)
- "the FX adjustment does distinct work" (§4.3)
- "It is close to its mirror image" (§6.2)
- "rewards the patient accumulation of a long macro history" (§6.1)
- "lives in local-currency space" (Ch. 8) / "lives in the cross-section" (§6.5)
- "carries" used 10+ times (currency leg / distinct information / economic value / carry-relevant information)

---

## Tier 2 — High-frequency stylistic tells

### 6. "Precisely / exactly" intensifiers (~10 instances)
§4.1, §6.3, §6.4, §4.3 ("Figure 4.6 shows exactly this pattern"), §5.4 ("reverses exactly where an investor needs it to"), §6.2, §6.3. Cut most.

### 7. Hollow verdict one-liners
- "The magnitude of this predictability is considerable" (§4.1)
- "The wedge is considerable" (§4.3)
- "The results of this split are revealing" (§5.4)
- "Figure 5.2 demonstrates this well" (§5.3)
- "We consider the exceptions as informative as the rule" (§7.1)
- "Integration is therefore the rule" (Ch. 1)

Either justify or delete.

### 8. "We read this as..." formula
§6.1 (×2), §6.2, §5.6, plus "should be read accordingly" (§7.2), "should therefore be read down each column" (§4.4).

### 9. Conditional hedging "We would suggest / advise"
§7.1 (×2), §7.3 (×2), Ch. 8. Replace with direct claims.

### 10. Sentence-initial connective density
"However," ~25×; "Furthermore," ~10×; "Moreover," ~5×; "Therefore/We therefore" constant. Vary or embed mid-sentence.

### 11. Duplicated chapter-opening content in Ch. 2
First and second paragraphs say the same thing twice ("moving from the US evidence to the international setting/gap"). "Our thesis sits at the intersection of three strands" is a stock LLM opener.

### 12. Adjective clusters
- "economically + adj.": meaningful, exploitable, intelligible, coherent, large (§4.1, §4.4, §5, §6.1, §6.4)
- "clean/cleanly": generalizes cleanly, measures cleanly, clean comparison, clean excess return, converge less cleanly
- "sharpen/sharper/sharpest": Ch. 1, §7.1, §4.3, §6.3, §6.2, §7.2

### 13. "Discipline" as noun of virtue
"out-of-sample discipline" (Ch. 1 ×2, §2.5).

---

## Tier 3 — Localized flourishes to rewrite

14. "At the base sits... One level up... At the top" spatial-hierarchy tour (Ch. 1)
15. "two views of the same X" trope — §4.3 and §2.3
16. "a reader is entitled to ask..." (§6.1)
17. "Not only whether... but when... and why." fragment (§4.3)
18. "Our answer to the main question is affirmative" (Ch. 8); "answer the first research question affirmatively" (§4.1)
19. Dramatic verb register: swamps, panic-driven repricing, erodes, destroys, collapses, breaks (§6.2, §5.5, throughout) — thin out
20. Flat meta-narration: "We keep this exercise self-contained" (§5), "In this section, we cover the implementation" (§5.2), "The evidence so far is in-sample" (§4.4)
21. "seems hard to reconcile" — incomplete comparative, reads truncated (§7.1)
22. "Taken together... coherent picture" summary opener (§4.5, App. B)
23. "signature of a single return-forecasting factor" — verbatim in §2.2 and §4.1

---

## Tier 4 — Mechanical seams (fix regardless)

24. §3 opening: "We then develop the , namely..." — **missing word**
25. §4.1: "the fitted combination how Cieslak and Povala (2015) do it" — **garbled syntax**
26. App. B intro: "agreement on signs, magnitudes." — **truncated list**
27. Two broken "??" LaTeX cross-references in §B.1
28. Ch. 1 / §3.7: Section 3.12 cited twice for two different things
29. Newey–West lag inconsistency: Table 4.1 note says 12-month overlap vs. 18 lags in §3.12/§4 text; App. B uses 18 (CP) and 12 (DH) — verify main tables

---

## Suggested workflow

1. Fix Tier 4 + Item 1 (objective, fast).
2. Ctrl+F pass per pattern: "deserve", "precisely", "exactly", "We read", "carries", "Taken together", "However,".
3. Aim to break repetition density, not eliminate every instance — occasional use is normal human academic style.
4. Your AI-use declaration covers language editing, so some residue is defensible; the goal is a consistent single authorial voice.
