# Proposed Nodes and Edges

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


