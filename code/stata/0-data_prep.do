/*******************************************************************************
 * 0-data_prep.do — Summary statistics and engagement → vote share analysis
 * Inputs:  $data_root/processed/tweets_processed.dta
 *          $data_root/processed/election_data_processed.dta
 * Outputs: $root/Figures/summary_stats.tex
 *          $root/Figures/vote_share_by_state.png
 * Last updated: 2026-03-12
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
* Update $root to YOUR local clone of the GitHub repo (machine-specific)
* Andrea:    global root "C:\Users\AndreaMentasti\Projects\tweet-election"
* Raffaella: global root "C:\Users\RaffaellaIntinghero\Projects\tweet-election"
global root "C:\Users\AndreaMentasti\OneDrive - Wyss Academy for Nature\Desktop\tweet-election"

* Load machine-specific Dropbox data path from config_local.do (gitignored).
* To set up: copy config_local.do.template → config_local.do, fill in data_root.
capture qui do "$root/code/stata/config_local.do"
if _rc != 0 {
    di as error "ERROR: config_local.do not found."
    di as error "Copy code/stata/config_local.do.template to config_local.do"
    di as error "and set global data_root to your Dropbox data folder."
    exit 1
}
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* 1. Load processed tweet data
*------------------------------------------------------------------------------*
use "$data_root/processed/tweets_processed.dta", clear

* Summary statistics
summarize retweet_count favorite_count text_length engagement

* Export summary stats table
estpost summarize retweet_count favorite_count text_length engagement
esttab using "$root/Figures/summary_stats.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) min max count") ///
    title("Summary Statistics - Tweet Data") ///
    replace


*------------------------------------------------------------------------------*
* 2. Load election data
*------------------------------------------------------------------------------*
use "$data_root/processed/election_data_processed.dta", clear

* Summary by party
tabulate party, summarize(vote_share)

* Simple bar graph of vote share by state and party
graph bar vote_share, over(party) over(state) ///
    title("Vote Share by State and Party (2020)") ///
    ytitle("Vote Share") ///
    bar(1, color(blue)) bar(2, color(red)) ///
    graphregion(color(white)) bgcolor(white)
graph export "$root/Figures/vote_share_by_state.png", replace width(2400)

*------------------------------------------------------------------------------*
* End
*------------------------------------------------------------------------------*
