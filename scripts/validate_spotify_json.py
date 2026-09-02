import json

FILE = "/Users/dijanalozanoska/Desktop/GIT HUB PORTFOLIO/Spotify Extended Streaming History/Streaming_History_Audio_2021_LANA_DEL_REY_CLEAN.json"

with open(FILE, encoding="utf-8") as f:
    data = json.load(f)

print(f"Valid JSON: {len(data):,} records")

print("\nFields:")
for field in data[0].keys():
    print(f" - {field}")

print("\nArtists:")
artists = set(r["artist_name"] for r in data)

for artist in artists:
    print(f" - {artist}")

print("\nValidation:")

assert all(
    r["artist_name"] == "Lana Del Rey"
    for r in data
)

assert all(
    r["track_name"] is not None
    for r in data
)

assert all(
    len(r.keys()) == 11
    for r in data
)

print("✓ All records belong to Lana Del Rey")
print("✓ No records have a NULL track_name")
print("✓ All records contain exactly 11 fields")
print("✓ JSON validation successful")