# Graph-Data-Model-for-Asset-Management-in-a-Distribution-Grid
A Neo4j-based graph data model for Asset Management in Power Systems


The selection of node properties within the graph data model is guided by the principle of capturing essential characteristics to address specific use cases effectively. Each property aims to uniquely identify nodes, provide data for querying, and answer questions outlined in the use cases.

For the DSO (Distribution System Operator) node, the Name property serves as a unique string identifier for each DSO. The supplyArea (Geometry) defines the geographical operational zone of the DSO, which is crucial for queries related to coverage. dateRegistered (Date) indicates when the DSO commenced operations, providing a temporal dimension. Optional reliabilityIndices (Float) can store metrics for performance assessment. These properties collectively enable the identification of DSOs, their operational areas, and operational history, aligning with use cases such as determining which DSO operates a specific MV Cable System or Substation.

The Substation node uses an id (Integer) for a unique identifier. While name (String) can also be unique, the id ensures distinctness. highVoltageLimit and lowVoltageLimit (Integer) define the operational voltage parameters of the substation; these can also be modeled as a single string representing a range (e.g., "10-20 kV"). installationDate (Date) records when the substation was installed. coordinates (Geometry - POINT) specify the geographical location of the substation. These attributes are essential for identifying substations, their voltage characteristics, and locations, directly supporting use cases about substation operations and voltage levels.

Regarding the MVCSystem (Medium Voltage Cable System), the name (String) can function as an identifier. averageLoading and maxLoading (Float) are intended to reflect the system's operational load. It is noted that averageLoading is a derived property, potentially calculated over time, and might not be strictly necessary during the initial design phase. These properties are key for use cases related to system capacity.

For the MVCSubsection (Medium Voltage Cable Subsection), an id (Integer) ensures unique identification. Physical attributes such as numberOfConductors (Integer), conductorSize (Float, in mm), conductorMaterial (String), insulation (String), and conductorType (String) provide detailed technical specifications crucial for analysis. The manufacturer (String) allows tracking of components by origin. inServiceDate (Date) marks when the subsection became operational, and lengthInKm (Float) quantifies its length. Coordinates (Geometry - LINESTRING) map the cable's geographical path. isRepairSection (Boolean) indicates if it was installed as part of a repair, and outOfService (Boolean) shows its current operational status. These detailed properties support a wide range of use cases, including failure analysis, maintenance records, and inquiries about specific cable materials or types affected by events like digging.

The CableJoint node has an id (Integer) to uniquely identify each joint. jointType (String) specifies the type of joint, which can be pertinent for failure analysis, for example, if certain joint types are more prone to failure. coordinatesInstalled (Geometry - POINT) gives the precise location of the joint. This node and its properties are relevant for use cases investigating the correlation between the number of joints and cable failures.

The CableEvent node uses an id (Integer) as a unique identifier for all cable events, whether failures or repairs. eventStart and eventEnd (Date) define the occurrence period of the event, which might differ from when the cable was affected. locationOfEvent (Geometry - POINT) pinpoints where the event took place. causeOfEvent (String) describes the reason for the failure or repair. For failure events, failureType (String) provides classification, while repairSpecs (String) details repair actions for repair events. These properties are fundamental for analyzing failure occurrences, durations, causes, and repair histories.

For ExternalEvent nodes, eventId (Integer) is a unique identifier for events like DiggingActivity or WeatherEvents (Lightning, ColdWave, Flood, HeatWave). Timestamps such as eventStart (Date), eventEnd (Date), and impactTime (DateTime) record the timing of these events. Location data, including diggingCoordinates (Geometry - POLYGON), lightingCoordinates (Geometry - POINT), and coordinatesAffected (Geometry - MULTIPOLYGON), provide spatial context. Specific attributes like utilityType and diggingType (String) for digging activities, or numberOfStroke (Integer) and intensity (Float) for lightning, and maxTemperature/minTemperature (Float) for heatwaves/coldwaves, capture event-specific details for acute weather events (average temperatures are stored in LocationDriver). reportedTo (Boolean) indicates if cable details were requested for digging events, capturing the authority if reported. These properties enable the investigation of external causes of cable failures, such as digging or weather events.

Finally, the LocationDriver node has a driverID (Integer) to uniquely identify each location driver. driverType (String) categorizes the driver (e.g., Road, Rail, SoilType, WeatherCondition). coordinates (Geometry - LINESTRING for Road, Rail, Water, Soil) and gridCoordinates (Geometry - MULTIPOLYGON for WeatherCondition) define the spatial extent of these drivers. lengthInKm (Float) applies to linear features like roads and rails. Weather-related properties such as averageTemperature, averageWindSpeed, maxWindSpeed, averageHumidity, maxHumidity, averagePrecipitation, maxPrecipitation, maxTemperature, and min_Temperature (Float) store long-term, static environmental data (e.g., annual climate metrics), which is distinct from acute ExternalEvent weather data. timeRangeStart and timeRangeEnd (Datetime) specify the period for which these average weather conditions are relevant. These properties model static environmental influences on cable subsections, independent of specific failure events, and help identify contributing factors to failures.

## Nodes and its associated properties
### DSO

| **Label** | **Properties**                                           | **Description**                          |
|-----------|----------------------------------------------------------|------------------------------------------|
| `DSO`     | `name: String`                                           | Unique for each DSO                      |
|           | `supplyArea: Geometry (Multipolygon)`                   | Representing the DSO's supply area       |
|           | `dateRegistered: Date`                                  | When it started operations               |
|           | `reliabilityIndices: Float`                             | Optional, for reliability metrics        |

### Substation (MainSubstation, SecondarySubstation)

| **Label**     | **Properties**                      | **Description**                                         |
|---------------|-------------------------------------|---------------------------------------------------------|
| `Substation`  | `id: Integer`                       | Unique identifier                                       |
|               | `name: String`                      | Can be unique                                           |
|               | `highVoltageLimit: Integer`         | Can also be modeled as a single string (e.g., 10-20 kV) |
|               | `lowVoltageLimit: Integer`          |                                                         |
|               | `installationDate: Date`            |                                                         |
|               | `coordinates: Geometry (POINT)`     |                                                         |

### MVCSystem

| **Label**     | **Properties**            | **Description**                                                                 |
|---------------|---------------------------|---------------------------------------------------------------------------------|
| `MVCSystem`   | `name: String`            | Can act as an ID                                                                |
|               | `averageLoading: Float`   | Derived; may be excluded in schema design                                       |
|               | `maxLoading: Float`       |                                                                                 |

### MVCSubsection

| **Label**        | **Properties**                            | **Description**                                |
|------------------|-------------------------------------------|------------------------------------------------|
| `MVCSubsection`  | `id: Integer`                             |                                                |
|                  | `numberOfConductors: Integer`             |                                                |
|                  | `conductorSize: Float`                    | Stored in mm                                   |
|                  | `conductorMaterial: String`               |                                                |
|                  | `insulation: String`                      | Insulation type                                |
|                  | `conductorType: String`                   |                                                |
|                  | `manufacturer: String`                    |                                                |
|                  | `inServiceDate: Date`                     | Date put into service                          |
|                  | `lengthInKm: Float`                       | Length of subsection                           |
|                  | `coordinates: Geometry (LINESTRING)`      | Path of the cable                              |
|                  | `isRepairSection: Boolean`                | Indicates if installed due to a repair         |
|                  | `outOfService: Boolean`                   | Indicates operational status                   |

### CableJoint

| **Label**      | **Properties**                            | **Description**                    |
|----------------|-------------------------------------------|------------------------------------|
| `CableJoint`   | `id: Integer`                             |                                    |
|                | `jointType: String`                       |                                    |
|                | `coordinatesInstalled: Geometry (POINT)`  |                                    |

### CableEvent (CableFailure, CableRepair)

| **Label**         | **Properties**                                  | **Description**                                                                 |
|-------------------|--------------------------------------------------|---------------------------------------------------------------------------------|
| `CableEvent`      | `id: Integer`                                    | Shared ID format for all cable events                                          |
|                   | `eventStart: Date`                               | When the event began                                                           |
|                   | `eventEnd: Date`                                 | When the event ended                                                           |
|                   | `locationOfEvent: Geometry (POINT)`              | Event location                                                                 |
|                   | `causeOfEvent: String`                           | Cause of failure or repair                                                     |
|                   | `failureType: String`                            | For failure events                                                             |
|                   | `repairSpecs: String`                            | For repair events                                                              |

### ExternalEvent (e.g., DiggingActivity, WeatherEvents)

| **Label**          | **Properties**                                   | **Description**                                                                                  |
|--------------------|--------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `ExternalEvent`    | `eventId: Integer`                               | For all external events                                                                          |
|                    | `eventStart: Date`                               |                                                                                                  |
|                    | `eventEnd: Date`                                 |                                                                                                  |
|                    | `utilityType: String`                            | For digging activities                                                                           |
|                    | `diggingType: String`                            |                                                                                                  |
|                    | `diggingCoordinates: Geometry (POLYGON)`         | Area of digging                                                                                  |
|                    | `reportedTo: Boolean`                            | Whether cable details were requested                                                             |
|                    | `impactTime: DateTime`                           | For lightning-related events                                                                     |
|                    | `lightingCoordinates: Geometry (POINT)`          |                                                                                                  |
|                    | `numberOfStroke: Integer`                        |                                                                                                  |
|                    | `intensity: Float`                               |                                                                                                  |
|                    | `maxTemperature: Float`                          | For heatwave/coldwave                                                                            |
|                    | `minTemperature: Float`                          |                                                                                                  |
|                    | `coordinatesAffected: Geometry (MULTIPOLYGON)`  |                                                                                                  |

### LocationDriver (e.g., Road, Rail, WaterBody, SoilType, WeatherCondition)

| **Label**          | **Properties**                                   | **Description**                                                                                  |
|--------------------|--------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `LocationDriver`   | `driverID: Integer`                              | Shared format for all types                                                                      |
|                    | `driverType: String`                             |                                                                                                  |
|                    | `coordinates: Geometry (LINESTRING)`            | For Road, Rail, Water, Soil                                                                      |
|                    | `lengthInKm: Float`                              | For Road and Rail                                                                                |
|                    | `averageTemperature: Float`                      | Long-term environmental data                                                                     |
|                    | `averageWindSpeed: Float`                        |                                                                                                  |
|                    | `maxWindSpeed: Float`                            |                                                                                                  |
|                    | `averageHumidity: Float`                         |                                                                                                  |
|                    | `maxHumidity: Float`                             |                                                                                                  |
|                    | `averagePrecipitation: Float`                    |                                                                                                  |
|                    | `maxPrecipitation: Float`                        |                                                                                                  |
|                    | `maxTemperature: Float`                          |                                                                                                  |
|                    | `min_Temperature: Float`                         |                                                                                                  |
|                    | `timeRangeStart: Datetime`                       |                                                                                                  |
|                    | `timeRangeEnd: Datetime`                         |                                                                                                  |
|                    | `gridCoordinates: Geometry (MULTIPOLYGON)`      |                                                                                                  |

> ⚠️ **Note**:  
> - Avoid using average temperature for *acute weather events*; this is captured in the `LocationDriver` node.  
> - Environmental data in `LocationDriver` is intended for long-term averages (e.g., yearly statistics).


## Edges and its properties
| **Edge**         | **Properties**                                                                 | **Direction**                                        | **Description**                                                                                         |
|------------------|---------------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `ROUTES_THROUGH` | `connectionDate: Date`                                                          | `MVCSystem → MVCSubsection`                          | Connects MVCSystem to Substation nodes, indicating start and end points.                                |
| `OPERATES`       | `dateFrom: Date`, `dateTo: Date`                                                | `DSO → MVCSystem`                                    | Links DSO to MVCSystem, reflecting ownership or operational control.                                    |
| `OPERATES`       | `dateFrom: Date`, `dateTo: Date`                                                | `DSO → Substation`                                   | Assumes DSOs have direct operational control over substations.                                          |
| `JOINS`          | `position: String`, `joinedOn: Date`                                            | `CableJoint → MVCSubsection (x2)`                    | Connects a CableJoint to two MVCSubsection nodes; `position` distinguishes first and second subsection. |
| `FEEDS`          | `startDate: Date`                                                               | `Substation (main) → MVCSystem`                      | Assumes a substation can also feed into multiple MVC systems.                                           |
| `AFFECTS`        | `dateAffected: Date`                                                            | `CableEvent → MVCSubsection`                         | Connects CableEvent to a subsection, indicating the impact location.                                    |
| `CONNECTS_TO`    | `connectionDate: Date`                                                          | `Substation (secondary) → MVCSystem`                 | Connects a secondary substation to a MVC system.                                                        |
| `REPAIRS`        | `repairDate: Date`                                                              | `CableEvent (repair) → CableEvent (failure)`         | Links repair events to the original failure event.                                                      |
| `IMPACTS`        | `spatialOverlapPercentage: Float`                                               | `ExternalEvent → MVCSubsection`                      | Indicates how much an external event overlaps spatially with a subsection.                              |
| `CONTRIBUTES_TO` | `spatialOverlapPercentage: Float`                                               | `LocationDriver → CableEvent (failure)`              | Quantifies how much a location driver contributed to a failure.                                         |
| `INFLUENCES`     | *(none)*                                                                        | `LocationDriver → MVCSubsection`                     | Models static environmental impacts on cables, independent of failures.                                 |
| `CAUSED_BY`      | `spatialOverlapPercentage: Float`, `timeOverlap: Boolean`                       | `CableEvent (failure) → ExternalEvent (e.g., DiggingActivity)` | Indicates causes of cable failures, with spatial and temporal context.                   |
| `PARENT_OF`      | *(none)*                                                                        | `Substation (main) → Substation (secondary)`         | Enables grouping of secondary substations under a main substation.                                      |


# CIM-Based Model Alignement
The table below details the transition of the original graph database nodes to CIM-aligned nodes, including updated properties and descriptions of changes. 

| **Original Node** | **CIM-Based Node Proposal** | **Properties** | **Description of Change** |
|-------------------|-----------------------------|---------------|---------------------------|
| `DSO` | `Organisation` | `mRID: String`, `name: String`, `serviceRegion: Location`, `activityRecords: ActivityRecord[]`, `organisationRole: String` | Redefined as `Organisation` per IEC 61968::Common. `supplyArea` is replaced with `serviceRegion` (Location with Polygon geometry). `dateRegistered` moves to `activityRecords`, and `reliabilityIndices` are derived from linked `OutageRecord` or `FailureEvent`, aligning with IEC 61968-4. |
| `Substation` | `Substation` | `mRID: String`, `name: String`, `voltageLevels: VoltageLevel[]`, `installationDate: Date`, `location: PositionPoints` | Retains name, mapping to CIM’s `Substation` (IEC 61970::Wires). `highVoltageLimit` and `lowVoltageLimit` are replaced with `voltageLevels` (`nominalVoltage`), per IEC 61968-11. `coordinates` become `location` (PositionPoints). Subtype labels are replaced with CIM relationships. |
| `MVCSystem` | `AssetContainer` | `mRID: String`, `name: String`, `containedAssets: ACLineSegment[]`, `operationalMeasurements: MeasurementValue[]` | Redefined as `AssetContainer` to group `ACLineSegments` and equipment, per IEC 61968-11. `averageLoading` and `maxLoading` move to `operationalMeasurements`, reflecting CIM’s dynamic data approach. |
| `MVCSubsection` | `ACLineSegment` | `mRID: String`, `length: Float`, `assetInfo: CableInfo`, `installationDate: Date`, `location: PositionPoints`, `status: String`, `isRepairSection: Boolean` | Maps to `ACLineSegment` (IEC 61970::Wires). Properties like `conductorMaterial` move to `CableInfo` (IEC 61968-4). `id` becomes `mRID`, `coordinates` become `location`. `isRepairSection` and `outOfService` consolidate into `status`. |
| `CableJoint` | `Junction + Asset` | `mRID: String`, `assetInfo: JointInfo`, `location: PositionPoints`, `terminals: Terminal[]`, `installationDate: Date` | Split into `Junction` (electrical) and `Asset` (physical), per IEC 61968-4 and IEC 61970::Wires. `jointType` and `manufacturer` move to `JointInfo`. `coordinatesInstalled` become `location`. `terminals` link to `ACLineSegments`. |
| `CableEvent` | `FailureEvent / WorkOrder` | `mRID: String`, `eventType: String`, `startTime: Date`, `endTime: Date`, `affectedAsset: ACLineSegment/Junction`, `cause: String`, `failureMode: String`, `workDetails: String`, `location: PositionPoints` | Split into `FailureEvent` (failures) and `WorkOrder` (repairs) per IEC 61968-6. `eventStart`/`end` map to timestamps, `causeOfEvent` to `faultCause`/`comment`, `repairSpecs` to `workDetails`. `locationOfEvent` is optional. |
| `ExternalEvent` | `ActivityRecord` | `mRID: String`, `eventType: String`, `startTime: Date`, `endTime: Date`, `location: PositionPoints`, `attributes: Object`, `associatedAssets: ACLineSegment[]` | Redefined as `ActivityRecord` (IEC 61968::Common). `utilityType`, `intensity`, etc., move to `attributes`. `reportedTo` links to a `Document`. Connects to affected assets for fault analysis. |
| `LocationDriver` | `Location / Measurement` | `mRID: String`, `locationType: String`, `locationAttributes: Object`, `measurementValues: Object[]`, `timeRangeStart: Date`, `timeRangeEnd: Date`, `position: PositionPoints`, `associatedAssets: ACLineSegment[]` | Split into `Location` (static, e.g., SoilType) and `Measurement` (dynamic, e.g., weather) per IEC 61968-4. `locationAttributes` and `measurementValues` separate static and dynamic data. `gridCoordinates` become `position`. |

## Edge Transition to CIM/IEC 61968 Standards

The table below describes the transformation of each edge in the original graph database model to align with CIM/IEC 61968 standards. It includes the updated properties, direction, and a description of changes to maintain compatibility with IEC 61968 Parts 4 (Asset Records), 6 (Maintenance & Construction), and 11 (CIM Extensions for Distribution).

| **Edge** | **Properties** | **Direction** | **Description** |
|----------|----------------|---------------|-----------------|
| `OPERATES` | `mRID: String`, `dateFrom: Date`, `dateTo: Date`, `roleType: String` | `Organisation → AssetContainer/Substation` | Retained as `OPERATES`, linking `Organisation` (DSO) to `AssetContainer` (MVCSystem) or `Substation`. Properties include `mRID` for unique identification and `roleType` to specify the role (e.g., Operator), aligning with IEC 61968-4’s OrganisationRole for asset management. |
| `FEEDS` | `mRID: String`, `connectionDate: Date`, `terminalIds: String[]` | `Substation → AssetContainer` | Redefined to use CIM’s `Terminal` and `ConnectivityNode` model (IEC 61968-11). Links a `Substation` (via its `PowerTransformer` and `Terminal`) to an `AssetContainer` (MVCSystem). `terminalIds` reference CIM `Terminal` objects for precise electrical connectivity. |
| `CONNECTS_TO` | `mRID: String`, `connectionDate: Date`, `terminalIds: String[]` | `Substation → AssetContainer` | Maps to CIM’s connectivity model (IEC 61968-11), linking `Substation` to `AssetContainer` via `Terminals` and `ConnectivityNodes`. `terminalIds` ensure accurate representation of electrical paths, replacing the original simplified connection. |
| `PARENT_OF` | `mRID: String`, `relationshipDate: Date` | `Substation → Substation` | Replaced with CIM’s hierarchical `VoltageLevel` or `Feeder` relationships (IEC 61968-11). Links a Main `Substation` to a Secondary `Substation` via electrical topology or asset hierarchy, with `relationshipDate` tracking establishment. |
| `ROUTES_THROUGH` | `mRID: String`, `connectionDate: Date`, `terminalIds: String[]` | `Substation → ACLineSegment` | Redefined to align with CIM’s `Terminal` and `ConnectivityNode` model (IEC 61968-11). Connects `Substation` to `ACLineSegment` (MVCSubsection) via `terminalIds`, ensuring precise electrical routing and topology representation. |
| `CONTAINS` | `mRID: String`, `groupingDate: Date` | `AssetContainer → ACLineSegment` | Retained as `CONTAINS`, linking `AssetContainer` (MVCSystem) to `ACLineSegment` (MVCSubsection), per IEC 61968-11. `groupingDate` tracks when the grouping was established, aligning with CIM’s container-based asset organization. |
| `JOINS` | `mRID: String`, `connectionDate: Date`, `terminalIds: String[]` | `Junction → ACLineSegment (x2)` | Maps to CIM’s `Junction` with multiple `Terminals` (IEC 61970::Wires). Connects a `Junction` (CableJoint) to two `ACLineSegments` (MVCSubsections) via `terminalIds`, ensuring accurate electrical connectivity per IEC 61968-11. |
| `AFFECTS` | `mRID: String`, `eventDate: Date`, `affectedAssetId: String` | `FailureEvent/WorkOrder → ACLineSegment/Junction` | Retained as `AFFECTS`, linking `FailureEvent` or `WorkOrder` (CableEvent) to `ACLineSegment` or `Junction`, per IEC 61968-6. `affectedAssetId` specifies the impacted asset, aligning with CIM’s event-asset association for fault and maintenance tracking. |
| `REPAIRS` | `mRID: String`, `repairDate: Date`, `workOrderId: String` | `WorkOrder → FailureEvent` | Maps to CIM’s `WorkOrder` linking to a `FailureEvent` (IEC 61968-6). `workOrderId` references the corrective `WorkOrder` addressing a `FailureEvent` (cable failure), enhancing maintenance process tracking. |
| `IMPACTS` | `mRID: String`, `impactDate: Date`, `affectedAssetId: String` | `ActivityRecord → ACLineSegment/Junction` | Retained as `IMPACTS`, linking `ActivityRecord` (ExternalEvent) to `ACLineSegment` or `Junction`, per IEC 61968::Common. `affectedAssetId` identifies impacted assets, supporting fault analysis due to external events (e.g., digging, weather). |
| `CONTRIBUTES_TO` | `mRID: String`, `contributionDate: Date`, `factorType: String` | `Location/Measurement → FailureEvent` | Maps to CIM’s causal linking (IEC 61968-4/6). Connects `Location` or `Measurement` (LocationDriver) to `FailureEvent`, with `factorType` specifying the contribution (e.g., SoilType, WeatherConditions), aligning with CIM’s fault cause analysis. |
| `INFLUENCES` | `mRID: String`, `influenceDate: Date`, `attributeType: String` | `Location/Measurement → ACLineSegment/Junction` | Redefined to link `Location` or `Measurement` (LocationDriver) to `ACLineSegment` or `Junction`, per IEC 61968-4. `attributeType` specifies static (e.g., SoilType) or dynamic (e.g., temperature) influences, supporting environmental impact analysis. |
| `CAUSED_BY` | `mRID: String`, `eventDate: Date`, `causeType: String` | `FailureEvent → ActivityRecord` | Maps to CIM’s `FailureEvent` linking to an `ActivityRecord` (ExternalEvent), per IEC 61968::Common. `causeType` specifies the external cause (e.g., DiggingActivity), aligning with CIM’s fault cause attribution model. |

Note: The model can be enhanced to present edge properties with additional CIM attributes (e.g., `PowerFlow` data for `FEEDS` or `ROUTES_THROUGH`). ALso, enhencing validation for `Terminal` and `ConnectivityNode` relationships to ensure electrical topology accuracy. In practice, it is also necessary to Integrate real-time event data (e.g., via `MeasurementValues`) to dynamically update `IMPACTS` and `CONTRIBUTES_TO` edges.
