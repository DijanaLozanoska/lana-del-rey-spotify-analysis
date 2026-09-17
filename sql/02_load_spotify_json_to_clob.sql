DECLARE
    v_bfile  BFILE;
    v_clob   CLOB;
    v_dir    VARCHAR2(30) := 'TMP_JSON_DIR';
BEGIN
    -- Map an internal Oracle Directory object to the container's /tmp path
    EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY ' || v_dir || ' AS ''/tmp''';
    
    -- Initialize an empty CLOB and target it for update streaming
    INSERT INTO raw_json_load (raw_doc) VALUES (EMPTY_CLOB()) RETURNING raw_doc INTO v_clob;
    
    -- Load the file binary contexts natively into database clusters
    v_bfile := BFILENAME(v_dir, 'spotify_staging.json');
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(v_clob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.FILECLOSE(v_bfile);
    
    COMMIT;
END;
