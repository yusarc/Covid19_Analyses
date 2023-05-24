select * from
Covid19..CovidDeaths
where continent is not null
order by 3,4

--select * from Covid19..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date,total_cases, new_cases, total_deaths, population
from Covid19..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying you contract covid in your country

select location, date,total_cases,total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
from Covid19..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from Covid19..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from Covid19..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Showing the Countries with highest death count per population

select location, population,max(cast(total_deaths as float)) as TotalDeathCount, max((cast(total_deaths as float)/population))*100 as PercentDeath
from Covid19..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

select location,max(cast(total_deaths as float)) as TotalDeathCount
from Covid19..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
from Covid19..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Covid19..CovidVaccinations vac
left join Covid19..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
order by 2,3

--USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Covid19..CovidVaccinations vac
left join Covid19..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Covid19..CovidVaccinations vac
left join Covid19..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
--where dea.continent is not null
--order by 2,3

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating a View to store data for later visualizations


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Covid19..CovidVaccinations vac
left join Covid19..CovidDeaths dea
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
