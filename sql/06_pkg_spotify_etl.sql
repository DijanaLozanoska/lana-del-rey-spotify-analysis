-- ============================================================================
-- Spotify Advanced Data Analytics Pipeline
-- Oracle SQL / PL/SQL ETL Layer
-- ============================================================================
-- Purpose:
--   1. Seed canonical Lana Del Rey album/song dimensions
--   2. Normalize album variants in the staging layer
--   3. Register listening platforms
--   4. Transform staging records into the streaming fact table
--
-- Data flow:
--   spotify_json_staging
--          |
--          v
--   deduplicate_and_merge_albums
--          |
--          v
--   dim_albums / dim_songs / dim_platforms
--          |
--          v
--   fact_streaming_history
-- ============================================================================


CREATE OR REPLACE PACKAGE pkg_spotify_etl AS
    PROCEDURE seed_static_dimensions;
    PROCEDURE deduplicate_and_merge_albums;
    PROCEDURE execute_fact_transform;
END pkg_spotify_etl;
/

CREATE OR REPLACE PACKAGE BODY pkg_spotify_etl AS

    -- =========================================================================
    -- SEED STATIC DIMENSIONS
    -- =========================================================================
    PROCEDURE seed_static_dimensions AS
    BEGIN

        -- ---------------------------------------------------------------------
        -- Populate canonical album dimension
        -- ---------------------------------------------------------------------

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Born To Die', 2012, 'Born To Die Era', 12);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Honeymoon', 2015, 'Honeymoon Era', 14);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Ultraviolence', 2014, 'Ultraviolence Era', 12);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Lust For Life', 2017, 'Lust for Life Era', 16);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Norman Fucking Rockwell!', 2019, 'NFR Era', 14);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Chemtrails Over The Country Club', 2021, 'Chemtrails Era', 11);

        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Blue Banisters', 2021, 'Blue Banisters Era', 15);

        -- Consolidated category for soundtrack and remix records
        INSERT INTO dim_albums
            (album_name, release_year, era, total_tracks)
        VALUES
            ('Other Lana Del Rey (Soundtracks and Remixes)',
             NULL,
             'Soundtracks and Remixes',
             NULL);


        -- ---------------------------------------------------------------------
        -- Map selected source track profiles to canonical album dimension rows
        -- ---------------------------------------------------------------------

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Radio', album_id, 224000, 8, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Religion', album_id, 320000, 9, 'N'
        FROM dim_albums
        WHERE album_name = 'Honeymoon';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Brooklyn Baby', album_id, 307000, 4, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Music To Watch Boys To', album_id, 284000, 2, 'N'
        FROM dim_albums
        WHERE album_name = 'Honeymoon';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Fucked My Way Up To The Top', album_id, 218000, 9, 'Y'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'White Mustang', album_id, 240000, 4, 'N'
        FROM dim_albums
        WHERE album_name = 'Lust For Life';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Burning Desire', album_id, 249000, 8, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Summertime Sadness', album_id, 265000, 11, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Cinnamon Girl', album_id, 295000, 7, 'N'
        FROM dim_albums
        WHERE album_name = 'Norman Fucking Rockwell!';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Ride', album_id, 323000, 1, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Without You', album_id, 229293, 10, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Old Money', album_id, 271480, 10, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Tulsa Jesus Freak', album_id, 215673, 3, 'N'
        FROM dim_albums
        WHERE album_name = 'Chemtrails Over The Country Club';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Lust For Life (with The Weeknd)', album_id, 264066, 2, 'N'
        FROM dim_albums
        WHERE album_name = 'Lust For Life';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Let Me Love You Like A Woman', album_id, 200661, 4, 'N'
        FROM dim_albums
        WHERE album_name = 'Chemtrails Over The Country Club';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Sad Girl', album_id, 317760, 6, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Pretty When You Cry', album_id, 234146, 7, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Doin'' Time', album_id, 202192, 5, 'N'
        FROM dim_albums
        WHERE album_name = 'Norman Fucking Rockwell!';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Florida Kilos', album_id, 256040, 14, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Breaking Up Slowly', album_id, 177535, 9, 'N'
        FROM dim_albums
        WHERE album_name = 'Chemtrails Over The Country Club';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Body Electric', album_id, 233440, 4, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Love', album_id, 272742, 1, 'N'
        FROM dim_albums
        WHERE album_name = 'Lust For Life';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Money Power Glory', album_id, 270680, 8, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Fuck it I love you', album_id, 218287, 4, 'Y'
        FROM dim_albums
        WHERE album_name = 'Norman Fucking Rockwell!';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT '13 Beaches', album_id, 295569, 3, 'N'
        FROM dim_albums
        WHERE album_name = 'Lust For Life';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'National Anthem', album_id, 230533, 6, 'N'
        FROM dim_albums
        WHERE album_name = 'Born To Die';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Cruel World', album_id, 399083, 1, 'N'
        FROM dim_albums
        WHERE album_name = 'Ultraviolence';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Dealer', album_id, 216642, 8, 'N'
        FROM dim_albums
        WHERE album_name = 'Blue Banisters';

        INSERT INTO dim_songs
            (track_name, album_id, duration_ms, track_number, is_explicit)
        SELECT 'Swan Song', album_id, 323475, 14, 'N'
        FROM dim_albums
        WHERE album_name = 'Honeymoon';

        COMMIT;
    END seed_static_dimensions;


    -- =========================================================================
    -- DEDUPLICATE AND MERGE ALBUMS
    -- =========================================================================
    -- Canonicalizes album names in the staging layer before fact loading.
    --
    -- Business rules:
    --   Born To Die variants                                  -> Born To Die
    --   Arcadia / Arcadia                                     -> Blue Banisters
    --   Let Me Love You Like A Woman / same album             -> Chemtrails...
    --   Gatsby / Summertime Sadness remix / Young And Beautiful
    --                                                           -> Other Lana...
    -- =========================================================================
    PROCEDURE deduplicate_and_merge_albums AS
    BEGIN

        -- 1. Merge Born To Die album-name variants
        UPDATE spotify_json_staging
        SET album_name = 'Born To Die'
        WHERE UPPER(album_name) LIKE '%BORN TO DIE%'
          AND album_name <> 'Born To Die';


        -- 2. Arcadia was supplied as its own album in the source data.
        --    Normalize it to the Blue Banisters album.
        UPDATE spotify_json_staging
        SET album_name = 'Blue Banisters'
        WHERE track_name = 'Arcadia'
          AND album_name = 'Arcadia';


        -- 3. Let Me Love You Like A Woman belongs to
        --    Chemtrails Over The Country Club.
        UPDATE spotify_json_staging
        SET album_name = 'Chemtrails Over The Country Club'
        WHERE track_name = 'Let Me Love You Like A Woman'
          AND album_name = 'Let Me Love You Like A Woman';


        -- 4. Consolidate soundtrack and remix records into one
        --    analytical album category.
        UPDATE spotify_json_staging
        SET album_name = 'Other Lana Del Rey (Soundtracks and Remixes)'
        WHERE album_name IN (
            'Music From Baz Luhrmann''s Film The Great Gatsby',
            'Summertime Sadness (Lana Del Rey Vs. Cedric Gervais)',
            'Young And Beautiful'
        );

        COMMIT;
    END deduplicate_and_merge_albums;


    -- =========================================================================
    -- EXECUTE FACT TRANSFORM
    -- =========================================================================
    PROCEDURE execute_fact_transform AS
    BEGIN

        -- 1. Dynamically identify and register unseen source platforms.
        MERGE INTO dim_platforms d
        USING (
            SELECT DISTINCT
                   platform,
                   CASE
                       WHEN LOWER(platform) LIKE '%iphone%'
                         OR LOWER(platform) LIKE '%ios%'
                         OR LOWER(platform) LIKE '%ipad%'
                           THEN 'mobile'

                       WHEN LOWER(platform) LIKE '%windows%'
                         OR LOWER(platform) LIKE '%os x%'
                         OR LOWER(platform) LIKE '%desktop%'
                           THEN 'desktop'

                       ELSE 'web_player'
                   END AS c_plat,

                   CASE
                       WHEN LOWER(platform) LIKE '%windows%'
                           THEN 'Windows'

                       WHEN LOWER(platform) LIKE '%os x%'
                           THEN 'macOS'

                       WHEN LOWER(platform) LIKE '%ios%'
                         OR LOWER(platform) LIKE '%ipad%'
                           THEN 'iOS'

                       ELSE 'Web App'
                   END AS os_n

            FROM spotify_json_staging
            WHERE platform IS NOT NULL
        ) s
        ON (d.raw_platform = s.platform)

        WHEN NOT MATCHED THEN
            INSERT
                (raw_platform, clean_platform, os_name)
            VALUES
                (s.platform, s.c_plat, s.os_n);


        -- 2. Load the streaming fact table.
        INSERT INTO fact_streaming_history
            (
                song_id,
                album_id,
                platform_id,
                played_at,
                play_date,
                ms_played,
                skipped_flag,
                shuffle_flag
            )
        SELECT
            t.song_id,
            a.album_id,
            p.platform_id,

            TO_TIMESTAMP(
                stg.timestamp_str,
                'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            ) AS played_at,

            TRUNC(
                TO_TIMESTAMP(
                    stg.timestamp_str,
                    'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                )
            ) AS play_date,

            stg.ms_played,

            CASE
                WHEN LOWER(stg.skipped) = 'true'
                  OR stg.ms_played < 30000
                    THEN 1
                ELSE 0
            END AS skipped_flag,

            CASE
                WHEN LOWER(stg.shuffle) = 'true'
                    THEN 1
                ELSE 0
            END AS shuffle_flag

        FROM spotify_json_staging stg

        JOIN dim_albums a
          ON stg.album_name = a.album_name

        JOIN dim_songs t
          ON stg.track_name = t.track_name
         AND t.album_id = a.album_id

        JOIN dim_platforms p
          ON stg.platform = p.raw_platform;


        COMMIT;
    END execute_fact_transform;

END pkg_spotify_etl;
/
