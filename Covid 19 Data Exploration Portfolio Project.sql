
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject.dbo.[Covid Deaths]
WHERE continent is not null
ORDER BY 3,4

--Select Data that we are going to stating with

 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.[Covid Deaths]
WHERE continent is not null 
ORDER BY 1,2

-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.[Covid Deaths]
WHERE location like '%India%'
and continent is not null
ORDER BY 1,2

--Total Cases VS Population
-- Shows what percentage of population infected with covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 as Percent_Population_Infected
FROM PortfolioProject.dbo.[Covid Deaths]
--WHERE location like '%India%'
ORDER BY 1,2

--Countries with Highest Infection Rate Compared to Population

SELECT location, population, max(total_cases) as Highest_Infection_Count,  max((total_cases/population))*100 as Percent_Population_Infected
FROM PortfolioProject.dbo.[Covid Deaths]
--WHERE location like '%India%'
WHERE continent is not null
Group By location, population
ORDER BY Percent_Population_Infected desc


--Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as Total_Death_Count
FROM PortfolioProject.dbo.[Covid Deaths]
--WHERE location like '%India%'
WHERE continent is not null
Group By location
ORDER BY Total_Death_Count desc

--BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
FROM PortfolioProject.dbo.[Covid Deaths]
--WHERE location like '%India%'
WHERE continent is not null
Group By continent
ORDER BY Total_Death_Count desc

--GLOBAL NUMBERS

SELECT date,SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.[Covid Deaths]
--WHERE location like '%India%'
WHERE continent is not null
Group BY date
ORDER BY 1,2

--Total Population VS Vaccinations
-- Showing Percentage of population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.DATE) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.[Covid Deaths] dea 
JOIN PortfolioProject.dbo.[Covid Vaccinations] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.DATE) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.[Covid Deaths] dea 
JOIN PortfolioProject.dbo.[Covid Vaccinations] vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


--Using Temp Table to perform Calculation on Partition by in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.DATE) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.[Covid Deaths] dea 
JOIN PortfolioProject.dbo.[Covid Vaccinations] vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store Data for later visualizations

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.DATE) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.[Covid Deaths] dea 
JOIN PortfolioProject.dbo.[Covid Vaccinations] vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null