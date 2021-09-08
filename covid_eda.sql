SELECT *
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE continent!=''
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-eda-3252222.covid_data.covid-deaths`
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE location like '%States%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what % of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE location like '%States%'
ORDER BY 1,2;

-- Looking at countries w/ highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM `covid-eda-3252222.covid_data.covid-deaths`
-- WHERE location like '%States%'
WHERE continent!=''
GROUP BY Location, population
ORDER BY percent_population_infected desc;

-- Showing countries w/ highest death count per population

SELECT location, MAX(total_deaths) as total_death_count
FROM `covid-eda-3252222.covid_data.covid-deaths`
-- WHERE location like '%States%'
WHERE continent!=''
GROUP BY Location
ORDER BY total_death_count desc;

--LET'S BREAK THINGS DOWN BY CONTINENT
--showing continent w/ highest death count

SELECT location, MAX(total_deaths) as total_death_count
FROM `covid-eda-3252222.covid_data.covid-deaths`
-- WHERE location like '%States%'
WHERE continent=''
GROUP BY location
ORDER BY total_death_count desc;

SELECT continent, MAX(total_deaths) as total_death_count
FROM `covid-eda-3252222.covid_data.covid-deaths`
-- WHERE location like '%States%'
WHERE continent!=''
GROUP BY continent
ORDER BY total_death_count desc;

--GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM `covid-eda-3252222.covid_data.covid-deaths`
--WHERE location like '%States%'
WHERE continent!=''
GROUP BY date
ORDER BY 1,2;

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date)
     as rolling_people_vacc,
     --(rolling_people_vacc/population)*100
FROM `covid-eda-3252222.covid_data.covid-deaths` dea
JOIN `covid-eda-3252222.covid_data.covid-vaccinations` vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent!=''
ORDER BY 2,3;

--USE CTE

WITH pop_vs_vac
AS (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date)
     as rolling_people_vacc,
     --(rolling_people_vacc/population)*100
FROM `covid-eda-3252222.covid_data.covid-deaths` dea
JOIN `covid-eda-3252222.covid_data.covid-vaccinations` vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent!=''
--ORDER BY 2,3
)
SELECT *, (rolling_people_vacc/population)*100
FROM pop_vs_vac;

--creating view to store for later visualizations

CREATE VIEW covid-eda-3252222.covid_data.pop_vs_vac AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date)
     as rolling_people_vacc,
     --(rolling_people_vacc/population)*100
FROM `covid-eda-3252222.covid_data.covid-deaths` dea
JOIN `covid-eda-3252222.covid_data.covid-vaccinations` vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent!='';

CREATE VIEW covid-eda-3252222.covid_data.highest_death_pop AS
SELECT location, MAX(total_deaths) as total_death_count
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE continent!=''
GROUP BY Location
ORDER BY total_death_count desc;

CREATE VIEW `covid-eda-3252222.covid_data.total_deaths_continent` AS
SELECT continent, MAX(total_deaths) as total_death_count
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE continent!=''
GROUP BY continent
ORDER BY total_death_count desc;

CREATE VIEW `covid-eda-3252222.covid_data.cases_vs_deaths` AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `covid-eda-3252222.covid_data.covid-deaths`
WHERE location like '%States%'
ORDER BY 1,2;

CREATE VIEW `covid-eda-3252222.covid_data.highest_infection_count` AS
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM `covid-eda-3252222.covid_data.covid-deaths`
-- WHERE location like '%States%'
WHERE continent!=''
GROUP BY Location, population
ORDER BY percent_population_infected desc; 
