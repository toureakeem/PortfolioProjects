SELECT *
FROM CovidDeaths
-- where continent is not null AND TRIM(continent) <> ''


-- SELECT *
-- FROM CovidVaccinations
-- ORDER BY 3 , 4


select *
from CovidDeaths


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null AND TRIM(continent) <> ''
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths


Select Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null AND TRIM(continent) <> ''
and location like '%kingdom%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Showing percentage of population that got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null AND TRIM(continent) <> ''
and location like '%kingdom%'
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
-- where continent is not null AND TRIM(continent) <> ''
-- and location like '%kingdom%'
group by Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with the highest death Count per population

SELECT Location, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM CovidDeaths
where continent is not null AND TRIM(continent) <> ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- break it down into continent

SELECT continent, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM CovidDeaths
where  continent is not null AND TRIM(continent) <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM CovidDeaths
where  continent is not null AND TRIM(continent) <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths

where continent is not null AND TRIM(continent) <> ''
-- and location like '%kingdom%'
-- group by date
ORDER BY 1,2

-- Looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null AND TRIM(dea.continent) <> ''
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null AND TRIM(dea.continent) <> ''
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating vew to store dta for later visualizations

create view HighestDeathcount as

SELECT continent, MAX(cast(total_deaths as signed)) AS TotalDeathCount
FROM CovidDeaths
where  continent is not null AND TRIM(continent) <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC

create view HighestInfectionRate as

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
-- where continent is not null AND TRIM(continent) <> ''
-- and location like '%kingdom%'
group by Location, Population
ORDER BY PercentPopulationInfected desc

create view PopulationPercentage as

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null AND TRIM(continent) <> ''
and location like '%kingdom%'
ORDER BY 1,2

create view PopulationVsVaccination as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null AND TRIM(dea.continent) <> ''
order by 2,3
