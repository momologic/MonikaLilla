--Looking at total cases vs Total deaths
--Shows likelihood of dying if you contract covid in Hungary

Select  *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--Where location like '%hungary%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what precentage of population got covid

Select location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PrecentPopulationInfected
from PortfolioProject..covidDeaths
--Where location like '%hungary%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PrecentPopulationInfected
from PortfolioProject..covidDeaths
--Where location like '%hungary%'
Group by location, population
order by PrecentPopulationInfected desc


--Showing the highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%hungary%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per country
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%hungary%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(CONVERT(float, new_deaths)) as total_deaths, SUM(CONVERT(float, new_deaths))/NULLIF(SUM(new_cases),0) *100 as DeathPrecentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SElect *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
SElect *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations)OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated