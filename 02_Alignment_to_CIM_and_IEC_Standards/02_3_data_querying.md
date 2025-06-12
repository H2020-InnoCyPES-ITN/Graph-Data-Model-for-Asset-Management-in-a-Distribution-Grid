
# --- Testing Queries for Use Cases ---

## Use Case 1: Which Organisation operates an AssetContainer?
MATCH (o:Organisation)-[:OPERATES]->(ac:AssetContainer)
RETURN o.name, ac.name
LIMIT 10;

## Use Case 3: How many failures occurred in a given year?
MATCH (fe:FailureEvent {eventType: "CableFailure"})
WHERE fe.startTime.year = 2023
RETURN COUNT(fe) AS failure_count;

## Use Case 4: Which Organisation had the most failures?
MATCH (o:Organisation)-[:OPERATES]->(ac:AssetContainer)-[:CONTAINS]->(ls:ACLineSegment)<-[:AFFECTS]-(fe:FailureEvent {eventType: "CableFailure"})
RETURN o.name, COUNT(fe) AS failure_count
ORDER BY failure_count DESC
LIMIT 5;

## Use Case 5: What are the leading factors for most failures?
MATCH (fe:FailureEvent {eventType: "CableFailure"})
OPTIONAL MATCH (fe)-[:CAUSED_BY]->(ar:ActivityRecord)
RETURN fe.cause, ar.eventType AS external_event, COUNT(*) AS failure_count
ORDER BY failure_count DESC
LIMIT 10;

## Use Case 7: Give maintenance record for a certain component
MATCH (ls:ACLineSegment {mRID: "LS1"})<-[:AFFECTS]-(wo:WorkOrder {eventType: "CableRepair"})
RETURN wo.startTime, wo.workDetails, wo.relatedFailureId
ORDER BY wo.startTime;

## Use Case 9: Were certain activities reported to the responsible authorities?
MATCH (ar:ActivityRecord {eventType: "DiggingActivity"})
RETURN ar.mRID, ar.attributes.diggingType, ar.attributes.reportedToAuthority
LIMIT 10;

## Use Case 12: What is the coverage area of an Organisation?
MATCH (o:Organisation)
RETURN o.name, o.serviceRegion
LIMIT 5;

## Use Case 14: What cable types are mostly affected by digging activities?
MATCH (ar:ActivityRecord {eventType: "DiggingActivity"})-[:IMPACTS]->(ls:ACLineSegment)-[:HAS_ASSET_INFO]->(ci:CableInfo)
RETURN ci.conductorType, COUNT(*) AS impact_count
ORDER BY impact_count DESC;

## Use Case 15: Are there specific cable materials that lead to most of the failures?
MATCH (ls:ACLineSegment)<-[:AFFECTS]-(fe:FailureEvent {eventType: "CableFailure"})-[:HAS_ASSET_INFO]->(ci:CableInfo)
RETURN ci.conductorMaterial, COUNT(fe) AS failure_count
ORDER BY failure_count DESC;

## Use Case 19: What weather conditions are associated with most failures?
MATCH (fe:FailureEvent {eventType: "CableFailure"})-[:CAUSED_BY]->(ar:ActivityRecord)
WHERE ar.eventType IN ["Flood", "HeatWave", "ColdWave"]
RETURN ar.eventType, ar.attributes.maxTemperature, ar.attributes.maxPrecipitation, COUNT(*) AS failure_count
ORDER BY failure_count DESC;

## Use Case 20: Do cables with many joints fail more than those with few joints?
MATCH (ls:ACLineSegment)
OPTIONAL MATCH (ls)<-[:AFFECTS]-(fe:FailureEvent {eventType: "CableFailure"})
RETURN ls.numberOfJoints, COUNT(fe) AS failure_count
ORDER BY ls.numberOfJoints
LIMIT 20;

## Use Case 21: What distance of the cable system was affected?
MATCH (ac:AssetContainer)-[:CONTAINS]->(ls:ACLineSegment)<-[:AFFECTS]-(fe:FailureEvent {eventType: "CableFailure"})
RETURN ac.name, SUM(ls.length) AS affected_length_km
ORDER BY affected_length_km DESC
LIMIT 10;
