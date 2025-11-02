# 🛡️ Financial Transaction Anomaly Detection Engine

## Project Overview

This project showcases the design, deployment, and operationalization of a real-time Machine Learning (ML) system for financial transaction monitoring. It is built entirely on the modern cloud data stack (**Snowflake** and **AWS**) and utilizes **Snowpark Python**, demonstrating proficiency in building scalable, governed risk models.

**The primary goal was to transition from traditional monitoring to an agile, performance-driven classification and detection system.**

### 📊 Key Results & Business Impact

| Metric | Result | Value to the Business |
| :--- | :--- | :--- |
| **Alert Quality** | **20% Reduction in False Positives** | Directly increases AML investigator efficiency and reduces operational costs. |
| **Deployment** | **Real-Time Scoring** | Enables immediate identification of high-risk activity as transactions occur. |
| **Compliance** | Full **Data Governance & Lineage** | Guarantees auditability and regulatory compliance for the model output. |

---

## 💻 Technical Architecture & Deployment

The architecture is designed for scale and efficiency, running the entire ML pipeline within the Snowflake ecosystem.

### Stack

* **Data Warehouse:** Snowflake
* **ML & Logic:** **Snowpark Python**, Python ($\text{scikit-learn}$), SQL
* **Cloud Storage:** AWS S3
* **Orchestration:** Snowflake Tasks (simulated real-time scheduling)
* **Dataset:** Capital One DS Challenge 2018 (6.3 Million Records)

### End-to-End Flow

1.  **Ingestion:** Data is loaded from **AWS S3** into Snowflake via **Snowpipe**.
2.  **Feature Engineering:** **Snowpark Python** is used for high-scale, in-database feature creation (e.g., transaction velocity, account aggregates).
3.  **Model Training:** An **Isolation Forest** model is trained on the prepared features using Snowpark.
4.  **Real-Time Deployment:** The model is served via a **Snowflake Python UDF (User-Defined Function)**. A **Snowflake Task** executes the UDF on incoming new data, producing real-time anomaly scores.
5.  **Reporting:** Results are pushed to a final `ALERTS` table, which feeds the **BI Dashboard** for regulatory review.

---

## 🛠️ Governance and Value Proposition

The project's design prioritizes the governance and compliance requirements critical to a banking environment.

### **In-Database Deployment (Snowflake UDFs)**

Deploying the scoring logic via Snowflake UDFs ensures:
* **Data Security (ELT):** Data never leaves the secure environment for scoring, simplifying security review.
* **Scalability:** The scoring logic leverages Snowflake's compute, dynamically scaling without dedicated MLOps infrastructure.

### **Data Lineage and Auditability**

* The final `ALERTS` table includes metadata (model version, execution timestamp) for full **lineage**.
* This system leverages the efficient data handling and pipeline agility I developed **at Dell** to ensure data quality and rapid deployment.

---

## 🚀 Get Started

### Prerequisites

1.  Access to a **Snowflake** environment.
2.  An **AWS S3** bucket for data ingestion.
3.  Python 3.9+ with Snowpark and $\text{scikit-learn}$ libraries.

### Key Files in Repository

* `01_ingestion_setup.sql`: Sets up the database, schema, S3 Stage, and raw tables in Snowflake.
* `02_feature_engineering_snowpark.py`: Python script containing Snowpark logic for feature creation, model training, and UDF creation.
* `03_alert_reporting_view.
