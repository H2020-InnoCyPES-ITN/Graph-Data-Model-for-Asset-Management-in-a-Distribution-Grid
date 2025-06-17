# Graph Model based on CIM/IEC
This folder present a refined graph data model to align with CIM/IEC standards. This is done by considering major critical components that has been documented in the standards. To better model data for the reliability of the MV cable network and failure data, a combination of three IEC profiles is needed. First, since we track the failure of cables, asset records are required (as specified in IEC 61968-4). Second, components will be maintained, repaired, and some will be built. In such cases, maintenance and construction records (as specified in IEC 61968-6) are required. Third, the cable system is connected through substations, which have joints or junctions, and subsections that belong to IEC 61968-11. Hence, our graph-based data model takes into consideration these standards to ensure correctness and support scalability. Three files are presented, (i) detailed descriptions of how previous graph-based model is refined to align with CIM/IEC, (ii) the CYPHER model to implement the proposal and (iii) basic queries to fetch the stored data.

## Overview

We target power system cable networks, tailored for DSOs. The model supports critical use cases, including fault analysis, maintenance tracking, and network topology management, and hence facilitating efficient querying of complex relationships in medium-voltage cable systems (can easily accomodate low voltage cables). Initially designed for agility, the model has been refined to align with the CIM/IEC 61968 standards to ensure interoperability with utility systems while benefiting from the strengths of graph databases for relationship-driven analysis.

## Model Description

The model represents power system components and their interactions as nodes and edges in a graph database, optimised for DSO operations. Key entities include:

- **Nodes**:
  - `Organisation`: Represents DSOs, with properties like `serviceRegion` and `organisationRole`, aligned with IEC 61968::Common.
  - `Substation`: Models substations with `VoltageLevel` associations for electrical characteristics, per IEC 61970::Wires.
  - `AssetContainer`: Groups `ACLineSegment` nodes (cable subsections), supporting network organization per IEC 61968-11.
  - `ACLineSegment`: Represents cable subsections with `CableInfo` for physical attributes, aligned with IEC 61968-4.
  - `Junction` and `Asset`: Dual representation of cable joints for electrical connectivity and physical properties, per IEC 61970::Wires and IEC 61968-4.
  - `FailureEvent` and `WorkOrder`: Capture cable failures and repairs, aligned with IEC 61968-6 for maintenance tracking.
  - `ActivityRecord`: Models external events (e.g., digging, weather), per IEC 61968::Common.
  - `Location` and `Measurement`: Represent static environmental factors (e.g., soil type) and dynamic weather data, per IEC 61968-4.

- **Edges**:
  - `OPERATES`: Links `Organisation` to `AssetContainer` or `Substation`, reflecting operational control.
  - `FEEDS`, `CONNECTS_TO`, `ROUTES_THROUGH`: Use `Terminal` nodes for precise electrical connectivity, per IEC 61968-11.
  - `CONTAINS`: Groups `ACLineSegment` within `AssetContainer`.
  - `JOINS`: Connects `Junction` to `ACLineSegment` for cable connections.
  - `AFFECTS`, `IMPACTS`, `CAUSED_BY`, `CONTRIBUTES_TO`, `INFLUENCES`: Model fault propagation, external event impacts, and environmental influences, aligned with IEC 61968-4 and 6.
  - `REPAIRS`: Links `WorkOrder` to `FailureEvent` for maintenance tracking.

## CIM/IEC 61968 Alignment

The model has been refined to align with CIM/IEC 61968 standards:
- **Part 4 (Asset Records)**: Standardises asset data (e.g., `ACLineSegment`, `Junction`) with `mRID` identifiers and `CableInfo`/`JointInfo` for detailed properties.
- **Part 6 (Maintenance & Construction)**: Models maintenance via `WorkOrder` and `FailureEvent` for repair and fault tracking.
- **Part 11 (CIM Extensions for Distribution)**: Ensures accurate electrical topology using `VoltageLevel`, `Terminal`, and `ConnectivityNode` concepts.

This alignment enables interoperability with CIM-compliant utility systems while maintaining graph-based efficiency for DSO-specific queries (e.g., fault cause analysis, cable material failure trends).

## Usage

The provided Cypher code (see [CYPHER CODE](/02_Alignment_to_CIM_and_IEC_Standards/02_2_graph_model_cim_iec_standard.cypher)) implements the model in Neo4j, including:
- **Constraints and Indexes**: ensuring that assets are uniquely identified using (`mRID`). This also helps to optimise query performance.
- **Sample Data**: The code loads 5 DSOs, 50 substations, 100 asset containers, 500 cable subsections, 300 joints, 200 failures, 150 repairs, and 100 external events. This is all synthetic data.
- **Relationships**: Establishes CIM-aligned connections for topology, fault, and maintenance analysis.
- **Testing Queries**: Supports use cases like identifying DSO-operated systems, analysing failure causes, and tracking maintenance records.

To use:
1. Install Neo4j with spatial data support.
2. Run the Cypher script to create nodes, relationships, and indexes.
3. Execute testing queries to validate use cases.
