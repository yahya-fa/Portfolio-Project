
Select * From portofolio_project..CovidDeaths
where continent is not null
Order by 3,4

--Select * From portofolio_project..CovidVaccinations
--Order by 3,4


-- looking at total cases vs total death
-- showing percentage of death by number of cases
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portofolio_project..CovidDeaths
where location = 'Indonesia' 
order by 1,2

--looking at total cases vs population
-- showing percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as populationInfectedPercentage
from portofolio_project..CovidDeaths
where location = 'Indonesia'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population)*100 as populationInfectedPercentage
from portofolio_project..CovidDeaths
where continent is not null
group by location, population
order by populationInfectedPercentage desc

-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portofolio_project..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- showing continent with highest death count per population
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portofolio_project..CovidDeaths
where continent is not null and location not in ('World', 'European Union', 'International')
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from portofolio_project..CovidDeaths
where continent is not null
order by 1,2

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portofolio_project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- population vs vaccinated
select die.continent, die.location, die.date, die.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by die.location order by die.location, die.date) as RollingPeopleVaccinated
from portofolio_project..CovidDeaths as die
join portofolio_project..CovidVaccinations as vac
	on die.location = vac.location
	and die.date = vac.date
where die.location is not null
order by 2,3

-- USE CTE
with popvsvac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select die.continent, die.location, die.date, die.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by die.location order by die.location, die.date) as RollingPeopleVaccinated
from portofolio_project..CovidDeaths as die
join portofolio_project..CovidVaccinations as vac
	on die.location = vac.location
	and die.date = vac.date
where die.location is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from popvsvac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select die.continent, die.location, die.date, die.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by die.location order by die.location, die.date) as RollingPeopleVaccinated
from portofolio_project..CovidDeaths as die
join portofolio_project..CovidVaccinations as vac
	on die.location = vac.location
	and die.date = vac.date
--where die.location is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

--create view for visualizations
create view PercentPopulationVaccinated as
select die.continent, die.location, die.date, die.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by die.location order by die.location, die.date) as RollingPeopleVaccinated
from portofolio_project..CovidDeaths as die
join portofolio_project..CovidVaccinations as vac
	on die.location = vac.location
	and die.date = vac.date
where die.location is not null
--order by 2,3

select * from PercentPopulationVaccinated

