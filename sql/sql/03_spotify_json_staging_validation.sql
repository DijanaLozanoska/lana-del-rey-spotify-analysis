-- Confirm rows were parsed into the staging table
SELECT COUNT(*) FROM spotify_json_staging;

-- Spot-check a few parsed rows
SELECT * FROM spotify_json_staging FETCH FIRST 5 ROWS ONLY;
