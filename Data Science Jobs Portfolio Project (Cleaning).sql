Select *
From PortfolioProject..DataScienceJobs

-- Clean up salary estimate column

Update PortfolioProject..DataScienceJobs
Set salary_estimate_thousands_usd = Replace(salary_estimate_thousands_usd, '$', '')

Update PortfolioProject..DataScienceJobs
Set salary_estimate_thousands_usd = Replace(salary_estimate_thousands_usd, 'K', '')

-- Create seperate column for salary estimate source

Alter Table PortfolioProject..DataScienceJobs
Add salary_estimate_source nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set salary_estimate_source = Case When salary_estimate_thousands_usd like '%(Glassdoor est.)' Then 'Glassdoor'
								  When salary_estimate_thousands_usd like '%(Employer est.)' Then 'Employer'
								  Else Null
							 End 

Update PortfolioProject..DataScienceJobs
Set salary_estimate_thousands_usd = Case When salary_estimate_thousands_usd like '%(Glassdoor%'
											  Then Replace(salary_estimate_thousands_usd, '(Glassdoor est.)', '')
										 When salary_estimate_thousands_usd like '%(Employer%'
											  Then Replace(salary_estimate_thousands_usd, '(Employer est.)', '')
									End

-- Break out salary estimate into minimum and maximum salary estimates

Alter Table PortfolioProject..DataScienceJobs
Add min_salary_estimate_thousands_usd nvarchar(255)

Alter Table PortfolioProject..DataScienceJobs
Add max_salary_estimate_thousands_usd nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set min_salary_estimate_thousands_usd = Substring(salary_estimate_thousands_usd, 1, CharIndex('-', 
	salary_estimate_thousands_usd)-1)

Update PortfolioProject..DataScienceJobs
Set max_salary_estimate_thousands_usd= Substring(salary_estimate_thousands_usd, CharIndex('-', 
	salary_estimate_thousands_usd)+1, Len(salary_estimate_thousands_usd) - CharIndex('-', 
	salary_estimate_thousands_usd))

Update PortfolioProject..DataScienceJobs
Set min_salary_estimate_thousands_usd = Convert(int, min_salary_estimate_thousands_usd)

Update PortfolioProject..DataScienceJobs
Set max_salary_estimate_thousands_usd = Convert(int, max_salary_estimate_thousands_usd)

-- Remove ratings that have values outside of 0-5 range

Update PortfolioProject..DataScienceJobs
Set rating = Case When rating < 0 or rating > 5 Then Null
				  Else rating
			 End 

-- Remove ratings from company_name column

Select Distinct company_name
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set company_name = Trim(Trailing '0123456789.0123456789' From company_name)

-- Clean up location column

Select Distinct location
From PortfolioProject..DataScienceJobs
Where location not like '%,%'

Update PortfolioProject..DataScienceJobs
Set location = Case When location = 'California' Then 'CA'
					When location = 'New Jersey' Then 'NJ'
					When location = 'Texas' Then 'TX'
					When location = 'Utah' Then 'UT'
					When location = 'United States' Then Null 
					Else location
			   End 

-- Seperate location into city and state columns

Alter Table PortfolioProject..DataScienceJobs
Add location_city nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set location_city = Case When location like '%,%' Then Substring(location, 1, CharIndex(',', location)-1)
						 When location = 'Remote' Then 'Remote'
						 Else Null
					End 

Alter Table PortfolioProject..DataScienceJobs
Add location_state nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set location_state = Case When location like '%,%' then Substring(location, CharIndex(',', location)+1, Len(location))
						  Else location
					 End

-- Clean up headquarters column

Select Distinct headquarters
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set headquarters = Case When headquarters = '-1' Then Null
						When headquarters like '%061%' Then Replace(headquarters, '061', 'NY')
						Else headquarters
				   End 

Alter Table PortfolioProject..DataScienceJobs
Add headquarters_city nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set headquarters_city = Substring(headquarters, 1, CharIndex(',', headquarters)-1)

Alter Table PortfolioProject..DataScienceJobs
Add headquarters_state_or_country nvarchar(255)

Update PortfolioProject..DataScienceJobs
Set headquarters_state_or_country = Substring(headquarters, CharIndex(',', headquarters)+1, Len(headquarters))

-- Clean up employees/size column

Update PortfolioProject..DataScienceJobs
Set employees = Replace(employees, 'to', '-')

Update PortfolioProject..DataScienceJobs
Set employees = Case When employees = 'Unknown' or employees = '-1' Then Null
				     When employees like '%employees%' Then Substring(employees, 1, CharIndex('e', employees)-2)
				End

Update PortfolioProject..DataScienceJobs
Set employees = Replace(employees, ' ', '')

-- Clean up founded column

Select Distinct founded
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set founded = Case When founded = '-1' Then Null
				   Else founded
			  End

-- Clean up type of ownership column

Select Distinct type_of_ownership
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set type_of_ownership = Case When type_of_ownership in ('-1', 'Unknown') Then Null
							 Else type_of_ownership
						End 

-- Clean up industry column

Select Distinct industry
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set industry = Case When industry = '-1' Then Null
					Else industry
			   End 

-- Clean up sector column

Select Distinct sector
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set sector = Case When sector = '-1' Then Null
					Else sector
			 End 

-- Clean up revenue column

Select Distinct revenue
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set revenue = Case When revenue in ('-1', 'Unknown / Non-Applicable') Then Null
							 Else revenue
			  End 

-- Clean up competitors column

Select Distinct competitors
From PortfolioProject..DataScienceJobs

Update PortfolioProject..DataScienceJobs
Set competitors = Case When competitors = '-1' Then Null
					   Else competitors
			      End 

-- Remove columns that are not needed

Alter Table DataScienceJobs
Drop Column location, headquarters, salary_estimate_thousands_usd