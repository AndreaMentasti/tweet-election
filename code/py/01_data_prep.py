"""
01_data_prep.py — Data cleaning and feature engineering.

Inputs:  data/rawdata/sample_tweets.csv, data/rawdata/election_results.csv
Outputs: data/processed/tweets_processed.{csv,dta},
         data/processed/election_data_processed.{csv,dta}
"""

import logging

import pandas as pd

import config as cfg

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# --- Ensure output directories exist ---
cfg.DATA_PROCESSED.mkdir(parents=True, exist_ok=True)

# --- 1. Load raw tweets ---
df = pd.read_csv(cfg.DATA_RAW / "sample_tweets.csv", encoding="utf-8")
logging.info(f"Loaded {len(df)} tweets")

# --- 2. Basic data preparation ---
# Keep only U.S. tweets
df_us = df[df["category"] == "U.S."].copy()
logging.info(f"U.S. tweets: {len(df_us)}")

# Add text length column
df_us["text_length"] = df_us["text"].str.len()

# Ensure int64 to prevent overflow on high-engagement accounts
df_us["retweet_count"] = df_us["retweet_count"].astype("int64")
df_us["favorite_count"] = df_us["favorite_count"].astype("int64")

# Engagement proxy: sum of retweets and favorites
df_us["engagement"] = df_us["retweet_count"] + df_us["favorite_count"]

# Save processed tweets
df_us.to_csv(cfg.DATA_PROCESSED / "tweets_processed.csv", index=False, encoding="utf-8")
logging.info(f"Saved processed tweets to {cfg.DATA_PROCESSED / 'tweets_processed.csv'}")

# --- 3. Load and process election data ---
df_elec = pd.read_csv(cfg.DATA_RAW / "election_results.csv", encoding="utf-8")

# Guard against division by zero
assert (df_elec["total_votes"] > 0).all(), "Found zero or negative total_votes"
df_elec["vote_share"] = df_elec["votes"] / df_elec["total_votes"]

# Save processed election data
df_elec.to_csv(cfg.DATA_PROCESSED / "election_data_processed.csv", index=False, encoding="utf-8")

# Also save as Stata .dta format
df_us.to_stata(cfg.DATA_PROCESSED / "tweets_processed.dta", write_index=False)
df_elec.to_stata(cfg.DATA_PROCESSED / "election_data_processed.dta", write_index=False)

logging.info("Data preparation complete.")

# AGGIUNTA DI UNA FRASE
# MI PIACE DEPLOYARE E FARE MERGE SU GITHUB, MI FA SENTIRE UN VERO DATA SCIENTIST!
