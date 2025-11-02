AI Jobs Data Warehouse (SQL Project)

## 📋 Project Overview

This project aims to design and implement a **Data Warehouse** for an **AI job dataset**, using **MySQL**.
The goal is to **organize raw job data** into a clean, normalized database structure — enabling **efficient analysis and reporting** about salaries, job roles, skills, industries, and employment trends in the AI field.
---
## 🗂️ Dataset

The project is based on a dataset named `ai_job_dataset1`, which contains information about:

* Company details (name, location, size)
* Employee information (residence, employment type, experience level)
* Job titles and required skills
* Salary, industry, remote ratio, and more
---
## 🏗️ Project Steps

### **1️⃣ Database Creation**

* Created a new database called `Project_SQL`.
* Imported the main dataset table `ai_job_dataset1`.

### **2️⃣ Data Normalization**

Split the dataset into multiple relational tables to remove redundancy:

* **`company`** → company details
* **`employee`** → employee and experience info
* **`job`** → job titles
* **`skills`** → technical skills required per job
* **`fact_job`** → fact table linking all dimensions (used for analysis)

Each table includes:

* A **primary key** (auto-incremented)
* **Foreign keys** for referential integrity

### **3️⃣ Data Cleaning**

Performed transformations for consistency:

* Renamed and reformatted columns (e.g., `salary_usd` → `salary`)
* Replaced coded values with meaningful labels:

  * `remote_ratio`: 0 → On-Site, 50 → Hybrid, 100 → Remote
  * `company_size`: S → Small, M → Medium, L → Large
  * `experience_level` and `employment_type` standardized to readable forms

### **4️⃣ Data Analysis**

Ran several SQL queries to extract insights such as:

1. **Top requested AI technical skills**
2. **Average salary per country and employment type**
3. **Salary range per job and experience level**
4. **Salary range by industry**
5. **Distribution of full-time, part-time, contract, and freelance roles**
6. **Remote vs hybrid vs on-site job percentages**
7. **Top 5 industries hiring for each AI role**
---
## 📊 Key Insights

* Identified **most in-demand AI skills** across roles.
* Discovered **salary trends** by job title, experience level, and location.
* Highlighted **industry hiring patterns** and the **prevalence of remote work** in AI jobs.
---
## ⚙️ Tools & Technologies

MySQL – database creation, normalization, data cleaning, and analysis

SQL – used for schema design, joins, transformations, and analytical queries
* **MySQL** – database creation, normalization, data cleaning, and analysis
* **SQL** – used for schema design, joins, transformations, and analytical queries
