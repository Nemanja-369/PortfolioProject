use PortfolioProject

select *
from coviddeaths
where continent is not null
order by 3,4

--select *
--from covidvaccinations
--order by 3,4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

--Looking total_cases vs total_deaths
--Show likelihood od dying if you contract covid in you country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from coviddeaths
where location like'%state%'
and continent is not null
order by 1,2

--in Serbia
select top(100)location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from coviddeaths
where location like'ser%'
order by 1,2

--Looking total_cases vs population
--Show what percentage of population got covid
select location, date, population,total_cases,  (total_cases/population)*100 as PercentpopulationInfected
from coviddeaths
where continent is not null
order by 1,2

--Looking at countriest with highest infection rate compared to population
select location, population,max(total_cases)as HighestInfectionCount,  max((total_cases/population))*100 as PercentpopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentpopulationInfected desc

--Showing countries with highest death count per population.
select location,max(cast(Total_deaths as int))as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Let's break things down by continent

select location,max(cast(Total_deaths as int))as TotalDeathCount
from coviddeaths
where continent is null
group by location
order by TotalDeathCount desc

select continent,max(cast(Total_deaths as int))as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

select continent,max(cast(Total_deaths as int))as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from coviddeaths
--where location like'%state%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from coviddeaths
--where location like'%state%'
where continent is not null
--group by date
order by 1,2


select *
from covidvaccinations

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location)
from coviddeaths as dea
join covidvaccinations as vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--convert (bigint)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*10 as 
from coviddeaths as dea
join covidvaccinations as vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE

with Popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*10 as 
from coviddeaths as dea
join covidvaccinations as vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as h
from Popvsvac

--Temp.table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinacions numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths as dea
join covidvaccinations as vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*10 as 
from coviddeaths as dea
join covidvaccinations as vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as h
from PercentPopulationVaccinated
