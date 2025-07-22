-- =================================================================
-- FINAL DATABASE SETUP SCRIPT
-- The BEGIN command starts a transaction block. If any statement
-- fails before the COMMIT, all changes are automatically rolled back.
-- =================================================================

BEGIN; -- Starts the transaction. All subsequent commands are part of this block.

-- ---------------------------------------
-- SECTION 0: ENABLE EXTENSIONS 🚀
-- ---------------------------------------
CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------
-- SECTION 1: CLEAN UP 🧹
-- ---------------------------------------
DROP TABLE IF EXISTS dso CASCADE;
DROP TABLE IF EXISTS medium_voltage_radial CASCADE;
DROP TABLE IF EXISTS substation CASCADE;
DROP TABLE IF EXISTS main_substation CASCADE;
DROP TABLE IF EXISTS secondary_substation CASCADE;
DROP TABLE IF EXISTS medium_voltage_cable_system CASCADE;
DROP TABLE IF EXISTS medium_voltage_cable_subsection CASCADE;
DROP TABLE IF EXISTS cable_events CASCADE;
DROP TABLE IF EXISTS cable_failures CASCADE;
DROP TABLE IF EXISTS cable_repairs CASCADE;
DROP TABLE IF EXISTS external_events CASCADE;
DROP TABLE IF EXISTS digging_activities CASCADE;


-- ---------------------------------------
-- SECTION 2: CREATE TABLES (SCHEMA DEFINITION) 🏗️
-- ---------------------------------------
CREATE TABLE dso (
    id INTEGER NOT NULL,
    name VARCHAR,
    cvr INTEGER,
    geometry GEOMETRY('GEOMETRY', 4326)
);

CREATE TABLE medium_voltage_radial (
    id INTEGER NOT NULL,
    name VARCHAR(255),
    load_embeddings FLOAT[],
    max_loading FLOAT,
    median_loading FLOAT,
    upper_quartile_loading FLOAT
);

CREATE TABLE substation (
    id VARCHAR(255) NOT NULL,
    dso_id INTEGER,
    number_of_consumers INTEGER,
    installation_date DATE,
    geometry GEOMETRY('POINT', 4326),
    station_class VARCHAR(255)
);

CREATE TABLE main_substation (
    id VARCHAR(255) NOT NULL,
    name VARCHAR(255)
);

CREATE TABLE secondary_substation (
    id VARCHAR(255) NOT NULL,
    parent_station_id VARCHAR(255)
);

CREATE TABLE medium_voltage_cable_system (
    id INTEGER NOT NULL,
    dso_id INTEGER,
    radial_id INTEGER,
    station_from_id VARCHAR(255),
    station_to_id VARCHAR(255),
    operating_voltage INTEGER,
    average_loading FLOAT,
    max_loading FLOAT,
    time_of_max_loading DATE,
    geometry GEOMETRY('GEOMETRY', 4326)
);

CREATE TABLE medium_voltage_cable_subsection (
    id INTEGER NOT NULL,
    cable_system_id INTEGER,
    number_of_conductors_primary INTEGER,
    conductor_size_primary_mm FLOAT,
    conductor_material VARCHAR(255),
    insulation VARCHAR(255),
    conductor_type VARCHAR(255),
    manufacturer VARCHAR(255),
    in_service_date DATE,
    length_km FLOAT,
    geometry GEOMETRY('GEOMETRY', 4326),
    repairment_section BOOLEAN,
    out_of_service BOOLEAN
);

CREATE TABLE cable_events (
    id INTEGER NOT NULL,
    affected_medium_voltage_cable_id INTEGER,
    affected_medium_voltage_cable_subsection_id INTEGER,
    date DATE,
    cable_event_type VARCHAR
);

CREATE TABLE cable_failures (
    id INTEGER NOT NULL,
    elfas_report_name VARCHAR(255),
    failure_main_reason VARCHAR(255),
    failure_type VARCHAR(255),
    failure_location GEOMETRY('POINT', 4326)
);

CREATE TABLE cable_repairs (
    id INTEGER NOT NULL,
    failures_id INTEGER,
    repairment_cable_section INTEGER
);

CREATE TABLE external_events (
    id INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    external_event_type VARCHAR
);

CREATE TABLE digging_activities (
    id INTEGER NOT NULL,
    utilityType VARCHAR,
    utilityTypeOther VARCHAR,
    diggingType VARCHAR,
    diggingTypeOther VARCHAR,
    geometry GEOMETRY('GEOMETRY', 4326),
    cable_details_requested BOOLEAN
);

-- ---------------------------------------
-- SECTION 3: ADD CONSTRAINTS (PRIMARY & FOREIGN KEYS) 🔗
-- ---------------------------------------
ALTER TABLE dso ADD PRIMARY KEY (id);
ALTER TABLE medium_voltage_radial ADD PRIMARY KEY (id);
ALTER TABLE substation ADD PRIMARY KEY (id);
ALTER TABLE main_substation ADD PRIMARY KEY (id);
ALTER TABLE secondary_substation ADD PRIMARY KEY (id);
ALTER TABLE medium_voltage_cable_system ADD PRIMARY KEY (id);
ALTER TABLE medium_voltage_cable_subsection ADD PRIMARY KEY (id);
ALTER TABLE cable_events ADD PRIMARY KEY (id);
ALTER TABLE cable_failures ADD PRIMARY KEY (id);
ALTER TABLE cable_repairs ADD PRIMARY KEY (id);
ALTER TABLE external_events ADD PRIMARY KEY (id);
ALTER TABLE digging_activities ADD PRIMARY KEY (id);

ALTER TABLE substation ADD CONSTRAINT fk_substation_dso FOREIGN KEY (dso_id) REFERENCES dso(id);
ALTER TABLE main_substation ADD CONSTRAINT fk_main_substation_substation FOREIGN KEY (id) REFERENCES substation(id) ON DELETE CASCADE;
ALTER TABLE secondary_substation ADD CONSTRAINT fk_secondary_substation_substation FOREIGN KEY (id) REFERENCES substation(id) ON DELETE CASCADE;
ALTER TABLE secondary_substation ADD CONSTRAINT fk_secondary_substation_main FOREIGN KEY (parent_station_id) REFERENCES main_substation(id);
ALTER TABLE medium_voltage_cable_system ADD CONSTRAINT fk_mvcablesystem_dso FOREIGN KEY (dso_id) REFERENCES dso(id);
ALTER TABLE medium_voltage_cable_system ADD CONSTRAINT fk_mvcablesystem_radial FOREIGN KEY (radial_id) REFERENCES medium_voltage_radial(id);
ALTER TABLE medium_voltage_cable_system ADD CONSTRAINT fk_mvcablesystem_stfrom FOREIGN KEY (station_from_id) REFERENCES substation(id);
ALTER TABLE medium_voltage_cable_system ADD CONSTRAINT fk_mvcablesystem_stto FOREIGN KEY (station_to_id) REFERENCES substation(id);
ALTER TABLE medium_voltage_cable_subsection ADD CONSTRAINT fk_mvsubsection_system FOREIGN KEY (cable_system_id) REFERENCES medium_voltage_cable_system(id);
ALTER TABLE cable_events ADD CONSTRAINT fk_cableevents_system FOREIGN KEY (affected_medium_voltage_cable_id) REFERENCES medium_voltage_cable_system(id);
ALTER TABLE cable_events ADD CONSTRAINT fk_cableevents_subsection FOREIGN KEY (affected_medium_voltage_cable_subsection_id) REFERENCES medium_voltage_cable_subsection(id);
ALTER TABLE cable_failures ADD CONSTRAINT fk_cablefailures_events FOREIGN KEY (id) REFERENCES cable_events(id) ON DELETE CASCADE;
ALTER TABLE cable_repairs ADD CONSTRAINT fk_cablerepairs_events FOREIGN KEY (id) REFERENCES cable_events(id) ON DELETE CASCADE;
ALTER TABLE cable_repairs ADD CONSTRAINT fk_cablerepairs_failures FOREIGN KEY (failures_id) REFERENCES cable_failures(id);
ALTER TABLE digging_activities ADD CONSTRAINT fk_digging_events FOREIGN KEY (id) REFERENCES external_events(id) ON DELETE CASCADE;

-- ---------------------------------------
-- SECTION 4: DATA GENERATION AND POPULATION 📈
-- ---------------------------------------
INSERT INTO dso (id, name, cvr, geometry)
SELECT
    i AS id,
    'DSO-' || i AS name,
    (10000000 + (random() * 90000000))::int,
    ST_SetSRID(ST_Translate(ST_Buffer(ST_MakePoint(12.56, 55.67), 0.1), random()*0.5-0.25, random()*0.5-0.25), 4326)
FROM generate_series(1, 10) i;

CREATE TEMP TABLE temp_substation AS
SELECT
    'SUB_' || i AS id,
    (1 + (i-1) % 10)::int AS dso_id,
    (100 + random() * 500)::int AS number_of_consumers,
    ('2010-01-01'::date + (random() * 5000)::int * '1 day'::interval) AS installation_date,
    ST_SetSRID(ST_MakePoint(random()*0.5+12.3, random()*0.5+55.4), 4326) as geometry,
    CASE WHEN i <= 20 THEN 'main_substation' ELSE 'secondary_substation' END as station_class
FROM generate_series(1, 200) i;

INSERT INTO substation (id, dso_id, number_of_consumers, installation_date, geometry, station_class)
SELECT id, dso_id, number_of_consumers, installation_date, geometry, station_class FROM temp_substation;

INSERT INTO main_substation (id, name)
SELECT id, 'Main Station ' || id FROM temp_substation WHERE station_class = 'main_substation';

INSERT INTO secondary_substation (id, parent_station_id)
SELECT
    id,
    'SUB_' || (1 + (row_number() OVER (ORDER BY id) - 1) % 20)::int as parent_id
FROM temp_substation
WHERE station_class = 'secondary_substation';

INSERT INTO medium_voltage_radial (id, name, load_embeddings, max_loading, median_loading, upper_quartile_loading)
SELECT i, 'Radial-' || (random()*1000)::int, array(SELECT random() FROM generate_series(1,8)), random()*30+70, random()*20+40, random()*20+60
FROM generate_series(1, 50) i;

CREATE TEMP TABLE temp_mv_cable_system AS
SELECT
    i AS id,
    (1+(i-1)%10)::int AS dso_id,
    (1+(i-1)%50)::int AS radial_id,
    s1.id AS station_from_id,
    s2.id AS station_to_id,
    10000 AS operating_voltage,
    ST_MakeLine(s1.geometry, s2.geometry) AS geometry
FROM generate_series(1, 300) i
CROSS JOIN LATERAL (SELECT id, geometry FROM substation ORDER BY random() LIMIT 1) s1
CROSS JOIN LATERAL (SELECT id, geometry FROM substation WHERE id != s1.id ORDER BY random() LIMIT 1) s2;

INSERT INTO medium_voltage_cable_system (id, dso_id, radial_id, station_from_id, station_to_id, operating_voltage, geometry)
SELECT id, dso_id, radial_id, station_from_id, station_to_id, operating_voltage, geometry FROM temp_mv_cable_system;

INSERT INTO medium_voltage_cable_subsection (id, cable_system_id, number_of_conductors_primary, conductor_size_primary_mm, conductor_material, in_service_date, length_km, geometry)
SELECT
    10000+id,
    id,
    3,
    240,
    CASE WHEN random()>0.5 THEN 'Aluminium' ELSE 'Copper' END,
    ('2015-01-01'::date + (random()*3000)::int * '1 day'::interval),
    ST_Length(geometry::geography)/1000,
    geometry
FROM temp_mv_cable_system;

INSERT INTO external_events (id, start_date, end_date, external_event_type) VALUES (99999, '2025-07-15', '2025-07-25', 'digging_activity');
INSERT INTO digging_activities(id, diggingType, geometry) VALUES (99999, 'City Metro Expansion', ST_SetSRID(ST_GeomFromText('POLYGON((12.55 55.65, 12.60 55.65, 12.60 55.70, 12.55 55.70, 12.55 55.65))'), 4326));

CREATE TEMP TABLE temp_generated_failures AS
WITH affected_cables AS (
    SELECT cs.id, cs.geometry FROM medium_voltage_cable_system cs, digging_activities da
    WHERE da.id = 99999 AND ST_Intersects(cs.geometry, da.geometry)
)
SELECT 9000 + row_number() over() AS id, ac.id as affected_cable_id, ac.geometry as cable_geom
FROM affected_cables ac, generate_series(1, 10)
ORDER BY random() LIMIT 250;

INSERT INTO cable_events (id, affected_medium_voltage_cable_id, date, cable_event_type)
SELECT id, affected_cable_id, ('2025-07-15'::date + (random() * 10)::int * '1 day'::interval), 'cable_failure'
FROM temp_generated_failures;

INSERT INTO cable_failures (id, elfas_report_name, failure_main_reason, failure_type, failure_location)
SELECT gf.id, 'RPT-25-'||(1000+gf.id), CASE WHEN random()>0.1 THEN 'Excavation damage' ELSE 'Component wear' END, 'Phase to ground', ST_LineInterpolatePoint(gf.cable_geom, random())
FROM temp_generated_failures gf;


COMMIT; -- Attempts to save all changes. If any command above failed, this will fail and automatically trigger a ROLLBACK.
