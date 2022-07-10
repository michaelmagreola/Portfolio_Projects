Select *
From Portfolio_Project..CovidDeaths$
order by 3,4



--Selecting data that we are using

Select Location,date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in your country

Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
where location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows what percentage of population got Covid

Select Location,date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as
PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
	



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)	
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
	
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View PercentPopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationvaccinated