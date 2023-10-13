Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
Order By 3,4 

-- Select data that is to be used for first few queries

Select continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 2,3

-- Total cases in each country as of May 2021

Select location, Max(total_cases) as EndTotal 
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By location
Order By EndTotal Desc

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelyhood of dying if you contract Covid in any given country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Canada' and continent is not null
Order by 1,2

-- Percentage of population in each country that contracted COVID as of May 2021 

Select location, population, Round((Max(total_cases)/population), 4)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By ContractionPercentage Desc

-- Number of people in each country who died after contracting COVID  as of May 2021

Select location, Max(Convert(int, total_deaths)) as CountryDeaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population
Order By CountryDeaths Desc

-- Percentage of contractors in each country who died 

Select location, Round((Sum(Cast(new_deaths as int))/Sum(new_cases)),4)*100 as DeathPct
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By DeathPct Desc

-- Number of new cases in each month of 2020 for Canada

Select Month(date) as month, Sum(new_cases) as cases
From PortfolioProject..CovidDeaths
Where Year(date) = 2020 and location='Canada'
Group By Month(date)

-- Top 3 months with the most number of cases for each continent in 2020

With TopThreeMonths as
(Select continent, Month(date) as month, Sum(new_cases) as cases, Rank() Over (Partition By continent
		Order By Sum(new_cases) Desc) as rank
 From PortfolioProject..CovidDeaths
 Where Year(date)=2020 and continent is not null
 Group By continent, Month(date))

Select *
From TopThreeMonths
Where rank <= 3

-- Running percentage of total cases in Canada during 2020 over each month

Select dea.location, sub.month, sub.tot_cases as cases_month, Max(dea.total_cases) as cases_2020,
Round((sub.tot_cases/Max(dea.total_cases))*100, 4) as pct_cases_2020
From PortfolioProject..CovidDeaths dea
Join (
	  Select location, Month(date) as month, Max(total_cases) as tot_cases
	  From PortfolioProject..CovidDeaths dea
	  Where Year(date) = 2020 and location = 'Canada'
	  Group By location, Month(date)
	  ) sub
On dea.location=sub.location
Where dea.date < '2021-01-01'
Group By dea.location, sub.month, sub.tot_cases

-- Look at vaccinations data

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
Order By 3,4

-- Rolling percentage of Canadian population getting vaccinated

With CTE as 
(Select dea.continent as Continent, dea.location as Location, dea.date as Date, dea.population  as Population,
		vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) Over 
		(Partition By dea.Location Order By dea.date) as RollingPeopleVaccinated	
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac on 
	 dea.location=vac.location and dea.date=vac.date
Where dea.location='Canada')

Select *, (RollingPeopleVaccinated/Population)*100 as PctPeopleVaccinated
From CTE

-- Using a temp table

Drop Table if exists #PopVaccinationPct
Create Table #PopVaccinationPct
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PopVaccinationPct
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) Over 
	   (Partition By dea.location Order By dea.date) as RollingPeopleVaccinated	   
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
Where dea.location = 'Canada'

Select *, (RollingPeopleVaccinated/population)*100 as PctPeopleVaccinated
From #PopVaccinationPct

--------------------------------------------------------------------------------












