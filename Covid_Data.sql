
use SQL_Covid_Data;
SELECT * FROM CovidDeaths;

SELECT * FROM SQL_Covid_Data..CovidVaccinations
order by 3,4;

select *from SQL_Covid_Data..CovidDeaths;

-- select data that we are gonna use
SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS 
FROM CovidDeaths
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT LOCATION, DATE, TOTAL_CASES, total_deaths, (TOTAL_DEATHS / TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE (TOTAL_DEATHS / TOTAL_CASES)*100 is not null
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS in particular location
SELECT LOCATION, DATE, TOTAL_CASES, total_deaths, (TOTAL_DEATHS / TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE (TOTAL_DEATHS / TOTAL_CASES)*100 is not null and location like '%India%'
order by date ;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS in particular location comparision using UNION
SELECT LOCATION, DATE, TOTAL_CASES, total_deaths, (TOTAL_DEATHS / TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE (TOTAL_DEATHS / TOTAL_CASES)*100 is not null and location like '%India%'
union 
SELECT LOCATION, DATE, TOTAL_CASES, total_deaths, (TOTAL_DEATHS / TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE (TOTAL_DEATHS / TOTAL_CASES)*100 is not null and location like 'United States'
ORDER BY date desc;

--
exec sp_columns CovidDeaths;
alter table covidDeaths 
alter column population float;
alter column total_cases float

--Looking at total cases vs population
-- show what population got covid
SELECT LOCATION, DATE, population, TOTAL_CASES, (TOTAL_cases/Population)*100 AS cases_to_population
FROM CovidDeaths
WHERE TOTAL_cases is not null
ORDER BY 1,2 ;

-- looking at countries with highest infection rate compared to population
SELECT distinct LOCATION, population, max(total_cases) as hihghestInfectedCount,round(max((TOTAL_cases / population))*100 , 4) AS percentage_population_infected
FROM CovidDeaths
where location like '%States'
group by location, population
ORDER BY percentage_population_infected desc;

-- showing countries with highest death count per population
select location , max(total_deaths) as total_death_count
from CovidDeaths 
where continent is not null
group by location 
order by total_death_count desc;

-- showing continents with counties death count on population
select continent,location,population, max(total_deaths) as total_death_count
from CovidDeaths 
where continent is not null 
group by location , continent , population
order by population desc;

--GLOBAL NUMBERS EACH DAY
SELECT  DATE, SUM(NEW_CASES) AS NUMBER_OF_CASES_EVERYDAY --TOTAL_CASES, total_deaths, ROUND((TOTAL_DEATHS / TOTAL_CASES)*100,3) AS DEATH_PERCENTAGE ,
FROM CovidDeaths
where continent is not null AND TOTAL_CASES is not null AND TOTAL_DEATHS is not null 
GROUP BY DATE
ORDER BY DATE;


select  * from CovidDeaths
where continent is not null
order by 3,4;

-- showing continents with counties death count on population
select continent, max(total_deaths) as total_death_count
from CovidDeaths 
where continent is not null 
group by  continent 
order by total_death_count desc;

-- total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from coviddeaths d 
join covidvaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null and v.new_vaccinations <> 0
order by 3,5;

-- total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from coviddeaths d 
join covidvaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;

-- use cte

with popvsvac (continent, location, date, population, new_vaccination, rolling_people_vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from coviddeaths d 
join covidvaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3;
)
select *, (rolling_people_vaccinated/population)*100 
from popvsvac
--where rolling_people_vaccinated is not null

-- Temp Table

drop table if exists Percentage_population_vaccinnated
Create Table Percentage_population_vaccinnated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

insert into Percentage_population_vaccinnated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from coviddeaths d 
join covidvaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null

select *, (rolling_people_vaccinated/population)*100 
from Percentage_population_vaccinnated

-- creating view to store data for later visualization

create view Percentage_population_vaccinnated_view as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from coviddeaths d 
join covidvaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null