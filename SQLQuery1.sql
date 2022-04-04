--select*from PortfolioProject..CovidVaccinations
--order by 3,4

select*from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Looking at Total cases vs Population
--Shows what percent of the population got covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like 'India'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectedCount , max(total_cases/population)*100 as HighestInfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc


--Looking at Countries with Highest Death Count compared to Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

--Looking at things by continents

--Looking at Continents with Highest Death Count

GO
create view v1 as 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by 2 desc offset 0 rows
GO

create view v2 as
select continent, max(cast(total_deaths as int)) as TotalDeathCount1
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc offset 0 rows
GO

select*from v1
select*from v2

GO
create view v3 as
select location,TotalDeathCount+TotalDeathCount1 as TotalDeathCount from v1,v2
where location=continent
order by TotalDeathCount desc offset 0 rows
GO

select*from v3

-- GLOBAL NUMBERS

select date, sum(new_cases) Totalcases, sum(cast(new_deaths as bigint)) TotalDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) Totalcases, sum(cast(new_deaths as bigint)) TotalDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from 
PortfolioProject..CovidVaccinations vac join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent,Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from 
PortfolioProject..CovidVaccinations vac join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3 offset 0 rows
)
select*, (RollingPeopleVaccinated/Population)*100 from PopvsVac
