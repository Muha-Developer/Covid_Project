SELECT * 
FROM Covid_DB..CovidDeaths
ORDER BY 3,4;

/* SELECT *
FROM Covid_DB..CovidVaccinations
ORDER BY 3,4; */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_DB..CovidDeaths
ORDER BY 1,2 ;

-- Looking For TotalCases VS TotalDeaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
FROM Covid_DB..CovidDeaths
WHERE location LIKE '%Saudi%'
ORDER BY 1,2 ;

-- Percentage of Population Got Covid

SELECT location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Covid_DB..CovidDeaths
--WHERE location LIKE '%Saudi%'
ORDER BY 1,2 ;

-- Countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) AS highsetInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_DB..CovidDeaths
--WHERE location LIKE '%Saudi%'
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest deaths count

SELECT location,MAX(CAST(total_deaths as int)) AS Total_Deaths_Count
FROM Covid_DB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_Deaths_Count DESC ;

-- Continents with highest deaths count 

SELECT continent, MAX(CAST(total_deaths as int)) AS Total_Deaths_Count
FROM Covid_DB..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC ;

-- Global numbers

SELECT SUM(new_cases) AS Total_New_Cases, SUM(CAST(new_deaths AS INT)) AS Total_New_Deaths, 
(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100) AS DeathsPercentage
FROM Covid_DB..CovidDeaths
WHERE continent IS NOT NULL ;

-- Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
AS RollingPeopleVaccinated
FROM Covid_DB..CovidDeaths dea
JOIN Covid_DB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 ;

-- CTE

WITH PopVsVac ( continent, location , date, population, new_vaccinations, RollingPeopleVaccinated )
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
	AS RollingPeopleVaccinated
	FROM Covid_DB..CovidDeaths dea
	JOIN Covid_DB..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3 
)
SELECT *,(RollingPeopleVaccinated/population) * 100 AS PopVsVac
FROM PopVsVac ;

-- View To Store Data For Later Visualization

CREATE VIEW PercentPeopleVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
		AS RollingPeopleVaccinated
		FROM Covid_DB..CovidDeaths dea
		JOIN Covid_DB..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2,3 

SELECT * 
FROM PercentPeopleVaccinated;
