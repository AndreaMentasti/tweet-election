/*******************************************************************************
 * 0-data_prep.do — Summary statistics and descriptive figures
 * Inputs:  $data_root/processed/tweets_processed.dta
 *          $data_root/processed/election_data_processed.dta
 * Outputs: $root/output/tables/summary_stats.tex
 *          $root/output/figures/vote_share_by_state.png
 * Last updated: 2026-03-13
 *
 * Note: Tweet and election data are loaded separately for descriptive stats.
 *       Merge for regression analysis will be in a downstream script once
 *       tweets have a candidate/party linkage column.
 *******************************************************************************/

*------------------------------------------------------------------------------*
* Program Setup
*------------------------------------------------------------------------------*
version 17
clear all
clear mata
set more off
macro drop _all
capture log close
set scheme s2color
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Directories
*------------------------------------------------------------------------------*
* Set $root to YOUR local clone of this repo. See CLAUDE.md "Machine Setup".
global root "C:/Users/RaffaellaIntinghero/OneDrive - Wyss Academy for Nature/tweet-election"

* Open log early so config errors are captured
log using "$root/quality_reports/stata_logs/0-data_prep.log", replace

* Load machine-specific Dropbox data path from config_local.do (gitignored).
* To set up: copy config_local.do.template → config_local.do, fill in data_root.
capture noisily do "$root/code/stata/config_local.do"
if _rc != 0 {
    di as error "ERROR: config_local.do not found or contains errors."
    di as error "Copy code/stata/config_local.do.template to config_local.do"
    di as error "and set global data_root to your Dropbox data folder."
    exit 1
}
* Verify data_root was actually set
if `"$data_root"' == "" {
    di as error "ERROR: data_root not defined. Check config_local.do."
    exit 1
}

* No stochastic operations in this script; set seed omitted intentionally.
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* 1. Load processed tweet data
*------------------------------------------------------------------------------*
use "$data_root/processed/tweets_processed.dta", clear

* Check for missing values
misstable summarize

* Validate data loaded
assert _N > 0

* Apply variable labels
label var retweet_count "Retweet count"
label var favorite_count "Favorite count"
label var text_length "Tweet text length (characters)"
label var engagement "Engagement (retweets + favorites)"

* Summary statistics
summarize retweet_count favorite_count text_length engagement

* Export summary stats table
* Using cells() instead of standard se/star because this is descriptive, not regression.
estpost summarize retweet_count favorite_count text_length engagement
esttab using "$root/output/tables/summary_stats.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") ///
    title("Summary Statistics -- Tweet Data") ///
    booktabs label replace ///
    nomtitle nonumber


*------------------------------------------------------------------------------*
* 2. Load election data
*------------------------------------------------------------------------------*
use "$data_root/processed/election_data_processed.dta", clear

* Check for missing values
misstable summarize

* Validate data loaded and vote_share is in [0,1]
assert _N > 0
assert vote_share >= 0 & vote_share <= 1 if !missing(vote_share)

* Apply variable labels
label var party "Political party"
label var state "U.S. state"
label var votes "Total votes received"
label var total_votes "Total votes cast in state"
label var vote_share "Party vote share (0-1)"

* Summary by party
tabulate party, summarize(vote_share)

* Note: over(party) sorts alphabetically → bar(1)=Democrat(blue), bar(2)=Republican(red)
graph bar vote_share, over(party) over(state) ///
    title("Vote Share by State and Party (2020)") ///
    ytitle("Vote Share") ///
    bar(1, color(blue)) bar(2, color(red)) ///
    legend(order(1 "Democrat" 2 "Republican")) ///
    graphregion(color(white)) bgcolor(white)
graph export "$root/output/figures/vote_share_by_state.png", replace width(2400)

* ECCOMI, SONO IO!

*------------------------------------------------------------------------------*
* Cleanup
*------------------------------------------------------------------------------*
graph drop _all
log close
*------------------------------------------------------------------------------*







