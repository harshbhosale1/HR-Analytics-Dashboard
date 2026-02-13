CREATE DATABASE hr_analytics;
USE hr_analytics;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    dob DATE,
    startdate DATE,
    exitdate DATE,
    departmenttype VARCHAR(100),
    division VARCHAR(100),
    title VARCHAR(100),
    jobfunctiondescription VARCHAR(255),
    employeetype VARCHAR(50),
    employeestatus VARCHAR(50),
    payzone VARCHAR(50),
    employeeclassificationtype VARCHAR(50),
    gendercode VARCHAR(50),
    racedesc VARCHAR(50),
    maritaldesc VARCHAR(50),
    state VARCHAR(50),
    location VARCHAR(50)
    
);

CREATE TABLE performance (
    employee_id INT,
    review_date DATE,
    performance_score VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE surveys (
    employee_id INT,
    survey_date DATE,
    engagement_score INT,
    satisfaction_score INT,
    work_life_balance_score INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE training (
    employee_id INT,
    training_program_name VARCHAR(100),
    training_type VARCHAR(50),
    training_outcome VARCHAR(50),
    training_duration INT,
    training_date DATE,
    training_cost FLOAT,
    trainer VARCHAR(50),
    location VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE termination (
    employee_id INT,
    exitdate DATE,
    terminationtype VARCHAR(100),
    terminationdescription VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 1  Employee Count by Performance Rating
SELECT performance_score, COUNT(*) AS employee_count
FROM performance
GROUP BY performance_score;

-- 2  Monthly Hiring Trend
SELECT YEAR(startdate) AS year, MONTH(startdate) AS month, COUNT(*) AS hires
FROM employees
GROUP BY year, month
ORDER BY year, month;

-- 3  Attrition Count by Pay Zone
SELECT e.payzone, COUNT(t.employee_id) AS exits
FROM employees e
LEFT JOIN termination t ON e.employee_id = t.employee_id
GROUP BY e.payzone;

-- 4  Most Expensive Training Programs
SELECT * FROM training
ORDER BY training_cost DESC
LIMIT 3;

-- 5  Average Engagement Score by Department
SELECT e.departmenttype, AVG(s.engagement_score) AS avg_engagement
FROM employees e
JOIN surveys s ON e.employee_id = s.employee_id
GROUP BY e.departmenttype;

-- 6  Employees with Low Average Engagement
SELECT employee_id, AVG(engagement_score) AS avg_engagement
FROM surveys
GROUP BY employee_id
HAVING avg_engagement < 3;

-- 7  Attrition Count by Department
SELECT e.departmenttype, COUNT(t.employee_id) AS attrition
FROM employees e
JOIN termination t ON e.employee_id = t.employee_id
GROUP BY e.departmenttype;

-- 8  Average Training Cost by Performance Rating
SELECT p.performance_score, AVG(tr.training_cost) AS avg_training_cost
FROM performance p
JOIN training tr ON p.employee_id = tr.employee_id
GROUP BY p.performance_score;

-- 9  Attrition Rate by Department
SELECT e.departmenttype,
	COUNT(t.employee_id) * 100.0 / COUNT(e.employee_id) AS attrition_rate
FROM employees e
LEFT JOIN termination t ON e.employee_id = t.employee_id
GROUP BY e.departmenttype;

-- 10  Active Employees with Low Engagement (Attrition Risk)
SELECT e.employee_id, e.departmenttype, s.engagement_score
FROM employees e
JOIN surveys s ON e.employee_id = s.employee_id
LEFT JOIN termination t ON e.employee_id = t.employee_id
WHERE s.engagement_score < 3 AND t.employee_id IS NULL;

-- 11  Engagement vs Performance Relationship
SELECT p.performance_score, AVG(s.engagement_score) AS avg_engagement
FROM performance p
JOIN surveys s ON p.employee_id = s.employee_id
GROUP BY p.performance_score;

-- 12  Top 5 Job Titles with Highest Attrition
SELECT e.title, COUNT(*) AS exits
FROM employees e
JOIN termination t ON e.employee_id = t.employee_id
GROUP BY e.title
ORDER BY exits DESC LIMIT 5;