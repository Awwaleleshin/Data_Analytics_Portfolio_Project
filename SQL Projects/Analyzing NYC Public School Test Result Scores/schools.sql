/* 
   Project: Analyzing NYC Public School Test Result Scores
*/

-- Table: schools

DROP TABLE schools;

CREATE TABLE schools
(
    school_name VARCHAR(100) PRIMARY KEY,
    borough VARCHAR(100),
    building_code VARCHAR(10),
    average_math INT,
    average_reading INT,
    average_writing INT,
    percent_tested FLOAT
);



--1. Inspecting the data

SELECT * FROM schools
LIMIT 10;



--2. Finding missing values, count the number of schools not reporting the percentage of students tested and the total number of schools in the database.

SELECT COUNT(*) - COUNT(percent_tested) AS num_tested_missing, 
       COUNT(*) AS num_schools
FROM schools;


--3. Find how many unique schools there are based on building code

SELECT COUNT (DISTINCT building_code) AS num_school_buildings
FROM schools;



--4.Filter the database for all schools with math scores of at least 640.

SELECT school_name,
       average_math
FROM schools
WHERE average_math  > 639
ORDER BY average_math DESC;



--5.Find the lowest average reading score.

SELECT MIN (average_reading) AS lowest_reading
FROM schools;



--6 Filter the database for the top-performing school, as measured by average writing scores.

SELECT school_name,
       MAX(average_writing) AS max_writing
FROM schools
GROUP BY school_name
ORDER BY max_writing DESC
LIMIT 1;



--7 Top 10 schools

SELECT school_name,
       average_math + average_reading + average_writing AS average_sat
FROM schools
GROUP BY school_name
ORDER BY average_sat DESC
LIMIT 10;



--8 Find out how NYC SAT performance varies by borough.

SELECT borough,
       COUNT(*) AS num_schools,
       SUM (average_math + average_reading + average_writing) / COUNT(*) AS average_borough_sat
FROM schools
GROUP BY borough
ORDER BY average_borough_sat DESC;



--9 Find the top five best schools in Brooklyn by math score.

SELECT school_name, average_math
FROM schools
WHERE borough = 'Brooklyn'
GROUP BY school_name
ORDER BY average_math DESC
LIMIT 5;