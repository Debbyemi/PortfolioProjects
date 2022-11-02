select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

-- Total cases vs total death

select location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths
where location like '%nigeria%'
order by 1,2

-- Total cases vs population

select location,population,total_cases,total_deaths,(total_cases/population)*100 as PercentagePopulationInfected from CovidDeaths
--where location like '%nigeria%'
order by 1,2

--countries with highest infection rate compared to population
select location,population,max(total_cases) as highestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected from CovidDeaths
--where location like '%nigeria%'
group by location, population
order by PercentagePopulationInfected desc


--showing countries with the highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location, population
order by TotalDeathCount desc--showing countries with the highest death count per population

--Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2 

 --Looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths dea
Join CovidVacinations vac
on dea.location = vac.location and dea.date = vac.date
--where location like '%nigeria%'
where dea.continent is not null
order by 2,3

--use CTE
with VacVsPops(continent, location, date, population,new_vaccinations,RollingPeopleVacinated) as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths dea
Join CovidVacinations vac
on dea.location = vac.location and dea.date = vac.date
--where location like '%nigeria%'
where dea.continent is not null
--order by 2,3
) select *, (RollingPeopleVacinated/population)*100 from VacVsPops


--using temp table

create table #PercentagePopulationVacinated
(continent nvarchar (225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric) 
insert into #PercentagePopulationVacinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths dea
Join CovidVacinations vac
on dea.location = vac.location and dea.date = vac.date
--where location like '%nigeria%'
where dea.continent is not null
--order by 2,3
 select *, (RollingPeopleVacinated/population)*100 from #PercentagePopulationVacinated

 
--using temp table

Drop table if exists #PercentagePopulationVacinated
create table #PercentagePopulationVacinated
(continent nvarchar (225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric) 
insert into #PercentagePopulationVacinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths dea
Join CovidVacinations vac
on dea.location = vac.location and dea.date = vac.date
--where location like '%nigeria%'
--where dea.continent is not null
--order by 2,3
 select *, (RollingPeopleVacinated/population)*100 from #PercentagePopulationVacinated


 -- creating view to store data for later visualizations

 create view PercentagePopulationVacinated as
 select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
--, total_deaths, max(total_cases/total_deaths)*100 as DeathPercentage 
from CovidDeaths dea
Join CovidVacinations vac
on dea.location = vac.location and dea.date = vac.date
--where location like '%nigeria%'
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVacinated