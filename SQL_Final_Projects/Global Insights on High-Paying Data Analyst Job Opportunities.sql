-- Salary Categorization 
/* To determine these thresholds, we need to analyze the data. We can do this by calculating the percentiles for the salary_year_avg of Data Analysts.

Let's first get the salary distribution percentiles:

1. Calculate the 20th percentile (P20): This will be the threshold for the Low Salary.
2. Calculate the 80th percentile (P80): This will be the threshold for the High Salary.
3. The range between P20 and P80: This will be considered the Standard Salary.
*/

SELECT 
    PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY salary_year_avg) AS P20,
    PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY salary_year_avg) AS P80
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL;



-- After Identifying the Percentiles, we now have the idea of categorizing the salaries.
-- now lets code a query to classify the salaries and count job postings by country.

SELECT 
    COUNT(job_id) AS job_postings,
    job_country,
    CASE
        WHEN salary_year_avg <= 65000 THEN 'Low Salary'
        WHEN salary_year_avg >= 115000 THEN 'High Salary'
        ELSE 'Standard Salary'
    END AS job_salary
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    job_country,
    CASE
        WHEN salary_year_avg <= 65000 THEN 'Low Salary'
        WHEN salary_year_avg >= 115000 THEN 'High Salary'
        ELSE 'Standard Salary'
    END
ORDER BY
   -- 1 DESC(optional),
    job_country,
    CASE
        WHEN CASE 
                WHEN salary_year_avg <= 65000 THEN 'Low Salary'
                WHEN salary_year_avg >= 115000 THEN 'High Salary'
                ELSE 'Standard Salary'
             END = 'High Salary' THEN 1
        WHEN CASE 
                WHEN salary_year_avg <= 65000 THEN 'Low Salary'
                WHEN salary_year_avg >= 115000 THEN 'High Salary'
                ELSE 'Standard Salary'
             END = 'Low Salary' THEN 2
        ELSE 3
    END,
    job_postings DESC
LIMIT 1000;


