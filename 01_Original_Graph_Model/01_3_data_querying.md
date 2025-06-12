# Sample queries to fetch datasets
### Use Case 1: Which DSO operates an MV Cable System?
MATCH (d:DSO)-[:OPERATES]->(m:MVCSystem)
RETURN d.name, m.name
LIMIT 10;

### Use Case 3: How many failures occurred in a given year?
MATCH (ce:CableEvent {kind: "cable_failure"})
WHERE ce.eventStart.year = 2023
RETURN COUNT(ce) AS failure_count;

### Use Case 4: Which DSO had the most failures?
MATCH (d:DSO)-[:OPERATES]->(m:MVCSystem)-[:CONTAINS]->(ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN d.name, COUNT(ce) AS failure_count
ORDER BY failure_count DESC
LIMIT 5;

### Use Case 5: What are the leading factors for most failures?
MATCH (ce:CableEvent {kind: "cable_failure"})
OPTIONAL MATCH (ce)-[:CAUSED_BY]->(ee:ExternalEvent)
RETURN ce.failureCause, ee.kind AS external_event, COUNT(*) AS failure_count
ORDER BY failure_count DESC
LIMIT 10;

### Use Case 7: Give maintenance record for a certain component
MATCH (ms:MVCSubsection {id: 1})<-[:AFFECTS]-(ce:CableEvent {kind: "cable_repair"})
RETURN ce.eventStart, ce.repairSpecs, ce.relatedFailureId
ORDER BY ce.eventStart;

### Use Case 9: Were certain activities reported to the responsible authorities?
MATCH (ee:ExternalEvent {kind: "DiggingActivity"})
RETURN ee.eventId, ee.diggingType, ee.reportedToAuthority
LIMIT 10;

### Use Case 12: What is the coverage area of a DSO
MATCH (d:DSO)
RETURN d.name, d.supplyArea
LIMIT 5;

### Use Case 14: What cable types are mostly affected by digging activities?
MATCH (ee:ExternalEvent {kind: "DiggingActivity"})-[:IMPACTS]->(ms:MVCSubsection)
RETURN ms.conductorType, COUNT(*) AS impact_count
ORDER BY impact_count DESC;

### Use Case 15: Are there specific cable materials that lead to most of the failures?
MATCH (ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN ms.conductorMaterial, COUNT(ce) AS failure_count
ORDER BY failure_count DESC;

### Use Case 19: What weather conditions are associated with most failures?
MATCH (ce:CableEvent {kind: "cable_failure"})-[:CAUSED_BY]->(ee:ExternalEvent)
WHERE ee.kind IN ["Flood", "HeatWave", "ColdWave"]
RETURN ee.kind, ee.maxTemperature, ee.maxPrecipitation, COUNT(*) AS failure_count
ORDER BY failure_count DESC;

### Use Case 20: Do cables with many joints fail more than those with few joints?
MATCH (ms:MVCSubsection)
OPTIONAL MATCH (ms)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN ms.numberOfJoints, COUNT(ce) AS failure_count
ORDER BY ms.numberOfJoints
LIMIT 20;

### Use Case 21: What distance of the cable system was affected?
MATCH (m:MVCSystem)-[:CONTAINS]->(ms:MVCSubsection)<-[:AFFECTS]-(ce:CableEvent {kind: "cable_failure"})
RETURN m.name, SUM(ms.lengthInKm) AS affected_length_km
ORDER BY affected_length_km DESC
LIMIT 10;
