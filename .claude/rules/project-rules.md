# Project Rules — Tweet-Election Mini-Project

**These rules are non-negotiable.** They apply to every task, every session.
To change a rule, edit this file explicitly — never override silently.

---

## Rule 1: Raw Data Is Sacred

**NEVER delete, overwrite, or modify any file in `data/rawdata/`.**

- `data/rawdata/sample_tweets.csv` — original tweet data
- `data/rawdata/election_results.csv` — original election data

If you need a cleaned or transformed version, write it to `data/processed/`.
The protect-files.sh hook enforces this at the tool level, but the rule holds even
if the hook is bypassed.

**Rationale:** Raw data is irreproducible. Any transformation must be traceable to the raw source.

---

## Rule 2: Correlational Framing

**Never use causal language (causes, leads to, drives, effect of) without a valid
identification strategy (IV, RD, DiD, experiment).**

The correct framing for this project is:
- ✅ "engagement is associated with vote share"
- ✅ "engagement predicts vote share"
- ✅ "the correlation between engagement and vote share is..."
- ❌ "engagement drives vote share"
- ❌ "higher retweets cause better electoral outcomes"

The domain-reviewer agent flags causal language as CRITICAL. Fix before committing.

---

## Rule 3: All Paths Via Config

**Python scripts must import `config as cfg` and use `cfg.DATA_PROCESSED`, `cfg.FIGURES`, etc.**
**Stata scripts must set `global root "..."` and use `$root` for all paths.**

No hardcoded absolute paths anywhere. This makes the project portable across machines.

---

## Rule 4: Publication-Ready Figures Only

**All figures saved to `Figures/` must meet publication standards:**

- PNG format
- 300 DPI (Python: `dpi=300`; Stata: `width(2400)`)
- White background
- Labeled axes with units
- No chart junk (no unnecessary gridlines, 3D effects, etc.)

If a figure is exploratory/diagnostic, save it to `explorations/` instead.

---

## Rule 5: Scripts Must Run Clean

**Every `.py` and `.do` script must run to completion with exit code 0
before it can be committed.**

- Python: `python code/py/<script>.py` — no errors, no unhandled exceptions
- Stata: `stata -b do code/stata/<script>.do` — `.log` file shows no `r(` errors

The verify-reminder hook will remind you after every edit.

---

## Amendment Protocol

To change a rule: state "I want to amend Rule N" in the chat.
Claude will ask whether this is a permanent amendment (update this file)
or a one-time override (proceed without changing the rule).
