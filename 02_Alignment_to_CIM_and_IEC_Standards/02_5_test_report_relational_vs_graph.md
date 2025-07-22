# Database Performance Comparison: Relational vs. Graph

This document outlines the setup, queries, and results of a performance benchmark comparing a relational database (PostgreSQL) and a native graph database (Neo4j) for analysing power distribution network data.

---

## 1. Test Setup and Data

### Test Environment
The performance benchmark was conducted on two database systems: Neo4j (v5), a native graph database, and PostgreSQL (v15) with the PostGIS extension for spatial capabilities. Both systems were loaded with an identical, synthetically generated dataset representing a power distribution network. The data models were designed to be functionally equivalent, with the relational model using standard table structures and foreign key relationships, and the graph model using nodes and edges.

### Dataset
The test data was generated to simulate a realistic power grid network, consisting of 5 Distribution System Operators (DSOs), 50 substations, 100 asset containers, 500 AC line segments, 300 junctions, 200 failure events, 150 work orders, and 100 external activity records. In the PostgreSQL model, these entities are stored across 8 primary tables, with their connections managed in 3 junction tables, including 2,058 records in the main failure_affects_asset table. In the Neo4j model, this corresponds to approximately 2,701 nodes and 63,506 relationships (edges).

---

## 2. Test Queries

Three queries of varying complexity were executed on both database systems.

### Q1: How many failures occurred in a given year?
A simple aggregation query filtering on a single entity.

* **SQL (PostgreSQL)**
    ```sql
    SELECT
        COUNT(*) AS failure_count
    FROM
        failure_event
    WHERE
        event_type = 'CableFailure'
        AND EXTRACT(YEAR FROM start_time) = 2023;
    ```
* **Cypher (Neo4j)**
    ```cypher
    MATCH (fe:FailureEvent {eventType: "CableFailure"})
    WHERE fe.startTime.year = 2023
    RETURN COUNT(fe) AS failure_count;
    ```

### Q2: Which DSO had the most failures?
A complex query requiring deep traversal across multiple entities and relationships/joins.

* **SQL (PostgreSQL)**
    ```sql
    WITH organisation_failures AS (
        -- Path 1: Find failures that affect ACLineSegments directly
        SELECT o.name AS organisation_name, fe.mrid AS failure_mrid
        FROM organisation o
        JOIN organisation_operates_asset ooa ON o.mrid = ooa.organisation_mrid
        JOIN asset_container ac ON ooa.asset_mrid = ac.mrid
        JOIN ac_line_segment ls ON ac.mrid = ls.asset_container_mrid
        JOIN failure_affects_asset faa ON ls.mrid = faa.asset_mrid AND faa.asset_type = 'ac_line_segment'
        JOIN failure_event fe ON faa.failure_mrid = fe.mrid
        WHERE ooa.asset_type = 'asset_container'
        UNION
        -- Path 2: Find failures that affect Junctions
        SELECT o.name AS organisation_name, fe.mrid AS failure_mrid
        FROM organisation o
        JOIN organisation_operates_asset ooa ON o.mrid = ooa.organisation_mrid
        JOIN asset_container ac ON ooa.asset_mrid = ac.mrid
        JOIN ac_line_segment ls ON ac.mrid = ls.asset_container_mrid
        JOIN junction_joins_acls jja ON ls.mrid = jja.ac_line_segment_mrid
        JOIN failure_affects_asset faa ON jja.junction_mrid = faa.asset_mrid AND faa.asset_type = 'junction'
        JOIN failure_event fe ON faa.failure_mrid = fe.mrid
        WHERE ooa.asset_type = 'asset_container'
    )
    SELECT
        organisation_name AS "Organisation",
        COUNT(DISTINCT failure_mrid) AS "NumberOfFailures"
    FROM organisation_failures
    GROUP BY organisation_name
    ORDER BY "NumberOfFailures" DESC;
    ```
* **Cypher (Neo4j)**
    ```cypher
    CALL () {
        // Path 1: Find failures that affect ACLineSegments
        MATCH (o:Organisation)-[:OPERATES]->(:AssetContainer)-[:CONTAINS]->(:ACLineSegment)<-[:AFFECTS]-(fe:FailureEvent)
        RETURN o, fe
        UNION
        // Path 2: Find failures that affect Junctions
        MATCH (o:Organisation)-[:OPERATES]->(:AssetContainer)-[:CONTAINS]->(:ACLineSegment)<-[:JOINS]-(:Junction)<-[:AFFECTS]-(fe:FailureEvent)
        RETURN o, fe
    }
    RETURN
        o.name AS Organisation,
        count(DISTINCT fe) AS NumberOfFailures
    ORDER BY NumberOfFailures DESC;
    ```

### Q3: What are the leading factors for most failures?
A query involving an optional relationship traversal to correlate failures with external events.

* **SQL (PostgreSQL)**
    ```sql
    SELECT
        fe.cause,
        ar.event_type AS external_event,
        COUNT(*) AS failure_count
    FROM
        failure_event fe
    LEFT JOIN
        activity_record ar ON
            (
                (fe.cause = 'Digging Incident' AND ar.event_type = 'DiggingActivity') OR
                (fe.cause = 'Lightning Strike' AND ar.event_type = 'Lightning') OR
                (fe.cause = 'Flooding' AND ar.event_type = 'Flood')
            )
            AND ST_DWithin(fe.location, ar.location, 0.05)
    WHERE
        fe.event_type = 'CableFailure'
    GROUP BY
        fe.cause,
        ar.event_type
    ORDER BY
        failure_count DESC;
    ```
* **Cypher (Neo4j)**
    ```cypher
    MATCH (fe:FailureEvent {eventType: "CableFailure"})
    OPTIONAL MATCH (fe)-[:CAUSED_BY]->(ar:ActivityRecord)
    RETURN fe.cause, ar.eventType AS external_event, COUNT(*) AS failure_count
    ORDER BY failure_count DESC;
    ```

---

## 3. Results Summary

The performance results for each query are summarized below.

| Query | Relational Data (PostgreSQL) | | | Graph Data (Neo4j) | |
| :--- | :--- | :--- | :--- | :--- | :--- |
| | **Time** | **Blocks Accessed** | **Returned Rows** | **Time** | **Database Hits** |
| **Q1** | 0.532 ms | 4 | 1 | 1 ms | 601 |
| **Q2** | 35.181 ms | 88 | 5 | 21 ms | 22,522 |
| **Q3** | 16.789 ms | 6 | 7 | 6 ms | 4,875 |

---

## 4. Analysis and Conclusion

The performance evaluation of the relational (PostgreSQL) and graph (Neo4j) database models reveals a clear distinction in efficiency based on query complexity. For simple aggregation tasks (Q1), the relational database demonstrated superior performance, executing in 0.532 ms with only 4 block accesses. However, for queries requiring deep traversal of interconnected data (Q2 and Q3), the graph database was significantly faster, with execution times up to 1.7 times quicker (21 ms compared to 35.181 ms). Although the graph model registered a higher number of internal database hits, its native relationship-based processing proved more efficient than the computationally expensive JOIN operations required by the relational model for complex, multi-hop queries.
