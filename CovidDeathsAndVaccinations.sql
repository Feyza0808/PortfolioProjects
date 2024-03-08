Select * From PortfolioProject..CovidDeaths
order by 3,4

Select * From PortfolioProject..CovidVaccinations
WHERE continent is not null
order by 3,4


 --Select data that we are going to be using 

Select Location, date, total_cases,new_cases, total_deaths, population

From PortfolioProject..CovidDeaths

order by 1,2


--	Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%turkey%' AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInefted
FROM CovidDeaths
WHERE location LIKE '%turkey%' AND continent is not null
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS PercentPopulationInefted
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%turkey%'
GROUP BY location, population
ORDER BY PercentPopulationInefted DESC


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%turkey%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing cýntinents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%turkey%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT  SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%turkey%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




--TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(

continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location =vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated