import json

INPUT_FILE = "/Users/dijanalozanoska/Desktop/GIT HUB PORTFOLIO/Spotify Extended Streaming History/Streaming_History_Audio_2021.json"
OUTPUT_FILE = "/Users/dijanalozanoska/Desktop/GIT HUB PORTFOLIO/Spotify Extended Streaming History/Streaming_History_Audio_2021_LANA_DEL_REY_CLEAN.json"

ARTIST_FILTER = "Lana Del Rey"

with open(INPUT_FILE, encoding="utf-8") as f:
    data = json.load(f)

cleaned = []

for r in data:

    # Keep music records only
    if not r.get("master_metadata_track_name"):
        continue

    # Keep selected artist only
    if r.get("master_metadata_album_artist_name") != ARTIST_FILTER:
        continue

    cleaned.append({
        "timestamp": r.get("ts"),
        "platform": r.get("platform"),
        "ms_played": r.get("ms_played"),
        "country": r.get("conn_country"),
        "track_name": r.get("master_metadata_track_name"),
        "artist_name": r.get("master_metadata_album_artist_name"),
        "album_name": r.get("master_metadata_album_album_name"),
        "reason_start": r.get("reason_start"),
        "reason_end": r.get("reason_end"),
        "shuffle": r.get("shuffle"),
        "skipped": r.get("skipped")
    })

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(cleaned, f, indent=2, ensure_ascii=False)

print("=" * 50)
print("SPOTIFY DATA CLEANING COMPLETE")
print("=" * 50)
print(f"Original records:       {len(data):,}")
print(f"Artist filter:          {ARTIST_FILTER}")
print(f"Lana records retained:  {len(cleaned):,}")
print(f"Records removed:        {len(data) - len(cleaned):,}")
print(f"Output file:            {OUTPUT_FILE}")
print("=" * 50)