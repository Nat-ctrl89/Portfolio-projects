
--SELECT * FROM dbo.CovidDeaths$


--SELECT * FROM dbo.CovidVaccinations$


Select location, date, total_cases, new_cases, total_cases, population
From dbo.CovidDeaths$
order by 1,2

--Shows likelihood of dying if contract covid in your country
select Location, date, Population, total_cases, (total_cases/Population)*100
from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total cases against Population
--Shows the Population that has gotten covid
select location, date,total_cases, Population, total_cases,(total_cases/Population)*100 as Deathpercentage
from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate
select location, population, Max(total_cases) as HighInfections
from dbo.CovidDeaths$
group by Location, Population
--Looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighInfections, Max(total_cases/Population) as Prcentpopinfected
from dbo.CovidDeaths$
group by Location, Population
order by Prcentpopinfected desc

--Showing countries with highest death count per population
select location, population, Max(cast(Total_deaths as int)) as TotalD_count
from dbo.CovidDeaths$
where continent is not null
group by location, population
order by TotalD_count desc

--Breaking by continent
select continent, Max(cast(Total_deaths as int)) as TotalD_count
from dbo.CovidDeaths$
where continent is not null
group by continent 
order by TotalD_count desc

--Showing continents with the highest death count per population
select continent, Max(cast(total_deaths as int)) as TD
from dbo.CovidDeaths$
where continent is not null
group by continent 
order by TD desc

--Gloabl Numbers
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_cases)*100 as Death_percent
From dbo.CovidDeaths$
order by 1,2


select * 
From dbo.CovidVaccinations$ as dea
Join dbo.CovidDeaths$ as vac
On dea.location = vac.location
and dea.date= vac.date

--Total amount of people that have been vaccinated 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
		and dea.date = vac.date
	 where dea.continent is not null 
	--order by 2,3 
	)
--CTE
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table to perform Calculation

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 