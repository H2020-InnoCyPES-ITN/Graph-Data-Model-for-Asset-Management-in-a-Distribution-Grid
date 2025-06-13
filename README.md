# Graph-Data-Model-to-Facilitate-Reliability-Studies-of-Medium-Voltage-Cable-Systems-in-a-Distribution-Grid
This repository presents a graph data model to facilitate reliability studies of medium-voltage cables in a distribution grid. We present the models in two fold; first a graph model which is the results of a relational data model that was designed to facilitate decentralised data storage for MV cables [1]. This graph model is described in detail in [Data Model Folder](/01_Original_Graph_Model). Second, its refinement to align with CIM/IEC standard is presentend in folder [CIM/IEC Refined Data Model Folder](/02_Alignment_to_CIM_and_IEC_Standards). We use Neo4j database for designing the model, populating it, and run test queries. In this regard, the current model is designed to respond to the following query requirements.

## Important use cases
1.	Which DSO operates an MV Cable System?
2.	Which DSO operates a Substation?
3.	How many failures occurred in a given year?
4.	Which DSO had the most failures?
5.	What are the leading factors for most failures?
6.	Are there specific durations for most of these failures?
7.	Give maintenance record for a certain component
8.	What activities caused cable failure
9.	Were certain activities reported to the responsible authorities?
10.	What drivers facilitated the most in cable failures?
11.	How many repairs were done to the cable system?
12.	What is the coverage area of a DSO
13.	What are the operating voltages for a substation, subsection, or at a certain joint?
14.	What cable types are mostly affected by digging activities?
15.	Are there specific cable materials that lead to most of the failures?
16.	What is the capacity of a cable system?
17.	Are there specific qualities of cable materials from certain manufacturers that was highly impacted?
18.	Are there failures that were caused by other activities like digging, lightning, weather events, etc?
19.	What weather conditions are associated with most failures?
20.	Do cables with many joints, fail more that those with few joints?
21.	What distance of the cable system was affected?

The extent to which the model respond to various queries is not limited to the presented use cases. Many more queries, including aggregation of data can also be done.

To use:
1. Install Neo4j with spatial data support.
2. Run the Cypher script to create nodes, relationships, and indexes.
3. Execute testing queries to validate use cases.

## References
1. K. Sundsgaard, L. J. Mwinuka, M. Cafaro, J. Z. Hansen and G. Yang, "A Decentralised Relational Data Model for Reliability Studies of Medium-Voltage Cables," 2024 IEEE PES Innovative Smart Grid Technologies Europe (ISGT EUROPE), Dubrovnik, Croatia, 2024, pp. 1-5, doi: 10.1109/ISGTEUROPE62998.2024.10863105.




