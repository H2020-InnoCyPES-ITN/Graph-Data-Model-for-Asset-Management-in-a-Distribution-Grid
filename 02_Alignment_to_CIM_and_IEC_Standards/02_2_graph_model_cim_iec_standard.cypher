// --- Create Constraints for Unique Identifiers ---
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

// --- Create Indexes for Performance ---
CREATE INDEX IF NOT EXISTS FOR (fe:FailureEvent) ON (fe.startTime, fe.eventType);
CREATE INDEX IF NOT EXISTS FOR (wo:WorkOrder) ON (wo.startTime, wo.eventType);
// Index on ACLineSegment is not possible for nested properties; consider indexing on top-level properties if needed
// CREATE INDEX IF NOT EXISTS FOR (ls:ACLineSegment) ON (ls.assetInfo.conductorType, ls.assetInfo.conductorMaterial);
CREATE INDEX IF NOT EXISTS FOR (ar:ActivityRecord) ON (ar.eventType, ar.startTime);

// --- Create Sample Data ---

// Organisations (5 major Danish DSOs)
CREATE (o1:Organisation {mRID: "ORG1", name: "Radius Elnet", serviceRegion: "MULTIPOLYGON((12.4 55.5, 12.7 55.8, ...))", organisationRole: "Operator"})
CREATE (o2:Organisation {mRID: "ORG2", name: "N1", serviceRegion: "MULTIPOLYGON((10.0 56.0, 10.3 56.3, ...))", organisationRole: "Operator"})
CREATE (o3:Organisation {mRID: "ORG3", name: "Cerius", serviceRegion: "MULTIPOLYGON((11.8 55.3, 12.1 55.6, ...))", organisationRole: "Operator"})
CREATE (o4:Organisation {mRID: "ORG4", name: "TREFOR Elnet", serviceRegion: "MULTIPOLYGON((9.8 57.0, 10.1 57.3, ...))", organisationRole: "Operator"})
CREATE (o5:Organisation {mRID: "ORG5", name: "SEAS-NVE", serviceRegion: "MULTIPOLYGON((12.0 55.0, 12.3 55.3, ...))", organisationRole: "Operator"})
FOREACH (o IN [o1, o2, o3, o4, o5] |
  CREATE (ar:ActivityRecord {mRID: "AR" + o.mRID, eventType: "Registration", startTime: date("2010-01-01") + duration({years: toInteger(rand() * 5)})})
  CREATE (o)-[:HAS_RECORD]->(ar)
)

// Substations (50 substations across Denmark: Copenhagen, Aarhus, Odense, Aalborg, rural Jutland)
CREATE (s1:Substation {mRID: "SUB1", name: "Copenhagen Central", installationDate: date("2000-03-15"), location: "POINT(12.565 55.675)"})
CREATE (vl1:VoltageLevel {mRID: "VL1", nominalVoltage: 50.0}), (vl2:VoltageLevel {mRID: "VL2", nominalVoltage: 10.0})
CREATE (s1)-[:HAS_VOLTAGE_LEVEL]->(vl1), (s1)-[:HAS_VOLTAGE_LEVEL]->(vl2)
CREATE (s2:Substation {mRID: "SUB2", name: "Nørrebro Station", installationDate: date("2005-07-20"), location: "POINT(12.550 55.690)"})
CREATE (vl3:VoltageLevel {mRID: "VL3", nominalVoltage: 10.0}), (vl4:VoltageLevel {mRID: "VL4", nominalVoltage: 0.4})
CREATE (s2)-[:HAS_VOLTAGE_LEVEL]->(vl3), (s2)-[:HAS_VOLTAGE_LEVEL]->(vl4)
CREATE (s3:Substation {mRID: "SUB3", name: "Aarhus Main", installationDate: date("1998-11-10"), location: "POINT(10.200 56.150)"})
CREATE (vl5:VoltageLevel {mRID: "VL5", nominalVoltage: 50.0}), (vl6:VoltageLevel {mRID: "VL6", nominalVoltage: 10.0})
CREATE (s3)-[:HAS_VOLTAGE_LEVEL]->(vl5), (s3)-[:HAS_VOLTAGE_LEVEL]->(vl6)
CREATE (s4:Substation {mRID: "SUB4", name: "Aarhus North", installationDate: date("2010-04-05"), location: "POINT(10.210 56.165)"})
CREATE (vl7:VoltageLevel {mRID: "VL7", nominalVoltage: 10.0}), (vl8:VoltageLevel {mRID: "VL8", nominalVoltage: 0.4})
CREATE (s4)-[:HAS_VOLTAGE_LEVEL]->(vl7), (s4)-[:HAS_VOLTAGE_LEVEL]->(vl8)
CREATE (s5:Substation {mRID: "SUB5", name: "Odense Central", installationDate: date("2002-06-01"), location: "POINT(10.385 55.395)"})
CREATE (vl9:VoltageLevel {mRID: "VL9", nominalVoltage: 50.0}), (vl10:VoltageLevel {mRID: "VL10", nominalVoltage: 10.0})
CREATE (s5)-[:HAS_VOLTAGE_LEVEL]->(vl9), (s5)-[:HAS_VOLTAGE_LEVEL]->(vl10)
CREATE (s6:Substation {mRID: "SUB6", name: "Odense South", installationDate: date("2008-09-15"), location: "POINT(10.375 55.380)"})
CREATE (vl11:VoltageLevel {mRID: "VL11", nominalVoltage: 10.0}), (vl12:VoltageLevel {mRID: "VL12", nominalVoltage: 0.4})
CREATE (s6)-[:HAS_VOLTAGE_LEVEL]->(vl11), (s6)-[:HAS_VOLTAGE_LEVEL]->(vl12)
FOREACH (i IN range(7, 50) |
  CREATE (s:Substation {
    mRID: "SUB" + i,
    name: "Station_" + i,
    installationDate: date("1990-01-01") + duration({years: toInteger(rand() * 30)}),
    location: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
  })
  CREATE (vl1:VoltageLevel {mRID: "VL" + (i*2-1), nominalVoltage: CASE WHEN i % 2 = 1 THEN 50.0 ELSE 10.0 END})
  CREATE (vl2:VoltageLevel {mRID: "VL" + (i*2), nominalVoltage: CASE WHEN i % 2 = 1 THEN 10.0 ELSE 0.4 END})
  CREATE (s)-[:HAS_VOLTAGE_LEVEL]->(vl1), (s)-[:HAS_VOLTAGE_LEVEL]->(vl2)
)

// AssetContainers (100 MV systems across Denmark)
CREATE (ac1:AssetContainer {mRID: "AC1", name: "Copenhagen MV1"})
CREATE (mv1:MeasurementValue {mRID: "MV1", averageLoading: 0.75, maxLoading: 0.95})
CREATE (ac1)-[:HAS_MEASUREMENT]->(mv1)
CREATE (ac2:AssetContainer {mRID: "AC2", name: "Aarhus MV1"})
CREATE (mv2:MeasurementValue {mRID: "MV2", averageLoading: 0.80, maxLoading: 0.90})
CREATE (ac2)-[:HAS_MEASUREMENT]->(mv2)
CREATE (ac3:AssetContainer {mRID: "AC3", name: "Odense MV1"})
CREATE (mv3:MeasurementValue {mRID: "MV3", averageLoading: 0.78, maxLoading: 0.92})
CREATE (ac3)-[:HAS_MEASUREMENT]->(mv3)
FOREACH (i IN range(4, 100) |
  CREATE (ac:AssetContainer {mRID: "AC" + i, name: "MVSystem_" + i})
  CREATE (mv:MeasurementValue {mRID: "MV" + i, averageLoading: 0.7 + rand() * 0.2, maxLoading: 0.9 + rand() * 0.1})
  CREATE (ac)-[:HAS_MEASUREMENT]->(mv)
)

// ACLineSegments (500 subsections, varied materials and manufacturers)
CREATE (ls1:ACLineSegment {mRID: "LS1", length: 1.5, installationDate: date("2016-02-01"), location: "LINESTRING(12.565 55.675, 12.550 55.690)", status: "InService", isRepairSection: false})
CREATE (ci1:CableInfo {mRID: "CI1", numberOfConductors: 3, conductorSize: 240.0, conductorMaterial: "Copper", insulation: "XLPE", conductorType: "Stranded", manufacturer: "Nexans"})
CREATE (ls1)-[:HAS_ASSET_INFO]->(ci1)
CREATE (ls2:ACLineSegment {mRID: "LS2", length: 1.2, installationDate: date("2018-06-15"), location: "LINESTRING(12.550 55.690, 12.540 55.700)", status: "InService", isRepairSection: true})
CREATE (ci2:CableInfo {mRID: "CI2", numberOfConductors: 3, conductorSize: 185.0, conductorMaterial: "Aluminum", insulation: "XLPE", conductorType: "Solid", manufacturer: "Prysmian"})
CREATE (ls2)-[:HAS_ASSET_INFO]->(ci2)
CREATE (ls3:ACLineSegment {mRID: "LS3", length: 2.0, installationDate: date("2015-09-01"), location: "LINESTRING(10.200 56.150, 10.210 56.165)", status: "InService", isRepairSection: false})
CREATE (ci3:CableInfo {mRID: "CI3", numberOfConductors: 3, conductorSize: 240.0, conductorMaterial: "Copper", insulation: "XLPE", conductorType: "Stranded", manufacturer: "NKT"})
CREATE (ls3)-[:HAS_ASSET_INFO]->(ci3)
FOREACH (i IN range(4, 500) |
  CREATE (ls:ACLineSegment {
    mRID: "LS" + i,
    length: 0.5 + rand() * 2.5,
    installationDate: date("2000-01-01") + duration({years: toInteger(rand() * 23)}),
    location: "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")",
    status: CASE WHEN rand() < 0.05 THEN "OutOfService" ELSE "InService" END,
    isRepairSection: rand() < 0.2
  })
  CREATE (ci:CableInfo {
    mRID: "CI" + i,
    numberOfConductors: 3,
    conductorSize: CASE toInteger(rand() * 3) WHEN 0 THEN 150.0 WHEN 1 THEN 185.0 ELSE 240.0 END,
    conductorMaterial: CASE toInteger(rand() * 2) WHEN 0 THEN "Copper" ELSE "Aluminum" END,
    insulation: "XLPE",
    conductorType: CASE toInteger(rand() * 2) WHEN 0 THEN "Stranded" ELSE "Solid" END,
    manufacturer: CASE toInteger(rand() * 3) WHEN 0 THEN "Nexans" WHEN 1 THEN "Prysmian" ELSE "NKT" END
  })
  CREATE (ls)-[:HAS_ASSET_INFO]->(ci)
)

// Junctions and Assets (300 cable joints)
CREATE (j1:Junction {mRID: "J1", location: "POINT(12.550 55.690)"})
CREATE (a1:Asset {mRID: "A1", installationDate: date("2016-02-01")})
CREATE (ji1:JointInfo {mRID: "JI1", jointType: "Heat-Shrink", manufacturer: "Nexans"})
CREATE (a1)-[:HAS_ASSET_INFO]->(ji1), (j1)-[:HAS_ASSET]->(a1)
CREATE (j2:Junction {mRID: "J2", location: "POINT(10.205 56.155)"})
CREATE (a2:Asset {mRID: "A2", installationDate: date("2018-06-15")})
CREATE (ji2:JointInfo {mRID: "JI2", jointType: "Cold-Shrink", manufacturer: "Prysmian"})
CREATE (a2)-[:HAS_ASSET_INFO]->(ji2), (j2)-[:HAS_ASSET]->(a2)
FOREACH (i IN range(3, 300) |
  CREATE (j:Junction {mRID: "J" + i, location: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"})
  CREATE (a:Asset {mRID: "A" + i, installationDate: date("2000-01-01") + duration({years: toInteger(rand() * 23)})})
  CREATE (ji:JointInfo {
    mRID: "JI" + i,
    jointType: CASE toInteger(rand() * 2) WHEN 0 THEN "Heat-Shrink" ELSE "Cold-Shrink" END,
    manufacturer: CASE toInteger(rand() * 3) WHEN 0 THEN "Nexans" WHEN 1 THEN "Prysmian" ELSE "NKT" END
  })
  CREATE (a)-[:HAS_ASSET_INFO]->(ji), (j)-[:HAS_ASSET]->(a)
)

// FailureEvents and WorkOrders (200 failures, 150 repairs)
CREATE (fe1:FailureEvent {mRID: "FE1", eventType: "CableFailure", startTime: date("2023-05-10"), endTime: date("2023-05-11"), location: "POINT(12.555 55.685)", failureMode: "Mechanical Damage", cause: "Digging Incident"})
CREATE (fe2:FailureEvent {mRID: "FE2", eventType: "CableFailure", startTime: date("2023-07-15"), endTime: date("2023-07-16"), location: "POINT(12.545 55.695)", failureMode: "Electrical Fault", cause: "Lightning Strike"})
CREATE (fe3:FailureEvent {mRID: "FE3", eventType: "CableFailure", startTime: date("2024-01-20"), endTime: date("2024-01-22"), location: "POINT(10.205 56.155)", failureMode: "Insulation Failure", cause: "Flooding"})
CREATE (fe4:FailureEvent {mRID: "FE4", eventType: "CableFailure", startTime: date("2024-06-01"), endTime: date("2024-06-02"), location: "POINT(12.550 55.690)", failureMode: "Joint Failure", cause: "Aging"})
CREATE (wo1:WorkOrder {mRID: "WO1", eventType: "CableRepair", startTime: date("2023-05-12"), endTime: date("2023-05-12"), location: "POINT(12.555 55.685)", workDetails: "Replaced damaged section", relatedFailureId: "FE1"})
CREATE (wo2:WorkOrder {mRID: "WO2", eventType: "CableRepair", startTime: date("2023-07-17"), endTime: date("2023-07-17"), location: "POINT(12.545 55.695)", workDetails: "Repaired insulation", relatedFailureId: "FE2"})
FOREACH (i IN range(5, 200) |
  CREATE (fe:FailureEvent {
    mRID: "FE" + i,
    eventType: "CableFailure",
    startTime: date("2020-01-01") + duration({days: toInteger(rand() * 1825)}),
    endTime: date("2020-01-01") + duration({days: toInteger(rand() * 1825) + toInteger(rand() * 3)}),
    location: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")",
    failureMode: CASE toInteger(rand() * 6)
      WHEN 0 THEN "Mechanical Damage"
      WHEN 1 THEN "Electrical Fault"
      WHEN 2 THEN "Insulation Failure"
      WHEN 3 THEN "Joint Failure"
      WHEN 4 THEN "Overheating"
      ELSE "Corrosion" END,
    cause: CASE toInteger(rand() * 6)
      WHEN 0 THEN "Digging Incident"
      WHEN 1 THEN "Lightning Strike"
      WHEN 2 THEN "Flooding"
      WHEN 3 THEN "Aging"
      WHEN 4 THEN "Material Defect"
      ELSE "High Load" END
  })
)

MATCH (fe:FailureEvent)
WHERE fe.mRID <= "FE156"
WITH fe, "WO" + substring(fe.mRID, 2) AS woMRID
CREATE (wo:WorkOrder {
  mRID: woMRID,
  eventType: "CableRepair",
  startTime: fe.endTime + duration({days: 1}),
  endTime: fe.endTime + duration({days: 1}),
  location: fe.location,
  workDetails: CASE fe.failureMode
    WHEN "Mechanical Damage" THEN "Replaced damaged section"
    WHEN "Electrical Fault" THEN "Repaired insulation"
    WHEN "Insulation Failure" THEN "Installed new insulation"
    WHEN "Joint Failure" THEN "Replaced joint"
    ELSE "General repair" END,
  relatedFailureId: fe.mRID
})
CREATE (wo)-[:REPAIRS {
  mRID: "R" + substring(fe.mRID, 2),
  repairDate: fe.endTime + duration({days: 1}),
  workOrderId: woMRID
}]->(fe);


// ActivityRecords (100 external events: digging, lightning, floods, heatwaves, cold waves)
// Create the first 5 ActivityRecords
CREATE (ar1:ActivityRecord {
  mRID: "AR1",
  eventType: "DiggingActivity",
  startTime: date("2023-05-09"),
  endTime: date("2023-05-10"),
  location: "POLYGON((12.554 55.684, 12.556 55.686, ...))",
  utilityType: "Water",
  diggingType: "Pipeline Installation",
  reportedToAuthority: "Copenhagen Municipality"
})

CREATE (ar2:ActivityRecord {
  mRID: "AR2",
  eventType: "Lightning",
  startTime: date("2023-07-15"),
  endTime: date("2023-07-15"),
  location: "POINT(12.545 55.695)",
  impactTime: datetime("2023-07-15T14:30:00"),
  numberOfStroke: 3,
  intensity: 100.0
})

CREATE (ar3:ActivityRecord {
  mRID: "AR3",
  eventType: "Flood",
  startTime: date("2024-01-19"),
  endTime: date("2024-01-23"),
  location: "MULTIPOLYGON((10.200 56.150, 10.210 56.165, ...))",
  maxPrecipitation: 150.0
})

CREATE (ar4:ActivityRecord {
  mRID: "AR4",
  eventType: "HeatWave",
  startTime: date("2023-08-01"),
  endTime: date("2023-08-05"),
  location: "MULTIPOLYGON((12.5 55.6, 12.6 55.7, ...))",
  maxTemperature: 32.0,
  minTemperature: 20.0
})

CREATE (ar5:ActivityRecord {
  mRID: "AR5",
  eventType: "ColdWave",
  startTime: date("2024-02-10"),
  endTime: date("2024-02-15"),
  location: "MULTIPOLYGON((10.0 56.0, 10.3 56.3, ...))",
  maxTemperature: -5.0,
  minTemperature: -15.0
})

// Insert dummy WITH clause before UNWIND
WITH true AS dummy

// Generate AR6 to AR100
UNWIND range(6, 100) AS i
WITH i,
  CASE toInteger(rand() * 5)
    WHEN 0 THEN "DiggingActivity"
    WHEN 1 THEN "Lightning"
    WHEN 2 THEN "Flood"
    WHEN 3 THEN "HeatWave"
    ELSE "ColdWave"
  END AS eventType,
  date("2020-01-01") + duration({days: toInteger(rand() * 1825)}) AS startDate,
  date("2020-01-01") + duration({days: toInteger(rand() * 1825) + toInteger(rand() * 7)}) AS endDate,
  "MULTIPOLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))" AS location

// DiggingActivity
FOREACH (_ IN CASE WHEN eventType = "DiggingActivity" THEN [1] ELSE [] END |
  CREATE (:ActivityRecord {
    mRID: "AR" + i,
    eventType: eventType,
    startTime: startDate,
    endTime: endDate,
    location: location,
    utilityType: "Water",
    diggingType: "Pipeline Installation",
    reportedToAuthority: CASE toInteger(rand() * 3)
      WHEN 0 THEN "Copenhagen Municipality"
      WHEN 1 THEN "Aarhus Municipality"
      ELSE NULL END
  })
)

// Lightning
FOREACH (_ IN CASE WHEN eventType = "Lightning" THEN [1] ELSE [] END |
  CREATE (:ActivityRecord {
    mRID: "AR" + i,
    eventType: eventType,
    startTime: startDate,
    endTime: endDate,
    location: location,
    impactTime: datetime("2020-01-01T00:00:00") + duration({days: toInteger(rand() * 1825)}),
    numberOfStroke: toInteger(rand() * 5) + 1,
    intensity: 50.0 + rand() * 150.0
  })
)

// Flood
FOREACH (_ IN CASE WHEN eventType = "Flood" THEN [1] ELSE [] END |
  CREATE (:ActivityRecord {
    mRID: "AR" + i,
    eventType: eventType,
    startTime: startDate,
    endTime: endDate,
    location: location,
    maxPrecipitation: 100.0 + rand() * 100.0
  })
)

// HeatWave
FOREACH (_ IN CASE WHEN eventType = "HeatWave" THEN [1] ELSE [] END |
  CREATE (:ActivityRecord {
    mRID: "AR" + i,
    eventType: eventType,
    startTime: startDate,
    endTime: endDate,
    location: location,
    maxTemperature: 25.0 + rand() * 10.0,
    minTemperature: 15.0 + rand() * 10.0
  })
)

// ColdWave
FOREACH (_ IN CASE WHEN eventType = "ColdWave" THEN [1] ELSE [] END |
  CREATE (:ActivityRecord {
    mRID: "AR" + i,
    eventType: eventType,
    startTime: startDate,
    endTime: endDate,
    location: location,
    maxTemperature: -5.0 + rand() * 10.0,
    minTemperature: -15.0 + rand() * 10.0
  })
)


// Locations and Measurements (50 drivers: roads, railways, water bodies, soil types, weather)
// Initial 5 Locations and 1 Measurement

CREATE (l1:Location {
  mRID: "L1",
  locationType: "Road",
  lengthInKm: 2.0,
  position: "LINESTRING(12.560 55.670, 12.550 55.690)"
})

CREATE (m2:Measurement {
  mRID: "M2",
  locationType: "WeatherCondition",
  averageTemperature: 8.5,
  averageWindSpeed: 5.0,
  maxWindSpeed: 15.0,
  averageHumidity: 80.0,
  maxHumidity: 95.0,
  averagePrecipitation: 600.0,
  maxPrecipitation: 50.0,
  maxTemperature: 25.0,
  minTemperature: -5.0,
  timeRangeStart: date("2023-01-01"),
  timeRangeEnd: date("2023-12-31"),
  position: "MULTIPOLYGON((12.5 55.6, 12.6 55.7, ...))"
})

CREATE (l3:Location {
  mRID: "L3",
  locationType: "Railway",
  lengthInKm: 3.0,
  position: "LINESTRING(10.195 56.145, 10.215 56.170)"
})

CREATE (l4:Location {
  mRID: "L4",
  locationType: "WaterBody",
  position: "MULTIPOLYGON((10.190 56.140, 10.220 56.160, ...))"
})

CREATE (l5:Location {
  mRID: "L5",
  locationType: "SoilType",
  soilType: "Clay",
  position: "MULTIPOLYGON((12.540 55.680, 12.560 55.700, ...))"
})

WITH true AS dummy

// Create L6 to L50 with optional WeatherCondition Measurements
UNWIND range(6, 50) AS i
WITH i,
  CASE toInteger(rand() * 5)
    WHEN 0 THEN "Road"
    WHEN 1 THEN "Railway"
    WHEN 2 THEN "WaterBody"
    WHEN 3 THEN "SoilType"
    ELSE "WeatherCondition"
  END AS locationType,
  CASE toInteger(rand() * 5)
    WHEN 0 THEN "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
    WHEN 1 THEN "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
    ELSE "MULTIPOLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))"
  END AS position,
  toInteger(rand() * 5) AS attrType

// Create Location node
CREATE (node:Location {
  mRID: "L" + i,
  locationType: locationType,
  position: position
})
// Add flattened attributes
SET node.lengthInKm = CASE WHEN locationType IN ["Road", "Railway"] THEN 1.0 + rand() * 5.0 ELSE null END


// --- Create Relationships ---

// Organisation OPERATES AssetContainer/Substation
MATCH (o:Organisation), (ac:AssetContainer)
WHERE rand() < 0.2
CREATE (o)-[:OPERATES {mRID: "OP" + o.mRID + ac.mRID, dateFrom: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), roleType: "Operator"}]->(ac);
MATCH (o:Organisation), (s:Substation)
WHERE rand() < 0.2
CREATE (o)-[:OPERATES {mRID: "OP" + o.mRID + s.mRID, dateFrom: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), roleType: "Operator"}]->(s);

// Substation FEEDS AssetContainer
MATCH (s:Substation), (ac:AssetContainer)
WHERE rand() < 0.2
CREATE (t1:Terminal {mRID: "T" + s.mRID + ac.mRID + "_1"}), (t2:Terminal {mRID: "T" + s.mRID + ac.mRID + "_2"})
CREATE (s)-[:HAS_TERMINAL]->(t1), (ac)-[:HAS_TERMINAL]->(t2)
CREATE (s)-[:FEEDS {mRID: "F" + s.mRID + ac.mRID, connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), terminalIds: [t1.mRID, t2.mRID]}]->(ac);

// Substation CONNECTS_TO AssetContainer
MATCH (s:Substation), (ac:AssetContainer)
WHERE rand() < 0.2
CREATE (t1:Terminal {mRID: "T" + s.mRID + ac.mRID + "_3"}), (t2:Terminal {mRID: "T" + s.mRID + ac.mRID + "_4"})
CREATE (s)-[:HAS_TERMINAL]->(t1), (ac)-[:HAS_TERMINAL]->(t2)
CREATE (s)-[:CONNECTS_TO {mRID: "C" + s.mRID + ac.mRID, connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), terminalIds: [t1.mRID, t2.mRID]}]->(ac);

// Substation PARENT_OF Substation
MATCH (s1:Substation)-[:HAS_VOLTAGE_LEVEL]->(vl1:VoltageLevel WHERE vl1.nominalVoltage = 50.0),
      (s2:Substation)-[:HAS_VOLTAGE_LEVEL]->(vl2:VoltageLevel WHERE vl2.nominalVoltage = 10.0)
WHERE rand() < 0.3
CREATE (s1)-[:PARENT_OF {mRID: "P" + s1.mRID + s2.mRID, relationshipDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(s2);

// Substation ROUTES_THROUGH ACLineSegment
MATCH (s:Substation), (ls:ACLineSegment)
WHERE rand() < 0.2
CREATE (t1:Terminal {mRID: "T" + s.mRID + ls.mRID + "_1"}), (t2:Terminal {mRID: "T" + s.mRID + ls.mRID + "_2"})
CREATE (s)-[:HAS_TERMINAL]->(t1), (ls)-[:HAS_TERMINAL]->(t2)
CREATE (s)-[:ROUTES_THROUGH {mRID: "RT" + s.mRID + ls.mRID, connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), terminalIds: [t1.mRID, t2.mRID]}]->(ls);

// AssetContainer CONTAINS ACLineSegment
MATCH (ac:AssetContainer)
WITH ac, toInteger(rand() * 8 + 3) AS numSubsections
MATCH (ls:ACLineSegment)
WHERE rand() < 0.02
WITH ac, numSubsections, collect(ls) AS allLS
WITH ac, allLS[0..numSubsections] AS selectedLS
UNWIND selectedLS AS ls
CREATE (ac)-[:CONTAINS {
  mRID: "CT" + ac.mRID + ls.mRID,
  groupingDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})
}]->(ls)


// Junction JOINS ACLineSegment
MATCH (ac:AssetContainer)
WITH ac, toInteger(rand() * 8 + 3) AS numSubsections

CALL {
  WITH ac, numSubsections
  MATCH (ls:ACLineSegment)
  WHERE rand() < 0.02
  WITH ac, numSubsections, collect(ls) AS allLS
  RETURN allLS[0..numSubsections] AS selectedLS
}

UNWIND selectedLS AS ls
CREATE (ac)-[:CONTAINS {
  mRID: "CT" + ac.mRID + ls.mRID,
  groupingDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})
}]->(ls)

/* MATCH (ls1:ACLineSegment), (ls2:ACLineSegment), (j:Junction)
WHERE ls1.mRID < ls2.mRID AND rand() < 0.01
CREATE (t1:Terminal {mRID: "T" + j.mRID + ls1.mRID}), (t2:Terminal {mRID: "T" + j.mRID + ls2.mRID})
CREATE (j)-[:HAS_TERMINAL]->(t1), (j)-[:HAS_TERMINAL]->(t2)
CREATE (j)-[:JOINS {mRID: "J" + j.mRID + ls1.mRID, connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), terminalIds: [t1.mRID]}]->(ls1)
CREATE (j)-[:JOINS {mRID: "J" + j.mRID + ls2.mRID, connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), terminalIds: [t2.mRID]}]->(ls2); */

// FailureEvent/WorkOrder AFFECTS ACLineSegment/Junction
MATCH (fe:FailureEvent), (ls:ACLineSegment)
WHERE rand() < 0.05
CREATE (fe)-[:AFFECTS {mRID: "AF" + fe.mRID + ls.mRID, eventDate: fe.startTime, affectedAssetId: ls.mRID}]->(ls);
MATCH (wo:WorkOrder), (ls:ACLineSegment)
WHERE rand() < 0.05
CREATE (wo)-[:AFFECTS {mRID: "AF" + wo.mRID + ls.mRID, eventDate: wo.startTime, affectedAssetId: ls.mRID}]->(ls);
MATCH (fe:FailureEvent), (j:Junction)
WHERE rand() < 0.05
CREATE (fe)-[:AFFECTS {mRID: "AF" + fe.mRID + j.mRID, eventDate: fe.startTime, affectedAssetId: j.mRID}]->(j);

// ActivityRecord IMPACTS ACLineSegment
MATCH (ar:ActivityRecord), (ls:ACLineSegment)
WHERE rand() < 0.05
CREATE (ar)-[:IMPACTS {mRID: "IM" + ar.mRID + ls.mRID, impactDate: ar.startTime, affectedAssetId: ls.mRID}]->(ls);

// FailureEvent CAUSED_BY ActivityRecord
MATCH (fe:FailureEvent), (ar:ActivityRecord)
WHERE (fe.cause = "Digging Incident" AND ar.eventType = "DiggingActivity")
   OR (fe.cause = "Lightning Strike" AND ar.eventType = "Lightning")
   OR (fe.cause = "Flooding" AND ar.eventType = "Flood")
   AND rand() < 0.3
CREATE (fe)-[:CAUSED_BY {mRID: "CB" + fe.mRID + ar.mRID, eventDate: fe.startTime, causeType: ar.eventType}]->(ar);

// Location/Measurement INFLUENCES ACLineSegment
MATCH (l:Location), (ls:ACLineSegment)
WHERE rand() < 0.05
CREATE (l)-[:INFLUENCES {mRID: "IN" + l.mRID + ls.mRID, influenceDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)}), attributeType: l.locationType}]->(ls);
MATCH (m:Measurement), (ls:ACLineSegment)
WHERE rand() < 0.05
CREATE (m)-[:INFLUENCES {mRID: "IN" + m.mRID + ls.mRID, influenceDate: m.timeRangeStart, attributeType: "WeatherCondition"}]->(ls);

// Location/Measurement CONTRIBUTES_TO FailureEvent
MATCH (l:Location), (fe:FailureEvent)
WHERE rand() < 0.05
CREATE (l)-[:CONTRIBUTES_TO {mRID: "CTB" + l.mRID + fe.mRID, contributionDate: fe.startTime, factorType: l.locationType}]->(fe);
MATCH (m:Measurement), (fe:FailureEvent)
WHERE rand() < 0.05
CREATE (m)-[:CONTRIBUTES_TO {mRID: "CTB" + m.mRID + fe.mRID, contributionDate: fe.startTime, factorType: "WeatherCondition"}]->(fe);

// --- Update Derived Properties ---
MATCH (ac:AssetContainer)-[:CONTAINS]->(ls:ACLineSegment)
WITH ac, count(ls) AS numSubsections, sum(ls.length) AS totalLength
SET ac.numberOfSubsections = numSubsections,
    ac.totalLength = coalesce(totalLength, 0.0);


MATCH (ls:ACLineSegment)<-[:JOINS]-(j:Junction)
WITH ls, count(j) AS jointCount
SET ls.numberOfJoints = jointCount;
