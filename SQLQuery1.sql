/*
Covid 19 Data Exploration Project

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
from project..CovidDeaths$
Where continent is not null
order by 3, 4


-- Select Data that we are going to be starting with


Select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths$
Where location like '%states%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select location, population, total_cases, (total_cases/population)*100 as PercentPopuationinfected
from project..CovidDeaths$
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population


Select location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as PercentPopuationinfected
from project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopuationinfected desc


-- Countries with Highest Death Count per Population


Select location, MAX(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by totaldeathcount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by totaldeathcount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query



With popvsvac (continent, location, dae, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac



-- Using Temp Table to perform Calculation on Partition By in previous query


 
 DROP TABLE if exists #PerentagePopulationVaccinated
 Create Table #PerentagePopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date  Datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 Insert into #PerentagePopulationVaccinated
 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PerentagePopulationVaccinated




-- Creating View to store data for later visualizations



 Create View  PerentagePopulationVaccinated as         
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
             