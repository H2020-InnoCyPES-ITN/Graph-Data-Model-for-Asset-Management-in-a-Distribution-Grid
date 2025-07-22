-- ====================================================================
-- PostgreSQL Script to Create and Populate a Relational Asset Model
-- ====================================================================
-- This script creates a relational schema equivalent to the graph model
-- and loads it with a similar volume of data.
--
-- Requirements: PostgreSQL with the PostGIS extension enabled.
-- ====================================================================

-- Enable the PostGIS extension if it's not already enabled.
-- This command must be run before any tables using the GEOMETRY type are created.
CREATE EXTENSION IF NOT EXISTS postgis;

-- Drop existing tables to ensure a clean slate
DROP TABLE IF EXISTS failure_affects_asset, organisation_operates_asset, substation_feeds_assetcontainer, junction_joins_acls, work_order, failure_event, activity_record, junction, ac_line_segment, asset_container, substation, organisation CASCADE;

-- ====================================================================
-- 1. Table Definitions
-- ====================================================================
-- Each table corresponds to a node type in the graph model.

CREATE TABLE organisation (
    mrid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    organisation_role VARCHAR(100)
);

CREATE TABLE substation (
    mrid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    installation_date DATE,
    location GEOMETRY(POINT, 4326) -- Using PostGIS for spatial data
);

CREATE TABLE asset_container (
    mrid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    total_length NUMERIC,
    number_of_subsections INT
);

CREATE TABLE ac_line_segment (
    mrid VARCHAR(50) PRIMARY KEY,
    asset_container_mrid VARCHAR(50) REFERENCES asset_container(mrid),
    length NUMERIC,
    installation_date DATE,
    status VARCHAR(50),
    is_repair_section BOOLEAN,
    conductor_material VARCHAR(100),
    manufacturer VARCHAR(100),
    number_of_joints INT,
    shape GEOMETRY(LINESTRING, 4326) -- Added geometry column for the line shape
);

CREATE TABLE junction (
    mrid VARCHAR(50) PRIMARY KEY,
    location GEOMETRY(POINT, 4326)
);

CREATE TABLE activity_record (
    mrid VARCHAR(50) PRIMARY KEY,
    event_type VARCHAR(100),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    location GEOMETRY(POINT, 4326)
);

CREATE TABLE failure_event (
    mrid VARCHAR(50) PRIMARY KEY,
    event_type VARCHAR(100),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    cause VARCHAR(255),
    failure_mode VARCHAR(255),
    location GEOMETRY(POINT, 4326)
);

CREATE TABLE work_order (
    mrid VARCHAR(50) PRIMARY KEY,
    related_failure_mrid VARCHAR(50) REFERENCES failure_event(mrid),
    event_type VARCHAR(100),
    start_time TIMESTAMP,
    end_time TIMESTAMP
);


-- ====================================================================
-- 2. Junction Tables for Relationships
-- ====================================================================
-- These tables model the many-to-many relationships from the graph.

CREATE TABLE organisation_operates_asset (
    organisation_mrid VARCHAR(50) REFERENCES organisation(mrid),
    -- Using a generic asset_mrid and asset_type to link to multiple tables
    asset_mrid VARCHAR(50),
    asset_type VARCHAR(50), -- e.g., 'substation', 'asset_container'
    PRIMARY KEY (organisation_mrid, asset_mrid)
);

CREATE TABLE failure_affects_asset (
    failure_mrid VARCHAR(50) REFERENCES failure_event(mrid),
    asset_mrid VARCHAR(50),
    asset_type VARCHAR(50), -- 'ac_line_segment' or 'junction'
    PRIMARY KEY (failure_mrid, asset_mrid)
);

CREATE TABLE junction_joins_acls (
    junction_mrid VARCHAR(50) REFERENCES junction(mrid),
    ac_line_segment_mrid VARCHAR(50) REFERENCES ac_line_segment(mrid),
    PRIMARY KEY (junction_mrid, ac_line_segment_mrid)
);


-- ====================================================================
-- 3. Data Generation
-- ====================================================================
-- This PL/pgSQL block generates and inserts the sample data.

DO $$
DECLARE
    i INT;
    org_mrid VARCHAR;
    ac_mrid VARCHAR;
    ls_mrid VARCHAR;
    fe_mrid VARCHAR;
    wo_mrid VARCHAR;
    j_mrid VARCHAR;
    ar_mrid VARCHAR;
    sub_mrid VARCHAR;
    random_org_mrid VARCHAR;
    random_ac_mrid VARCHAR;
    random_ls_mrid VARCHAR;
    random_j_mrid VARCHAR;
    random_fe_mrid VARCHAR;
BEGIN
    -- Organisations (5 DSOs)
    INSERT INTO organisation (mrid, name, organisation_role) VALUES
    ('ORG1', 'Radius Elnet', 'Operator'),
    ('ORG2', 'N1', 'Operator'),
    ('ORG3', 'Cerius', 'Operator'),
    ('ORG4', 'TREFOR Elnet', 'Operator'),
    ('ORG5', 'SEAS-NVE', 'Operator');

    -- Substations (50)
    FOR i IN 1..50 LOOP
        sub_mrid := 'SUB' || i;
        INSERT INTO substation (mrid, name, installation_date, location)
        VALUES (sub_mrid, 'Substation ' || i, '1990-01-01'::date + (random() * 30 * 365)::int * '1 day'::interval, ST_SetSRID(ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5), 4326));

        -- Assign to an organisation
        SELECT mrid INTO random_org_mrid FROM organisation ORDER BY random() LIMIT 1;
        INSERT INTO organisation_operates_asset (organisation_mrid, asset_mrid, asset_type) VALUES (random_org_mrid, sub_mrid, 'substation');
    END LOOP;

    -- Asset Containers (100)
    FOR i IN 1..100 LOOP
        ac_mrid := 'AC' || i;
        INSERT INTO asset_container (mrid, name) VALUES (ac_mrid, 'MV System ' || i);

        -- Assign to an organisation
        SELECT mrid INTO random_org_mrid FROM organisation ORDER BY random() LIMIT 1;
        INSERT INTO organisation_operates_asset (organisation_mrid, asset_mrid, asset_type) VALUES (random_org_mrid, ac_mrid, 'asset_container');
    END LOOP;

    -- AC Line Segments (500)
    FOR i IN 1..500 LOOP
        ls_mrid := 'LS' || i;
        SELECT mrid INTO random_ac_mrid FROM asset_container ORDER BY random() LIMIT 1;
        INSERT INTO ac_line_segment (mrid, asset_container_mrid, length, installation_date, status, is_repair_section, conductor_material, manufacturer, shape)
        VALUES (
            ls_mrid,
            random_ac_mrid,
            0.5 + random() * 2.5,
            '2000-01-01'::date + (random() * 23 * 365)::int * '1 day'::interval,
            CASE WHEN random() < 0.05 THEN 'OutOfService' ELSE 'InService' END,
            random() < 0.2,
            CASE WHEN random() < 0.5 THEN 'Copper' ELSE 'Aluminum' END,
            CASE WHEN random() < 0.33 THEN 'Nexans' WHEN random() < 0.66 THEN 'Prysmian' ELSE 'NKT' END,
            ST_SetSRID(ST_MakeLine(ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5), ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5)), 4326)
        );
    END LOOP;

    -- Junctions (300)
    FOR i IN 1..300 LOOP
        j_mrid := 'J' || i;
        INSERT INTO junction (mrid, location)
        VALUES (j_mrid, ST_SetSRID(ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5), 4326));

        -- Connect junction to 2 random line segments
        INSERT INTO junction_joins_acls (junction_mrid, ac_line_segment_mrid)
        SELECT j_mrid, mrid FROM ac_line_segment ORDER BY random() LIMIT 2;
    END LOOP;

    -- Failure Events (200)
    FOR i IN 1..200 LOOP
        fe_mrid := 'FE' || i;
        INSERT INTO failure_event (mrid, event_type, start_time, end_time, cause, failure_mode, location)
        VALUES (
            fe_mrid,
            'CableFailure',
            '2020-01-01'::timestamp + (random() * 1825 * 86400)::int * '1 second'::interval,
            '2020-01-01'::timestamp + (random() * 1825 * 86400)::int * '1 second'::interval + (random() * 3 * 86400)::int * '1 second'::interval,
            (ARRAY['Digging Incident', 'Lightning Strike', 'Flooding', 'Aging', 'Material Defect', 'High Load'])[floor(random() * 6 + 1)],
            (ARRAY['Mechanical Damage', 'Electrical Fault', 'Insulation Failure', 'Joint Failure', 'Overheating', 'Corrosion'])[floor(random() * 6 + 1)],
            ST_SetSRID(ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5), 4326)
        );

        -- Create AFFECTS relationships to nearby assets
        -- Affects nearby Line Segments
        INSERT INTO failure_affects_asset (failure_mrid, asset_mrid, asset_type)
        SELECT fe.mrid, ls.mrid, 'ac_line_segment'
        FROM failure_event fe, ac_line_segment ls
        WHERE fe.mrid = fe_mrid -- Filter to the failure event from the current loop iteration
          AND ST_DWithin(fe.location, ls.shape, 0.05);

        -- Affects nearby Junctions
        INSERT INTO failure_affects_asset (failure_mrid, asset_mrid, asset_type)
        SELECT fe.mrid, j.mrid, 'junction'
        FROM failure_event fe, junction j
        WHERE fe.mrid = fe_mrid -- Filter to the failure event from the current loop iteration
          AND ST_DWithin(fe.location, j.location, 0.05);
    END LOOP;

    -- Work Orders (150 repairs)
    FOR i IN 1..150 LOOP
        wo_mrid := 'WO' || i;
        SELECT mrid INTO random_fe_mrid FROM failure_event ORDER BY random() LIMIT 1;
        INSERT INTO work_order (mrid, related_failure_mrid, event_type, start_time, end_time)
        VALUES (
            wo_mrid,
            random_fe_mrid,
            'CableRepair',
            (SELECT end_time + '1 day'::interval FROM failure_event WHERE mrid = random_fe_mrid),
            (SELECT end_time + '2 days'::interval FROM failure_event WHERE mrid = random_fe_mrid)
        );
    END LOOP;

    -- Activity Records (100 external events)
    FOR i IN 1..100 LOOP
        ar_mrid := 'AR' || i;
        INSERT INTO activity_record (mrid, event_type, start_time, end_time, location)
        VALUES (
            ar_mrid,
            (ARRAY['DiggingActivity', 'Lightning', 'Flood', 'HeatWave', 'ColdWave'])[floor(random() * 5 + 1)],
            '2020-01-01'::timestamp + (random() * 1825 * 86400)::int * '1 second'::interval,
            '2020-01-01'::timestamp + (random() * 1825 * 86400)::int * '1 second'::interval + (random() * 7 * 86400)::int * '1 second'::interval,
            ST_SetSRID(ST_MakePoint(9.8 + random() * 3.0, 55.0 + random() * 2.5), 4326)
        );
    END LOOP;

END $$;
