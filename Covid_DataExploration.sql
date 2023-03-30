SELECT * 
FROM portfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM portfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your countury

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Death_Percentage
From portfolioProject.dbo.CovidDeaths
WHERE location like '%pak%'
and continent is not null
Order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population) *100 as Percentage_of_population_infected
From portfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, total_cases, population, (total_cases/population) *100 as Percentage_of_population_infected
From portfolioProject.dbo.CovidDeaths
WHERE continent is not null
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with highest death counr per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths , (SUM(cast(new_deaths as int))/SUM(new_cases)) *100 as Death_Percentage
From portfolioProject.dbo.CovidDeaths
--WHERE location like '%pak%'
where continent is not null
group by date
Order by 1


-- Looking at total population vs Vaccination 
-- USE CTE

with PopvsVac as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
JOIN portfolioProject.dbo.CovidVaccinations as vac ON
dea.location = vac. location and dea.date = vac.date
where dea.continent is not null

)
Select *, (RollingPeopleVaccinated/ population)*100 as percentage
from PopvsVac


--Temp Table
Drop Table if exists #PercentagePopulationVaccinated
Create TABLE #PercentagePopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
JOIN portfolioProject.dbo.CovidVaccinations as vac ON
dea.location = vac. location and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/ population)*100 as percentage
from #PercentagePopulationVaccinated

--Creating View to store data for later visualization
USE PortfolioProject
GO
Create View PercentagePopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject.dbo.CovidDeaths as dea
JOIN portfolioProject.dbo.CovidVaccinations as vac ON
dea.location = vac. location and dea.date = vac.date
where dea.continent is not null

Select * 
from PercentagePopulationVaccinated