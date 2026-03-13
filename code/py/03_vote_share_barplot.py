"""
03_vote_share_barplot.py — Bar chart of vote share by state and party.

Inputs:  data/processed/election_data_processed.csv
Outputs: output/figures/vote_share_by_state.png
"""

import logging

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

import config as cfg

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# --- Ensure output directories exist ---
cfg.FIGURES.mkdir(parents=True, exist_ok=True)

# --- 1. Load election data ---
election = pd.read_csv(cfg.DATA_PROCESSED / "election_data_processed.csv", encoding="utf-8")
logging.info(f"Election data: {len(election)} rows")

# --- 2. Pivot for grouped bar chart ---
expected_parties = {"Democrat", "Republican"}
actual_parties = set(election["party"].unique())
assert expected_parties == actual_parties, f"Unexpected parties: {actual_parties}"

pivot = election.pivot(index="state", columns="party", values="vote_share")
states = pivot.index.tolist()

x = np.arange(len(states))
width = 0.35

fig, ax = plt.subplots(figsize=(10, 6))
fig.patch.set_facecolor("white")

bars_dem = ax.bar(x - width / 2, pivot["Democrat"], width, label="Democrat User", color="blue", alpha=0.8)
bars_rep = ax.bar(x + width / 2, pivot["Republican"], width, label="Republican User", color="red", alpha=0.8)

ax.set_ylabel("Vote Share in Percentage")
ax.set_title("Vote Share by State and Party (2020/2025 Elections)")
ax.set_xticks(x)
ax.set_xticklabels(states)
ax.legend()
ax.set_ylim(0, 0.78)
ax.grid(axis="y", alpha=0.3)

fig.savefig(cfg.FIGURES / "vote_share_by_state.png", dpi=300, bbox_inches="tight")
plt.close(fig)
logging.info(f"Figure saved to {cfg.FIGURES / 'vote_share_by_state.png'}")
