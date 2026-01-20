# E-Commerce Customer & Marketing Intelligence with Databricks

## Table of Contents
- [Project Purpose & Business Context](#1-project-purpose--business-context)
  - [The Problem](#the-problem)
  - [The Solution](#the-solution)
  - [Key Metrics / Value](#key-metrics--value)
- [System Architecture & Data Flow](#2-system-architecture--data-flow)
  - [High-Level Flow](#high-level-flow)
  - [Dataflow Diagram](#dataflow-diagram)
- [Pipeline Resources & Notebooks](#pipeline-resources--notebooks)
  - [Quick Start](#quick-start)
  - [Databricks Ingestion & Transformation Pipelines](#databricks-ingestion--transformation-pipelines)
  - [Databricks Queries](#databricks-queries)
  - [dbt Models](#dbt-models)
  - [dbt Tests](#dbt-tests)
  - [ML Models](#ml-models)
  - [Stack & Justification](#stack--justification)
  - [Benefits of Design Choices](#benefits-of-design-choices)
- [Data Flow & Medallion Design](#3-data-flow--medallion-design)
  - [Data Sources](#data-sources)
  - [Medallion Layers](#medallion-layers)
  - [Notes for Future Engineers](#notes-for-future-engineers)
- [Pipeline Components](#4-pipeline-components)
  - [Ingestion](#ingestion)
  - [Transformation](#transformation)
  - [Analytics Modeling](#analytics-modeling)
  - [Data Quality & Testing](#data-quality--testing)
- [Analytics Use Cases Enabled](#5-analytics-use-cases-enabled)
- [Stakeholders & Value Alignment](#6-stakeholders--value-alignment)
  - [Primary Decision-Makers](#primary-decision-makers)
  - [Secondary Beneficiaries](#secondary-beneficiaries)
  - [Notes on Value Alignment](#notes-on-value-alignment)
- [Known Tradeoffs & Future Improvements](#7-known-tradeoffs--future-improvements)
  - [Tradeoffs](#tradeoffs)
  - [Future Improvements](#future-improvements)
- [Appendix: Acceptance Criteria](#appendix-acceptance-criteria)

---

## 1) Project Purpose & Business Context

### The Problem
This project is based on a hypothetical e-commerce company and uses a synthetic dataset to illustrate an end-to-end data engineering scenario. The dataset contains customer, transaction, and campaign data stored in multiple CSV files. Analysts and stakeholders cannot easily measure customer conversion, campaign attribution, CLV, or revenue trends. Manual aggregation is time-consuming, dashboards are inconsistent, and errors are possible.  

- Impact: Decisions across marketing, product, and finance are slower or misaligned. Manual work reduces scalability and increases the risk of inconsistent metrics.  

### The Solution
An end-to-end analytics pipeline that ingests CSVs from cloud storage, standardizes and validates data, and outputs analytics-ready tables for:  

- Customer 360 / segmentation  
- Campaign performance / attribution  
- Funnel and conversion analysis  
- CLV modeling and revenue tracking  
- Next-best-action triggers  

### Key Metrics / Value
- Time-to-insight: Eliminates manual SQL and spreadsheet work  
- Data trust: Provides validated, consistent metrics for decision-making  
- Scalability: Supports growth in transactions and campaigns without major rework  
- Decision support: Enables cross-functional decisions for marketing, finance, and product teams  

---

## 2) System Architecture & Data Flow

### High-Level Flow
1. Ingest: CSV files from cloud storage mounted in Volumes  
2. Bronze Layer: Raw ingestion via PySpark, stored using Unity Catalog for centralized governance  
3. Silver Layer: Cleaned, standardized, and enriched tables (PySpark transformations for scalability)  
4. Gold Layer / dbt Models: Business logic, KPIs, and analytics-ready tables  

### Dataflow Diagram
![E-Commerce Dataflow](images/e-commerce%20data%20flow.png)
*Figure 1: End-to-end dataflow from ingestion to Gold tables.*

---

## Pipeline Resources & Notebooks

### Quick Start
1. Open Databricks workspace  
2. Import notebooks from `pipeline/` folder  
3. Run dbt models in order: staging → intermediate → marts  
4. Explore ML models in `ML/`  
5. Use queries in `queries-e-commerce/` for KPI and CLV analysis  

### Databricks Ingestion & Transformation Pipelines
- [DLT Expectations](pipeline/DLT%20expectations)  
- [Dimension Transformations](pipeline/dim_transformations)  
- [Fact Transformations](pipeline/fact_transformations)  
- [Ingestion Pipelines](pipeline/ingestion)  

### Databricks Queries
- [KPI Calculations](queries-e-commerce/KPIs_calculations)  
- [CLV Proxy](queries-e-commerce/CLV_proxy)  
- [CAC vs LTV Ratio by Cohort](queries-e-commerce/CAC_vs_LTV_by_cohort)  
- [Run Log Table](queries-e-commerce/run_log_table)  

### dbt Models
- [All dbt models](models)  
- Key subfolders:  
  - [Staging](models/staging) (10 models)  
  - [Intermediate](models/intermediate) (5 models)  
  - [Marts](models/marts) (7 models)  

### dbt Tests
- [All dbt tests](tests)  

### ML Models
- [Propensity Model](ML/features_propensity_3_model.ipynb)  
- [Propensity Score Distribution](ML/propensity%20score%20dist.dbquery.ipynb)  

### Stack & Justification
- Storage / Compute: Databricks — decoupled storage/compute for cost-efficient scaling; provides notebooks, cluster management, and integrated dashboarding for analysis  
- Transformation: dbt — version-controlled, tested, and documented business logic  
- Orchestration / ETL: Databricks DLT + PySpark — handles large CSV ingestion, incremental updates, transformations, and validation  
- Data Governance: Unity Catalog — ensures centralized metadata, lineage, access control, and auditability  

### Benefits of Design Choices
- PySpark ingestion: Efficiently processes large CSVs; scalable for transformations at Bronze and Silver layers  
- Unity Catalog: Secure, discoverable, and auditable datasets for all stakeholders  
- Medallion architecture: Clear separation of raw → cleaned → business-ready tables, simplifying maintenance and future extensions  
- dbt & DLT: Simplifies testing, documentation, incremental updates, and ensures reliability of Gold outputs  

---

## 3) Data Flow & Medallion Design

### Data Sources
- `invoice_customer_bridge.csv` — links invoices to customers  
- `invoice_items.csv` — line items including quantity, unit price, and totals  
- `products_dim.csv` — product catalog with metadata  
- `customers_demographics.csv` — synthetic PII keyed by customer_id  
- `customers_base_metrics.csv` — base RFM-style metrics  
- `marketing_campaigns.csv` & `marketing_spend.csv` — campaign metadata and spend  
- `journey_events.csv` — customer interaction events  
- `event_triggers.csv` — next-best-action triggers  

### Medallion Layers
- Bronze: Raw ingestion with audit logs, schema enforcement via DLT, non-null and valid key checks  
- Silver: Cleaned and standardized tables; PySpark transformations for sessions, joins, and enrichments  
- Gold / dbt Models: Business logic, KPIs, aggregated metrics, funnel tables, marketing attribution, CLV  

### Notes for Future Engineers
- Upstream changes: adding new CSV columns, data types, or new campaign/event sources  
- Downstream dependencies: dashboards or ML models consuming Gold tables  
- Incremental updates handled by DLT; additional transformations added at Silver or Gold only  
- Unit tests and dbt documentation capture expected behavior  

---

## 4) Pipeline Components

### Ingestion
- CSVs uploaded to cloud storage (DBFS / S3)  
- PySpark ingestion into Bronze tables  
- DLT checkpoints for replayable ingestion  

### Transformation
- Silver tables: cleaned, standardized, enriched  
- Fact tables for customer and campaign metrics  

### Analytics Modeling
- dbt transforms Silver → Gold tables  
- KPIs: CLV, RFM, campaign attribution, funnel conversion rates  

### Data Quality & Testing
- DLT expectations: non-null primary keys, valid ranges  
- dbt tests: uniqueness, referential integrity, consistency  
- Run logs validate record counts at each stage  

---

## 5) Analytics Use Cases Enabled
- Customer Segmentation: Identify high-value customers and churn risk  
- Campaign Attribution: Measure multi-channel marketing effectiveness  
- Funnel Analysis: Track conversion from awareness → purchase  
- CLV / Revenue Forecasting: Support lifetime value and revenue projections  
- Next-Best-Action Triggers: Enable personalized engagement for retention and upsell  

---

## 6) Stakeholders & Value Alignment

### Primary Decision-Makers
- Marketing Managers: campaign optimization, ROI, and engagement metrics  
- Product Managers: insights into customer behavior and feature adoption  
- Finance: revenue and CLV forecasting  

### Secondary Beneficiaries
- Operations: inventory and fulfillment insights  
- Data Analysts: easier access to cleaned, validated data  

### Notes on Value Alignment
- Focus efforts on outputs that directly influence decisions  
- Surface potential value conflicts early: e.g., finance may prioritize revenue over marketing KPIs  
- Document assumptions and limitations for future handoff  

---

## 7) Known Tradeoffs & Future Improvements

### Tradeoffs
- Incremental batch updates (DLT) may not be fully real-time  
- Synthetic dataset used; some patterns may differ from production data  
- CLV and attribution models are proxies, not production-grade ML  

### Future Improvements
- Integrate additional channels or event sources  
- Support real-time streaming for web events  
- Enhance predictive models for CLV and churn  
- Monitor data quality with automated anomaly detection  

---

## Appendix: Acceptance Criteria
- CSV ingestion works without manual intervention  
- Silver tables validated with DLT expectations and run logs  
- Gold tables provide KPIs, dashboards, and attribution metrics  
- Documentation and dbt tests are complete  
- Future engineers can pick up and extend the pipeline without investigation

