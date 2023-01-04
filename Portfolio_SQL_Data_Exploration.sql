SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Selecting data to be used on the project

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

-- Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From CovidDeaths
Order By 1,2

-- Shows likelihood of dying over time if you contract covid in Brazil (my country)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From CovidDeaths
Where location like '%Brazil%'
Order By 1,2

-- Exploring Total Cases vs Population
-- Shows the percentage of population that got Covid
Select location, date, total_cases, population, (total_cases/population)*100 As InfectionPercentage
From CovidDeaths
Where location like '%Brazil%'
Order By 1,2

-- Countries with the highest infection rates compared to population

Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population)*100) As InfectionPercentage
From CovidDeaths
Group By location, population
Order By InfectionPercentage Desc

-- Countries with the highest death count
Select location, MAX(Cast(Total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount Desc

-- Looking by continent
Select location, MAX(Cast(Total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent is null 
Group By location
Order By TotalDeathCount Desc
-- Another option removing World, European Union and International (not actual continents)
Select continent, SUM(Cast(new_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent is not null 
Group By continent
Order By TotalDeathCount Desc

-- Countries with the highest death count compared to population
Select location, population, MAX(Cast(Total_deaths as int)) As TotalDeathCount, MAX((total_deaths/population)*100) As DeathPercentage
From CovidDeaths
Where continent is not null
Group By location, population
Order By DeathPercentage Desc

-- GLOBAL NUMBERS

-- Analysing Death % per day
Select date, sum(new_cases) As Cases, sum(Cast(new_deaths as int)) As Deaths, (sum(Cast(new_deaths as int))/sum(new_cases))*100 As DeathPercentage
From CovidDeaths
Where continent is not null
Group By date
Order By 1

-- Total death % over the pandemic period so far
Select sum(new_cases) As Total_Cases, sum(Cast(new_deaths as int)) As Total_Deaths, (sum(Cast(new_deaths as int))/sum(new_cases))*100 As DeathPercentage
From CovidDeaths
Where continent is not null

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) As Total_Vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Using CTE to look at vaccinations percentage in Brazil
With PopvsVac (continent, location, date, population, new_vaccinations, Total_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) As Total_Vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Total_Vaccinations/population)*100 as PercentVaccination
From PopvsVac
Where location = 'Brazil'

-- Create view for later data visualization
Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) As Total_Vaccinations
From CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null