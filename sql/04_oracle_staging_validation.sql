 -- Row count and cardinality sanity check
   SELECT COUNT(*), COUNT(DISTINCT track_name) FROM spotify_json_staging;

   -- Spot-check the first few parsed rows
   SELECT * FROM spotify_json_staging FETCH FIRST 10 ROWS ONLY;

   -- Confirm no rows were dropped between raw JSON and staging
   SELECT
       (SELECT JSON_VALUE(raw_doc, '$.size()' RETURNING NUMBER) FROM raw_json_load) AS raw_count,
       (SELECT COUNT(*) FROM spotify_json_staging) AS staging_count
   FROM dual;

   -- Check for NULLs in fields that should always be populated
   SELECT
       COUNT(*) FILTER (WHERE track_name IS NULL)   AS null_track,
       COUNT(*) FILTER (WHERE timestamp_str IS NULL) AS null_ts,
       COUNT(*) FILTER (WHERE ms_played IS NULL)      AS null_ms
   FROM spotify_json_staging;

   -- Confirm ms_played has no negative/nonsensical values
   SELECT MIN(ms_played), MAX(ms_played), AVG(ms_played)
   FROM spotify_json_staging;

   -- Check the distinct value sets for expected enum-like fields
   SELECT DISTINCT shuffle FROM spotify_json_staging;
   SELECT DISTINCT reason_start FROM spotify_json_staging;
   SELECT DISTINCT reason_end FROM spotify_json_staging;

   -- Confirm timestamp strings are parseable / in expected range
   SELECT
       MIN(TO_TIMESTAMP_TZ(timestamp_str, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) AS earliest,
       MAX(TO_TIMESTAMP_TZ(timestamp_str, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) AS latest
   FROM spotify_json_staging;
