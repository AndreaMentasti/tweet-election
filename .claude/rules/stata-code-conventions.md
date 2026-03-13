# Stata Code Conventions

Standards for all Stata scripts in `code/stata/`. Apply these during code generation
and when running `/data-analysis`.

---

## 1. Reproducibility (Non-Negotiable)

- **Version statement:** Every `.do` file starts with:
  ```stata
  version 17
  ```
  This ensures backward compatibility and documents the Stata version used.

- **Root path macro:** Set a single global root at the very top of each `.do` file:
  ```stata
  global root "C:/Users/yourname/Dropbox/tweet-election-mini-project"
  ```
  All subsequent paths use `$root`. Never hardcode any other absolute path.
  *(Note: update `$root` when moving between machines.)*

- **Seed:** Set before any stochastic operation (bootstrap, permutation, simulation):
  ```stata
  set seed 42
  ```
  Place immediately after the root macro, before `use` or `import`.

- **Entry point:** Every `.do` file must run cleanly with:
  ```
  stata -b do code/stata/<script>.do
  ```
  No interactive input, no error exit. Check the `.log` file for errors.

---

## 2. Style

- **File header:** Every `.do` file opens with a comment banner:
  ```stata
  /*
   * 0-data_prep.do — Summary statistics and engagement → vote share analysis
   * Inputs:  data/processed/tweets_processed.dta, election_data_processed.dta
   * Outputs: Figures/table_summary.tex, Figures/fig_engagement.png
   * Last updated: YYYY-MM-DD
   */
  ```

- **Section banners:** Separate major sections with:
  ```stata
  *---- 1. Load and merge data ----*
  ```

- **Variable labels:** Label every variable immediately after creation:
  ```stata
  gen vote_share = votes / total_votes
  label var vote_share "Party vote share (0-1)"
  ```

- **Value labels:** Apply value labels for categorical variables:
  ```stata
  label define partylab 0 "Democrat" 1 "Republican"
  label values party_num partylab
  ```

- **`tab` before regressions:** Always inspect N and distribution before running a model:
  ```stata
  tab party
  sum retweet_count favorite_count vote_share
  ```

- **Comment style:** Explain WHY, not WHAT.
  Bad: `* generate engagement`. Good: `* proxy for visibility: total interactions per tweet`

---

## 3. Tables (LaTeX Output)

Use `esttab` (part of `estout`) for publication-ready LaTeX tables:

```stata
eststo clear
eststo: reg vote_share engagement_score i.year, robust
eststo: reg vote_share engagement_score i.year i.state_num, robust

esttab using "$root/Figures/table_main.tex", ///
    booktabs label replace ///
    title("Engagement and Vote Share") ///
    mtitles("OLS" "OLS + State FE") ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(3) se(3)
```

- Always use `booktabs` and `label` options.
- Always use `replace` to allow re-running.
- Include `se` (standard errors in parentheses) and significance stars.
- Use `b(3) se(3)` for 3 decimal places.

---

## 4. Figures (PNG Output)

```stata
twoway (scatter vote_share engagement_score), ///
    xtitle("Engagement Score") ytitle("Vote Share") ///
    title("Engagement vs. Vote Share") ///
    graphregion(color(white)) bgcolor(white)

graph export "$root/Figures/fig_engagement.png", replace width(2400)
```

- Always set `graphregion(color(white)) bgcolor(white)` for white background.
- `width(2400)` at standard screen resolution ≈ 300 DPI for an 8-inch figure.
- Use `replace` always.
- Save ALL figures to `$root/Figures/`.

---

## 5. Merging Data

```stata
use "$root/data/processed/tweets_processed.dta", clear
merge m:1 party year using "$root/data/processed/election_data_processed.dta"
tab _merge
keep if _merge == 3          // keep matched only; log how many dropped
drop _merge
```

Always inspect `_merge` before dropping. Document how many observations are unmatched
and why it's expected (or unexpected).

---

## 6. Known Pitfalls

- **`encode` auto-ordering:** `encode party, gen(party_num)` assigns numeric codes
  alphabetically ("Democrat"=1, "Republican"=2). This is NOT random but IS arbitrary.
  Always verify ordering before interpreting dummy coefficients.

- **`destring` vs. `encode`:** Use `destring` for variables that are already numeric
  stored as strings. Use `encode` for true string categoricals. Confusing the two
  causes silent data errors.

- **`sort` stability:** Stata's `sort` is not stable by default. Use `sort var1 var2`
  with enough keys to uniquely identify rows, or use `gsort`.

- **`robust` vs. `cluster`:** If multiple tweets map to the same candidate/state,
  standard errors should be clustered: `vce(cluster state)`. Plain `robust` is
  insufficient when errors are correlated within groups.

- **Log file:** Always check `<script>.log` after batch runs. A non-zero exit code
  means Stata hit an error; the log shows where.

---

## 7. Verification Checklist

After writing or modifying a `.do` file:

- [ ] Script runs cleanly: `stata -b do code/stata/<script>.do` exits 0
- [ ] `.log` file shows no errors (search for `r(`)
- [ ] All output files created: `Figures/*.tex`, `Figures/*.png`
- [ ] Variable labels applied to all new variables
- [ ] `$root` macro set and all paths use it
- [ ] `set seed 42` present if any stochastic operations
