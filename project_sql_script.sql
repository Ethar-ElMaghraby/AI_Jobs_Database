CREATE DATABASE Project_SQL;
USE Project_SQL;

select * from ai_job_dataset1;
-- 1) split main table to multiple tables
-- first table
CREATE TABLE company (
    company_name VARCHAR(35),
    company_location VARCHAR(20),
    company_size VARCHAR(20)
);
-- ADD data from main table to company without duplicates
INSERT INTO company (company_name, company_location, company_size)
SELECT DISTINCT company_name, company_location, company_size
FROM ai_job_dataset1;
-- add primary key
ALTER TABLE company
ADD company_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE company AUTO_INCREMENT = 100;
-- show all data
SELECT * FROM company;
-- -------------------------------------------------------------------------
-- second table
CREATE TABLE Employee (
    employee_residence VARCHAR(35),
    employment_type VARCHAR(20),
    experience_level VARCHAR(20)
);

INSERT INTO Employee (employee_residence, employment_type, experience_level)
SELECT DISTINCT employee_residence, employment_type, experience_level
FROM ai_job_dataset1;

ALTER TABLE Employee
ADD Employee_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE Employee AUTO_INCREMENT = 500;

SELECT * FROM Employee;
-- -------------------------------------------------------------------------
-- Third table
CREATE TABLE JOB (
job_title VARCHAR(50)
);

INSERT INTO JOB (job_title)
SELECT DISTINCT job_title
FROM ai_job_dataset1;

ALTER TABLE JOB
ADD job_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE JOB AUTO_INCREMENT = 100;

SELECT * FROM JOB;

-- -------------------------------------------------------------------------
-- four table (fact table )
CREATE TABLE fact_job (
    company_id INT,
    employee_id INT,
    job_id INT,
    salary_usd INT,
    remote_ratio VARCHAR(20),
    education_required VARCHAR(25),
    years_experience INT,
    industry VARCHAR(30),
    FOREIGN KEY (company_id) REFERENCES company(company_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (job_id) REFERENCES Job(job_id)
);

INSERT INTO fact_job (company_id, employee_id, job_id, salary_usd, remote_ratio, education_required, years_experience, industry)
SELECT 
    c.company_id,
    e.employee_id,
    j.job_id,
    a.salary_usd,
    a.remote_ratio,
    a.education_required,
    a.years_experience,
    a.industry
FROM ai_job_dataset1 a
JOIN company c 
    ON a.company_name = c.company_name 
   AND a.company_location = c.company_location 
   AND a.company_size = c.company_size
JOIN Employee e 
    ON a.employee_residence = e.employee_residence 
   AND a.employment_type = e.employment_type 
   AND a.experience_level = e.experience_level
JOIN Job j 
    ON a.job_title = j.job_title;
-- ------------------------------------------------------------------------------------------------------
-- LAST TABLE THEN cleaning
CREATE TABLE skills (
    job_id INT,
    required_skills VARCHAR(100),
    FOREIGN KEY (job_id) REFERENCES job(job_id)
);

INSERT INTO skills (job_id, required_skills)
SELECT 
	j.job_id,
	a.required_skills
FROM ai_job_dataset1 a
JOIN JOB j
ON a.job_title = j.job_title;

select * from skills;
-- ------------------------------------------------------------------------------------------------------
-- 2) Cleaning

-- RENAME SALARY
ALTER TABLE fact_job
RENAME COLUMN salary_usd TO salary;

-- CAHNGE TYPE remote_ratio TO STRING AND RENAME 
ALTER TABLE fact_job
MODIFY remote_ratio VARCHAR(20);
-- CHANGE NAMES IN every table 
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_job
SET remote_ratio = 
    CASE 
        WHEN remote_ratio = '0' THEN 'On-Site'
        WHEN remote_ratio = '50' THEN 'Hybrid'
        WHEN remote_ratio = '100' THEN 'Remote'
    END;

UPDATE company
SET company_size = 
    CASE 
        WHEN company_size = 'L' THEN 'Large'
        WHEN company_size = 'M' THEN 'Medium'
        WHEN company_size = 'S' THEN 'Small'
    END;


UPDATE Employee
SET experience_level = 
    CASE experience_level
        WHEN 'EN' THEN 'Entry-level'
        WHEN 'MI' THEN 'Mid-level'
        WHEN 'SE' THEN 'Senior'
        WHEN 'EX' THEN 'Executive'
    END;

UPDATE Employee
SET employment_type = 
    CASE employment_type
        WHEN 'FT' THEN 'Full-time'
        WHEN 'PT' THEN 'Part-time'
        WHEN 'CT' THEN 'Contract'
        WHEN 'FL' THEN 'Freelance'
    END;
-- -------------------------------------------------------------------------------------------------
-- 3) Analysis
-- 1-Top requested technical AI skills across all roles
WITH skill_list AS(
SELECT
	job_id,
	TRIM(substring_index(required_skills, ",", 1)) AS skill_1,
    TRIM(substring_index(substring_index(required_skills, ",", 2), ",", -1)) AS skill_2,
    TRIM(substring_index(substring_index(required_skills, ",", 3), ",", -1)) AS skill_3,
    TRIM(IF(CHAR_LENGTH(required_skills) - CHAR_LENGTH(REPLACE(required_skills, ',', '')) >= 3, 
       SUBSTRING_INDEX(SUBSTRING_INDEX(required_skills, ',', 4), ',', -1), NULL)) AS skill_4,
    TRIM(IF(CHAR_LENGTH(required_skills) - CHAR_LENGTH(REPLACE(required_skills, ',', '')) >= 4,
    substring_index(substring_index(required_skills, ",", 5), ",", -1),NULL)) AS skill_5
FROM
	skills
),
all_skills AS (
  SELECT job_id, skill_1 AS skill FROM skill_list WHERE skill_1 IS NOT NULL
  UNION ALL
  SELECT job_id, skill_2 FROM skill_list WHERE skill_2 IS NOT NULL
  UNION ALL
  SELECT job_id, skill_3 FROM skill_list WHERE skill_3 IS NOT NULL
  UNION ALL
  SELECT job_id, skill_4 FROM skill_list WHERE skill_4 IS NOT NULL
  UNION ALL
  SELECT job_id, skill_5 FROM skill_list WHERE skill_5 IS NOT NULL
)
SELECT
  skill,
  COUNT(job_id) AS job_postings_with_skill,
  ROUND(COUNT(job_id) / 30000 * 100, 2) AS percent_of_jobs
FROM all_skills
GROUP BY skill
ORDER BY percent_of_jobs DESC;
-- 2- Average salary (USD) per role per country
SELECT 
    c.company_location,
    e.employment_type,
    AVG(f.salary) AS Average_Salary
FROM fact_job f
JOIN company c 
    ON f.company_id = c.company_id
JOIN employee e
	ON f.employee_id = e.employee_id 
GROUP BY 1, 2;
-- 3- average salary  by experience level (entry, mid, senior) per job  and range of experience level
SELECT 
    j.job_title,
    e.experience_level, 
    MIN(f.salary) AS Min_Salary, 
    ROUND(AVG(f.salary)) AS Average_Salary, 
    MAX(f.salary) AS Max_Salary
FROM fact_job f
JOIN employee e 
    ON f.employee_id = e.employee_id
JOIN job j 
    ON f.job_id = j.job_id
GROUP BY j.job_title, e.experience_level
ORDER BY 1, 4;
-- 4- Salary range (min–max) by industry
SELECT industry, MIN(salary) AS MinSalary, MAX(salary) AS MaxSalary
FROM fact_job
GROUP BY 1
ORDER BY 1;
-- 5- % of AI roles that are full-time vs part-time vs freelance
SELECT 
    j.job_title AS job,
    ROUND((SUM(CASE WHEN e.employment_type = 'Full-Time' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS full_time,
    ROUND((SUM(CASE WHEN e.employment_type = 'Part-Time' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS part_time,
    ROUND((SUM(CASE WHEN e.employment_type = 'Freelance' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS freelance,
    ROUND((SUM(CASE WHEN e.employment_type = 'Contract' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS contract
FROM fact_job f
JOIN  
   job j ON f.job_id = j.job_id
JOIN  
  employee e ON f.employee_id = e.employee_id
GROUP BY j.job_title
ORDER BY j.job_title;
-- 6- % of remote/hybrid AI roles vs on-site roles
SELECT 
    j.job_title AS job,
    ROUND((SUM(CASE WHEN f.remote_ratio = 'Remote' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS Remote,
    ROUND((SUM(CASE WHEN f.remote_ratio = 'Hybrid' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS Hybrid,
    ROUND((SUM(CASE WHEN f.remote_ratio = 'On-Site' THEN 1 ELSE 0 END) / COUNT(*))*100,2) AS On_Site
FROM fact_job f
JOIN  
   job j ON f.job_id = j.job_id
GROUP BY j.job_title
ORDER BY j.job_title;
-- 7- Top 5 industries by volume of AI hiring per role
WITH RankedIndustries AS (
    SELECT 
        f.job_id,
        f.industry, 
        COUNT(CASE WHEN f.industry IS NOT NULL THEN 1 END) AS industry_count,
        ROW_NUMBER() OVER (
            PARTITION BY f.job_id 
            ORDER BY COUNT(CASE WHEN f.industry IS NOT NULL THEN 1 END) DESC
        ) AS industry_id
    FROM fact_job f
    GROUP BY f.job_id, f.industry
)
SELECT 
    j.job_title, 
    MAX(CASE WHEN r.industry_id = 1 THEN r.industry END) AS Industry_1,
    MAX(CASE WHEN r.industry_id = 2 THEN r.industry END) AS Industry_2,
    MAX(CASE WHEN r.industry_id = 3 THEN r.industry END) AS Industry_3,
    MAX(CASE WHEN r.industry_id = 4 THEN r.industry END) AS Industry_4,
    MAX(CASE WHEN r.industry_id = 5 THEN r.industry END) AS Industry_5
FROM RankedIndustries r
JOIN job j 
    ON r.job_id = j.job_id
GROUP BY j.job_title
ORDER BY j.job_title;
