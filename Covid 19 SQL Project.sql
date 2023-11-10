/*
--Covid 19 Data Exploration Project
--Skilled Used : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From CovidDeaths
Where continent is Not Null
Order by 3,4



-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
WHERE continent is not NULL
Order by 1,2



--Covid 19 Total Cases vs Total Deaths and likelihood of dying if you contract covid in United States

Select 
    Location, 
    date, 
    total_cases,
    total_deaths, 
Cast((total_deaths * 1.0/ total_cases) * 100 AS numeric(13,2)) DeathPercentage
From CovidDeaths
Where continent is not null and
location Like'%States%'
order by 1,2



-- Covid 19 Total Cases Vs Population (Prevalence Rate)
-- Shows what percentage of population infected with Covid


Select 
    location, 
    date, 
    total_cases, 
    Population, 
Cast((total_cases * 1.0/ population) * 100 AS numeric(9,7)) Prevalence_rate
From CovidDeaths
--Where location Like'%States%'
order by 1,2


-- Covid 19 Total Deaths Vs population (Mortality Rate)

Select 
    Location, 
    total_deaths,
    Population,
    Cast((total_deaths*1.0/Population)*100 As Numeric(10,4)) MortalityRate
From CovidDeaths
Where continent is not null 
Group BY location, total_deaths, population 
Order by MortalityRate DESC



-- Countries with Highest Infection Rate compared to Population

Select 
    Location, 
    Population, 
    MAX(total_cases) as HighestInfectionCount, 
   CAST(Max((total_cases*1.0/population))*100 AS NUMERIC(10,2))  PercentPopulationInfected
From CovidDeaths
--Where continent is not null and location Like'%States%'
Group by Location, Population
Order BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Segmenting data according to continents
-- Showing contintents with the highest death count per population

Select 
    continent, 
    cast(max(total_deaths) as int) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount Desc


-- Covid 19 GLOBAL NUMBERS


SELECT
    SUM(total_cases * 1.0) AS Sum_total_cases,
    SUM(total_deaths * 1.0) AS Sum_total_deaths,
    CAST(SUM(total_deaths * 1.0) / SUM(total_cases * 1.0) * 100 AS Numeric(5, 2)) AS DeathPercentage
FROM
    CovidDeaths


-- review the Vaccinations table
SELECT * 
FROM CovidVaccinations
ORDER BY 3,4



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM 
    CovidDeaths AS dea
JOIN 
    CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL --and new_vaccinations is not null
ORDER BY 
    dea.location, dea.population, dea.date 



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) as RollingPeopleVaccinated
    FROM 
        CovidDeaths dea
    JOIN 
        CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL --and new_vaccinations is not null
)
SELECT 
    *,
    (RollingPeopleVaccinated * 1.0 / Population) * 100 AS PercentageVaccinated
FROM 
    PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query
-- DROP TABLE IF EXISTS PercentPopulationVaccinated


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) as RollingPeopleVaccinated
    FROM 
        CovidDeaths dea
    JOIN 
        CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL --and new_vaccinations is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinatedView as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM 
    CovidDeaths AS dea
JOIN 
    CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL --and new_vaccinations is not null



