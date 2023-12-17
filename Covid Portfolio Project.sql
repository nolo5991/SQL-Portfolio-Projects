SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of contracting covid in your country

SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%pakistan%'
ORDER BY 1,2

--Looking at total cases vs the population
--Percentage of population affected by Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
where location like '%pakistan%'
ORDER BY 1,2

--Looking towards countries with highest infection rate with respect to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%pakistan%'
Where continent is not null
Group by location,population
ORDER BY InfectionPercentage DESC

--Countries with highest death count with respect to population

SELECT location, MAX(CONVERT(float,total_deaths)) as DeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%pakistan%'
Where continent is not null
Group by location
ORDER BY DeathCount DESC

--Categorizing using Continents

SELECT continent, MAX(CONVERT(float,total_deaths)) as DeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%pakistan%'
Where continent is not null
Group by continent
ORDER BY DeathCount DESC


SET ANSI_WARNINGS OFF;
GO
--GLOBAL Numbers

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
ORDER BY 1,2 

Select *
from PortfolioProject..CovidVaccinations

Select *
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date

 -- Total population vs vaccinations

 --Using CTE

 With PopvsVac (continent, location, date, population, new_vaccinations, updatedvaccinatedpeople)
 as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as UpdatedVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (updatedvaccinatedpeople/population)*100 as percentageofvaccinated
from PopvsVac

--Temp table
Drop Table #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
UpdatedVaccinatedPeople numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as UpdatedVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 --Where dea.continent is not null
--ORDER BY 2,3

Select *, (updatedvaccinatedpeople/population)*100 as percentageofvaccinated
from #PercentPopulationVaccinated

--Creating view for visualization
go
Create view PercentPopulationVaccinatedMy as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as UpdatedVaccinatedPeople
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--ORDER BY 2,3

select * 
from dbo.PercentPopulationVaccinatedMy