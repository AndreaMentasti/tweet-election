"""
02_scatter_engagement.py — Scatter plot of votes vs vote share by state and party.

Inputs:  data/processed/tweets_processed.csv
         data/processed/election_data_processed.csv
Outputs: output/figures/scatter_votes_vote_share.png

Note: The current sample data lacks a direct tweet-to-candidate link.
      This script demonstrates the pattern; once tweets are linked to
      candidates (e.g., via a 'candidate' or 'party' column in the tweet
      data), the merge will produce a real engagement-vs-vote-share scatter.
"""

import logging

import pandas as pd
import matplotlib.pyplot as plt

import config as cfg

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# --- Ensure output directories exist ---
cfg.FIGURES.mkdir(parents=True, exist_ok=True)

# --- 1. Load processed data ---
tweets = pd.read_csv(cfg.DATA_PROCESSED / "tweets_processed.csv", encoding="utf-8")
election = pd.read_csv(cfg.DATA_PROCESSED / "election_data_processed.csv", encoding="utf-8")

logging.info(f"Tweets: {len(tweets)} rows, Election: {len(election)} rows")

# --- 2. Aggregate tweet engagement by party (placeholder logic) ---
# TODO: Replace with real merge key once tweets have candidate/party column.
#   Example future merge:
#     tweets_by_cand = tweets.groupby('candidate')['engagement'].mean().reset_index()
#     merged = tweets_by_cand.merge(election, on='candidate', validate='1:m')

# --- 3. Scatter plot: vote share by state and party ---
fig, ax = plt.subplots(figsize=(8, 6))
fig.patch.set_facecolor("white")

colors = {"Democrat": "blue", "Republican": "red"}
for party, group in election.groupby("party"):
    ax.scatter(
        group["votes"] / 1e6,
        group["vote_share"],
        c=colors.get(party, "gray"),
        label=party,
        s=80,
        alpha=0.7,
        edgecolors="white",
        linewidth=0.5,
    )
    # Label each point with the state name
    for _, row in group.iterrows():
        ax.annotate(
            row["state"],
            (row["votes"] / 1e6, row["vote_share"]),
            fontsize=7,
            ha="left",
            va="bottom",
            xytext=(4, 2),
            textcoords="offset points",
        )

ax.set_xlabel("Votes (millions)")
ax.set_ylabel("Vote Share")
ax.set_title("Vote Share vs Total Votes by State and Party (2020)")
ax.legend()
ax.grid(True, alpha=0.3)

fig.savefig(cfg.FIGURES / "scatter_votes_vote_share.png", dpi=300, bbox_inches="tight")
plt.close(fig)
logging.info(f"Figure saved to {cfg.FIGURES / 'scatter_votes_vote_share.png'}")
