SELECT COUNT(*), COUNT(DISTINCT track_name) FROM spotify_json_staging;

SELECT * FROM spotify_json_staging FETCH FIRST 10 ROWS ONLY;