-- Confirm the CLOB was loaded and check its size
SELECT id, DBMS_LOB.GETLENGTH(raw_doc) AS clob_length
FROM raw_json_load;

-- Peek at the first characters to confirm it's valid JSON-looking content
SELECT ASCIISTR(DBMS_LOB.SUBSTR(raw_doc, 200, 1)) AS preview
FROM raw_json_load;
