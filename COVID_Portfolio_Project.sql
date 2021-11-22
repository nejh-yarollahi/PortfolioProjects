
select *

from PortfolioProject..CovidDeathsNew

order by 3, 4;

go


--select *

--from PortfolioProject..CovidVaccinationsNew

--order by 3, 4;

--go


select location, date, total_cases, new_cases, total_deaths, population

from PortfolioProject..CovidDeathsNew

order by 1, 2;

go


-- Looking at Total Cases vs Total Deaths For Iran

select location, date, total_cases, total_deaths,
	   (cast (total_deaths as float)/ cast(total_cases as float)) * 100 as DeathPercentage

from PortfolioProject..CovidDeathsNew

where location like 'Iran'

order by 1, 2;


-- Looking at Total Cases vs Population For Iran

select location, date, population, total_cases, 
	   (cast (total_cases as float)/ population) * 100 as InfectionRate

from PortfolioProject..CovidDeathsNew

where location like 'Iran'

order by 1, 2;


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(cast (total_cases as float)) as HighestInfectionCount, 
	   max(cast (total_cases as float)/ population) * 100 as PercentPopulationInfected

from PortfolioProject..CovidDeathsNew

group by location, population

order by 4 desc;


-- Showing Countries with Highest Death Count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount

from PortfolioProject..CovidDeathsNew

where continent is not null

group by location

order by 2 desc;

go


-- Let's Break Things by Continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount

from PortfolioProject..CovidDeathsNew

where continent is not null

group by continent

order by 2 desc;

go


-- Global Numbers

select date, sum(cast(new_cases as float)) as Total_cases, sum(cast(new_deaths as float)) as Total_deaths,
	   sum(cast (new_deaths as float))/ sum(cast(new_cases as float)) * 100 as DeathPercentage

from PortfolioProject..CovidDeathsNew

-- where location like 'Iran'
where location is not null
and date <> '2020-01-22'

group by date

order by 1;

go


-- Looking at Total Vaccinations vs Population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(float, vac.new_vaccinations)) over 
		(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeathsNew dea

join PortfolioProject..CovidVaccinationsNew vac

	on dea.location = vac.location

	and dea.date = vac.date

where dea.continent is not null

-- and dea.location like 'Iran'

order by 2, 3;

go


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

as (

	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		   sum(convert(float, vac.new_vaccinations)) over 
		   (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

	from PortfolioProject..CovidDeathsNew dea

	join PortfolioProject..CovidVaccinationsNew vac

		on dea.location = vac.location

		and dea.date = vac.date

	where dea.continent is not null

	-- and dea.location like 'Iran'

	-- order by 2, 3 

)

select *, (RollingPeopleVaccinated/population) * 100 as RollPeopleVacperPop

from PopvsVac;


-- Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated (

Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(float, vac.new_vaccinations)) over 
		(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeathsNew dea

join PortfolioProject..CovidVaccinationsNew vac

	on dea.location = vac.location

	and dea.date = vac.date

where dea.continent is not null

-- and dea.location like 'Iran'

-- order by 2, 3 

select *, (RollingPeopleVaccinated/population) * 100 as RollPeopleVacperPop

from #PercentPopulationVaccinated;


-- Creating View to store date for later Visualizations

create view PercentPopVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(float, vac.new_vaccinations)) over 
		(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeathsNew dea

join PortfolioProject..CovidVaccinationsNew vac

	on dea.location = vac.location

	and dea.date = vac.date

where dea.continent is not null

-- and dea.location like 'Iran'

-- order by 2, 3;

go