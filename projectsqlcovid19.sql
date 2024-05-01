--looking at the data which I gonna use
select * from PortfolioProject..CovidDeaths order by 3,4

select * from PortfolioProject..CovidDeaths order by 1,2


--change data type of total_cases and total_deaths
use PortfolioProject
alter table CovidDeaths
alter column total_cases float
alter table CovidDeaths
alter column total_deaths float

--shows likelilhood of dying
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--totaldeaths/totalcases in the world
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as
DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--
select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
group by location, population, date
order by Percentpopulationinfected desc

--totalcases and population
select location, date, population, total_cases, (total_cases/population)*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--countries with highest infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount,  max((total_cases/population)*100) as Percentpopulationinfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percentpopulationinfected desc

--countries with highest death count per population
select location, population, max(total_deaths) as highestdeath, max((total_deaths/population)*100) as DeathperPopulation
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by DeathperPopulation desc

--continents with highest death count
select location, max(total_deaths) as highestdeath
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%' and location not like '%union%'
group by location
order by highestdeath desc

--global numbers and totalcases+totaldeaths by location and totalcases+totaldeaths by continent
select date, sum(new_cases) as TotalNC, sum(new_deaths) as TotalND
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select location, max(total_cases) as totalcases, max(total_deaths) as totaldeaths,
round((nullif(max(total_deaths),0)/nullif(max(total_cases),0))*100, 3) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by location

select location, max(total_cases) as totalcases, max(total_deaths) as totaldeaths,
round((nullif(max(total_deaths),0)/nullif(max(total_cases),0))*100, 3) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income' and location not like '%union'
group by location
order by DeathPercentage desc


----looking at the data which I gonna use
select * from PortfolioProject..CovidVaccinations order by 3,4

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date


--sum of new_vaccinations and percentagevaccinatedperpopu

with popuandvaccinated (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100 as PercentageVaccinatedperPopu
from popuandvaccinated
order by 2,3

--view for data visualization later
create view PercentPopuVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
