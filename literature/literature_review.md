# Literature Review — Expected Returns in International Government Bond Markets

*An independent, multi-source literature review compiled for the master's thesis
"Expected Returns in International Government Bond Markets" (J. Heissenberger).*

**Scope.** The thesis takes the Cieslak–Povala (2015) macro-anchored trend-inflation
*cycle factor* for predicting US Treasury excess returns, extends it to the G10,
builds a GDP-weighted **global cycle factor (GCF)**, and introduces a novel
**FX-adjusted global cycle factor (FXGCF)** for an unhedged US-dollar investor. It
relies on Dahlquist–Hasseltoft (2013) for international integration and
Cochrane–Piazzesi (2005) for the forward-rate factor. This review maps the six
literatures the thesis sits inside and positions its contribution.

**How this review was produced.** Five parallel web-search agents covered (1) US
predictability, (2) macro/trend-inflation yield drivers, (3) international/global
integration, (4) currency risk/carry/hedging, (5) the out-of-sample/spanning
debate and predictive-regression econometrics. Findings were cross-checked across
independent aggregators (journal pages, NBER, SSRN, RePEc, author pages) and, for
the central papers (Cieslak–Povala 2015, Dahlquist–Hasseltoft 2013,
Cochrane–Piazzesi 2005, Zhang et al. 2021), against the primary PDFs in the repo's
`literature/` folder and the thesis's own replication.

**Reliability flag.** Citation details (authors, year, title, journal, volume,
pages) are corroborated across multiple sources and are reliable. Several *exact
numerical magnitudes* (per-maturity R², OOS R², Sharpe ratios) were drawn from
abstracts/secondary summaries because publisher full texts were not directly
retrievable; these are marked **[verify in primary PDF]**. Where a figure is
confirmed from a primary source in the repo, it is marked **[confirmed]**.

---

## Table of contents
1. [Bond return predictability and the rejection of the expectations hypothesis (US)](#1)
2. [Macro and trend-inflation drivers of the yield curve](#2)
3. [International and global bond risk premia and market integration](#3)
4. [Currency risk, UIP, carry, and hedged vs. unhedged international bonds](#4)
5. [Out-of-sample predictability and the spanning hypothesis](#5)
6. [Econometrics of predictive regressions](#6)
7. [Synthesis: how the strands connect](#7)
8. [Where this thesis sits — contribution positioning](#8)
9. [Open debates and research gaps the thesis touches](#9)
10. [Annotated references with links](#10)

---

<a name="1"></a>
## 1. Bond return predictability and the rejection of the expectations hypothesis (US)

The expectations hypothesis (EH) holds that long yields are the average of expected
future short rates plus a constant term premium, so excess bond returns should be
unforecastable. The US Treasury literature decisively rejects this and documents a
large, time-varying, countercyclical term/risk premium. The strand runs from
single-spread regressions to a single forward-rate factor to macro-augmented and
trend-inflation factors, and then into the "unspanned/hidden risk" debate.

- **Fama & Bliss (1987)**, *AER* 77(4), 680–692 — "The Information in Long-Maturity
  Forward Rates." The forward–spot spread predicts the one-year excess return on
  the matched-maturity bond; R² ≈ 15% **[verify in primary PDF]**. Founding
  rejection of the EH; introduced the CRSP/Fama–Bliss zero-coupon data that became
  the field standard.

- **Campbell & Shiller (1991)**, *REStud* 58(3), 495–514 — "Yield Spreads and
  Interest Rate Movements." The "Campbell–Shiller regressions" produce slope
  coefficients that are significantly *negative* (and more so with maturity) versus
  the EH benchmark of +1: when the spread is high, long yields tend to *fall*. The
  cleanest statement of the EH-rejection puzzle.

- **Cochrane & Piazzesi (2005)**, *AER* 95(1), 138–160 — "Bond Risk Premia." A
  *single* "tent-shaped" linear combination of forward rates (the **CP factor**)
  predicts one-year excess returns across 2–5y maturities with **R² ≈ 0.35–0.44**
  [confirmed: corroborated and matched in the thesis's own replication]. The factor
  is countercyclical, forecasts stock returns too, and is largely **orthogonal to
  level/slope/curvature** — the seed of the "unspanned" debate. *This is the
  forward-rate factor the thesis replicates (Ch. 6) and races against the cycle
  factor (Ch. 8).*

- **Ludvigson & Ng (2009)**, *RFS* 22(12), 5027–5067 — "Macro Factors in Bond Risk
  Premia." Factors from a large macro panel ("real activity," "inflation") forecast
  excess returns *beyond* forwards/yields and are countercyclical — the empirical
  origin of **unspanned macro risk**. Augmented R² often cited ≈ 0.45–0.55
  **[verify in primary PDF]**.

- **Duffee (2011)**, *RFS* 24(9), 2895–2934 — "Information in (and not in) the Term
  Structure." ~Half of risk-premium variation is **"hidden"**: a factor whose effect
  on expected short rates is offset by an opposite effect on premia, leaving the
  current curve nearly unchanged, yet which forecasts returns. The affine-model
  counterpart to Ludvigson–Ng.

- **Cieslak & Povala (2015)**, *RFS* 28(10), 2859–2901 — "Expected Returns in
  Treasury Bonds." **The thesis's backbone.** Decompose yields into a trend-inflation
  expectation and maturity-specific **cycles** (the part of yields orthogonal to
  trend inflation); a single **cycle factor (cf)** forecasts one-year excess returns
  in and out of sample and **subsumes the CP factor**. Reported in-sample predictive
  R² rises above 50% at long maturities over 1971–2009 **[verify in primary PDF;
  thesis replication on a shorter 1990–2014 US sample finds US R² ≈ 0.33 and
  corr(cf, average cycle) ≈ 0.69 vs. CP's reported 0.61 — confirmed in repo]**.

- **Supply/demand and decompositions.** **Greenwood & Vayanos** ("Bond Supply and
  Excess Bond Returns," NBER WP 13806 / *RFS* 2014): relative supply of long bonds
  predicts long-bond excess returns even after the term spread and CP factor — a
  *preferred-habitat* (quantity) source of premia, grounded in **Vayanos & Vila**'s
  preferred-habitat model. **Cochrane & Piazzesi (2008)** "Decomposing the Yield
  Curve" embeds the return-forecasting factor in an affine model.

- **Surveys.** **Duffee (2013)**, "Bond Pricing and the Macroeconomy," *Handbook of
  the Economics of Finance* 2B, ch. 13; **Gürkaynak & Wright (2012)**,
  "Macroeconomics and the Term Structure," *JEL* 50(2), 331–367.

**Central themes.** (i) The EH fails; premia move over time and countercyclically.
(ii) Predictive R² rises from ~15% (one spread) to ~35–44% (one forward factor) to
>50% (the cycle factor). (iii) A live dispute over the *state vector*: one
forward factor (CP) vs. macro factors (LN) vs. a single trend-inflation cycle (CP15)
vs. hidden/unspanned components (Duffee). The thesis adopts the CP15 cycle view.

---

<a name="2"></a>
## 2. Macro and trend-inflation drivers of the yield curve (trend–cycle decomposition)

The unifying idea: nominal yields = a slow **trend** anchored by long-run macro
fundamentals — trend inflation (π\*) and the equilibrium real rate (r\*) — plus a
transitory **cycle**. The trend dominates the *level* and low-frequency drift; the
cycle carries the *return-relevant* business-cycle information. Detrending by trend
inflation isolates the predictive component and tames the near-unit-root persistence
of yields.

- **Cieslak & Povala (2015)** — trend inflation construction. The trend τ is a
  **discounted (exponentially weighted) moving average of past core CPI inflation**.
  Parameters **[confirmed from thesis code and Zhang et al. (2021) fn. 2]**: monthly
  decay **v ≈ 0.987**, window **M = 120 months (10 years)**, applied to year-on-year
  **core** CPI (ex food & energy). Core is used to strip transitory food/energy noise
  and isolate the persistent anchor. The construction descends from Kozicki–Tinsley's
  finding that discounting past inflation closely tracks survey long-run expectations.

- **Rebonato (2015/2022)** — "Why Does the Cieslak–Povala Model Predict Treasury
  Returns? A Reinterpretation" (*J. Fixed Income* 2022; SSRN 2015). Reformulates the
  cf with identical explanatory power but clearer economics: what predicts returns is
  the **distance of the level/slope from a conditional reference set by trend
  inflation** — the *unconditional* level barely predicts, the *conditional*
  deviation does. Reinforces the thesis's "detrend-by-trend-inflation" logic.

- **Bauer & Rudebusch (2020)**, *AER* 110(5), 1316–1354 — "Interest Rates Under
  Falling Stars." The structural, arbitrage-free counterpart to CP15. A **shifting-
  endpoint** dynamic term-structure model ties the risk-neutral long-run mean of the
  short rate to **i\* = π\* + r\***. Accounting for the moving trend raises measured
  return predictability, yields more plausible term premia and better OOS yield
  forecasts, and resolves the spurious near-unit-root persistence; the post-1980s
  yield decline is attributed largely to **falling stars** rather than the term
  premium. **[exact R²/term-premium magnitudes: verify in primary PDF]**

- **The shifting-endpoints lineage.** **Kozicki & Tinsley (2001)**, *JME* 47(3) —
  long-rate forecasts are dominated by the time-varying "endpoint"; moving endpoints
  tied to perceived inflation targets fix the curve fit (intellectual origin of
  π\*-anchored long yields). **Fama (2006)**, *RFS* 19(2) — forwards predict spot
  rates via **mean reversion to a time-varying (permanently shifting) level**, not a
  constant mean. **van Dijk, Koopman, van der Wel & Wright (2014)**, *JAE* 29(5) —
  modeling yields as stationary around a slow endpoint; **survey- and inflation-based
  endpoints give the best OOS yield forecasts**, beating random walk and constant mean.

- **r\*/π\* estimation and its real-time critique.** **Holston, Laubach & Williams
  (2017, upd. 2023)**, *JIE* 108(S1) — the workhorse semi-structural Kalman-filter r\*
  estimates (real-time one-sided vs. smoothed two-sided), extended to many economies.
  **Beyer & Wieland (2019)** — r\* estimates are **imprecise and heavily revised**
  (two-sided 68% bands ≈ ±2.3 pp), a *real-time observability* caution for any
  trend-based predictability claim.

- **Macro-finance models linking inflation to the level factor.** **Rudebusch & Wu
  (2008)**, *Economic Journal* 118(530) — in a no-arbitrage + macro model the **level
  factor ≈ the perceived inflation target (π\*)** and the slope ≈ policy stance; the
  structural basis for detrending by trend inflation. **Joslin, Priebsch & Singleton
  (2014)**, *JF* 69(3) — output and inflation are *unspanned* by yields yet drive the
  prices of level/slope/curvature risk (the model behind "macro matters beyond yields").

- **International extension.** **Zhang, Zhu & Zhu (2021)**, *Finance Research Letters*
  42, 101916 **[citation confirmed from repo PDF]** — "Global bond risk premia under
  falling stars." Uses the **same DMA trend** (v = 0.987, N = 120) plus an EWMA r\*
  (α = 0.98) for **CA, DE, JP, UK**; adding both trends to canonical excess-return
  regressions yields notable OOS gains. *The closest predecessor to this thesis* —
  but it adds raw trends to yield PCs rather than using the cycle factor, covers 4
  markets (not the G10), and builds no global or FX-adjusted factor.

**Why this matters for the thesis.** This strand justifies the core construction:
detrending yields by a discounted core-CPI trend isolates a mean-reverting cycle
that concentrates risk-premium variation. The unresolved real-time observability of
the trend (Beyer–Wieland) is exactly why the thesis's *recursive out-of-sample*
evaluation and its core-vs-headline-CPI robustness matter.

---

<a name="3"></a>
## 3. International and global bond risk premia and market integration

Do national bond premia share a common, predictable global component, and does a
global factor subsume local ones (integration)?

- **Ilmanen (1995)**, *JF* 50(2), 481–506 — international long-bond excess returns are
  predictable with a few **global instruments**, and expected returns are **highly
  correlated across countries** (≈4–12% of monthly variation). The founding stylized
  facts of predictability + comovement.

- **Dahlquist & Hasseltoft (2013)**, *J. International Economics* 90(1), 17–32 —
  **the thesis's international backbone.** A **GDP-weighted global Cochrane–Piazzesi
  factor** predicts bond returns in each country and **largely subsumes the local CP
  factors**; the global factor is tied to **US bond risk premia and the international
  business cycle**. They construct a **currency/FX-adjusted global factor for a USD
  investor**, distinguishing local-currency from USD-converted excess returns, and
  embed everything in a one-local + one-global affine model. Original sample ≈
  Germany, Switzerland, UK, US, 1975–2009. **[exact R²: verify in primary PDF; thesis
  replicates the Table 3/4/6/7 patterns]**

- **Zhu (2015)**, *JIMF* 51, 155–173 — "Out-of-sample bond risk premium predictions:
  A global common factor." The GDP-weighted **global CP factor predicts OOS** and
  beats the historical mean economically across developed markets — the OOS extension
  of DH and a direct counterpoint to OOS skeptics. *Closely parallels the thesis's
  OOS finding that the global factor (not the local) survives real time.*

- **Zhang, Zhu & Zhu (2021)** — see §2; the macro-trend (falling-stars) international
  extension.

- **Wright (2011)**, *AER* 101(4), 1514–1534 — international term premia declined,
  especially where monetary reform cut **inflation uncertainty**; ~10 countries,
  affine + survey decompositions. (Comment: **Bauer, Rudebusch & Wu 2014** on
  small-sample bias in affine term-premium estimates; Wright 2014 reply.)

- **Common global yield factors (the integration backbone).** **Diebold, Li & Yue
  (2008)**, *J. Econometrics* 146(2) — hierarchical dynamic Nelson–Siegel: a **global
  level and global slope** drive much cross-country yield comovement (DE, JP, UK, US,
  1985–2005), with a residual country role. **Venetis & Ladas (2022, MPRA)** — three
  global factors across 11 countries, the global curvature tied to US-linked systemic
  risk; US–Germany the best anchor. **Zhu & Rahman (2009)** — integration is **partial
  and time-varying**, stronger in the level than in slope/curvature.

- **The macro-finance frame for US dominance.** **Miranda-Agrippino & Rey (2020)**,
  *REStud* 87(6) — one **Global Financial Cycle** factor driven by **US monetary
  policy** explains much global risky-asset comovement; rationalizes why the global
  bond factor is "US-centric."

- **The economic-value skeptic.** **Sarno, Schneider & Wagner (2016)**, *J. Empirical
  Finance* 37 — affine models fit yields+returns with high in-sample R² yet **cannot
  beat the EH out-of-sample** in utility terms except in high-uncertainty states.

**Open within this strand.** Degree of integration (dominant global factor vs. partial
segmentation); whether the global factor truly subsumes local ones for *risk premia*
(vs. yields); statistical vs. economic value (Zhu vs. Sarno et al.); the role of the
US; the (largely conventional) GDP-weighting choice; and euro-area peripheral spreads,
where redenomination/default risk diverges from the core — directly relevant to the
thesis's finding of *surviving local Italian predictability in the 2010–12 crisis*.

---

<a name="4"></a>
## 4. Currency risk, UIP, carry, and hedged vs. unhedged international bonds

For a USD investor holding foreign bonds unhedged, the return adds a volatile currency
component. This strand explains why that erodes bond predictability and whether hedging
restores it.

- **UIP failure (foundations).** **Fama (1984)**, *JME* 14(3) — the forward premium
  predicts currency returns with a slope < 1 and often negative (the **forward-premium
  puzzle**), implying a volatile, time-varying currency risk premium. **Hansen &
  Hodrick (1980)**, *JPE* 88(5) — reject forward-rate unbiasedness; introduce the
  overlapping-data GMM "Hansen–Hodrick" standard errors used throughout this field.
  **Engel (1996, 2014)** surveys — risk-premium models struggle to match the anomaly;
  the short-horizon sign can reverse at long horizons (the "new Fama puzzle").

- **Carry as a return source.** **Lustig, Roussanov & Verdelhan (2011)**, *RFS*
  24(11) — two factors price currencies: a **dollar factor (DOL)** and a **carry/slope
  factor (HML-FX)**, the latter loading on global volatility. (The DOL is exactly
  what an unhedged USD investor bears.) **Menkhoff, Sarno, Schmeling & Schrimpf
  (2012)**, *JF* 67(2) — carry returns are compensation for **global FX-volatility
  risk**. **Koijen, Moskowitz, Pedersen & Vrugt (2018)**, *JFE* 127(2) — "Carry"
  generalizes to all assets incl. **global bonds and Treasuries**; carry predicts
  returns and rejects a generalized UIP/EH jointly.

- **Hedged vs. unhedged bonds.** **Campbell, Serfaty-de Medeiros & Viceira (2010)**,
  *JF* 65(1) — "Global Currency Hedging." For a **global bond investor the
  risk-minimizing currency strategy is close to a full hedge** (with a small long
  USD); little reason to tilt on interest differentials for risk reasons. *Directly
  supports the thesis's logic that currency conversion adds mostly uncompensated
  noise to bond predictability and that the hedged (local-currency) premium is the
  cleaner object.* ("Ang & Chen" on hedged/unhedged bonds in the original brief could
  not be matched to a verified paper — treat as unconfirmed.)

- **Joint bond–currency structure.** **Lustig, Stathopoulos & Verdelhan (2019)**,
  *AER* 109(12) — the carry premium **declines with foreign-bond maturity** (foreign
  term premia offset the currency premium), and dollar foreign-bond predictability
  declines with maturity; leading no-arbitrage models cannot match this slope.
  **Brusa, Ramadorai & Verdelhan (WP)** — an "International CAPM Redux": a global
  equity factor + **dollar and carry currency factors** price international returns
  (currency risk is *priced*). **Wiriadinata (WP)** — dollar-denominated external debt
  drives cross-country currency risk premia.

**Tension for the thesis.** Currency exposure is *partly* a compensated premium
(carry/dollar factors) and *partly* uncompensated noise (Campbell et al.). This is
exactly why the thesis's FXGCF — and its finding that the FX adjustment helps only
marginally for the *cycle* factor (vs. DH's forward FXGCP) — is informative.

---

<a name="5"></a>
## 5. Out-of-sample predictability and the spanning hypothesis

- **The OOS critique (equities).** **Goyal & Welch (2008)**, *RFS* 21(4), 1455–1508 —
  most equity-premium predictors fail OOS vs. the prevailing mean. **Campbell &
  Thompson (2008)**, *RFS* 21(4), 1509–1531 — with sensible sign/forecast restrictions
  many predictors *do* beat the mean; introduce the **out-of-sample R²** (forecast MSE
  vs. prevailing-mean MSE) — **the exact statistic this thesis uses** to score the
  recursive factor. Small OOS R² can still be economically meaningful for a
  mean-variance investor.

- **OOS bond predictability.** **Thornton & Valente (2012)**, *RFS* 25(10) (correct
  title: "Out-of-Sample Predictions of Bond Excess Returns and Forward Rates: An Asset
  Allocation Perspective") — forward-rate (CP-type) predictability yields **no
  systematic economic value** to a real-time investor. **Sarno, Schneider & Wagner
  (2016)** — same statistical-vs-economic gap (value only in high-uncertainty states).
  **Gargano, Pettenuzzo & Timmermann (2019)**, *Management Science* 65(2) — the puzzle
  **resolves** once you model stochastic volatility, time-varying parameters, and
  combine FB + CP + LN predictors; then OOS economic value reappears.

- **The spanning hypothesis.** Under affine no-arbitrage, the current yield curve
  spans all return-relevant information, so macro variables should add nothing.
  **Joslin, Priebsch & Singleton (2014)** build *unspanned* macro risks into a
  no-arbitrage model (macro matters beyond yields). **Bauer & Rudebusch (2017)**,
  *Review of Finance* 21(2) — the "spanning puzzle" can arise **mechanically in finite
  samples even under full spanning**. **Bauer & Hamilton (2018)**, *RFS* 31(2),
  399–448 — "Robust Bond Risk Premia": the anti-spanning evidence in **six published
  studies** is **largely a small-sample artifact**; with a **bias-corrected bootstrap
  designed for the spanning test**, the case for predictors beyond level/slope/
  curvature is much weaker. **The central live challenge** to the unspanned-macro
  (and thus the cycle-factor) literature.

---

<a name="6"></a>
## 6. Econometrics of predictive regressions

The inference machinery behind every number above — and the reason the thesis uses
HAC, block-bootstrap, and an EH Monte-Carlo null.

- **Stambaugh (1999)**, *JFE* 54(3) — a **persistent, endogenous** lagged regressor
  biases the OLS predictive slope *upward*, over-rejecting no-predictability ("Stambaugh
  bias"). Yields/spreads are exactly such regressors.

- **Hodrick (1992)**, *RFS* 5(3) — for **overlapping** long-horizon returns, proposes
  the "Hodrick 1992" sum-of-coefficients reformulation that is better-sized than
  Hansen–Hodrick at long horizons; the standard alternative to **Newey–West HAC**
  (the thesis uses 18-lag Newey–West for 12-month overlap).

- **Bekaert, Hodrick & Marshall (1997)**, *JFE* 44(3) — **short-rate persistence**
  induces large small-sample bias/dispersion in Campbell–Shiller EH tests (over-
  rejection); motivates **Monte-Carlo / bootstrap inference under the EH null** —
  precisely the thesis's expectations-hypothesis Monte-Carlo and stationary block
  bootstrap (**Politis & Romano 1994**, the block-bootstrap reference behind the
  thesis's `block_boot` and the CP-Table-4 confidence bands).

- **Generated regressors.** The cycle/cf and trend inflation are *fitted* objects, so
  in-sample R² can overstate real-time content — the explicit motivation for the
  thesis's fully-recursive OOS protocol (Campbell–Thompson R²) and its EH Monte-Carlo
  benchmark.

---

<a name="7"></a>
## 7. Synthesis: how the strands connect

```
            EH REJECTION (Fama-Bliss '87; Campbell-Shiller '91)
                               │
          ┌────────────────────┼─────────────────────────┐
   FORWARD FACTOR        MACRO / TREND FACTORS       UNSPANNED / HIDDEN
   Cochrane-Piazzesi '05  Ludvigson-Ng '09            Duffee '11
   (single tent factor)   Cieslak-Povala '15 (cycle)  Joslin-Priebsch-
                          Bauer-Rudebusch '20 (π*,r*)   Singleton '14
                               │                              │
                               │   ── spanning debate ──> Bauer-Rudebusch '17
                               │                          Bauer-Hamilton '18
                               │                          (small-sample critique)
                INTERNATIONALISATION
        Ilmanen '95 → Dahlquist-Hasseltoft '13 (global CP factor, FX-adjusted)
            → Zhu '15 (OOS) → Zhang-Zhu-Zhu '21 (falling stars, intl.)
                               │
                       CURRENCY OVERLAY
        UIP failure (Fama '84) → carry as risk premium (LRV '11; MSSS '12;
        Koijen et al. '18) → hedge bonds (Campbell-Serfaty-Viceira '10) →
        joint bond-FX premia (Lustig-Stathopoulos-Verdelhan '19)
                               │
                  OOS / ECONOMETRIC SCRUTINY
        Goyal-Welch '08 / Campbell-Thompson '08 (R²_OS) →
        Thornton-Valente '12; Sarno et al. '16 (no economic value) →
        Gargano et al. '19 (value returns with richer dynamics);
        Stambaugh '99, Hodrick '92, Bekaert-Hodrick-Marshall '97 (inference)
```

The recurring fault lines: **(a)** the right *state vector* (one forward factor vs.
macro factors vs. a trend-inflation cycle vs. hidden components); **(b)** *statistical
vs. economic* predictability; **(c)** *spanned vs. unspanned* macro risk — under live
small-sample attack from Bauer–Hamilton; **(d)** *integration vs. partial segmentation*
internationally; **(e)** currency risk as *compensated premium vs. uncompensated noise*.

---

<a name="8"></a>
## 8. Where this thesis sits — contribution positioning

The thesis occupies a specific, largely unfilled cell at the intersection of three
literatures:

| Dimension | Prior work | This thesis |
|---|---|---|
| Predictive object | CP *forward* factor (DH 2013; Zhu 2015); raw macro *trends* added to PCs (Zhang et al. 2021) | The Cieslak–Povala **cycle factor** itself, taken international |
| Country scope | US only (CP15); 4 markets (Zhang); 4 markets (DH) | **G10 (11 markets)** |
| Aggregation | GDP-weighted global *CP* factor (DH; Zhu) | GDP-weighted global **cycle** factor (GCF) |
| Currency | FX-adjusted global *CP* factor (DH 2013) | FX-adjusted global **cycle** factor (FXGCF) for an unhedged USD investor |
| Evaluation | mostly in-sample; some OOS (Zhu) | fully-recursive **doubly-OOS** + crisis subsamples + core-vs-headline CPI |

**Specific positioning.**
- Against **Dahlquist–Hasseltoft (2013)**: the thesis replaces the forward-rate global
  factor with the **macro-anchored cycle** global factor and re-establishes the same
  *integration* result (global subsumes local) — and finds it *sharper out of sample*
  for the cycle factor than for the forward factor.
- Against **Zhang et al. (2021)**: same trend-inflation DMA, but the thesis uses the
  *cycle factor* construction, covers the *full G10*, and adds *global aggregation +
  FX adjustment* — none of which Zhang et al. do.
- A genuinely **novel result** that speaks to the **currency strand**: DH's *forward*
  FX-adjusted factor (FXGCP) recovers dollar-investor predictability, but the thesis's
  *cycle* FX-adjusted factor (FXGCF) is near-collinear with the unadjusted global
  factor (corr ≈ 0.99) in the G10 — so the FX adjustment that helps the forward factor
  adds little to the cycle factor. This is an informative *contrast*, not just an
  extension.
- It takes the **Bauer–Hamilton (2018)** robustness critique seriously by emphasizing
  OOS evaluation, block-bootstrap/HAC inference, an EH Monte-Carlo null, and explicit
  small-sample/subsample stress tests — directly addressing the spanning/small-sample
  scepticism that bears on any macro/cycle predictor.

---

<a name="9"></a>
## 9. Open debates and research gaps the thesis touches

1. **Spanning / small-sample robustness (Bauer–Hamilton 2018).** Does cycle-factor
   predictability survive proper inference? The thesis's OOS + bootstrap + EH-MC design
   is a direct response; its finding that only the *global* cycle factor beats the
   recursive mean OOS is the strongest robustness evidence.
2. **Statistical vs. economic value (Thornton–Valente; Sarno et al.; Gargano et al.).**
   The thesis adds a bond-timing strategy (certainty-equivalent gains, Sharpe) — a
   modest but positive economic-value result for the hedged global investor.
3. **Real-time trend observability (Beyer–Wieland; van Dijk et al.).** The thesis uses
   a real-time backward-looking DMA and lags inflation one month for publication delay;
   its core-vs-headline-CPI robustness shows the OOS edge depends on the *clean* core
   trend — a concrete contribution to the "which trend, measured how" debate.
4. **Integration vs. local content (DH; Zhu–Rahman; euro-area spreads).** The thesis's
   euro-crisis/Italy result (surviving local predictability under sovereign stress)
   speaks to the limits of integration in the peripheral segment.
5. **Currency: compensated vs. uncompensated (Campbell et al. vs. carry literature).**
   The FXGCF≈GCF collinearity and the regime-dependent dollar-investor results add G10
   evidence on when the FX adjustment is worth making.
6. **Aggregation conventions.** GDP-weighting is standard but under-examined;
   alternative weightings (market-cap, equal, PCA) remain an open robustness question.

---

<a name="10"></a>
## 10. Annotated references with links

**US predictability**
- Fama & Bliss (1987), *AER* 77(4):680–692 — https://ideas.repec.org/a/aea/aecrev/v77y1987i4p680-92.html
- Campbell & Shiller (1991), *REStud* 58(3):495–514 — https://academic.oup.com/restud/article-abstract/58/3/495/1593062 · NBER w3153
- Cochrane & Piazzesi (2005), *AER* 95(1):138–160 — https://www.aeaweb.org/articles?id=10.1257%2F0002828053828581 · https://web.stanford.edu/~piazzesi/cp.pdf
- Ludvigson & Ng (2009), *RFS* 22(12):5027–5067 — https://academic.oup.com/rfs/article-abstract/22/12/5027/1577464 · NBER w11703
- Duffee (2011), *RFS* 24(9):2895–2934 — https://academic.oup.com/rfs/article-abstract/24/9/2895/1568322
- Cieslak & Povala (2015), *RFS* 28(10):2859–2901 — https://academic.oup.com/rfs/article-abstract/28/10/2859/1580557 · author: https://pavol.povala.com/publication/2015_journal_cieslak_povala_rfs/
- Greenwood & Vayanos (2014), *RFS* — NBER w13806: https://www.nber.org/system/files/working_papers/w13806/w13806.pdf
- Duffee (2013) Handbook ch.13 — https://ideas.repec.org/h/eee/finchp/2-b-907-967.html
- Gürkaynak & Wright (2012), *JEL* 50(2):331–367 — https://www.aeaweb.org/articles?id=10.1257/jel.50.2.331

**Macro / trend-inflation drivers**
- Rebonato (2015/2022) — https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2626497 · https://jfi.pm-research.com/content/early/2022/02/04/jfi.2022.1.130
- Bauer & Rudebusch (2020), *AER* 110(5):1316–1354 — https://www.aeaweb.org/articles?id=10.1257/aer.20171822 · https://www.frbsf.org/wp-content/uploads/wp2017-16.pdf
- Kozicki & Tinsley (2001), *JME* 47(3):613–652 — https://ideas.repec.org/a/eee/moneco/v47y2001i3p613-652.html
- Fama (2006), *RFS* 19(2):359–379 — https://academic.oup.com/rfs/article-abstract/19/2/359/1642314
- van Dijk, Koopman, van der Wel & Wright (2014), *JAE* 29(5):693–712 — https://onlinelibrary.wiley.com/doi/abs/10.1002/jae.2358 · https://papers.tinbergen.nl/12076.pdf
- Holston, Laubach & Williams (2017, upd. 2023), *JIE* 108(S1) — https://www.newyorkfed.org/research/policy/rstar
- Beyer & Wieland (2019) — https://cepr.org/voxeu/columns/r-star-and-draghi-rules-correctly-measuring-equilibrium-interest-rate-policy-use
- Rudebusch & Wu (2008), *Economic Journal* 118(530):906–926 — https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-0297.2008.02155.x
- Joslin, Priebsch & Singleton (2014), *JF* 69(3):1197–1233 — https://onlinelibrary.wiley.com/doi/abs/10.1111/jofi.12131
- Zhang, Zhu & Zhu (2021), *Finance Research Letters* 42:101916 — https://www.sciencedirect.com/science/article/abs/pii/S154461232031730X

**International / global integration**
- Ilmanen (1995), *JF* 50(2):481–506 — https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1540-6261.1995.tb04792.x
- Dahlquist & Hasseltoft (2013), *J. Int. Econ.* 90(1):17–32 — https://www.sciencedirect.com/science/article/abs/pii/S0022199612002024 · SSRN 1670006
- Zhu (2015), *JIMF* 51:155–173 — https://ideas.repec.org/a/eee/jimfin/v51y2015icp155-173.html
- Wright (2011), *AER* 101(4):1514–1534 — https://www.aeaweb.org/articles?id=10.1257%2Faer.101.4.1514
- Diebold, Li & Yue (2008), *J. Econometrics* 146(2):351–363 — https://www.nber.org/system/files/working_papers/w13588/w13588.pdf
- Venetis & Ladas (2022), MPRA 115801 — https://mpra.ub.uni-muenchen.de/115801/
- Zhu & Rahman (2009), Nanyang EGC WP 0902 — https://ideas.repec.org/p/nan/wpaper/0902.html
- Miranda-Agrippino & Rey (2020), *REStud* 87(6):2754–2776 — https://academic.oup.com/restud/article/87/6/2754/5834728
- Sarno, Schneider & Wagner (2016), *J. Empirical Finance* 37:247–267 — https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2005178

**Currency / carry / hedging**
- Fama (1984), *JME* 14(3):319–338 — https://ideas.repec.org/a/eee/moneco/v14y1984i3p319-338.html
- Hansen & Hodrick (1980), *JPE* 88(5):829–853 — https://www.journals.uchicago.edu/doi/10.1086/260910
- Engel (1996), *J. Empirical Finance* 3(2):123–192 — https://users.ssc.wisc.edu/~cengel/PublishedPapers/RiskPremiumSurvey.pdf ; Engel (2014) Handbook ch.8 — https://users.ssc.wisc.edu/~cengel/PublishedPapers/Handbook.pdf
- Lustig, Roussanov & Verdelhan (2011), *RFS* 24(11):3731–3777 — https://www.nber.org/system/files/working_papers/w14082/w14082.pdf
- Menkhoff, Sarno, Schmeling & Schrimpf (2012), *JF* 67(2):681–718 — https://www.jstor.org/stable/41419708
- Koijen, Moskowitz, Pedersen & Vrugt (2018), *JFE* 127(2):197–225 — https://ideas.repec.org/a/eee/jfinec/v127y2018i2p197-225.html
- Campbell, Serfaty-de Medeiros & Viceira (2010), *JF* 65(1):87–121 — https://scholar.harvard.edu/files/lviceira/files/global_currency_hedging.pdf
- Lustig, Stathopoulos & Verdelhan (2019), *AER* 109(12):4142–4177 — https://www.aeaweb.org/articles?id=10.1257/aer.20180098
- Brusa, Ramadorai & Verdelhan, "International CAPM Redux" — https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2520475

**OOS / spanning / econometrics**
- Welch & Goyal (2008), *RFS* 21(4):1455–1508 — https://academic.oup.com/rfs/article-abstract/21/4/1455/1565737
- Campbell & Thompson (2008), *RFS* 21(4):1509–1531 — https://dash.harvard.edu/bitstreams/7312037c-4c39-6bd4-e053-0100007fdf3b/download
- Thornton & Valente (2012), *RFS* 25(10):3141–3168 — https://academic.oup.com/rfs/article-abstract/25/10/3141/1573606
- Gargano, Pettenuzzo & Timmermann (2019), *Management Science* 65(2):508–540 — https://pubsonline.informs.org/doi/10.1287/mnsc.2017.2829
- Bauer & Rudebusch (2017), *Review of Finance* 21(2):511–553 — https://www.frbsf.org/wp-content/uploads/wp2015-01.pdf
- Bauer & Hamilton (2018), *RFS* 31(2):399–448 — https://www.nber.org/papers/w23480
- Stambaugh (1999), *JFE* 54(3):375–421 — https://papers.ssrn.com/sol3/papers.cfm?abstract_id=205390
- Hodrick (1992), *RFS* 5(3):357–386 — https://www0.gsb.columbia.edu/faculty/rhodrick/dividendyields.pdf
- Bekaert, Hodrick & Marshall (1997), *JFE* 44(3):309–348 — https://ideas.repec.org/a/eee/jfinec/v44y1997i3p309-348.html
- Politis & Romano (1994), stationary bootstrap, *JASA* 89(428):1303–1313

---

### Verification appendix (deep-research provenance)
- **Method.** 5 parallel web-search agents (≈250 source fetches) + cross-checking
  against the primary PDFs in `literature/` (Cieslak–Povala 2015 + online appendix,
  Dahlquist–Hasseltoft 2013, Cochrane–Piazzesi 2005, Zhang et al. 2021) and the
  thesis's own replication output.
- **High confidence (multi-source corroborated):** all citations (authors, year,
  title, journal, volume, pages) and the qualitative core findings.
- **Confirmed from primary sources in the repo:** Cieslak–Povala trend parameters
  (v ≈ 0.987, M = 120, core CPI); Zhang et al. (2021) = *Finance Research Letters* 42,
  101916 with v = 0.987 / N = 120 / α = 0.98 over CA, DE, JP, UK; CP2005 R² ≈ 0.35–0.44
  (matched in the thesis replication); the Campbell–Thompson OOS-R² statistic (used in
  the thesis); corr(cf, average cycle) ≈ 0.69 in the thesis's US replication vs. CP's
  reported 0.61.
- **[verify in primary PDF] before quoting exact figures:** Fama–Bliss ~15% R²;
  Ludvigson–Ng augmented R² (~0.45–0.55); Cieslak–Povala >50% long-maturity R² and OOS
  R²; Dahlquist–Hasseltoft per-regression R²; Diebold–Li–Yue variance shares;
  Campbell–Thompson monthly R²_OS (~0.5%); Gargano et al. OOS/CER magnitudes;
  Beyer–Wieland r\* band (±~2.3 pp); HML-FX Sharpe (~0.3 developed to ~0.6–0.8 broad).
- **Corrections made during verification:** Thornton & Valente (2012) full title is
  "Out-of-Sample Predictions of Bond Excess Returns and Forward Rates: An Asset
  Allocation Perspective"; Lustig–Stathopoulos–Verdelhan cite the 2019 *AER* version
  (not the 2013 WP); Zhang et al. article number is 101916 (not 101906).
- **Unconfirmed reference:** an "Ang & Chen" hedged-vs-unhedged bond paper from the
  original brief could not be matched to a verified publication — omit or identify
  precisely before citing.
