/*
 * 3-vote_share_barplot.do — Bar chart of vote share by state and party.
 * Translated from: code/py/03_vote_share_barplot.py
 *
 * Inputs:  data/processed/election_data_processed.dta
 * Outputs: output/figures/vote_share_by_state_stata.png
 * Last updated: 2026-03-13
 */

version 17
clear all
set more off

global root "C:/Users/RaffaellaIntinghero/OneDrive - Wyss Academy for Nature/tweet-election"
log using "$root/quality_reports/3-vote_share_barplot.log", replace

capture noisily do "$root/code/stata/config_local.do"
if _rc != 0 {
    di as error "ERROR: config_local.do not found. See CLAUDE.md Machine Setup."
    exit 1
}
if `"$data_root"' == "" {
    di as error "ERROR: data_root not defined. Check config_local.do."
    exit 1
}

*--- 1. Load election data ---*
use "$data_root/processed/election_data_processed.dta", clear
assert _N > 0
di "Election data: `=_N' rows"

*--- 2. Validate parties ---*
tab party
assert r(r) == 2

*--- 3. Pivot: reshape wide so each state has Democrat & Republican columns ---*
encode state, gen(state_num)
gen x_pos = state_num - 1

keep state party vote_share state_num x_pos

rename vote_share vs
reshape wide vs, i(state state_num x_pos) j(party) string
rename vsDemocrat vs_dem
rename vsRepublican vs_rep

*--- 4. Create offset x-positions (width=0.35, offset=0.175) ---*
gen x_dem = x_pos - 0.175
gen x_rep = x_pos + 0.175

*--- 5. Build x-axis labels from encoded state names ---*
qui sum state_num
local n_states = r(max)
local xlabels ""
forvalues i = 1/`n_states' {
    local sname : label (state_num) `i'
    local xval = `i' - 1
    local xlabels `"`xlabels' `xval' "`sname'""'
}

*--- 6. Draw grouped bar chart ---*
twoway ///
    (bar vs_dem x_dem, barwidth(0.35) color(blue%80)) ///
    (bar vs_rep x_rep, barwidth(0.35) color(red%80)) ///
    , ///
    title("Vote Share by State and Party (2020)") ///
    ytitle("Vote Share") ///
    xtitle("") ///
    xlabel(`xlabels', labsize(medium)) ///
    ylabel(0(0.1)0.7, grid glcolor(gs14)) ///
    yscale(range(0 0.75)) ///
    legend(order(1 "Democrat" 2 "Republican") position(1) ring(0) ///
        region(lstyle(solid) lcolor(gs12) fcolor(white))) ///
    graphregion(color(white)) bgcolor(white) ///
    plotregion(margin(b=0))

graph export "$root/output/figures/vote_share_by_state_stata.png", replace width(2400)
di "Figure saved to $root/output/figures/vote_share_by_state_stata.png"

graph drop _all
log close
