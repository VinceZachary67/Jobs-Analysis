-- 1. What are the top paying jobs for my role as data analyst?
-- 2. What are the skills required for these top paying role?
-- 3. What are the most in-demand skills for my role?
-- 4. what are the top skills based on salary for my role?
-- 5. What are the most optical skills to learn?
    -- a. Optimal: High demand and High paying

-- 1. What are the top paying jobs for my role?
-- Identifying the top paying jobs for my role
SELECT 
    job_id,
    cd.name as company_name,
    job_title,
    salary_year_avg,
    job_location
FROM
    job_postings_fact
JOIN
    company_dim as cd
ON
    job_postings_fact.company_id = cd.company_id
WHERE
    salary_year_avg is not NULL AND
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere'
GROUP BY
    job_title_short,
    salary_year_avg,
    job_title,
    job_id,
    cd.name
ORDER BY
    4 DESC
LIMIT 10;

-- 2. What are the skills required for these top paying role?
-- Identifying the skills required for each job role
SELECT
    jpf.job_title as job_title,
    jpf.salary_year_avg as avg_yearly_salary,
    sd.skills as skills
FROM
    job_postings_fact as jpf
JOIN
    skills_job_dim as sjd
ON  
    jpf.job_id = sjd.job_id
JOIN
    skills_dim as sd
ON
    sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Analyst' AND
    jpf.salary_year_avg is not NULL AND
    jpf.job_location = 'Anywhere'
GROUP BY
    jpf.job_title,
    jpf.salary_year_avg,
    sd.skills,
    jpf.job_id
ORDER BY
    2 DESC
LIMIT 5;

-- 3. What are the most in-demand skills for my role?
-- Identifying the most required skill for my role
WITH job_count AS (
    SELECT
        jpf.job_title AS job_title,
        jpf.salary_year_avg AS avg_yearly_salary,
        sd.skills AS skills,
        jpf.job_id,
        cd.name
    FROM
        job_postings_fact AS jpf
    JOIN
        skills_job_dim AS sjd
    ON  
        jpf.job_id = sjd.job_id
    JOIN
        skills_dim AS sd
    ON
        sjd.skill_id = sd.skill_id
    JOIN
        company_dim AS cd
    ON
        jpf.company_id = cd.company_id
    WHERE
        jpf.job_title_short = 'Data Analyst' 
    GROUP BY
        jpf.job_title,
        jpf.salary_year_avg,
        sd.skills,
        jpf.job_id,
        cd.name
    ORDER BY
        jpf.salary_year_avg DESC
)

SELECT 
    COUNT(job_id) AS job_count,
    skills
FROM job_count
GROUP BY
    skills
ORDER BY
    job_count DESC
LIMIT 5;

-- 4. what are the top skills based on salary for my role?
-- Identifying top skills based on salary for my role
SELECT
    sd.skills as skills,
    round(avg(jpf.salary_year_avg), 0) as annual_avg_salary
FROM
    job_postings_fact as jpf
JOIN
    skills_job_dim as sjd
ON  
    jpf.job_id = sjd.job_id
JOIN
    skills_dim as sd
ON
    sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Analyst' AND
    jpf.salary_year_avg is not NULL 
GROUP BY
    skills
ORDER BY
    2 DESC
LIMIT 10;

-- 5. What are the most optical skills to learn?
    -- a. Optimal: High demand and High paying
WITH opt_skill AS (
    SELECT
        jpf.job_id,
        sd.skills,
        jpf.salary_year_avg
    FROM
        job_postings_fact AS jpf
    JOIN
        skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    JOIN
        skills_dim AS sd ON sjd.skill_id = sd.skill_id
    JOIN
        company_dim AS cd ON jpf.company_id = cd.company_id
    WHERE
        jpf.salary_year_avg IS NOT NULL
),

total_stats AS (
    SELECT
        COUNT(jpf.job_id) AS total_jobs,
        SUM(jpf.salary_year_avg) AS total_salary
    FROM
        job_postings_fact AS jpf
    WHERE
        jpf.salary_year_avg IS NOT NULL
)

SELECT
    skills,
    COUNT(job_id) AS job_offers,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    ROUND(COUNT(job_id) * 100.0 / (SELECT total_jobs FROM total_stats), 2) AS job_offers_pct,
    ROUND(SUM(salary_year_avg) * 100.0 / (SELECT total_salary FROM total_stats), 2) AS salary_pct,
    ROUND(((COUNT(job_id) * 100.0 / (SELECT total_jobs FROM total_stats)) + 
    (SUM(salary_year_avg) * 100.0 / (SELECT total_salary FROM total_stats))) / 2, 2) AS overall_score_pct
FROM
    opt_skill
GROUP BY
    skills
ORDER BY
    overall_score_pct DESC
LIMIT
    100;

-- Additional Analysis
-- Most Optimal Skills as Data Analyst for Remote Jobs

WITH opt_skill AS (
    SELECT
        jpf.job_id,
        sd.skills,
        jpf.salary_year_avg
    FROM
        job_postings_fact AS jpf
    JOIN
        skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
    JOIN
        skills_dim AS sd ON sjd.skill_id = sd.skill_id
    JOIN
        company_dim AS cd ON jpf.company_id = cd.company_id
    WHERE
        jpf.salary_year_avg IS NOT NULL AND
        jpf.job_work_from_home = 'True' AND
        jpf.job_title_short = 'Data Analyst'
),

total_stats AS (
    SELECT
        COUNT(jpf.job_id) AS total_jobs,
        SUM(jpf.salary_year_avg) AS total_salary
    FROM
        job_postings_fact AS jpf
    WHERE
        jpf.salary_year_avg IS NOT NULL
)

SELECT
    skills,
    COUNT(job_id) AS job_offers,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    ROUND(COUNT(job_id) * 100.0 / (SELECT total_jobs FROM total_stats), 2) AS job_offers_pct,
    ROUND(SUM(salary_year_avg) * 100.0 / (SELECT total_salary FROM total_stats), 2) AS salary_pct,
    ROUND(((COUNT(job_id) * 100.0 / (SELECT total_jobs FROM total_stats)) + 
    (SUM(salary_year_avg) * 100.0 / (SELECT total_salary FROM total_stats))) / 2, 2) AS overall_score_pct
FROM
    opt_skill
GROUP BY
    skills
ORDER BY
    overall_score_pct DESC
LIMIT
    100;