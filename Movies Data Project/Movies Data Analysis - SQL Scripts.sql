
USE PortfolioProjects


--Exploration--

SELECT * 
FROM Movies
WHERE Name = 'The shawshank redemption'
ORDER BY Year


--Selecting movies with the same name but different released years and directors

SELECT *
FROM Movies
WHERE Name IN (
    SELECT Name
    FROM Movies
    GROUP BY Name
    HAVING COUNT(DISTINCT Year) > 1 )
AND Name IN (
    SELECT Name
    FROM Movies
    GROUP BY Name
    HAVING COUNT(DISTINCT Director) > 1 )
ORDER BY Name



--Removing Unwanted values and Blank Rows, columns--
--Data type conversion, renaming--


DELETE FROM Movies
WHERE [released date] IS NULL OR [released date] = ''
AND year IN (2021, 2022, 2023);


ALTER TABLE Movies
DROP COLUMN  F17, F18, F19, F20, F21, F22;

ALTER TABLE Movies
ALTER COLUMN [Gross Income (USD)] BIGINT;

ALTER TABLE Movies
ALTER COLUMN [Budget (USD)] BIGINT;

ALTER TABLE Movies
ALTER COLUMN [Released date] DATE

UPDATE Movies
SET [Company] = 'Moho Film'
WHERE NAME = 'Snowpiercer';

EXEC sp_rename 'Movies.[Gross (USD)]', 'Gross Income (USD)', 'COLUMN';


---------------------------------------------------------------------------------------------------------------


---Average Gross income and Average rating of movies released in a month.

SELECT DATEPART(MONTH,[Released date]) AS Released_month,
       AVG([Gross Income (USD)]) AS Avg_income, 
       CAST(AVG(Score) AS DECIMAl (10,2)) AS Avg_score
FROM Movies
GROUP BY  DATEPART(MONTH, [Released date]) 
ORDER BY  Avg_Income DESC


--1). Movies performance at the box office based on released season.

SELECT 
   CASE
     WHEN MONTH([Released date]) IN (3,4,5) THEN 'Spring'
	 WHEN MONTH([Released date]) IN (6,7,8) THEN 'Summer'
	 WHEN MONTH([Released date]) IN (9,10,11) THEN 'Fall'
	 ELSE 'Winter'
   END AS Released_season,
     COUNT(Name) AS Movies_released,
'$   '+FORMAT(CONVERT(MONEY,AVG([Gross Income (USD)]),0),'N0') AS Avg_income,
     CAST(AVG(Votes) AS DECIMAL (5,0)) AS Avg_votes,
     CAST(AVG(Score) AS DECIMAL (5,2)) AS Avg_rating
FROM Movies
GROUP BY 
   CASE
     WHEN MONTH([Released date]) IN (3,4,5) THEN 'Spring'
	 WHEN MONTH([Released date]) IN (6,7,8) THEN 'Summer'
	 WHEN MONTH([Released date]) IN (9,10,11) THEN 'Fall'
	 ELSE 'Winter'
   END
ORDER BY Avg_income DESC
 

--------------------------------------------------------------------------------------------------------------


--2).Genre performance

SELECT Genre, 
       CAST(AVG(Score) AS DECIMAL(10,2)) AS Avg_rating,
       ROUND(AVG(Votes), 0) AS Avg_votes,
'$   '+FORMAT(CONVERT(MONEY,AVG([Gross Income (USD)]),0),'N0') AS Avg_income
FROM Movies
GROUP BY Genre
Having AVG([Gross Income (USD)]) IS NOT NULL 
ORDER BY AVG([Gross Income (USD)]) DESC


-------------------------------------------------------------------------------------------------------------


--3). Movies Runtime impact on movies rating and box office performance

SELECT
    CASE
       WHEN Runtime < 80 THEN 'Short (less than 80 mins)'
       WHEN Runtime >= 80 AND Runtime <= 120 THEN 'Medium (80-120 mins)'
       WHEN Runtime > 120 THEN 'Long (more than 120 mins)'
    END AS Runtime_category,
	CAST(AVG(Votes) AS DECIMAL (10, 0)) AS Avg_votes,
    CAST(AVG(Score) AS DECIMAL(10, 2)) AS Avg_rating,
'$   '+FORMAT(CONVERT(MONEY,AVG([Gross Income (USD)]),0),'N0') AS Avg_gross_icome,
'$   '+FORMAT(CONVERT(MONEY,MAX([Gross Income (USD)]),0),'N0') AS Highest_gross_income
FROM Movies
GROUP BY  
    CASE
       WHEN Runtime < 80 THEN 'Short (less than 80 mins)'
       WHEN Runtime >= 80 AND Runtime <= 120 THEN 'Medium (80-120 mins)'
       WHEN Runtime > 120 THEN 'Long (more than 120 mins)'
    END
ORDER BY Runtime_category

 
-------------------------------------------------------------------------------------------------------------


--4).Top ten Actors with a impact on movies' box Office total earnings and AVG rating.

SELECT TOP 10 Star, 
'$   '+FORMAT(CONVERT(MONEY,SUM([Gross Income (USD)]),0),'N0') AS Total_gross_earnings,
       CAST(AVG(Score) AS DECIMAL (10,3)) AS Avg_movies_rating,
	   ROUND(AVG(Votes),0) AS Avg_votes
	   --RANK() OVER ( ORDER BY  SUM([Gross Income (USD)]) DESC) AS [Rank]
FROM Movies
GROUP BY Star
ORDER BY SUM([Gross Income (USD)]) DESC


----------------------------------------------------------------------------------------------------------------


--5).Top ten Directors with a impact on movies' box office and AVG rating.

SELECT Top 10 Director, 
       COUNT(name) AS Directed_movies, 
'$   '+FORMAT(CONVERT(MONEY,SUM([Gross Income (USD)]),0),'N0') AS Total_gross_earnings, 
       CAST(AVG(Score) AS DECIMAL (10,2)) AS Avg_movies_rating
	   --RANK() OVER ( ORDER BY  SUM([Gross Income (USD)]) DESC)  AS [Rank]
FROM  Movies
GROUP BY Director
ORDER BY SUM([Gross Income (USD)]) DESC


--------------------------------------------------------------------------------------------------------------
 

--6). Top production companies performance and with impact on box office success of movies.

SELECT TOP 15 Company, 
       COUNT(Name) AS Movies_produced,
'$   '+FORMAT(CONVERT(MONEY,SUM([Gross Income (USD)]),0),'N0') AS Total_gross_earnings,
'$   '+FORMAT(CONVERT(MONEY,MAX([Gross Income (USD)]),0),'N0') AS Highest_gross_income,
	   CAST(AVG(Score) AS DECIMAL (10,3)) AS Avg_movies_rating
FROM Movies
GROUP BY Company
ORDER BY SUM([Gross Income (USD)]) DESC


--------------------------------------------------------------------------------------------------------------


--7). Movies performance at the box office success by top countries

SELECT Country,
       COUNT(Name) AS Movies_produced,
	   CAST(AVG(Score) AS DECIMAL(10, 2)) AS Avg_rating,
'$   '+FORMAT(CONVERT(MONEY,MAX([Gross Income (USD)]),0),'N0') AS Highest_gross_income,
'$   '+FORMAT(CONVERT(MONEY,MIN([Gross Income (USD)]),0),'N0') AS Lowest_gross_income
FROM Movies
GROUP BY Country
HAVING SUM([Gross Income (USD)]) >= 1000000000 
ORDER BY MAX([Gross Income (USD)]) DESC


------------------------------------------------------------------------------------------------------------


--8). Movies average/highest rating and performance over the decades

WITH DecadeData AS (
SELECT CASE
          WHEN YEAR >= 1980 AND YEAR <= 1989 THEN '1980-1989'
		  WHEN YEAR >= 1990 AND YEAR <= 1999 THEN '1990-1999'
		  WHEN YEAR >= 2000 AND YEAR <= 2009 THEN '2000-2009'
		  WHEN YEAR >= 2010 AND YEAR <= 2019 THEN '2010-2019'
	   END AS Decade,
	   Name, Score, Votes
	   FROM Movies )

SELECT Decade,
       COUNT(Name) AS Movies_released,
	   CAST(MAX(Score) AS DECIMAL (10,1)) AS Highest_rating,
	   CAST(AVG(Score) AS DECIMAL (10,2)) AS Avg_movies_rating,
	   CAST(AVG(Votes) AS DECIMAl (10,0)) AS Avg_votes
FROM DecadeData
GROUP BY Decade
HAVING Decade IS NOT NULL
ORDER BY CAST(AVG(Score) AS DECIMAL (10,2)) DESC













