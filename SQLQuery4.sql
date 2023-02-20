Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4
--Select the data that i am going to use

Select location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--looking at  total cases vs total deathe
--shows liklihood of dying in Egypt
Select location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths
Where location like '%Egypt%'
and continent is not null
Order by 1,2

-- looking at total cases vs population
-- shows what percentage of population  got covid

Select location, Date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
Order by 1,2

--looking at countries with highest infection rate compared with population

Select location, max(total_cases) as HighstInfectionCount, population, max((total_cases/population))*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
Group by location, population
Order by percentpopulationinfected desc

-- showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
Group by location
Order by TotalDeathCount desc


Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is null
Group by location
Order by TotalDeathCount desc

--break it down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- showing the continent with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global numbers

Select date, sum(new_cases) as GlobalInfectedCases, sum(cast(new_deaths as int)) as GlobalDeathsCaese, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPrecentage
from PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
Group by date
Order by 1,2

Select sum(new_cases) as GlobalInfectedCases, sum(cast(new_deaths as int)) as GlobalDeathsCaese, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPrecentage
from PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
--Group by date
Order by 1,2

Select *
From PortfolioProject..CovidVaccinations

--join the tables

Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
on dea.location = vac.location and dea. date = vac.date

--Total population vs total vaccination
-- use CET

With PopvsVac (continent, date, location, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
on dea.location = vac.location and dea. date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMB TABLE

Drop table if exists #PercentofPopulationVaccinated
create table #PercentofPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentofPopulationVaccinated
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
on dea.location = vac.location and dea. date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentofPopulationVaccinated

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidDeaths vac
on dea.location = vac.location and dea. date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated