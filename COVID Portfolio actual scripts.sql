Select *
From Portfolio..['covid deaths']
where continent is not null
order by 3,4

Select *
From Portfolio..['covid vaccinations']
order by 3,4


--Select data that were using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..['covid deaths']
order by 1,2


-- Total Cases vs Total Deaths
--shows likelihood of covid death contraction in US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..['covid deaths']
where location like '%states%'
order by 1,2

--Total cases vs Population
--percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..['covid deaths']
where location like '%states%'
order by 1,2

--countries with Highes infectiion rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..['covid deaths']
--where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


--Shows Countries w Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..['covid deaths']
--where location like '%states%'
where continent is not null
Group by Location 
order by TotalDeathCount desc

--break things down by Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..['covid deaths']
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc


--show continents with highest death counts per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..['covid deaths']
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc

--global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio..['covid deaths']
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['covid deaths'] dea
Join Portfolio..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['covid deaths'] dea
Join Portfolio..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TempTable

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['covid deaths'] dea
Join Portfolio..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--creating view to store data for later vizualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..['covid deaths'] dea
Join Portfolio..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated