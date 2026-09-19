-- Confirm raw_json_load structure exists and is empty before loading
SELECT COUNT(*) FROM raw_json_load;

-- Confirm spotify_json_staging structure is in place
SELECT COUNT(*) FROM spotify_json_staging;
