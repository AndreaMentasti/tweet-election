/*******************************************************************************
 * 3-vote_share_barplot.do — Bar chart of vote share by state and party.
 *
 * Translated line-by-line from code/py/03_vote_share_barplot.py
 * using script-translator skill.
 *
 * Inputs:  $data_root/processed/election_data_processed.dta
 * Outputs: $root/output/figures/vote_share_by_state.png
 * Last updated: 2026-03-16
 *******************************************************************************/

*------------------------------------------------------------------------------*
* Program Setup
*------------------------------------------------------------------------------*
version 17
clear all
set more off
macro drop _all
capture log close

*------------------------------------------------------------------------------*
* Directories
*------------------------------------------------------------------------------*
global root "C:/Users/RaffaellaIntinghero/OneDrive - Wyss Academy for Nature/tweet-election"
log using "$root/quality_reports/stata_logs/3-vote_share_barplot.log", replace

* Load machine-specific Dropbox data path
capture noisily do "$root/code/stata/config_local.do"
if _rc != 0 {
    di as error "ERROR: config_local.do not found or contains errors."
    di as error "Copy config_local.do.template to config_local.do and set data_root."
    exit 1
}
if `"$data_root"' == "" {
    di as error "ERROR: data_root not defined. Check config_local.do."
    exit 1
}
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* 1. Load election data
*------------------------------------------------------------------------------*
* election = pd.read_csv(cfg.DATA_PROCESSED / "election_data_processed.csv")
use "$data_root/processed/election_data_processed.dta", clear

* logging.info(f"Election data: {len(election)} rows")
count
di "Election data: `r(N)' rows"

*------------------------------------------------------------------------------*
* 2. Validate parties
*------------------------------------------------------------------------------*
* assert expected_parties == actual_parties
* Verify only Democrat and Republican exist
tab party
assert r(r) == 2    // exactly 2 categories

*------------------------------------------------------------------------------*
* 3. Pivot for grouped bar chart
*------------------------------------------------------------------------------*
* Python: pivot = election.pivot(index="state", columns="party", values="vote_share")
* Stata: reshape wide so each party becomes a separate variable → allows bar(1)/bar(2) coloring

* Keep only what we need for the pivot
keep state party vote_share

* Encode party for reshape
encode party, gen(party_num)
drop party

* Reshape wide: vote_share → vote_share1 (Democrat) vote_share2 (Republican)
reshape wide vote_share, i(state) j(party_num)

* Rename for clarity — party_num 1=Democrat, 2=Republican (alphabetical encode)
rename vote_share1 dem_share
rename vote_share2 rep_share
label var dem_share "Democrat User"
label var rep_share "Republican User"

*------------------------------------------------------------------------------*
* 4. Create grouped bar chart
*------------------------------------------------------------------------------*
* Python: ax.bar(x - width/2, pivot["Democrat"], ..., color="blue", alpha=0.8)
*         ax.bar(x + width/2, pivot["Republican"], ..., color="red", alpha=0.8)
* Stata: graph bar with two variables → bar(1) and bar(2) control colors

graph bar dem_share rep_share, over(state) ///
    title("Vote Share by State and Party (2020/2025 Elections)") ///
    ytitle("Vote Share in Percentage") ///
    bar(1, color(blue%80)) bar(2, color(red%80)) ///
    legend(order(1 "Democrat User" 2 "Republican User") position(1) ring(0)) ///
    yscale(range(0 0.78)) ylabel(0(0.1)0.7, grid glcolor(gs14)) ///
    xsize(10) ysize(6) ///
    graphregion(color(white)) bgcolor(white)

graph export "$root/output/figures/vote_share_by_state.png", replace width(2400)

*------------------------------------------------------------------------------*
* Cleanup
*------------------------------------------------------------------------------*
graph drop _all
log close
*------------------------------------------------------------------------------*
