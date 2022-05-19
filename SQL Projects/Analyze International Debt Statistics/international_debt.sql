/* 
    Inspect the international debt data collected by the world bank.
*/

-- Table: international_debt

CREATE TABLE international_debt
(
  country_name VARCHAR (50),
  country_code VARCHAR (50),
  indicator_name text,
  indicator_code text,
  debt numeric
);



--1. Inspect the top 10 international debt data

SELECT * FROM international_debt
    LIMIT 10;



--2. Finding the number of distinct countries

 COUNT(DISTINCT country_name) AS total_distinct_countries
FROM international_debt;



--3. Finding out the distinct debt indicators

SELECT DISTINCT (indicator_code) AS distinct_debt_indicators
FROM international_debt
ORDER BY distinct_debt_indicators;



--4. Totaling the amount of debt owed by the countries

SELECT
  ROUND(SUM(debt) / 1000000, 2) AS total_debt
FROM international_debt;



--5. Country with the highest debt

SELECT 
   country_name, SUM(debt) AS total_debt
FROM international_debt
GROUP BY country_name
ORDER BY total_debt DESC
LIMIT 1 ;



--6 Average amount of debt across indicators

SELECT
   indicator_code AS debt_indicator,
   indicator_name,
   AVG(debt) AS average_debt
FROM international_debt
GROUP BY debt_indicator, indicator_name
ORDER BY average_debt DESC
LIMIT 10;




--7 The highest amount of principal repayments

SELECT
   country_name,
   indicator_name
FROM international_debt
WHERE debt = (SELECT
                  MAX(debt)
              FROM international_debt
              WHERE indicator_code = 'DT', 'AMT', 'DLFX', 'CD')
;



--8 The most common debt indicator

SELECT indicator_code, COUNT(indicator_code) AS indicator_count
FROM international_debt
GROUP BY indicator_code
ORDER BY indicator_count DESC, indicator_code DESC
LIMIT 20;



--9 The top 10 countries with the most amount of debt

SELECT country_name, MAX(debt) AS maximum_debt
FROM international_debt
GROUP BY country_name
ORDER BY maximum_debt DESC 
LIMIT 10;