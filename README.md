# 🎧 Lana Del Rey Spotify Listening Advanced Data Analytics Pipeline

**End-to-End Data Analytics Project**

`Python` • `Docker` • `Oracle SQL` • `Star Schema Modelling` • `ETL` • `Power BI` • `DAX`

---
## 📌 Project overview

This project presents an end-to-end analysis of Lana Del Rey listening activity using my own personal Spotify Extended Streaming History data, transforming raw JSON data into a dimensional data warehouse in Oracle SQL and an interactive Power BI dashboard. 

The project follows this general architecture:  

```
Spotify Extended Streaming History
                │
                ▼
        Raw JSON Data
                │
                ▼
     Python Data Cleaning
       VS Code / MacBook
                │
                ▼
       Cleaned JSON Data
                │
                ▼
      JSON Validation
                │
                ▼
      Docker / PowerShell / Windows
                │
                ▼
       Oracle Database
                │
                ▼
       PL/SQL Processing
                │
                ▼
      Dimensional Model
        Star Schema
                │
                ▼
          SQL Analysis
                │
                ▼
          Power BI
                │
                ▼
        DAX Measures
                │
                ▼
      Interactive Dashboard
```

## 📂 Project Structure

```
spotify-advanced-data-analytics/
│
├── datasets/
│   └── Streaming_History_Audio_2021_LANA_DEL_REY_CLEAN.json
│
├── python/
│   ├── clean_spotify_json.py
│   └── validate_spotify_json.py
│
├── sql/
│   ├── 01_staging_tables_setup.sql
│   ├── 02_load_spotify_json_to_clob.sql
│   ├── 03_spotify_json_staging.sql
│   ├── 04_oracle_staging_validation.sql
│   ├── 05_star_schema_ddl.sql
│   ├── 06_
│   └── 07_analysis_queries.sql (posle vo materialized views)
│
├── powerbi/
│   ├── dax-measures.txt
│   └── Spotify_Lana_Del_Rey_Analysis.pbix
│
├── screenshots/
│   ├── 01-raw-data.png
│   ├── 02-python-cleaning.png
│   ├── 03-python-validation.png
│   ├── 04-docker-file-transfer.png
│   ├── 05-sql-step-1-staging-table-setup-img.png
│   ├── 06-
│   ├── 07-
│   ├── 08-
│   ├── oracle-staging.png
│   ├── data-model.png
│   └── powerbi-dashboard.png
│
└── README.md

```
> Personal Spotify listening-history data is not included in the public repository. The repository contains the processing logic, SQL scripts, documentation and selected screenshots instead.

---


## 1. 🛠️ Technologies Used

| Technology | Purpose |
| :--- | :--- |
| **Python** | Data cleaning and validation |
| **Visual Studio Code** | Python development environment |
| **Docker** | Oracle database container environment |
| **PowerShell** | File transfer between Windows host and Docker container |
| **Oracle Database** | Data storage, transformation and analytical modelling |
| **PL/SQL** | Database-side ETL and transformation |
| **SQL Developer** | Oracle database development and SQL execution |
| **Power BI** |	Business intelligence and visualization |
| **DAX** |	Analytical measures and calculations |
| **GitHub** |	Version control and portfolio documentation |

## 2. Data Source

The project uses Spotify Extended Streaming History data.

The original source contains individual listening events with information such as:

da se dodade od raw data screenshot
<!--
* **Timestamp**
* **Platform**
* **Playback duration**
* **Country**
* **Track**
* **Artist**
* **Album**
* **Playback start reason**
* **Playback end reason**
* **Shuffle status**
* **Skip status**
-->

The raw Spotify data contains records beyond the scope of this analysis, therefore a Python preprocessing stage was implemented before loading the analytical dataset into Oracle.

---

## 3. Python Data Cleaning

The first processing stage was performed locally on a macOS environment using Python and Visual Studio Code. The script loads the raw Spotify JSON payload, parses the stream collection, and filters it down to the target scope.

### Cleaning Objectives

The Python pipeline executes the following transformations:
1. **Filter Content:** Retains only music streaming records containing a valid track name.
2. **Isolate Artist:** Restricts the entire dataset exclusively to Lana Del Rey.
3. **Prune Schema:** Drops unnecessary source attributes to minimize the analytical payload.
4. **Normalize Fields:** Renames and maps variables into a clean, simplified structure.
5. **Serialize Output:** Exports the optimized dataset into a structural JSON file.

The target artist constraint is explicitly declared as:
```python
ARTIST_FILTER = "Lana Del Rey"
```

The records are evaluated and retained using the following structural logic:
```python
r.get("master_metadata_album_artist_name") == ARTIST_FILTER
```

### Cleaned Schema Structure
The resulting dataset is trimmed down to 11 core fields:

```yaml
- timestamp     - track_name    - reason_end
- platform      - artist_name   - shuffle
- ms_played     - album_name    - skipped
- country       - reason_start
```

* **Cleaned Dataset Export:** `Streaming_History_Audio_2021_LANA_DEL_REY_CLEAN.json`
* **Python Cleaning Script:** [`python/clean_spotify_json.py`](python/clean_spotify_json.py)

> **Execution Telemetry:** Upon completion, the script outputs runtime metrics detailing the *Original record count*, *Selected artist*, *Retained vs. removed records*, and the *Target output destination*.

![Python Data Cleaning Script](screenshots/clean-spotify-json-img.png)
---

## 4. Data Validation

Following the transformation layer, a dedicated validation suite is executed to guarantee data integrity before database ingestion.

### Core Validation Checks

* **JSON Validity:** Confirms the structural integrity of the file and verifies it loads successfully without parsing errors.
* **Artist Consistency:** Scans every single record to ensure absolute compliance with the filter criteria:
  ```python
  r["artist_name"] == "Lana Del Rey"
  ```
* **Track Completeness:** Assures data density by verifying that `track_name` contains zero null values.
* **Schema Uniformity:** Validates that every individual object block contains exactly **11 fields**.

###  Validation Output
When executed, the validation harness outputs the following status checks:
<!--
```diff
✓ All records belong to Lana Del Rey
✓ No records have a NULL track_name
✓ All records contain exactly 11 fields
✓ JSON validation successful
```
-->
* **Python Validation Script:** [`python/validate_spotify_json.py`](python/validate_spotify_json.py)

![Data Validation Harness](screenshots/validate-spotify-json-img.png)
---

## 5. Docker and Oracle Data Ingestion

To ensure scalability and performance, the verified JSON dataset is bypassed around the graphical interface client (SQL Developer) and injected directly into the Oracle Database container core.

```bash
# Transferring the dataset from the host machine straight to the container filesystem
docker cp "C:\Users\Acer\Desktop\SQL\Data\Streaming_History_Audio_2021_LANA_DEL_REY_CLEAN.json" oracle-db-free:/tmp/spotify_staging.json
```
![Staging Buffer](screenshots/docker-and-oracle-data-ingestion-img.png)

> **Design Architecture Decision:** Loading large JSON files directly through a client GUI caused me memory bottlenecks. Moving the payload directly into the container's virtual memory (`/tmp`) shifts processing overhead directly to the database server layer.

---

## 6. Oracle JSON Staging

 **Staging Table Setup:**

Two tables are created before the LOB binding step. `raw_json_load` acts as a bucket table to hold the raw JSON file as a `CLOB`, with a `CHECK` constraint (`raw_doc IS JSON`) enforcing that the content is valid JSON. `spotify_json_staging` is the structured relational destination table that the parsed JSON fields will ultimately be loaded into.

* **Staging Table Setup Script:** [`sql/01_staging_tables_setup.sql`](sql/01_staging_tables_setup.sql)
 
![Staging Table Setup Validation Script](screenshots/sql-step-1-staging-table-setup-img.png)

 **Server-Side LOB Binding:**

With the tables in place, the raw JSON file itself needs to get into `raw_json_load.raw_doc`. An Oracle `DIRECTORY` object is created pointing at the container's `/tmp` path, then a PL/SQL block uses `DBMS_LOB` to stream the raw JSON file directly into the `CLOB` column via a `BFILE` locator. This creates a database-side ingestion layer between the source JSON file and the relational staging tables.

* **Server-Side LOB Binding Script:** [`sql/02_load_spotify_json_to_clob.sql`](sql/02_load_spotify_json_to_clob.sql)

![Load Spotify JSON To CLOB Validation Script](screenshots/sql-step-2-server-side-lob-binding-img.png)

**JSON-to-Relational Parsing:**

Evaluated the native relational database engine `JSON_TABLE` function to extract structured fields out of the scalar JSON array. The relational stage parses 15,000+ data rows instantly with near-zero client processing overhead.

**Parallel Parsing Query Script:** [`sql/03_spotify_json_staging.sql`](sql/03_spotify_json_staging.sql)


**Validation:**

A few sanity checks confirm the load and parse steps worked as expected before moving on to Star Schema design.

**Staging Relational Environment Validation Script:** [`sql/04_oracle_staging_validation.sql`](sql/04_oracle_staging_validation.sql)

## 7. Core Star Schema DDL Design

The validated staging data is modelled into a dimensional star schema one central fact table surrounded by descriptive dimension tables optimized for BI/analytics tooling such as Power BI.

### Schema Overview

- **1 Fact table** — granular, event-level streaming records
- **3 Dimension tables** — descriptive context (songs, albums, platforms)

```
                 dim_albums
                     │
                     │
dim_platforms ── fact_streaming_history ── dim_songs
```

Technically this is closer to a snowflake schema, since `dim_songs` also references `dim_albums` directly (a song belongs to an album, independent of any given play event). This extra layer of normalization keeps album metadata from being duplicated across every song row.

### Entity Relationship Diagram

```mermaid
erDiagram
    DIM_ALBUMS ||--o{ DIM_SONGS : "contains"
    DIM_ALBUMS ||--o{ FACT_STREAMING_HISTORY : "played from"
    DIM_SONGS ||--o{ FACT_STREAMING_HISTORY : "played as"
    DIM_PLATFORMS ||--o{ FACT_STREAMING_HISTORY : "streamed on"

    DIM_ALBUMS {
        number album_id PK
        varchar2 album_name
        number release_year
        varchar2 era
        number total_tracks
        date created_at
    }

    DIM_SONGS {
        number song_id PK
        varchar2 track_name
        number album_id FK
        number duration_ms
        number track_number
        char is_explicit
    }

    DIM_PLATFORMS {
        number platform_id PK
        varchar2 raw_platform
        varchar2 clean_platform
        varchar2 os_name
    }

    FACT_STREAMING_HISTORY {
        number stream_id PK
        number song_id FK
        number album_id FK
        number platform_id FK
        timestamp played_at
        date play_date
        number ms_played
        number minutes_played
        number skipped_flag
        number shuffle_flag
    }
```

### Tables

#### `dim_albums` - Albums & Eras
Stores album-level metadata, including a custom "era" tag for grouping albums into stylistic/chronological periods (e.g. *Born to Die era*, *Norman Fucking Rockwell! era*).

| Column | Type | Notes |
|---|---|---|
| `album_id` | NUMBER (PK) | Auto-generated identity |
| `album_name` | VARCHAR2(100) | Required |
| `release_year` | NUMBER(4) | Constrained to 1900–2100 |
| `era` | VARCHAR2(50) | Custom grouping label |
| `total_tracks` | NUMBER | |
| `created_at` | DATE | Defaults to `SYSDATE` |

#### `dim_songs` - Deduplicated Songs / Tracks
One row per unique track, linked back to its parent album.

| Column | Type | Notes |
|---|---|---|
| `song_id` | NUMBER (PK) | Auto-generated identity |
| `track_name` | VARCHAR2(200) | Required |
| `album_id` | NUMBER (FK) | References `dim_albums` |
| `duration_ms` | NUMBER | Track length in milliseconds |
| `track_number` | NUMBER | |
| `is_explicit` | CHAR(1) | `'Y'`/`'N'` flag |

#### `dim_platforms` - Client Platforms & Operating Systems
Normalizes the raw platform strings from the streaming export data into clean, analysis-friendly categories.

| Column | Type | Notes |
|---|---|---|
| `platform_id` | NUMBER (PK) | Auto-generated identity |
| `raw_platform` | VARCHAR2(100) | Original string, unique |
| `clean_platform` | VARCHAR2(30) | Normalized: `mobile` / `desktop` / `web` / `partner` |
| `os_name` | VARCHAR2(30) | e.g. `OS X`, `iOS`, `Windows`, `Chrome` |

#### `fact_streaming_history` - Granular Streaming Events
The core fact table — one row per individual streaming event.

| Column | Type | Notes |
|---|---|---|
| `stream_id` | NUMBER (PK) | Always-generated identity |
| `song_id` | NUMBER (FK) | References `dim_songs` |
| `album_id` | NUMBER (FK) | References `dim_albums` |
| `platform_id` | NUMBER (FK) | References `dim_platforms` |
| `played_at` | TIMESTAMP(6) | Exact playback timestamp |
| `play_date` | DATE | Date key, used for partitioning & calendar joins |
| `ms_played` | NUMBER | Milliseconds played |
| `minutes_played` | NUMBER(10,3) | **Computed column**: `ms_played / 60000`, rounded |
| `skipped_flag` | NUMBER(1) | `0`/`1` |
| `shuffle_flag` | NUMBER(1) | `0`/`1` |

**Partitioning:** Range-partitioned on `play_date` with monthly auto-intervals (`INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))`), starting from an initial partition covering everything before `2021-01-01`. This keeps the fact table performant as history accumulates and prunes cleanly on date-range queries.

### Indexes

To optimize typical star-schema BI queries (date filters + dimension joins):

- `idx_fact_play_date` - speeds up date-range filtering/reporting
- `idx_fact_song_fk` / `idx_fact_album_fk` - speeds up joins back to dimensions
- `idx_songs_search` - function-based index on `UPPER(track_name)` for case-insensitive song search

### Data Integrity

- Foreign keys enforce referential integrity between the fact table and all three dimensions.
- `CHECK` constraints validate flag columns (`skipped_flag`, `shuffle_flag`, `is_explicit`) and bound `release_year` to a sane range.
- Tables are dropped in **topological order** (fact before dimensions) via a `PL/SQL` block at the top of the script, making the DDL safely re-runnable during development.

* **Star Schema DDL Script:** [`sql/05_star_schema_ddl.sql`](sql/05_star_schema_ddl.sql)

![Dimensional Data Model](screenshots/07-data-model.png)

---

## 8. Database Programming (PL/SQL Transformation Layer)

<!--

## 7. JSON to Relational Mapping

Leveraging Oracle’s native `JSON_TABLE` relational expression engine, the static JSON array layout is broken down and mapped dynamically into relational database table rows.

* **Step 1 — Staging Table Setup Script:** 


### Relational Staging Layout
The target relational columns correspond directly to the source attributes:

da se dodade screenshot

This persistent, relational staging baseline serves as the raw source of truth for all subsequent SQL transformations and PL/SQL dimensional modeling workflows.

---




## 📂 Dataset

Main objective is to keep only artist Lana Del Rey records in the JSON file and remove private metadata.

---

## 🛠️  1. Data Cleaning — Visual Studio Code

### Data Cleaning Process
![Data Cleaning Process](2.scripts/clean-spotify-json-img.png)

### Data Validation
![Data Validation Process](2,scripts/validate-spotify-json-img.png)
-->
---

## 👩🏻‍💻 Author

**Dijana Lozanoska, MSc**  
Microsoft Certified SQL Data Analyst

Focus areas:

* SQL & PL/SQL
* Power BI
* DAX
* Data Analytics
* ETL
* Data Modelling
* Business Intelligence

##
⭐ This project is part of my data analytics portfolio and demonstrates practical application of Python, Oracle SQL/PLSQL, dimensional modelling and Power BI.

