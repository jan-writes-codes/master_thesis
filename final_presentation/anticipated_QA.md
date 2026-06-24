# Final Presentation — Anticipated Q&A

**Thesis:** *Expected Returns in International Government Bond Markets*
**Author:** Jan Heissenberger · **Supervisor:** Giorgia Simion, Ph.D. (WU Vienna)

Ten questions an informed-but-diverse audience (asset-pricing specialists,
econometricians, macroeconomists, and curious non-specialists) is most likely to
ask, with answers you can deliver in 30–60 seconds. Key numbers are **bolded** so
you can find them under pressure. A rapid-fire factual appendix follows.

> **One thing to settle before you walk in.** The deck you are presenting
> (`final_presentation/`) reports the FX-adjusted factor built **bottom-up**
> (corr **0.78** with the GCF, "distinct"). The **thesis text still describes the
> top-down version** (corr **0.99**, "near-collinear"). That is a deliberate
> post-supervisor improvement, not an error — but anyone who has read both will
> notice. Q4 is your scripted answer; own it rather than be caught by it.

---

## Q1 — "In one sentence, what is genuinely new here?"
*(Everyone — the contribution question. Have the crisp version ready.)*

I take the **Cieslak–Povala (2015) macro-anchored cycle factor** — not the
forward-rate factor and not raw inflation trends — international, to the **full
G10 (11 markets)**, build a **GDP-weighted global cycle factor (GCF)** and a
novel **FX-adjusted version (FXGCF)** for a USD investor, and I evaluate the
*entire generated-regressor chain* **doubly out-of-sample**.

The headline result that nobody had shown: **of all the candidate factors —
local cycle, global cycle, the dollar variants, and even the Cochrane–Piazzesi
forward factor — only the *global cycle* factor beats the recursive prevailing
mean out of sample** (pooled R²ₒₒₛ = **+0.05**, positive in **10 of 11**
markets). Dahlquist–Hasseltoft established international integration on the
*forward* factor; I re-establish it on the macro-anchored cycle and show it is
*sharper out of sample* than the forward factor it replaces.

---

## Q2 — "Intuitively, why should the gap between yields and trend inflation predict returns? What *is* the cycle factor?"
*(Macroeconomists and non-specialists. The economic-story question.)*

Think of a nominal yield as two pieces: a slow **anchor** — where investors
expect rates to settle, pinned down by long-run trend inflation — and a
transitory **deviation** from that anchor, the *cycle*. The anchor barely moves
and barely predicts; the **deviation is where the risk premium lives**. When the
curve sits far above its inflation anchor, investors are demanding extra
compensation to hold duration, and that compensation **mean-reverts at
business-cycle frequency** — which is exactly what makes next year's excess
return forecastable.

Two points sell that this is a mechanism, not data-mining:
- The **same sign structure appears in all 11 markets** — negative on the 1-year
  cycle, positive on the average cycle — across countries with very different
  monetary histories. A data-mined artefact would not be that uniform.
- It is the international counterpart of the **"falling stars" evidence**
  (Bauer–Rudebusch 2020): once you account for the slow-moving macro anchor, the
  cyclical deviation is where predictability concentrates.

I construct trend inflation exactly as the original: a backward-looking
exponentially-weighted moving average of **core** CPI (decay **v = 0.987**,
window **M = 120 months**), so it is observable in real time with no look-ahead.

---

## Q3 — "Your local factor has a 25% in-sample R² but is *negative* out of sample in 9 of 11 markets. Doesn't that mean it's overfit — even spurious?"
*(Econometricians. The generated-regressor / overfitting challenge.)*

This is the most important honest point in the thesis, and I lead with it rather
than hide it. The cycle factor is a **generated regressor** — it is *fitted* on
the same sample it is then scored on — so an inflated in-sample R² is exactly the
failure mode to expect. That is *why* I built the doubly-out-of-sample protocol.

But "overfit" is not the same as "spurious." The local in-sample result is real:
the sign structure is uniform, it is jointly significant in 10/11 markets, and
the R² sits **far above the 95th percentile of my expectations-hypothesis Monte
Carlo** under the no-predictability null. What collapses out of sample is not the
*existence* of the premium but the **precision** with which each country's factor
can be estimated in real time.

And here is the payoff: **aggregating the 11 noisy national cycles into one
GDP-weighted global factor averages away the country-specific estimation noise**,
so the *global* factor predicts in real time (**+0.05**) where the *local* one
cannot (**−0.08**, positive in only 2 markets — US and Canada). The honest
headline is therefore not "the cycle factor works everywhere" but "**international
bond risk premia contain a common, macro-anchored component that is stable enough
to estimate in real time — provided you aggregate across markets.**"

---

## Q4 — "Your FX-adjusted factor correlates 0.78 with the plain global factor on your slide, but 0.99 in the thesis. Which is it — and does the FX adjustment add anything at all?"
*(The single most likely hard question. A specialist who read both will ask it.)*

Both numbers are correct; they come from **two different ways of building the
same factor**, and the difference is itself a finding.

- The **thesis** builds the FX factor **top-down**: fit one regression of the
  *GDP-weighted aggregate* dollar return on the *GDP-weighted aggregate* cycle
  predictors. But those are the **same aggregates that drive the GCF**, so the
  result is collinear with the GCF *almost by construction* → corr **0.99**.
- My supervisor rightly flagged this: Dahlquist–Hasseltoft report ≈ **0.50** for
  their FX-adjusted factor, so 0.99 looked like the FX information had vanished.
- I ran a **2×2 study** (top-down vs bottom-up × GDP vs equal weights). The
  result: **construction is the lever, not the weighting**. Rebuilding the factor
  **bottom-up** — estimate a local dollar-return cycle factor per country, *then*
  GDP-weight, i.e. the exact GCF recipe with the dollar return on the left —
  cuts the correlation to **0.78** and *raises* in-sample R² from **9.5% to
  14.3%**, significant in **10/11** markets versus 4/11. There is **no
  trade-off**: the less-collinear construction is also the more powerful one. That
  is the version in this deck.

**The honest caveat — say it before they do:** *none* of my four constructions
reaches DH's 0.50, because all of them reuse the **same bond-cycle predictors**.
They can only re-weight a common signal. To *truly* decouple the FX factor you
need a **currency-specific predictor** — the short-rate differential / carry,
which is what drives the predictable part of the currency return. That is the
natural next step, and it is *why* DH's factor is distinct: their forward factor
keeps the rate *level*, which is the carry signal; my cycle factor detrends the
level away. So the near-collinearity in the top-down version is not a bug, it's a
property of macro-anchored factors — the same detrending that gives the cycle
factor real-time stability in bonds removes its leverage over currencies.

---

## Q5 — "You use 18-lag Newey–West on overlapping returns with highly persistent regressors. Given Stambaugh bias and the Bauer–Hamilton small-sample critique, how do you know your t-statistics aren't inflated?"
*(Econometricians. The inference-validity challenge.)*

I take this seriously and I do **not** rest the conclusions on the t-statistics.
Three layers:

1. **I concede the problem openly.** HAC inference at a 12-month overlap can
   over-reject for persistent regressors, and I could not use Cieslak–Povala's
   exact reverse-regression delta method — it needs the underlying *monthly*
   returns, which my 12-month overlapping panel does not identify. I state this
   as a deviation rather than paper over it.
2. **I add small-sample machinery:** a **stationary block bootstrap**
   (Politis–Romano) for the t-stat and R² intervals, and an
   **expectations-hypothesis Monte Carlo** so the R² is judged against a
   *simulated* no-predictability band, not just an asymptotic t-ratio. The
   realised R² sit far above that band.
3. **Crucially, I lean the conclusions on the out-of-sample evidence**, which is
   *immune* to the over-rejection problem — a recursive forecast either beats the
   prevailing mean or it doesn't; there is no t-statistic to inflate. This is
   exactly the Bauer–Hamilton discipline: when in doubt, go out of sample. And
   out of sample only the global cycle factor survives, which is the
   strongest-possible answer to a spanning sceptic.

*(If pressed on the EH Monte Carlo:)* I am candid that my calibration reproduces
the *qualitative* null pattern but not Cieslak–Povala's exact published band — so
the "exceeds the EH null" claim rests on my own calibration. The margin is wide,
which is why I'm comfortable, but the gap is documented, not hidden.

---

## Q6 — "Five of your eleven markets are euro-area, sharing a currency and ECB policy since 1999, and the GDP weights are dominated by the US, euro area and Japan. Aren't you really testing about three blocs, not eleven countries? Is the 'global' result mechanical?"
*(A sharp asset-pricing specialist. This is a genuine design vulnerability — concede the valid part.)*

The valid part: yes, the panel contributes **far fewer than eleven independent
observations** of the global cycle. The five euro members share a currency and
policy from 1999, so the GDP-weighted factor is to a significant degree a
**US–euro-area–Japan** factor. An alternative design — Randl et al. (2025) — uses
**German Bunds alone** for the euro area and adds Australia, New Zealand and
Norway for currency diversity. I name this as a limitation.

But three things keep the integration result meaningful:
1. **"Integration" here is about the *conditional premium*, not return
   co-movement.** Randl et al. show three principal components explain **86%** of
   hedged bond *return* variance yet are *largely unpriced*. Common variation and
   common *compensation* are different objects. My claim is the second: a single
   factor describes the *time-varying expected return* across the G10 — fully
   compatible with much of the realised co-movement being unpriced noise.
2. **The exceptions prove it isn't mechanical.** If it were a pure currency-bloc
   artefact, the local factor would never survive. It does — in **Italy, the
   Netherlands and Belgium** — and the Italian case is a clean, economically
   driven exception (Q9), not a mechanical one.
3. The euro-bloc design is precisely **what makes the Italy/periphery result
   observable at all** — a Bunds-only design would hide it. The two universes are
   complementary.

---

## Q7 — "Why does converting to dollars destroy two-thirds of the predictability, and what's the practical takeaway?"
*(Finance specialists and practitioners. The currency question.)*

Mechanically: the one-year **currency return is far more volatile than the
cyclical bond signal**, so it swamps it. The global factor's average R² falls
from **25% on local-currency returns to 8% on dollar returns**, and significance
disappears across the entire euro area, Switzerland and Japan. It survives only
where the currency leg is small or itself cyclical — the US (no currency leg by
construction, R² = 33%), Canada, and marginally Sweden and the UK.

The takeaway is a clean portfolio prescription, and it doesn't rest on my
evidence alone:
- **Hedge the currency.** The predictable component lives in local-currency
  (hedged) space. This matches Campbell–Serfaty-de Medeiros–Viceira (2010) — the
  risk-minimising strategy for a global *bond* investor is close to a full hedge
  — and Randl et al. (2025), who find the mean–variance-efficient hedged bond
  portfolio carries negligible currency exposure. **The bond premium and the
  currency premium are separate objects, best harvested separately.**
- **Time the aggregate, not the cross-section** — the surviving factor is a single
  global series.

So currency exposure, *from the standpoint of cycle-based predictability*, is
largely uncompensated noise.

---

## Q8 — "A Sharpe-ratio gain of 0.07 and half a percent a year — is that actually worth anything?"
*(Practitioners and non-specialists. The 'so what' / is-it-exploitable question.)*

I present it as a **proof of concept, not a trading system**, and the modest size
is honest — it is typical of bond-return predictability and consistent with a
small out-of-sample R². But it is genuinely positive and genuinely real-time:

- The single GDP-weighted 10-year global bond portfolio has an out-of-sample
  **R²ₒₒₛ = 0.125**; timing it lifts the annual Sharpe ratio from **0.31
  (passive) to 0.38**, with a **certainty-equivalent gain of +0.51%/year**
  (γ = 5) over buy-and-hold.
- The gains come from **avoiding drawdowns** — chiefly cutting exposure before
  2022 — not from leverage in good years.
- The factor is **highly persistent → low turnover**, so realistic transaction
  costs erode little of it.

For context: Thornton–Valente (2012) found *no* economic value for forward-rate
predictability; I find some for the macro-anchored *global* factor — and only for
the **hedged** investor (the unhedged dollar strategy only reaches Sharpe ≈
0.24–0.25). And the ceiling is much higher: Randl et al. show a full
mean–variance-efficient hedged bond portfolio can exceed Sharpe 1, with the
*expected-return forecast* as the critical input — which is exactly the object I
provide.

---

## Q9 — "Your out-of-sample edge only holds with an expanding window, only with core CPI, and it fails in 2008. Isn't the result fragile and regime-dependent?"
*(Critical specialists. The robustness-boundary challenge — answer with candour, then reframe.)*

I'm candid about all three boundaries because the robustness chapter draws them
itself — and each is **economically intelligible rather than troubling**:

- **Expanding vs rolling window.** The edge needs an *expanding* window (R²ₒₒₛ
  **+0.05**); it goes to **−0.12** under a 10-year rolling window. That's
  coherent: the factor is anchored to slow-moving trend inflation, so accumulating
  a *long* macro history sharpens the loadings, whereas a rolling window throws
  away informative old data. The edge **rewards patience** — it is not a generic
  feature of any real-time scheme.
- **Core vs headline CPI.** In sample the two barely differ; out of sample the
  global factor's edge survives on **core (+0.05)** but vanishes on **headline
  (−0.02)**. Also coherent: energy-price swings don't pass through to the yield
  curve, so a real-time estimator re-fit on headline inflation inherits noise the
  full-sample regression averages away. **The macro anchor must be measured
  cleanly** — a substantive finding, not a footnote.
- **2008.** It fails *inside* the financial crisis (**−0.19**) but is positive
  pre-crisis, in the euro crisis, and post-crisis. **No slow-moving macro factor
  can forecast a flight-to-quality panic** — and I'd be more worried if it
  claimed to.

Reframe: rather than weakening the result, these boundaries **define exactly who
the predictability is for** — a patient, long-memory, core-inflation-based
estimator of a slow factor. That's a sharper and more useful claim than "it
always works."

---

## Q10 — "Why GDP weights specifically, and what would you do next?"
*(Forward-looking — common closing question.)*

**On GDP weights:** it's the Dahlquist–Hasseltoft convention, and the results are
**not sensitive** to it — the global factor is dominated by the large,
strongly-co-moving core economies, so re-weighting the smaller markets barely
moves the aggregate. I'm honest that I did *not* test market-cap,
debt-outstanding, equal, or PCA weightings — that's an open robustness question.

**Next steps, in priority order:**
1. **Add a currency-specific predictor** (short-rate differential / carry) to the
   FX factor — the only way to push the FXGCF–GCF correlation toward DH's 0.50 and
   give it genuinely independent currency information (Q4).
2. **Embed the global cycle in a no-arbitrage, shifting-endpoint term-structure
   model** with a shared international trend — closing the gap between my
   reduced-form evidence and the structural falling-stars framework
   (Bauer–Rudebusch).
3. **Richer data and use:** more maturities, longer/balanced samples, and using
   the real-time forecast as the expected-return input to a *cross-sectionally*
   optimised hedged bond portfolio (the high-ceiling use Randl et al. point to).

---

## Rapid-fire appendix (one-line factual jabs)

- **"Why core, not headline, CPI?"** Core strips transitory food/energy noise
  that doesn't pass through to yields; it's the better proxy for the persistent
  anchor, and out of sample it is *decisive* (Q9).
- **"Why duration-standardise and maturity-average the returns?"** Return vol
  scales with duration; standardising by D⁽ⁿ⁾ = n (Macaulay duration of a
  continuously-compounded zero) and averaging gives one scale-comparable series
  and a single curve-wide premium. Results are insensitive to the convention.
- **"Why 18 Newey–West lags?"** The 12-month overlap induces MA(11) errors; 18
  lags comfortably covers it — the standard choice for annual-horizon overlapping
  regressions.
- **"Why an expectations-hypothesis Monte Carlo?"** Even under zero risk premia,
  realised 12-month returns embed the future yield, so the in-sample R² has a
  non-degenerate null distribution; the EH-MC tells me what R² to expect under
  *no* predictability.
- **"What's the sample?"** G10 (BE, CA, FR, DE, IT, JP, NL, SE, CH, UK, US),
  monthly, ~1990/1994–2026; unbalanced (the 9 non-US/non-Japan markets start Dec
  1994); maturities {1,2,4,5,9,10}y, clean excess returns for n ∈ {2,5,10}. ≈30
  *non-overlapping* annual observations per country.
- **"Did you replicate the originals first?"** Yes — before any extension I
  reproduced the US Cieslak–Povala result (US R² ≈ 0.33; factor correlates 0.69
  with the average cycle vs their 0.61) and the Dahlquist–Hasseltoft
  international tables.
- **"Cycle vs Cochrane–Piazzesi?"** In sample the *forward* factor wins (0.38 vs
  0.25 — it has 6 predictors to my 2, more room to over-fit); out of sample
  **only the global cycle factor is positive** (+0.05 vs −0.01). The macro
  anchoring is load-bearing, not packaging.
- **"What's the one object the whole thesis stands on?"** The **GDP-weighted
  global cycle factor** — significant in every market, the only factor positive
  out of sample, robust across subsamples (except the 2008 panic) and against the
  forward factor, and carrying real economic value for a hedged investor.
</content>
</invoke>
