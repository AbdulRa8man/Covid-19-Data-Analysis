
USE PortfolioProjects;

SELECT *
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM Covidvaccinations
ORDER BY 3,4


SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM CovidDeaths ORDER BY 1,2


--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
--Death percentage
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN (total_cases  IS NOT NULL AND total_deaths  IS NOT NULL) AND total_cases > 0 
	THEN (CAST(total_deaths AS FLOAT) * 100 / CAST(total_cases AS FLOAT))
        ELSE NULL  -- Result is NULL if either total_cases or total_deaths is NULL or total_cases is 0
    END as Death_Percentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY location, date;



--Looking at total cases vs population
--Shows the percentage of population got Covid

SELECT
    location, date, population, total_cases,
	CASE
	   WHEN (Total_cases IS NOT NULL ) AND  Total_cases > 0
	   THEN CAST(CAST(Total_cases AS FLOAT) * 100 / CAST(population AS FLOAT)AS DECIMAL (10,8))
	   ELSE NULL
	END AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;



--1. looking at countries with Total Deaths and highest infection rate compared to population & Date

SELECT
    location, Date
    population,
    SUM(CAST(new_deaths as INT)) AS TotalDeathCount,
    MAX(CAST(total_cases AS INT)) AS Highest_infection_count,
    CASE
        WHEN  MAX(CAST(total_cases AS INT)) IS NOT NULL AND  MAX(CAST(total_cases AS INT)) > 0
        THEN MAX(CAST(total_cases AS FLOAT)) * 100 / MAX(CAST(population AS FLOAT))
        ELSE NULL
    END AS Percent_population_infected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location, population, Date
ORDER BY Percent_population_infected DESC 



--2. Countries with the highest death count and Total cases 

SELECT
    location, SUM(CAST(new_cases AS INT)) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location 
ORDER BY  TotalDeathCount  DESC;



--3. Continents with the highest death count  

SELECT
     Continent, SUM(CAST(new_deaths as INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY  TotalDeathCount  DESC;



--4. GLOBAL NUMBERS

SELECT 
       SUM(new_cases)as Total_cases,
       SUM(new_deaths) as Total_deaths,
      CASE
        WHEN (SUM(new_cases) IS NOT NULL AND SUM(new_deaths) IS NOT NULL) AND SUM(new_cases) > 0 
	THEN (CAST(SUM(new_deaths) AS FLOAT)/ CAST(SUM(new_cases) AS FLOAT)) * 100 
        ELSE NULL  
      END as DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;



--5. looking at countries with Total Vaccinations compared to population & Date

SELECT  vac.location, CONVERT(DATE,vac.date) AS Date, dea.population, 
        CAST(MAX(vac.total_vaccinations) AS BIGINT) AS Total_vaccinations,
        CAST(MAX(vac.people_vaccinated) AS BIGINT) AS People_partially_vaccianted,
	CAST(MAX(vac.people_fully_vaccinated) AS BIGINT) AS People_fully_vaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
GROUP BY vac.location, CONVERT(DATE,vac.date), dea.population
ORDER BY 3 DESC	



--6. Looking at total population vs. vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations )) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinations
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--WHERE dea.location LIKE 'Canada'
ORDER BY 2,3

	

--7. Create a Temp Table to get the Vaccination Percentage

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS total_vaccinations
INTO #PercentPopulationVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL;

SELECT *, (Total_vaccinations / Population) * 100 AS vaccinationPercentage
FROM  #PercentPopulationVaccinated
ORDER BY 2, 3;




