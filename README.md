# 📊 Customer Support Operations Analysis (SQL)

## 🔍 Overview

This project analyzes customer support ticket data to evaluate **resolution efficiency**, **SLA compliance**, **agent performance**, and **support demand patterns** using **MySQL**.

The objective is to simulate a real-world customer support environment and extract **operational insights using pure SQL**, without relying on dashboards or external BI tools.



## 🗂️ Dataset Description

The dataset is **synthetically generated** to closely resemble real customer support operations and contains thousands of ticket records representing end-to-end ticket lifecycles.


## 🧾 Tables Used

### **tickets**
Stores ticket lifecycle information.

- `ticket_id` – Unique ticket identifier  
- `created_at` – Ticket creation timestamp  
- `closed_at` – Ticket resolution timestamp  
- `priority` – High / Medium / Low  
- `category` – Issue type (Payment, Login, Bug, Other)  



### **agents**
Stores support agent information.

- `agent_id` – Unique agent identifier  
- `agent_name` – Agent name  
- `team` – Support team  


### **ticket_assignments**
Maps tickets to agents.

- `ticket_id`  
- `agent_id`  



## 🛠️ Data Preparation & Cleaning

- Generated synthetic CSV data programmatically using **Python**
- Imported data into **MySQL**
- Normalized timestamp formats
- Converted non-standard date strings to `DATETIME` using `STR_TO_DATE`
- Performed data integrity checks:
  - No null timestamps
  - No negative resolution times
  - No orphaned ticket assignments
- Added indexes on frequently queried columns to improve query performance



## 📈 Key Analyses Performed

### 1️. Core Operational Metrics
- Ticket distribution by priority and category  
- Overall and priority-wise average resolution time  
- Monthly ticket volume trends  



### 2️. SLA Compliance Analysis

**Defined SLA thresholds:**
- High priority → 4 hours  
- Medium priority → 12 hours  
- Low priority → 24 hours  

**Analysis includes:**
- SLA breach identification at ticket level  
- SLA breach percentage by priority  
- Monthly SLA breach trends  



### 3️. Agent Performance Analysis
- Tickets handled per agent  
- Average resolution time by agent  
- SLA breach rates by agent  
- Identification of workload imbalance across agents  



### 4️. Category & Issue Analysis
- Average resolution time by issue category  
- Priority distribution within each category  
- Identification of categories contributing to operational delays  



### 5️. Trend & Seasonality Patterns
- Hourly ticket arrival patterns  
- Weekday vs weekend ticket volume comparison  
- Monthly demand trends  



### 6️. Advanced Bottleneck Analysis
- Combined **agent × team × category** analysis  
- Identification of high-impact operational bottlenecks  


## 🧪 Tools & Technologies

- **SQL**
  - Joins
  - Aggregations
  - CASE statements
  - Date-time functions
- Indexing for query optimization
- **Python** (synthetic data generation)



## ✅ Key Takeaways

- SLA breaches occur most frequently in **low-priority tickets**, despite longer resolution windows  
- Resolution efficiency varies significantly across **agents** and **issue categories**  
- Ticket demand follows consistent **time-based patterns**, useful for staffing and capacity planning  
- SQL alone can uncover **meaningful business insights** without visualization tools  



## ℹ️ Notes

- The dataset is **synthetic** but designed to closely mimic real-world customer support workflows  
- The project focuses on **analysis and insight generation**, not predictive modeling or dashboards  




