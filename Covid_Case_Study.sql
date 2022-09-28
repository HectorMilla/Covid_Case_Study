SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths

-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases , total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases , population,(total_cases / population) * 100 AS infectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2



-- Looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as higheestInfectionCount , population, MAX((total_cases / population)) * 100 AS highestInfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by highestInfectedPopulationPercentage DESC

--Showing countries with the highest death count per population

Select location, MAX(CAST(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC


--Showing CONTINENTS with the highest death count 

Select continent, MAX(CAST(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--------------Global Numbers-------------------


--global death percentage

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint)) / SUM(new_cases)
* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
order by 1, 2



---- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER 
 (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
order by 2, 3



--using CTE to access RollingPeopleVaccinated

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER 
 (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
--order by 2, 3
 )
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac


-----------Creating views to store data for later viz---------------

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER 
 (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
--order by 2, 3


CREATE VIEW ChanceOfDeathByCountry
AS
Select location, date, total_cases , total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
--order by 1, 2


CREATE VIEW GlobalDeathPercentage
AS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint)) / SUM(new_cases)
* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
--order by 1, 2