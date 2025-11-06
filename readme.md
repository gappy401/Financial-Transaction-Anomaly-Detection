#  Financial Transaction Anomaly Detection Engine: Snowflake MLOps Pipeline

## Project Overview

This repository documents the design, deployment, and operationalization of a real-time Machine Learning (ML) system for financial transaction monitoring. The entire MLOps workflow is executed *within* the secure **Snowflake Data Cloud** using **Snowpark Python**, showcasing a robust, compliant, and scalable solution.

The primary goal was to replace static monitoring with an agile, performance-driven detection system.

---

## Key Results & Business Impact

| Metric | Outcome | Impact |
| :--- | :--- | :--- |
| **Alert Quality** | **20% False Positive Rate Reduction** | Achieved by tuning the Isolation Forest threshold from **0.05** to **0.06**, significantly boosting analyst efficiency. |
| **Deployment** | **Real-Time Detection** | Instantaneous scoring on new data via a persistent Snowflake UDF. |
| **Scalability** | **Serverless MLOps** | Eliminated dependency on external scoring infrastructure; solution scales elastically with Snowflake compute. |
| **Governance** | **Zero-Copy Security** | Scoring logic runs directly in the data warehouse, ensuring full auditability and security compliance. |

---

## Technical Architecture & Snowpark Flow

The pipeline leverages Snowpark Python for high-scale feature engineering and model deployment, using Snowflake's native orchestration tools.

### Stack

* **Data Cloud:** Snowflake
* **ML & Logic:** **Snowpark Python**, Python (scikit-learn Isolation Forest), SQL
* **Orchestration:** **Snowflake Tasks** (Incremental hourly scheduling)
* **Ingestion:** AWS S3 → Snowpipe
* **Reporting:** Tableau (fed by Snowflake View)

### End-to-End Workflow

1.  **Ingestion:** New transaction data arrives from **Snowpipe** into the `RAW_TRANSACTIONS` table.
2.  **Feature Engineering:** Complex aggregates and velocity features are created at scale using **Snowpark DataFrames**.
3.  **Deployment:** The trained model is deployed as a permanent **Snowflake Python UDF (`SCORE_TRANSACTION`)**.
4.  **Automation:** A scheduled **Snowflake Task** executes hourly, calling the UDF to score new data using the **optimized <-0.06 threshold** segmenting these users into High risk, Moderate risk, and low risk.
5.  **Visualization:** The final view aggregates these anomaly scores with business context and feeds the **Tableau dashboard** for stakeholders view and further decision making. [Dashboard Here!](https://public.tableau.com/app/profile/nandita.ghildyal4373/viz/Fraud-Detection_17621216990630/Dashboard1)

---

## Repository Contents

| Folder Name | Description | Key Content |
| :--- | :--- | :--- |
| `Setup` | Initial SQL environment setup. | `CREATE DATABASE/SCHEMA`, `CREATE STAGE`, `CREATE PIPE (Snowpipe)`. |
| `EDA` | Snowpark script for feature creation and model training. | Snowpark code for feature aggregates; Isolation Forest training; saving model to stage. |
| `Automation Scripts` | SQL to deploy the UDF and automation. | `CREATE FUNCTION SCORE_TRANSACTION` and the scheduled **`CREATE TASK`** logic. |
| `View` | Final SQL scripts for stakeholder output. | Creates the Tableau-ready **`V_FRAUD_REPORTING_VIEW`** with the explicit `RISK_LEVEL` tiering. |
| `model/if_model.joblib` | Trained Isolation Forest model file. | The binary model asset consumed by the UDF. |
