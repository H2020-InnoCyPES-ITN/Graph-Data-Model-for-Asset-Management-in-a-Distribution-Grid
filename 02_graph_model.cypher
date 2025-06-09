// Cypher Script for MV Cable Network Graph Model (Denmark Use)
// TODO: Adding explanations and confirm the tests


// --- Create Constraints for Unique Identifiers ---
CREATE CONSTRAINT IF NOT EXISTS FOR (d:DSO) REQUIRE d.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (s:Substation) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (m:MVCSystem) REQUIRE m.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ms:MVCSubsection) REQUIRE ms.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (j:CableJoint) REQUIRE j.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ce:CableEvent) REQUIRE ce.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ee:ExternalEvent) REQUIRE ee.eventId IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ld:LocationDriver) REQUIRE ld.driverID IS UNIQUE;

// --- Create Indexes for Performance ---
CREATE INDEX IF NOT EXISTS FOR (ce:CableEvent) ON (ce.eventStart, ce.kind);
CREATE INDEX IF NOT EXISTS FOR (ms:MVCSubsection) ON (ms.conductorType, ms.conductorMaterial);
CREATE INDEX IF NOT EXISTS FOR (ee:ExternalEvent) ON (ee.kind, ee.eventStart);

// --- Create Sample Data ---

// DSOs (5 major Danish operators)
CREATE (d1:DSO {name: "Radius Elnet", supplyArea: "MULTIPOLYGON((12.4 55.5, 12.7 55.8, ...))", dateRegistered: date("2010-01-01"), reliabilityIndices: 0.98})
CREATE (d2:DSO {name: "N1", supplyArea: "MULTIPOLYGON((10.0 56.0, 10.3 56.3, ...))", dateRegistered: date("2008-06-01"), reliabilityIndices: 0.97})
CREATE (d3:DSO {name: "Cerius", supplyArea: "MULTIPOLYGON((11.8 55.3, 12.1 55.6, ...))", dateRegistered: date("2012-03-01"), reliabilityIndices: 0.96})
CREATE (d4:DSO {name: "TREFOR Elnet", supplyArea: "MULTIPOLYGON((9.8 57.0, 10.1 57.3, ...))", dateRegistered: date("2009-09-01"), reliabilityIndices: 0.95})
CREATE (d5:DSO {name: "SEAS-NVE", supplyArea: "MULTIPOLYGON((12.0 55.0, 12.3 55.3, ...))", dateRegistered: date("2011-07-01"), reliabilityIndices: 0.97})

// Substations (50 substations across Denmark: Copenhagen, Aarhus, Odense, Aalborg, rural Jutland)
CREATE (s1:Substation {id: 1, kind: "primary", name: "Copenhagen Central", voltageLevelHigh: 50, voltageLevelLow: 10, installationDate: date("2000-03-15"), coordinates: "POINT(12.565 55.675)"})
CREATE (s2:Substation {id: 2, kind: "secondary", name: "Nørrebro Station", voltageLevelHigh: 10, voltageLevelLow: 0.4, installationDate: date("2005-07-20"), coordinates: "POINT(12.550 55.690)"})
CREATE (s3:Substation {id: 3, kind: "primary", name: "Aarhus Main", voltageLevelHigh: 50, voltageLevelLow: 10, installationDate: date("1998-11-10"), coordinates: "POINT(10.200 56.150)"})
CREATE (s4:Substation {id: 4, kind: "secondary", name: "Aarhus North", voltageLevelHigh: 10, voltageLevelLow: 0.4, installationDate: date("2010-04-05"), coordinates: "POINT(10.210 56.165)"})
CREATE (s5:Substation {id: 5, kind: "primary", name: "Odense Central", voltageLevelHigh: 50, voltageLevelLow: 10, installationDate: date("2002-06-01"), coordinates: "POINT(10.385 55.395)"})
CREATE (s6:Substation {id: 6, kind: "secondary", name: "Odense South", voltageLevelHigh: 10, voltageLevelLow: 0.4, installationDate: date("2008-09-15"), coordinates: "POINT(10.375 55.380)"})
FOREACH (i IN range(7, 50) |
  CREATE (:Substation {
    id: i,
    kind: CASE WHEN i % 2 = 1 THEN "primary" ELSE "secondary" END,
    name: "Station_" + i,
    voltageLevelHigh: CASE WHEN i % 2 = 1 THEN 50 ELSE 10 END,
    voltageLevelLow: CASE WHEN i % 2 = 1 THEN 10 ELSE 0.4 END,
    installationDate: date("1990-01-01") + duration({years: toInteger(rand() * 30)}),
    coordinates: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
  })
)

// MVC Systems (100 systems across Denmark)
CREATE (m1:MVCSystem {name: "Copenhagen MV1", averageLoading: 0.75, maxLoading: 0.95})
CREATE (m2:MVCSystem {name: "Aarhus MV1", averageLoading: 0.80, maxLoading: 0.90})
CREATE (m3:MVCSystem {name: "Odense MV1", averageLoading: 0.78, maxLoading: 0.92})
FOREACH (i IN range(4, 100) |
  CREATE (:MVCSystem {
    name: "MVSystem_" + i,
    averageLoading: 0.7 + rand() * 0.2,
    maxLoading: 0.9 + rand() * 0.1
  })
)

// MVC Subsections (500 subsections, varied materials and manufacturers)
CREATE (ms1:MVCSubsection {id: 1, numberOfConductors: 3, conductorSize: 240.0, conductorMaterial: "Copper", insulation: "XLPE", conductorType: "Stranded", manufacturer: "Nexans", inServiceDate: date("2016-02-01"), lengthInKm: 1.5, coordinates: "LINESTRING(12.565 55.675, 12.550 55.690)", isRepairSection: false, outOfService: false})
CREATE (ms2:MVCSubsection {id: 2, numberOfConductors: 3, conductorSize: 185.0, conductorMaterial: "Aluminum", insulation: "XLPE", conductorType: "Solid", manufacturer: "Prysmian", inServiceDate: date("2018-06-15"), lengthInKm: 1.2, coordinates: "LINESTRING(12.550 55.690, 12.540 55.700)", isRepairSection: true, outOfService: false})
CREATE (ms3:MVCSubsection {id: 3, numberOfConductors: 3, conductorSize: 240.0, conductorMaterial: "Copper", insulation: "XLPE", conductorType: "Stranded", manufacturer: "NKT", inServiceDate: date("2015-09-01"), lengthInKm: 2.0, coordinates: "LINESTRING(10.200 56.150, 10.210 56.165)", isRepairSection: false, outOfService: false})
FOREACH (i IN range(4, 500) |
  CREATE (:MVCSubsection {
    id: i,
    numberOfConductors: 3,
    conductorSize: CASE toInteger(rand() * 3) WHEN 0 THEN 150.0 WHEN 1 THEN 185.0 ELSE 240.0 END,
    conductorMaterial: CASE toInteger(rand() * 2) WHEN 0 THEN "Copper" ELSE "Aluminum" END,
    insulation: "XLPE",
    conductorType: CASE toInteger(rand() * 2) WHEN 0 THEN "Stranded" ELSE "Solid" END,
    manufacturer: CASE toInteger(rand() * 3) WHEN 0 THEN "Nexans" WHEN 1 THEN "Prysmian" ELSE "NKT" END,
    inServiceDate: date("2000-01-01") + duration({years: toInteger(rand() * 23)}),
    lengthInKm: 0.5 + rand() * 2.5,
    coordinates: "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")",
    isRepairSection: rand() < 0.2,
    outOfService: rand() < 0.05
  })
)

// Cable Joints (300 joints)
CREATE (j1:CableJoint {id: 1, jointType: "Heat-Shrink", coordinatesInstalled: "POINT(12.550 55.690)"})
CREATE (j2:CableJoint {id: 2, jointType: "Cold-Shrink", coordinatesInstalled: "POINT(10.205 56.155)"})
FOREACH (i IN range(3, 300) |
  CREATE (:CableJoint {
    id: i,
    jointType: CASE toInteger(rand() * 2) WHEN 0 THEN "Heat-Shrink" ELSE "Cold-Shrink" END,
    coordinatesInstalled: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
  })
)

// Cable Events (200 failures, 150 repairs, diverse scenarios)
CREATE (ce1:CableEvent {kind: "cable_failure", id: 1, eventStart: date("2023-05-10"), eventEnd: date("2023-05-11"), locationOfEvent: "POINT(12.555 55.685)", failureType: "Mechanical Damage", failureCause: "Digging Incident"})
CREATE (ce2:CableEvent {kind: "cable_failure", id: 2, eventStart: date("2023-07-15"), eventEnd: date("2023-07-16"), locationOfEvent: "POINT(12.545 55.695)", failureType: "Electrical Fault", failureCause: "Lightning Strike"})
CREATE (ce3:CableEvent {kind: "cable_failure", id: 3, eventStart: date("2024-01-20"), eventEnd: date("2024-01-22"), locationOfEvent: "POINT(10.205 56.155)", failureType: "Insulation Failure", failureCause: "Flooding"})
CREATE (ce4:CableEvent {kind: "cable_failure", id: 4, eventStart: date("2024-06-01"), eventEnd: date("2024-06-02"), locationOfEvent: "POINT(12.550 55.690)", failureType: "Joint Failure", failureCause: "Aging"})
CREATE (ce5:CableEvent {kind: "cable_repair", id: 5, eventStart: date("2023-05-12"), eventEnd: date("2023-05-12"), locationOfEvent: "POINT(12.555 55.685)", repairSpecs: "Replaced damaged section", relatedFailureId: 1})
CREATE (ce6:CableEvent {kind: "cable_repair", id: 6, eventStart: date("2023-07-17"), eventEnd: date("2023-07-17"), locationOfEvent: "POINT(12.545 55.695)", repairSpecs: "Repaired insulation", relatedFailureId: 2})
// Create failures
FOREACH (i IN range(7, 200) |
  CREATE (:CableEvent {
    kind: "cable_failure",
    id: i,
    eventStart: date("2020-01-01") + duration({days: toInteger(rand() * 1825)}),
    eventEnd: date("2020-01-01") + duration({days: toInteger(rand() * 1825) + toInteger(rand() * 3)}),
    locationOfEvent: "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")",
    failureType: CASE toInteger(rand() * 6)
      WHEN 0 THEN "Mechanical Damage"
      WHEN 1 THEN "Electrical Fault"
      WHEN 2 THEN "Insulation Failure"
      WHEN 3 THEN "Joint Failure"
      WHEN 4 THEN "Overheating"
      ELSE "Corrosion" END,
    failureCause: CASE toInteger(rand() * 6)
      WHEN 0 THEN "Digging Incident"
      WHEN 1 THEN "Lightning Strike"
      WHEN 2 THEN "Flooding"
      WHEN 3 THEN "Aging"
      WHEN 4 THEN "Material Defect"
      ELSE "High Load" END
  })
)
// Create repairs (for 150 failures, approximately 75% of failures)
MATCH (ce:CableEvent {kind: "cable_failure"})
WHERE ce.id <= 156
WITH ce, ce.id + 200 AS repairId
CREATE (repair:CableEvent {
  kind: "cable_repair",
  id: repairId,
  eventStart: ce.eventEnd + duration({days: 1}),
  eventEnd: ce.eventEnd + duration({days: 1}),
  locationOfEvent: ce.locationOfEvent,
  repairSpecs: CASE ce.failureType
    WHEN "Mechanical Damage" THEN "Replaced damaged section"
    WHEN "Electrical Fault" THEN "Repaired insulation"
    WHEN "Insulation Failure" THEN "Installed new insulation"
    WHEN "Joint Failure" THEN "Replaced joint"
    ELSE "General repair" END,
  relatedFailureId: ce.id
})
CREATE (repair)-[:REPAIRS {repairDate: repair.eventStart}]->(ce);

// External Events (100 events: digging, lightning, floods, heatwaves, cold waves)
CREATE (ee1:ExternalEvent {kind: "DiggingActivity", eventId: 1, eventStart: date("2023-05-09"), eventEnd: date("2023-05-10"), utilityType: "Water", diggingType: "Pipeline Installation", diggingCoordinates: "POLYGON((12.554 55.684, 12.556 55.686, ...))", reportedToAuthority: "Copenhagen Municipality"})
CREATE (ee2:ExternalEvent {kind: "Lightning", eventId: 2, eventStart: date("2023-07-15"), eventEnd: date("2023-07-15"), impactTime: datetime("2023-07-15T14:30:00"), lightingCoordinates: "POINT(12.545 55.695)", numberOfStroke: 3, intensity: 100.0})
CREATE (ee3:ExternalEvent {kind: "Flood", eventId: 3, eventStart: date("2024-01-19"), eventEnd: date("2024-01-23"), coordinatesAffected: "MULTIPOLYGON((10.200 56.150, 10.210 56.165, ...))", maxPrecipitation: 150.0})
CREATE (ee4:ExternalEvent {kind: "HeatWave", eventId: 4, eventStart: date("2023-08-01"), eventEnd: date("2023-08-05"), coordinatesAffected: "MULTIPOLYGON((12.5 55.6, 12.6 55.7, ...))", maxTemperature: 32.0, minTemperature: 20.0})
CREATE (ee5:ExternalEvent {kind: "ColdWave", eventId: 5, eventStart: date("2024-02-10"), eventEnd: date("2024-02-15"), coordinatesAffected: "MULTIPOLYGON((10.0 56.0, 10.3 56.3, ...))", maxTemperature: -5.0, minTemperature: -15.0})
FOREACH (i IN range(6, 100) |
  CREATE (:ExternalEvent {
    kind: CASE toInteger(rand() * 5)
      WHEN 0 THEN "DiggingActivity"
      WHEN 1 THEN "Lightning"
      WHEN 2 THEN "Flood"
      WHEN 3 THEN "HeatWave"
      ELSE "ColdWave" END,
    eventId: i,
    eventStart: date("2020-01-01") + duration({days: toInteger(rand() * 1825)}),
    eventEnd: date("2020-01-01") + duration({days: toInteger(rand() * 1825) + toInteger(rand() * 7)}),
    utilityType: CASE WHEN toInteger(rand() * 5) = 0 THEN "Water" ELSE NULL END,
    diggingType: CASE WHEN toInteger(rand() * 5) = 0 THEN "Pipeline Installation" ELSE NULL END,
    diggingCoordinates: CASE WHEN toInteger(rand() * 5) = 0 THEN "POLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))" ELSE NULL END,
    reportedToAuthority: CASE WHEN toInteger(rand() * 5) = 0 THEN CASE toInteger(rand() * 3) WHEN 0 THEN "Copenhagen Municipality" WHEN 1 THEN "Aarhus Municipality" ELSE NULL END ELSE NULL END,
    impactTime: CASE WHEN toInteger(rand() * 5) = 1 THEN datetime("2020-01-01T00:00:00") + duration({days: toInteger(rand() * 1825)}) ELSE NULL END,
    lightingCoordinates: CASE WHEN toInteger(rand() * 5) = 1 THEN "POINT(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")" ELSE NULL END,
    numberOfStroke: CASE WHEN toInteger(rand() * 5) = 1 THEN toInteger(rand() * 5) + 1 ELSE NULL END,
    intensity: CASE WHEN toInteger(rand() * 5) = 1 THEN 50.0 + rand() * 150.0 ELSE NULL END,
    maxTemperature: CASE WHEN toInteger(rand() * 5) IN [3, 4] THEN CASE toInteger(rand() * 5) WHEN 3 THEN 25.0 + rand() * 10.0 ELSE -5.0 + rand() * 10.0 END ELSE NULL END,
    minTemperature: CASE WHEN toInteger(rand() * 5) IN [3, 4] THEN CASE toInteger(rand() * 5) WHEN 3 THEN 15.0 + rand() * 10.0 ELSE -15.0 + rand() * 10.0 END ELSE NULL END,
    maxPrecipitation: CASE WHEN toInteger(rand() * 5) = 2 THEN 100.0 + rand() * 100.0 ELSE NULL END,
    coordinatesAffected: "MULTIPOLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))"
  })
)

// Location Drivers (50 drivers: roads, railways, water bodies, soil types, weather conditions)
CREATE (ld1:LocationDriver {kind: "Road", driverID: 1, driverType: "road", coordinates: "LINESTRING(12.560 55.670, 12.550 55.690)", lengthInKm: 2.0})
CREATE (ld2:LocationDriver {kind: "WeatherCondition", driverID: 2, driverType: "weather", timeGranularity: "yearly", averageTemperature: 8.5, averageWindSpeed: 5.0, maxWindSpeed: 15.0, averageHumidity: 80.0, maxHumidity: 95.0, averagePrecipitation: 600.0, maxPrecipitation: 50.0, maxTemperature: 25.0, minTemperature: -5.0, timeRangeStart: date("2023-01-01"), timeRangeEnd: date("2023-12-31"), gridCoordinates: "MULTIPOLYGON((12.5 55.6, 12.6 55.7, ...))"})
CREATE (ld3:LocationDriver {kind: "Railway", driverID: 3, driverType: "railway", coordinates: "LINESTRING(10.195 56.145, 10.215 56.170)", lengthInKm: 3.0})
CREATE (ld4:LocationDriver {kind: "WaterBody", driverID: 4, driverType: "water", coordinates: "MULTIPOLYGON((10.190 56.140, 10.220 56.160, ...))"})
CREATE (ld5:LocationDriver {kind: "SoilType", driverID: 5, driverType: "soil", coordinates: "MULTIPOLYGON((12.540 55.680, 12.560 55.700, ...))", soilType: "Clay"})
FOREACH (i IN range(6, 50) |
  CREATE (:LocationDriver {
    kind: CASE toInteger(rand() * 5)
      WHEN 0 THEN "Road"
      WHEN 1 THEN "Railway"
      WHEN 2 THEN "WaterBody"
      WHEN 3 THEN "SoilType"
      ELSE "WeatherCondition" END,
    driverID: i,
    driverType: CASE toInteger(rand() * 5)
      WHEN 0 THEN "road"
      WHEN 1 THEN "railway"
      WHEN 2 THEN "water"
      WHEN 3 THEN "soil"
      ELSE "weather" END,
    coordinates: CASE toInteger(rand() * 5)
      WHEN 0 THEN "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
      WHEN 1 THEN "LINESTRING(" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", " + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ")"
      ELSE "MULTIPOLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))" END,
    lengthInKm: CASE toInteger(rand() * 5) IN [0, 1] THEN 1.0 + rand() * 5.0 ELSE NULL END,
    timeGranularity: CASE toInteger(rand() * 5) WHEN 4 THEN "yearly" ELSE NULL END,
    averageTemperature: CASE toInteger(rand() * 5) WHEN 4 THEN 7.0 + rand() * 3.0 ELSE NULL END,
    averageWindSpeed: CASE toInteger(rand() * 5) WHEN 4 THEN 4.0 + rand() * 3.0 ELSE NULL END,
    maxWindSpeed: CASE toInteger(rand() * 5) WHEN 4 THEN 10.0 + rand() * 10.0 ELSE NULL END,
    averageHumidity: CASE toInteger(rand() * 5) WHEN 4 THEN 75.0 + rand() * 20.0 ELSE NULL END,
    maxHumidity: CASE toInteger(rand() * 5) WHEN 4 THEN 90.0 + rand() * 10.0 ELSE NULL END,
    averagePrecipitation: CASE toInteger(rand() * 5) WHEN 4 THEN 500.0 + rand() * 400.0 ELSE NULL END,
    maxPrecipitation: CASE toInteger(rand() * 5) WHEN 4 THEN 40.0 + rand() * 20.0 ELSE NULL END,
    maxTemperature: CASE toInteger(rand() * 5) WHEN 4 THEN 20.0 + rand() * 10.0 ELSE NULL END,
    minTemperature: CASE toInteger(rand() * 5) WHEN 4 THEN -10.0 + rand() * 5.0 ELSE NULL END,
    timeRangeStart: CASE toInteger(rand() * 5) WHEN 4 THEN date("2020-01-01") + duration({years: toInteger(rand() * 3)}) ELSE NULL END,
    timeRangeEnd: CASE toInteger(rand() * 5) WHEN 4 THEN date("2020-01-01") + duration({years: toInteger(rand() * 3) + 1}) ELSE NULL END,
    gridCoordinates: CASE toInteger(rand() * 5) WHEN 4 THEN "MULTIPOLYGON((" + (9.8 + rand() * 3.0) + " " + (55.0 + rand() * 2.5) + ", ...))" ELSE NULL END,
    soilType: CASE toInteger(rand() * 5) WHEN 3 THEN CASE toInteger(rand() * 3) WHEN 0 THEN "Clay" WHEN 1 THEN "Sand" ELSE "Loam" END ELSE NULL END
  })
)

// --- Create Relationships ---

// DSO OPERATES Substation (random assignments)
MATCH (d:DSO), (s:Substation)
WHERE rand() < 0.2
CREATE (d)-[:OPERATES {dateFrom: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(s);

// DSO OPERATES MVCSystem
MATCH (d:DSO), (m:MVCSystem)
WHERE rand() < 0.2
CREATE (d)-[:OPERATES {dateFrom: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(m);

// Substation PARENT_OF Substation (primary to secondary)
MATCH (s1:Substation {kind: "primary"}), (s2:Substation {kind: "secondary"})
WHERE rand() < 0.3
CREATE (s1)-[:PARENT_OF]->(s2);

// Substation CONNECTS MVCSystem (from primary, to secondary)
MATCH (s1:Substation {kind: "primary"}), (m:MVCSystem)
WHERE rand() < 0.2
CREATE (s1)-[:CONNECTS {role: "from", connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(m);
MATCH (s2:Substation {kind: "secondary"}), (m:MVCSystem)
WHERE rand() < 0.2
CREATE (s2)-[:CONNECTS {role: "to", connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(m);

// MVCSystem CONTAINS MVCSubsection (3-10 subsections per system)
MATCH (m:MVCSystem)
WITH m, toInteger(rand() * 8 + 3) AS numSubsections
MATCH (ms:MVCSubsection)
WHERE rand() < 0.02
LIMIT numSubsections
CREATE (m)-[:CONTAINS {connectionDate: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(ms);

// CableJoint JOINS MVCSubsection (connect pairs of subsections)
MATCH (ms1:MVCSubsection), (ms2:MVCSubsection), (j:CableJoint)
WHERE ms1.id < ms2.id AND rand() < 0.01
CREATE (j)-[:JOINS {position: "first", joinedOn: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(ms1)
CREATE (j)-[:JOINS {position: "second", joinedOn: date("2010-01-01") + duration({years: toInteger(rand() * 10)})}]->(ms2);

// CableEvent AFFECTS MVCSubsection
MATCH (ce:CableEvent {kind: "cable_failure"}), (ms:MVCSubsection)
WHERE rand() < 0.05
CREATE (ce)-[:AFFECTS {dateAffected: ce.eventStart}]->(ms);

// ExternalEvent IMPACTS MVCSubsection
MATCH (ee:ExternalEvent), (ms:MVCSubsection)
WHERE rand() < 0.05
CREATE (ee)-[:IMPACTS {spatialOverlapPercentage: 0.5 + rand() * 0.5}]->(ms);

// CableEvent CAUSED_BY ExternalEvent (for digging, lightning, flooding)
MATCH (ce:CableEvent {kind: "cable_failure"}), (ee:ExternalEvent)
WHERE (ce.failureCause = "Digging Incident" AND ee.kind = "DiggingActivity")
   OR (ce.failureCause = "Lightning Strike" AND ee.kind = "Lightning")
   OR (ce.failureCause = "Flooding" AND ee.kind = "Flood")
   AND rand() < 0.3
CREATE (ce)-[:CAUSED_BY {spatialOverlapPercentage: 0.5 + rand() * 0.5, timeOverlap: true}]->(ee);

// LocationDriver INFLUENCES MVCSubsection
MATCH (ld:LocationDriver), (ms:MVCSubsection)
WHERE rand() < 0.05
CREATE (ld)-[:INFLUENCES {spatialOverlapPercentage: 0.3 + rand() * 0.7}]->(ms);

// LocationDriver CONTRIBUTES_TO CableEvent
MATCH (ld:LocationDriver), (ce:CableEvent {kind: "cable_failure"})
WHERE rand() < 0.05
CREATE (ld)-[:CONTRIBUTES_TO {spatialOverlapPercentage: 0.3 + rand() * 0.7, timeOverlap: true}]->(ce);

// --- Update Derived Properties ---
MATCH (m:MVCSystem)
SET m.numberOfSubsections = SIZE([(m)-[:CONTAINS]->(ms) | ms]),
    m.lengthInKm = COALESCE(SUM([(m)-[:CONTAINS]->(ms) | ms.lengthInKm]), 0.0);

MATCH (ms:MVCSubsection)
SET ms.numberOfJoints = SIZE([(ms)<-[:JOINS]-() | 1]);

// --- Testing Queries for Use Cases ---

// Use Case 1: Which DSO operates an MV Cable System?
MATCH (d:DSO)-[:OPERATES]->(m:MVCSystem)
RETURN d.name, m.name
LIMIT 10;

// Use Case 3: How many failures occurred in a given year?
MATCH (ce:CableEvent {kind: "cable_failure"})
WHERE ce.eventStart.year = 2023
RETURN COUNT(ce) AS failure_count;

// Use Case 4: Which DSO had the most failures?
MATCH (d:DSO)-[:OPERATES]->(m:MVCSystem)-[:CONTAINS]->(ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN d.name, COUNT(ce) AS failure_count
ORDER BY failure_count DESC
LIMIT 5;

// Use Case 5: What are the leading factors for most failures?
MATCH (ce:CableEvent {kind: "cable_failure"})
OPTIONAL MATCH (ce)-[:CAUSED_BY]->(ee:ExternalEvent)
RETURN ce.failureCause, ee.kind AS external_event, COUNT(*) AS failure_count
ORDER BY failure_count DESC
LIMIT 10;

// Use Case 7: Give maintenance record for a certain component
MATCH (ms:MVCSubsection {id: 1})<-[:AFFECTS]-(ce:CableEvent {kind: "cable_repair"})
RETURN ce.eventStart, ce.repairSpecs, ce.relatedFailureId
ORDER BY ce.eventStart;

// Use Case 9: Were certain activities reported to the responsible authorities?
MATCH (ee:ExternalEvent {kind: "DiggingActivity"})
RETURN ee.eventId, ee.diggingType, ee.reportedToAuthority
LIMIT 10;

// Use Case 12: What is the coverage area of a DSO
MATCH (d:DSO)
RETURN d.name, d.supplyArea
LIMIT 5;

// Use Case 14: What cable types are mostly affected by digging activities?
MATCH (ee:ExternalEvent {kind: "DiggingActivity"})-[:IMPACTS]->(ms:MVCSubsection)
RETURN ms.conductorType, COUNT(*) AS impact_count
ORDER BY impact_count DESC;

// Use Case 15: Are there specific cable materials that lead to most of the failures?
MATCH (ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN ms.conductorMaterial, COUNT(ce) AS failure_count
ORDER BY failure_count DESC;

// Use Case 19: What weather conditions are associated with most failures?
MATCH (ce:CableEvent {kind: "cable_failure"})-[:CAUSED_BY]->(ee:ExternalEvent)
WHERE ee.kind IN ["Flood", "HeatWave", "ColdWave"]
RETURN ee.kind, ee.maxTemperature, ee.maxPrecipitation, COUNT(*) AS failure_count
ORDER BY failure_count DESC;

// Use Case 20: Do cables with many joints fail more than those with few joints?
MATCH (ms:MVCSubsection)
OPTIONAL MATCH (ms)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN ms.numberOfJoints, COUNT(ce) AS failure_count
ORDER BY ms.numberOfJoints
LIMIT 20;

// Use Case 21: What distance of the cable system was affected?
MATCH (m:MVCSystem)-[:CONTAINS]->(ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN m.name, SUM(ms.lengthInKm) AS affected_length_km
ORDER BY affected_length_km DESC
LIMIT 10;
