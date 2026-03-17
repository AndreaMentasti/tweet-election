/*******************************************************************************
 * 2-scatter_engagement.do — Scatter plot of votes vs vote share by state and party.
 * Translated line-by-line from: code/py/02_scatter_engagement.py
 *
 * Inputs:  $data_root/processed/tweets_processed.csv
 *          $data_root/processed/election_data_processed.csv
 * Outputs: $root/output/figures/scatter_votes_vote_share.png
 *
 * Note: The current sample data lacks a direct tweet-to-candidate link.
 *       This script demonstrates the pattern; once tweets are linked to
 *       candidates (e.g., via a 'candidate' or 'party' column in the tweet
 *       data), the merge will produce a real engagement-vs-vote-share scatter.
 * Last updated: 2026-03-16
 ******************************************************************************/

*------------------------------------------------------------------------------*
* Program Setup
*------------------------------------------------------------------------------*
version 17
clear all
set more off
macro drop _all
capture log close
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Directories
*------------------------------------------------------------------------------*
global root "C:/Users/RaffaellaIntinghero/OneDrive - Wyss Academy for Nature/tweet-election"
log using "$root/quality_reports/stata_logs/2-scatter_engagement.log", replace

* Load machine-specific data path
capture noisily do "$root/code/stata/config_local.do"
if _rc != 0 {
    di as error "ERROR: config_local.do not found. See SETUP.md."
    exit 1
}
if `"$data_root"' == "" {
    di as error "ERROR: data_root not defined. Check config_local.do."
    exit 1
}
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* 1. Load processed data
*------------------------------------------------------------------------------*
* tweets = pd.read_csv(cfg.DATA_PROCESSED / "tweets_processed.csv")
import delimited "$data_root/processed/tweets_processed.csv", clear encoding("utf-8")
local n_tweets = _N
di "Tweets: `n_tweets' rows"

* Save tweets to tempfile (Stata holds one dataset at a time)
tempfile tweets_data
save `tweets_data'

* election = pd.read_csv(cfg.DATA_PROCESSED / "election_data_processed.csv")
import delimited "$data_root/processed/election_data_processed.csv", clear encoding("utf-8")
local n_election = _N
di "Election: `n_election' rows"

di "Tweets: `n_tweets' rows, Election: `n_election' rows"


*------------------------------------------------------------------------------*
* 2. Aggregate tweet engagement by party (placeholder logic)
*------------------------------------------------------------------------------*
* TODO: Replace with real merge key once tweets have candidate/party column.
*   Example future merge:
*     use `tweets_data', clear
*     collapse (mean) engagement, by(candidate)
*     merge 1:m candidate using `election_data'


*------------------------------------------------------------------------------*
* 3. Scatter plot: vote share by state and party
*------------------------------------------------------------------------------*
* gen votes_millions = votes / 1e6 (for x-axis scaling)
gen votes_millions = votes / 1000000
label var votes_millions "Votes (millions)"

* Encode party for color separation
* Python: colors = {"Democrat": "blue", "Republican": "red"}
* Python loops over parties → Stata uses twoway overlays with if conditions

* ax.scatter with labels per point
* Stata: twoway scatter + mlabel for point labels
* alpha=0.7 → %70 transparency; s=80 → msymbol size; edgecolors=white → not directly available

twoway ///
    (scatter vote_share votes_millions if party == "Democrat", ///
        mcolor(blue%70) msymbol(circle) msize(large) ///
        mlabel(state) mlabsize(tiny) mlabposition(3) mlabgap(1)) ///
    (scatter vote_share votes_millions if party == "Republican", ///
        mcolor(red%70) msymbol(circle) msize(large) ///
        mlabel(state) mlabsize(tiny) mlabposition(3) mlabgap(1)) ///
    , ///
    xtitle("Votes (millions)") ///
    ytitle("Vote Share") ///
    title("Vote Share vs Total Votes by State and Party (2020)") ///
    legend(order(1 "Democrat" 2 "Republican")) ///
    graphregion(color(white)) bgcolor(white)

graph export "$root/output/figures/scatter_votes_vote_share.png", replace width(2400)
di "Figure saved to $root/output/figures/scatter_votes_vote_share.png"


*------------------------------------------------------------------------------*
* Cleanup
*------------------------------------------------------------------------------*
graph drop _all
log close
*------------------------------------------------------------------------------*
