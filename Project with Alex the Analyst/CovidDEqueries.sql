Select * 
from PortfolioProject..CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%IND%'
order by 1,2


--looking at total cases vs population
select location,date,total_cases,total_deaths,(total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths
--where location like '%Ind%'
order by 1,2


--Looking at countries with highest number of cases
select location,population,Max(total_cases) as HighestInfectionCount, (Max(Total_Cases)/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
Group by location,population
order by PopulationInfected desc

--Showing countries with highest deathcount per population
select location, population,MAx(cast(total_deaths as bigint)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location,population
order by Totaldeathcount desc

--Data broken down by continent
select continent, Max(Cast(total_deaths as bigint)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Totaldeathcount desc


--GLobal numbers
Select sum(new_cases) as TotalCases,sum(cast(new_cases as bigint))as TotalDeaths,sum(cast (new_deaths as bigint))/Sum(new_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Joining two tables

Select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date = vac.date

-- Looking at total population vs vaccinations
Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
     on dea.location=vac.location
	 and dea.date =vac.date
where dea.continent is not null
order by 2,3


--Using CTE to show Population vs RollingVaccination Percentage
with PopvsVac (continent, location,date,Population,new_vaccinations,RollingpeopleVaccinated)
as
(
Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint ,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingpeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
     on dea.location=vac.location
	 and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingpeopleVaccinated/Population)*100 as RollingVacPercentage
from PopvsVac


--Doing similar using Temp table

Drop table if exists #PercentagepopulationVaccinated
Create table #PercentagepopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentagepopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *,(RollingpeopleVaccinated/population)*100
from #PercentagepopulationVaccinated


--Creating view to store data for later visualizations
use PortfolioProject;
go
Create view PercentagepopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--Creating view to store data for later visualizations
USE PortfolioProject;
GO
CREATE VIEW NewGlobalnumbers 
AS
SELECT sum(new_cases) as TotalCases,
       sum(cast(new_cases as bigint)) as TotalDeaths, 
       sum(cast (new_deaths as bigint))/Sum(new_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null;
