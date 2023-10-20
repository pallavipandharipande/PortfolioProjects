
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths

SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your Country
SELECT continent,[location],date,total_cases,total_deaths,(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY continent,[location],[date]





--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT continent,[location],[date],population,total_cases,(CONVERT(float,total_cases)/CONVERT(float,population))*100 AS CovidPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY continent,[location],[date]





--Looking at Countries with highest Infection Rate compared to population
SELECT continent,[location],population,MAX(total_cases) AS HighestCovidCount, MAX((CAST(total_cases AS float)/CAST(population AS float))*100) AS HighestInfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,[location],population
ORDER BY HighestInfectionRate DESC




--Showing Countries with highest Death count per population
SELECT continent,[location],population,MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,[location],population
ORDER BY HighestDeathCount DESC





--Showing the continent with the highest death count per population

SELECT continent,MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC




--Global number

--Datewise
SELECT [date], SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, CASE
WHEN SUM(new_cases) = 0
THEN NULL
ELSE (CAST(SUM(new_deaths) AS float)/CAST(SUM(new_cases) AS float))*100
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY 1,2

--Over the world
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, CASE
WHEN SUM(new_cases) = 0
THEN NULL
ELSE (CAST(SUM(new_deaths) AS float)/CAST(SUM(new_cases) AS float))*100
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL



--Looking at Total population vs Vaccination (Rolling)
SELECT dea.continent, dea.[location],vac.[date],dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.[location] ORDER BY dea.location,vac.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date] 
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

--making use of CTE to use the newly made column RollingPeopleVaccinated for calculating the Vaccination rate

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location],vac.[date],dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.[location] ORDER BY dea.location,vac.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date] 
WHERE dea.continent IS NOT NULL

)
SELECT *, (CONVERT(float,RollingPeopleVaccinated)/CONVERT(float,Population))*100 AS RollingPeopleVaccinationRate
FROM PopvsVac

--Using temp table to calculate the Vaccination Rate 
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.[location],vac.[date],dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.[location] ORDER BY dea.location,vac.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date] 
WHERE dea.continent IS NOT NULL

SELECT *, (CONVERT(float,RollingPeopleVaccinated)/CONVERT(float,Population))*100 AS RollingPeopleVaccinationRate
FROM #PercentPopulationVaccinated


--Creating View to store
GO

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.[location],vac.[date],dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.[location] ORDER BY dea.location,vac.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date] 
WHERE dea.continent IS NOT NULL

GO 

SELECT *
FROM PercentPopulationVaccinated