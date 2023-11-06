select *
from CovidDeaths
where continent is not null
order by 3,4


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100
AS Deathpercentage
from CovidDeaths
where location like '%Nigeria%'
order by 1,2



--Looking at Total cases vs Population
--Showhs what percentage of the population got covid

select Location, date, population, total_cases,  (total_cases/population)*100 as PercentageofPopulationInfected
from CovidDeaths
where location like '%States%'
order by PercentageofPopulationInfected desc


--select Location, date, population, total_cases,
--(CONVERT(float,total_cases)/NULLIF(CONVERT(float, population),0))*100
--AS PercentageofPopulationInfected
--from CovidDeaths
--where location like '%States%'
--order by PercentageofPopulationInfected desc



--Looking at Countries with highest infection rate compared to population

select Location, population, max(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentageofPopulationInfected
from CovidDeaths
--where location like '%States%'
Group by location, population
order by PercentageofPopulationInfected desc


--select Location, population, max(total_cases) as HighestInfectionCount,
--max((CONVERT(float,total_cases)/NULLIF(CONVERT(float, population),0)))*100
--AS PercentageofPopulationInfected
--from CovidDeaths
----where location like '%States%'
--group by location, population



--Showing Countries with Highest Death count per population


select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%States%'
where continent is not null
Group by location
order by TotalDeathCount desc



--Breaking things down by continent


select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%States%'
where continent is not null
Group by Continent
order by TotalDeathCount desc




--Showing the Continents with the highest Death count per population

select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%States%'
where continent is not null
Group by Continent
order by TotalDeathCount desc


--Global Numbers


select SUM(New_cases) as Total_Cases, 
sum(new_deaths) as Total_Deaths,
sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

--Overall Death Percentage


select SUM(New_cases) as Total_Cases, 
sum(new_deaths) as Total_Deaths,
sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null
order by 2,3

--To partition by location and date


select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations)
over (Partition by CD.location order by CD.location, CD.date)
as RollingPeopleVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null
order by 2,3

----To convert New Vaccinations to integer


--select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
--sum(cast(CV.new_vaccinations as int)) over (Partition by CD.location)
--from CovidDeaths CD
--join CovidVaccinations CV
--on CD.location = CV.location 
--and CD.date = CV.date
--where CD.continent is not null
--order by 2,3

----OR


--select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
--sum(convert(int, CV.new_vaccinations))
--FROM CovidDeaths CD
--join CovidVaccinations CV
--on CD.location = CV.location 
--and CD.date = CV.date
--where CD.continent is not null
--order by 2,3



--Use CTE
--Pop is Population and Vac is Vaccination

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations)
over (Partition by CD.location order by CD.location, CD.date)
as RollingPeopleVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac





--TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations)
over (Partition by CD.location order by CD.location, CD.date)
as RollingPeopleVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store for later visualization

Create View PercentPopulationVaccinated as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations)
over (Partition by CD.location order by CD.location, CD.date)
as RollingPeopleVaccinated
from CovidDeaths CD
join CovidVaccinations CV
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null

select * 
from PercentPopulationVaccinated


CREATE VIEW ContinentsWithHighestDeathCount  AS
select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%States%'
where continent is not null
Group by Continent


select *
from ContinentsWithHighestDeathCount

