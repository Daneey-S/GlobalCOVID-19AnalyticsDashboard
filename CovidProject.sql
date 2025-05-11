select *
from CovidProject..CovidDeaths
where continent is not null 
order by 3,4

select *
from CovidProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from CovidProject..CovidDeaths
where continent is not null 
order by 1,2

-- percentage of deaths that where infected

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from CovidProject..CovidDeaths
where (continent is not null) AND (location like '%India%')
order by 1,2

-- percentage of total cases

select location, population, total_cases as HighestInfactionCount,(total_cases/population)*100 as InfectedPercent
from CovidProject..CovidDeaths
where (continent is not null) AND (location like '%India%')
order by 1,2

select location, population, max(total_cases) as HighestInfactionCount,(max(total_cases)/population)*100 as TotalInfectedPercent
from CovidProject..CovidDeaths
where continent is not null 
group by location, population
order by TotalInfectedPercent desc

--Highset Death Count

select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc

-- Total Deaths by contenent  

select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is null 
group by location
order by TotalDeathCount desc

-- Total death percentage global

select date, sum(new_cases)as CasesGlobal, sum(cast(new_deaths as int)) as DeathsGlobal,(sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathPercent
from CovidProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases)as CasesGlobal, sum(cast(new_deaths as int)) as DeathsGlobal,(sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathPercent
from CovidProject..CovidDeaths
where continent is not null
order by 1,2

-- Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea
join CovidProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to find people vaccinated with respect to poulation 
with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea
join CovidProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated 
from PopvsVac


--Using Temp Table to find people vaccinated with respect to poulation 

Drop Table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea
join CovidProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated 
from #PercentPopulationVaccinated

-- Creating VIEW to store data for later visualizations 

Create view PercentPopulationVaccinated 
as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths as dea
join CovidProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated


--Queries used for Tableau 

-- 1
select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from CovidProject..CovidDeaths
where continent is not null
order by 1,2

-- 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- 5
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- 6
Select Location, date, population, total_cases, total_deaths
From CovidProject..CovidDeaths
where continent is not null 
order by 1,2

-- 7
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac
