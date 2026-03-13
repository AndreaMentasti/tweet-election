#----------------------------------------------------------------------------#
# Set libraries
import os
import pandas as pd
import config

#----------------------------------------------------------------------------#

P = config.change_paths()
rawdata_dir = str(P["rawdata"])
processed_dir = str(P["processed"])

#----------------------------------------------------------------------------#

# 1. Load raw tweets
df = pd.read_csv(os.path.join(rawdata_dir, "sample_tweets.csv"))
print(f"Loaded {len(df)} tweets")

# 2. Basic data preparation
# Keep only U.S. tweets
df_us = df[df["category"] == "U.S."].copy()
print(f"U.S. tweets: {len(df_us)}")

# Add text length column
df_us["text_length"] = df_us["text"].str.len()

# Add engagement score
df_us["engagement"] = df_us["retweet_count"] + df_us["favorite_count"]

# Save processed tweets
df_us.to_csv(os.path.join(processed_dir, "tweets_processed.csv"), index=False)
print(f"Saved processed tweets to {processed_dir}/tweets_processed.csv")

# 3. Load and process election data
df_elec = pd.read_csv(os.path.join(rawdata_dir, "election_results.csv"))
df_elec["vote_share"] = df_elec["votes"] / df_elec["total_votes"]

# Save processed election data
df_elec.to_csv(os.path.join(processed_dir, "election_data_processed.csv"), index=False)

# Also save as Stata .dta format
df_us.to_stata(os.path.join(processed_dir, "tweets_processed.dta"), write_index=False)
df_elec.to_stata(os.path.join(processed_dir, "election_data_processed.dta"), write_index=False)

print("Data preparation complete.")
