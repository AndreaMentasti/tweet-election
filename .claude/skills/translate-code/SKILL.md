---
name: translate-code
description: Translate scripts between Python, Stata, and R while preserving project conventions. Use when user asks to "translate", "convert", "rewrite in Stata/Python/R", "port to R", "Stata equivalent", or any request to convert analysis code from one language to another. Handles all six directions (Python↔Stata, Python↔R, Stata↔R).
argument-hint: "[source file] to [python|stata|r]"
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash"]
---

# Translate Code

Exact translation between Python, Stata, and R. Same logic, same output.

## Golden Rule

**Translate faithfully. No additions, no removals, no improvements.**

- Same filters, transforms, variables, and output — in the same order
- Same figure layout: axes, colors, labels, ranges, legend, grid
- Same table structure: rows, columns, decimals, stars
- Differences ONLY for syntax, paths, and language boilerplate
- Even if you see a bug, translate it as-is

## Steps

### 1. Read source and translate

Read the source file. Write the target script directly — no intermediate
decomposition document needed. For each substantive line in the source,
write the equivalent in the target language.

Place output in: Python → `code/py/`, Stata → `code/stata/`, R → `code/R/`

### 2. Apply project boilerplate

**Python:** `import config as cfg`, `cfg.FIGURES / "name.png"`, `dpi=300`,
`encoding="utf-8"`, `fig.patch.set_facecolor("white")`, `plt.close(fig)`,
module docstring with inputs/outputs.

**Stata:** `version 17`, `clear all`, `set more off`,
`global root "C:/Users/RaffaellaIntinghero/OneDrive - Wyss Academy for Nature/tweet-election"`,
`do "$root/code/stata/config_local.do"` for `$data_root`,
`log using "$root/quality_reports/[name].log", replace`,
`graphregion(color(white)) bgcolor(white)`, `width(2400)` on graph export,
`log close` at end.

**R:** `library()` calls, `here::here()` for paths, `set.seed(42)` if needed,
`ggsave(width=8, height=6, dpi=300)`.

### 3. Run and verify

Run the translated script. Check log/output for errors. If it fails, fix and re-run.

Stata: `"C:/Program Files/StataNow19/StataSE-64.exe" -b do code/stata/[script].do`

## Path Mappings

| Concept | Python | Stata | R |
|---------|--------|-------|---|
| Raw data | `cfg.DATA_RAW / "f.csv"` | `"$data_root/rawdata/f.csv"` | `here("data","rawdata","f.csv")` |
| Processed | `cfg.DATA_PROCESSED / "f.dta"` | `"$data_root/processed/f.dta"` | `here("data","processed","f.dta")` |
| Figures | `cfg.FIGURES / "f.png"` | `"$root/output/figures/f.png"` | `here("output","figures","f.png")` |
| Tables | `cfg.TABLES / "f.tex"` | `"$root/output/tables/f.tex"` | `here("output","tables","f.tex")` |

## Cross-Language Traps

**Stata `graph bar` vs `twoway bar`:** `graph bar, over(party) over(state)`
puts BOTH variables on the x-axis. If the source has states on x-axis and
party as legend colors, use `twoway bar` with manual x-positions after
`reshape wide`. Never use `graph bar` for grouped bars with a color legend.

**Stata `reshape wide`:** Requires `keep`ing only the needed variables first
(drop candidate, votes, etc. that aren't constant within the reshape groups).
Variable names get the j-value appended: `vs` → `vsDemocrat`. Rename after.

**R `geom_bar` vs `geom_col`:** `geom_bar()` counts rows. For pre-computed
values, use `geom_col(position="dodge")`.

**Colors/opacity:** Python `alpha=0.8` → Stata `color(blue%80)` → R `alpha(0.8)`.
Always specify explicitly; don't rely on defaults.

**Stata `encode`:** Creates alphabetical numeric codes. To get state names
as x-axis labels at specific positions, build `xlabel()` dynamically with
a `forvalues` loop over encoded values.
