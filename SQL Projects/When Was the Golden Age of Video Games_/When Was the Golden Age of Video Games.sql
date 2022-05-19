/*
Project: When Was the Golden Age of Video Games?
Objective of the Project: To analyze video game critic and user scores as well as sales data for the top 400 video games released since 1977.


Skills used: Aggregate Functions,  Joins, Set theory, Subquery
*/



-- Create tables to import datas to be used


DROP TABLE game_sales;

CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold NUMERIC(5, 2),
  year INT
);

DROP TABLE reviews;

CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score NUMERIC(4, 2),   
    user_score NUMERIC(4, 2)
);

DROP TABLE top_critic_years;

CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_critic_years_more_than_four_games;

CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_user_years_more_than_four_games;

CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score NUMERIC(4, 2)  
);



-- Tables were imported automatically using pgAdmin import 




-- 1. The ten best-selling video games

-- Let's find the ten best-selling video games in game_sales

SELECT *
FROM game_sales
ORDER BY games_sold DESC
LIMIT 10;




--2. Missing review scores

--Let's determine how many games in the game_sales table are missing both a user_score and a critic_score

SELECT   COUNT (g.game)
FROM game_sales AS g LEFT JOIN reviews
USING (game)
WHERE user_score IS NULL AND
critic_score IS NULL;




--3. Years that video game critics loved

--Top 10 years with the highest average critic_score in decending order

SELECT year,ROUND( AVG (critic_score), 2) AS avg_critic_score
FROM game_sales JOIN reviews
USING (game)
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 10;




--4. Was 1982 really that great?

--Game critics' ten favorite years, this time with the stipulation that a year must have more than four games released in order to be considered

SELECT year,ROUND( AVG (critic_score), 2) AS avg_critic_score, 
  COUNT(g.game) AS num_games
FROM game_sales AS g JOIN reviews
USING (game)
GROUP BY year
HAVING COUNT(g.game) > 4
ORDER BY avg_critic_score DESC
LIMIT 10;




--5. Years that dropped off the critics' favorites list

--Years that were on our first critics' favorite list but not the second, from highest to lowest.

SELECT year, avg_critic_score
FROM top_critic_years
EXCEPT
SELECT year, avg_critic_score
FROM top_critic_years_more_than_four_games
ORDER BY avg_critic_score DESC;





--6. Years video game players loved

--Game users' ten favorite years, this time with the stipulation that a year must have more than four games released in order to be considered


SELECT year,ROUND( AVG (user_score), 2) AS avg_user_score, 
  COUNT(g.game) AS num_games
FROM game_sales AS g JOIN reviews
USING (game)
GROUP BY year
HAVING COUNT(g.game) > 4
ORDER BY avg_user_score DESC
LIMIT 10;





--7. Years that both players and critics loved

SELECT year FROM top_critic_years_more_than_four_games
INTERSECT
SELECT year FROM top_user_years_more_than_four_games;





--8. Sales in the best video game years

SELECT year, sum(games_sold) AS total_games_sold
FROM game_sales
WHERE year IN
(SELECT year FROM top_critic_years_more_than_four_games
INTERSECT
SELECT year FROM top_user_years_more_than_four_games)
GROUP BY year
ORDER BY total_games_sold DESC;