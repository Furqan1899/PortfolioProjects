
SELECT * FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--show likelihood of dying if your contract covid in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathspercentage
FROM PortfolioProject..CovidDeaths
where location like '%Indonesia%'
and continent is not null
order by 1,2

--total cases vs population
select location, date,population, total_cases,  (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
where location like '%Indonesia%'
and continent is not null
order by 1,2

--countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestPopulationInfectionCount,  MAX((total_cases/population))*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
--where location like '%Indonesia%'
where continent is not null
group by  location, population
order by CasePercentage desc 

--SHowing countries with highest death counts per population
select location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%Indonesia%'
where continent is not null
group by  location
order by totalDeathCount desc 

--Continent with highest death counts per population
select continent, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%Indonesia%'
where continent is not null
group by  continent
order by totalDeathCount desc 

--GLOBAL NUMBERS
select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%Indonesia%'
where continent is not null
--group by  date
order by 1,2

--looking total populatin vs vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER(PARTITION by DEA.location ORDER BY DEA.location, DEA.date ) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

	WHERE DEA.continent is not null
	ORDER BY 2,3

--USE CTE

with PopvsVac(continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)

as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER(PARTITION by DEA.location ORDER BY DEA.location, DEA.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

	WHERE DEA.continent is not null
	--ORDER BY 2,3
) 

SELECT * , (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
FROM PopvsVac


--TEMP Table
DROP TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar (255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )



INSERT INTO #PercentPopulationVaccinated

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER(PARTITION by DEA.location ORDER BY DEA.location, DEA.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

	--WHERE DEA.continent is not null
	--ORDER BY 2,3

	SELECT * , (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER(PARTITION by DEA.location ORDER BY DEA.location, DEA.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

	WHERE DEA.continent is not null
	--ORDER BY 2,3

	SELECT * FROM PercentPopulationVaccinated