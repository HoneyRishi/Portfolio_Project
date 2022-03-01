SELECT * 
FROM SQLProject..['covid-death]
Where continent is not null
order by 3,4

--SELECT * 
--FROM SQLProject..[covid vaccinations]
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM SQLProject..['covid-death]
Where continent is not null
order by 1,2

--calculating Death Percentage

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM SQLProject..['covid-death]
where location = 'India'
 and continent is not null
order by 1,2

--Percentage of Population infected

SELECT location, date, total_cases,population,(total_cases/population)*100 as Infecction_Percentage
FROM SQLProject..['covid-death]
where location = 'India'
and continent is not null
order by 1,2

--Highest infection rate of countries

SELECT location,population, Max( total_cases) as highest_infected_count,Max((total_cases/population))*100 as Infecction_Percentage
FROM SQLProject..['covid-death]
--where location like '%India%'
Where continent is not null
Group by location, population
order by Infecction_Percentage desc

--countries with highest death count per population


SELECT location, population, Max(cast(total_deaths as int)) as Total_death_counts
FROM SQLProject..['covid-death]
--where location like '%India%'
Group by location, population
order by Total_death_counts desc

--continents with highest death count percetage

SELECT continent, population, Max(cast(total_deaths as int)) as Total_death_counts
FROM SQLProject..['covid-death]
--where location like '%India%'
Where continent is not null
Group by continent, population
order by Total_death_counts desc

--New cases globally

Select date, SUM(new_cases) as New_Cases_per_day, SUM(cast(new_deaths as int)) as New_deaths_per_day, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Persentage_per_day
from SQLProject..['covid-death]
where continent is not null
Group by date

--joining two tables 

select * from SQLProject..[covid vaccinations] vac
join SQLProject..['covid-death] dea
on dea.location=vac.location
and dea.date=vac.date

--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by Dea.location, dea.date) as total_vaccination
 from SQLProject..[covid vaccinations] vac
join SQLProject..['covid-death] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and
vac.new_vaccinations is not null
order by 2,3
--use CTE 
--total % of vaccinated population
with popvsvac (continent, location ,date, population, new_vaccination, Total_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by Dea.location, dea.date) as total_vaccination
 from SQLProject..[covid vaccinations] vac
join SQLProject..['covid-death] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and
vac.new_vaccinations is not null
--order by 2,3
)
select *, (Total_vaccination/population)*100 
from popvsvac

or
--temp.table 
Drop table if exists #perecentpopulationvaccinated
Create Table #perecentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccination numeric
)
Insert into #perecentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by Dea.location, dea.date) as total_vaccination
 from SQLProject..[covid vaccinations] vac
join SQLProject..['covid-death] dea
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null and
--vac.new_vaccinations is not null
--order by 2,3
select *, (Total_vaccination/population)*100 
from #perecentpopulationvaccinated

--store data for view later 

Create view perecent_populationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by Dea.location, dea.date) as total_vaccination
 from SQLProject..[covid vaccinations] vac
join SQLProject..['covid-death] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
select *, (Total_vaccination/population)*100 
from popvsvac