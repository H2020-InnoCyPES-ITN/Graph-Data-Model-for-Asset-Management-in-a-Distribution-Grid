/*
 * This script initialises a Neo4j database with a graph model based on CIM and IEC standards.
 * It creates nodes for organisations, substations, asset containers, AC line segments, junctions,
 * assets, failure events, work orders, activity records, locations, measurements, cable info,
 * joint info, voltage levels, and measurement values.
 * It also establishes relationships between these nodes while ensuring data integrity and performance.
 */

// --- 1. Create Constraints and Indexes ---
// Constraints ensure data integrity by enforcing unique identifiers.
CREATE CONSTRAINT IF NOT EXISTS FOR (o:Organisation) REQUIRE o.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (s:Substation) REQUIRE s.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ac:AssetContainer) REQUIRE ac.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ls:ACLineSegment) REQUIRE ls.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (j:Junction) REQUIRE j.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (a:Asset) REQUIRE a.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (fe:FailureEvent) REQUIRE fe.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (wo:WorkOrder) REQUIRE wo.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ar:ActivityRecord) REQUIRE ar.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (l:Location) REQUIRE l.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (m:Measurement) REQUIRE m.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ci:CableInfo) REQUIRE ci.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ji:JointInfo) REQUIRE ji.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (vl:VoltageLevel) REQUIRE vl.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (mv:MeasurementValue) REQUIRE mv.mRID IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (t:Terminal) REQUIRE t.mRID IS UNIQUE;


// Indexes are crucial for query performance, especially for properties used in MATCH clauses.
CREATE INDEX IF NOT EXISTS FOR (fe:FailureEvent) ON (fe.startTime, fe.eventType);
CREATE INDEX IF NOT EXISTS FOR (wo:WorkOrder) ON (wo.startTime, wo.eventType);
CREATE INDEX IF NOT EXISTS FOR (ar:ActivityRecord) ON (ar.eventType, ar.startTime);

// --- 2. Create Nodes using UNWIND and MERGE ---
// Using UNWIND on a list of data is much faster than running individual CREATE/MERGE statements.

// Organisations
UNWIND [
  {mRID: "ORG1", name: "Radius Elnet"},
  {mRID: "ORG2", name: "N1"},
  {mRID: "ORG3", name: "Cerius"},
  {mRID: "ORG4", name: "TREFOR Elnet"},
  {mRID: "ORG5", name: "SEAS-NVE"}
] AS orgData
MERGE (o:Organisation {mRID: orgData.mRID})
SET o.name = orgData.name,
    o.organisationRole = "Operator",
    o.serviceRegion = "MULTIPOLYGON(((10 55, 11 56, 11 55, 10 55)))" // Using valid WKT
MERGE (ar:ActivityRecord {mRID: "AR_REG_" + o.mRID})
SET ar.eventType = "Registration", ar.startTime = date("2010-01-01") + duration({days: toInteger(rand() * 365 * 5)})
MERGE (o)-[:HAS_RECORD]->(ar);

// Substations
UNWIND range(1, 50) AS i
MERGE (s:Substation {mRID: "SUB" + i})
SET
  s.name = "Substation " + i,
  s.installationDate = date("1990-01-01") + duration({years: toInteger(rand() * 30)}),
  s.location = point({x: 9.8 + rand() * 3.0, y: 55.0 + rand() * 2.5})
MERGE (vl1:VoltageLevel {mRID: "VL" + (i*2-1)})
  SET vl1.nominalVoltage = CASE WHEN i % 4 = 0 THEN 132.0 ELSE 50.0 END
MERGE (vl2:VoltageLevel {mRID: "VL" + (i*2)})
  SET vl2.nominalVoltage = CASE WHEN i % 2 = 0 THEN 10.0 ELSE 0.4 END
MERGE (s)-[:HAS_VOLTAGE_LEVEL]->(vl1)
MERGE (s)-[:HAS_VOLTAGE_LEVEL]->(vl2);

// AssetContainers
UNWIND range(1, 100) AS i
MERGE (ac:AssetContainer {mRID: "AC" + i})
SET ac.name = "MV System " + i
MERGE (mv:MeasurementValue {mRID: "MV" + i})
SET mv.averageLoading = 0.7 + rand() * 0.2, mv.maxLoading = 0.9 + rand() * 0.1
MERGE (ac)-[:HAS_MEASUREMENT]->(mv);

// ACLineSegments
UNWIND range(1, 500) AS i
MERGE (ls:ACLineSegment {mRID: "LS" + i})
SET
  ls.length = 0.5 + rand() * 2.5,
  ls.installationDate = date("2000-01-01") + duration({years: toInteger(rand() * 23)}),
  ls.location = "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")",
  ls.status = CASE WHEN rand() < 0.05 THEN "OutOfService" ELSE "InService" END,
  ls.isRepairSection = rand() < 0.2
MERGE (ci:CableInfo {mRID: "CI" + i})
SET
  ci.numberOfConductors = 3,
  ci.conductorSize = apoc.coll.randomItem([150.0, 185.0, 240.0]),
  ci.conductorMaterial = apoc.coll.randomItem(["Copper", "Aluminum"]),
  ci.insulation = "XLPE",
  ci.conductorType = apoc.coll.randomItem(["Stranded", "Solid"]),
  ci.manufacturer = apoc.coll.randomItem(["Nexans", "Prysmian", "NKT"])
MERGE (ls)-[:HAS_ASSET_INFO]->(ci);

// Junctions and Assets
UNWIND range(1, 300) AS i
MERGE (j:Junction {mRID: "J" + i})
SET j.location = point({x: 9.8 + rand() * 3.0, y: 55.0 + rand() * 2.5})
MERGE (a:Asset {mRID: "A" + i})
SET a.installationDate = date("2000-01-01") + duration({years: toInteger(rand() * 23)})
MERGE (ji:JointInfo {mRID: "JI" + i})
SET
  ji.jointType = apoc.coll.randomItem(["Heat-Shrink", "Cold-Shrink"]),
  ji.manufacturer = apoc.coll.randomItem(["Nexans", "Prysmian", "NKT"])
MERGE (j)-[:HAS_ASSET]->(a)
MERGE (a)-[:HAS_ASSET_INFO]->(ji);

// FailureEvents and WorkOrders
UNWIND range(1, 200) AS i
MERGE (fe:FailureEvent {mRID: "FE" + i})
SET
  fe.eventType = "CableFailure",
  fe.startTime = date("2020-01-01") + duration({days: toInteger(rand() * 1825)}),
  fe.location = point({x: 9.8 + rand() * 3.0, y: 55.0 + rand() * 2.5}),
  fe.failureMode = apoc.coll.randomItem(["Mechanical Damage", "Electrical Fault", "Insulation Failure", "Joint Failure", "Overheating", "Corrosion"]),
  fe.cause = apoc.coll.randomItem(["Digging Incident", "Lightning Strike", "Flooding", "Aging", "Material Defect", "High Load"])
WITH fe
SET fe.endTime = fe.startTime + duration({days: toInteger(rand() * 3) + 1})
// Create a WorkOrder for ~75% of failures
FOREACH (_ IN CASE WHEN rand() < 0.75 THEN [1] ELSE [] END |
    MERGE (wo:WorkOrder {mRID: "WO" + fe.mRID})
    SET
        wo.eventType = "CableRepair",
        wo.startTime = fe.endTime + duration({days: 1}),
        wo.endTime = fe.endTime + duration({days: toInteger(rand()*2) + 1}),
        wo.location = fe.location,
        wo.relatedFailureId = fe.mRID
    MERGE (wo)-[:REPAIRS]->(fe)
);

// ActivityRecords
UNWIND range(1, 100) AS i
MERGE (ar:ActivityRecord {mRID: "AR" + i})
WITH ar, apoc.coll.randomItem(["DiggingActivity", "Lightning", "Flood", "HeatWave", "ColdWave"]) AS eventType
SET
  ar.eventType = eventType,
  ar.startTime = date("2020-01-01") + duration({days: toInteger(rand() * 1825)}),
  ar.location = point({x: 9.8 + rand() * 3.0, y: 55.0 + rand() * 2.5}),
  // Set properties based on eventType, otherwise NULL
  ar.utilityType = CASE eventType WHEN "DiggingActivity" THEN apoc.coll.randomItem(["Water", "Gas", "Telecom"]) ELSE null END,
  ar.maxPrecipitation = CASE eventType WHEN "Flood" THEN 100.0 + rand() * 100.0 ELSE null END,
  ar.intensity = CASE eventType WHEN "Lightning" THEN 50.0 + rand() * 150.0 ELSE null END,
  ar.maxTemperature = CASE eventType WHEN "HeatWave" THEN 28.0 + rand() * 10.0 WHEN "ColdWave" THEN -5.0 - rand() * 10.0 ELSE null END,
  ar.minTemperature = CASE eventType WHEN "HeatWave" THEN 18.0 + rand() * 8.0 WHEN "ColdWave" THEN -15.0 - rand() * 10.0 ELSE null END
WITH ar
SET ar.endTime = ar.startTime + duration({days: toInteger(rand() * 5) + 1});

// --- 3. Create Relationships (Avoiding Cartesian Products) ---
// This section creates connections between the nodes generated above.

// Organisation OPERATES Substation
// Each substation is operated by one organisation based on a modulo of its ID.
MATCH (s:Substation)
WITH s, toInteger(substring(s.mRID, 3)) AS sId
MATCH (o:Organisation)
WHERE toInteger(substring(o.mRID, 3)) = (sId % 5) + 1
MERGE (o)-[r:OPERATES]->(s)
SET r.mRID = "OP_S_" + o.mRID + s.mRID;

// Organisation OPERATES AssetContainer
// Each AC is operated by one organisation.
MATCH (ac:AssetContainer)
WITH ac, toInteger(substring(ac.mRID, 2)) AS acId
MATCH (o:Organisation)
WHERE toInteger(substring(o.mRID, 3)) = (acId % 5) + 1
MERGE (o)-[r:OPERATES]->(ac)
SET r.mRID = "OP_AC_" + o.mRID + ac.mRID;

// Substation FEEDS AssetContainer
// Connect a few Substations to AssetContainers randomly but efficiently.
MATCH (s:Substation)
WHERE rand() < 0.3 // Select a subset of substations
WITH s
MATCH (ac:AssetContainer)
WHERE rand() < 0.05 // For each selected substation, try to connect to a few ACs
MERGE (s)-[r:FEEDS]->(ac)
SET r.mRID = "F_" + s.mRID + ac.mRID;

// AssetContainer CONTAINS ACLineSegment
// Assign each Line Segment to an Asset Container.
MATCH (ls:ACLineSegment)
WITH ls, toInteger(substring(ls.mRID, 2)) AS lsId
MATCH (ac:AssetContainer)
WHERE toInteger(substring(ac.mRID, 2)) = (lsId % 100) + 1
MERGE (ac)-[r:CONTAINS]->(ls)
SET r.mRID = "CT_" + ac.mRID + ls.mRID;

// Junction JOINS adjacent ACLineSegments
// Find pairs of line segments in the same container and join them with a junction.
MATCH (ac:AssetContainer)-[:CONTAINS]->(ls1:ACLineSegment)
WITH ac, ls1, rand() as rnd
ORDER BY rnd
LIMIT 200 // Limit the search space to avoid large intermediate results
MATCH (ac)-[:CONTAINS]->(ls2:ACLineSegment)
WHERE id(ls1) < id(ls2) // Avoid duplicate pairs and self-loops
WITH ls1, ls2
LIMIT 1 // Pick the next available line segment
MATCH (j:Junction)
WHERE rand() < 0.1 // Pick a random junction
MERGE (ls1)<-[:JOINS]-(j)-[:JOINS]->(ls2);

// FailureEvent AFFECTS ACLineSegment
// For each failure, find one nearby line segment it affects.
MATCH (fe:FailureEvent)
MATCH (ls:ACLineSegment)
WITH fe, ls
// Using a spatial function is much better than random matching
WHERE point.distance(fe.location, ls.location) < 5000 // 5km radius
WITH fe, ls, point.distance(fe.location, ls.location) as dist
ORDER BY dist ASC
LIMIT 1 // Connect to the closest one
MERGE (fe)-[r:AFFECTS]->(ls)
SET r.mRID = "AF_" + fe.mRID + ls.mRID;

// FailureEvent CAUSED_BY ActivityRecord
// Link failures to their likely causes based on type and proximity.
MATCH (fe:FailureEvent)
WHERE fe.cause IN ["Digging Incident", "Lightning Strike", "Flood"]
MATCH (ar:ActivityRecord)
// Match cause type to event type
WHERE (fe.cause = "Digging Incident" AND ar.eventType = "DiggingActivity")
   OR (fe.cause = "Lightning Strike" AND ar.eventType = "Lightning")
   OR (fe.cause = "Flood" AND ar.eventType = "Flood")
// Check spatial and temporal proximity
AND point.distance(fe.location, ar.location) < 2000 // 2km radius
AND fe.startTime >= ar.startTime AND fe.startTime <= ar.endTime + duration({days: 2})
MERGE (fe)-[r:CAUSED_BY]->(ar)
SET r.mRID = "CB_" + fe.mRID + ar.mRID;

// --- 4. Update Derived Properties ---
// Calculate aggregate properties after the main graph structure is in place.

// Calculate total length and number of subsections for each AssetContainer
MATCH (ac:AssetContainer)
OPTIONAL MATCH (ac)-[:CONTAINS]->(ls:ACLineSegment)
WITH ac, count(ls) AS numSubsections, sum(ls.length) AS totalLength
SET ac.numberOfSubsections = numSubsections,
    ac.totalLength = coalesce(totalLength, 0.0);

// Calculate the number of joints for each ACLineSegment
MATCH (ls:ACLineSegment)
OPTIONAL MATCH (ls)<-[:JOINS]-(j:Junction)
WITH ls, count(j) AS jointCount
SET ls.numberOfJoints = jointCount;