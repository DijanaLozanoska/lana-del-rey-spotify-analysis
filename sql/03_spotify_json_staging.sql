INSERT INTO spotify_json_staging
SELECT jt.*
FROM raw_json_load r,
     JSON_TABLE(r.raw_doc, '$[*]'
         COLUMNS (
             timestamp_str VARCHAR2(50)  PATH '$.timestamp',
             platform      VARCHAR2(100) PATH '$.platform',
             ms_played     NUMBER        PATH '$.ms_played',
             country       VARCHAR2(10)  PATH '$.country',
             track_name    VARCHAR2(255) PATH '$.track_name',
             artist_name   VARCHAR2(255) PATH '$.artist_name',
             album_name    VARCHAR2(255) PATH '$.album_name',
             reason_start  VARCHAR2(50)  PATH '$.reason_start',
             reason_end    VARCHAR2(50)  PATH '$.reason_end',
             shuffle       VARCHAR2(10)  PATH '$.shuffle',
             skipped       VARCHAR2(10)  PATH '$.skipped'
         )
     ) jt;

COMMIT;

   -- Verify Results

-- Confirm rows were parsed into the staging table
SELECT COUNT(*) FROM spotify_json_staging;

-- Spot-check a few parsed rows
SELECT * FROM spotify_json_staging FETCH FIRST 5 ROWS ONLY;
