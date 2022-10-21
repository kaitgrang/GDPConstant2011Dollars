#these are the packages that you will need to have installed/run
#install.packages("WDI")
library(WDI)
library(tidyverse)
library(dplyr)
library(janitor)
library(readxl)
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#UPDATING GDP (CONSTANT 2011) IN THE INTERNATIONAL FUTURE'S MODEL (IFs):

#BACKGROUND:

  #Quarterly, we update the GDP series in IFs by using a special process that involves pulling data from the World Bank and the IMF.
  #The GDP values we have in IFs are based on constant 2011 prices, whereas the World Bank is based on constant 2010 prices.
  #If one country has a different World Bank historical value, all the countries must be updated.
    #Why?: (1) We do not necessarily know which country's historical series was revised. (2) If we have a method to update one or do not not which changed, we update all anyway.

#THREE SOURCES:

  #For this process, three sources are required:
    # Primary Source: WORLD BANK DEVELOPMENT INDICATORS (WDI)
      # GDP in US Current $:  https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
      # GDP Growth (based on constant price ):https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG

    # Secondary & Forecasting Source: IMF World Economic Outlook (WEO)
      # GDP in US Current $
      # GDP Growth (Based on Constant Price)
      # GDP Growth Rates (Still Constant Price)

  #Use of the Three Sources:
    # WORLD BANK GDP in US Current $
      # We use WB GDP values in current $ as the primary source to establish the 2011 constant $GDP base.
      # We start by pulling the most up to date GDP value for the year 2011 for all countries.
      # From here, we apply GDP growth rates to the 2011 GDP value both into the future and historically.
      # IF the World Bank doesn't have 2011 GDP data for certain countries, use IMF values, if there are no IMF values, we pull from IFs.
    # WORLD BANK GDP Growth (Annual %) Constant Price
      # The World Bank has GDP growth data from 1960 to the current year -1 (ie. if it is 2021, the Worl Bank will have data from 1960 to the current year)
      # If a country does not have full coverage, use IMF GDP growth rates. Though, the IMF only has historical vales back to 1980; therefore, we use IFs GDP growth rates to cover the rest of the missing historical values.
      # NOTE: not all countries will have data back to 1960, this is because some countries did not exist until later in time. 
    # IMF GDP in US Current $
      # As stated above, we use IMF GDP for those countries that are not covered or are missing from the World Bank. 
      # For example, the World Bank does not have data for Taiwan. In this case we would use the 2011 Current GDP from the IMF
    # IMF GDP Growth (Annual %) Constant Price
      # As stated above, we use IMF GDP growth rates as a secondary source when the WB does not have data both into the future and historically
      # We use IMF growth rates starting from the last available year from the WB (EX: if WB ends in 2018, start 2019 with IMF growth rate OR if WB ends in 1999, start in 1998 with IMF growth rate)
      # The IMF also publishes forecasts of GDP growth rates 5 years into the future (EX: if it is 2021, they have GDP growth rates into 2026). We want to include these forecasts in our data. This is where it can get tricky. The IMF updates its forecasts for big economies twice a year (in April and July). 
      # These updates are only for big economies (usually around 30 countries) and only include revisions for the next 2 years. 
      # Going back to our example, if IMF releases forecasts for 2022-2026, the years 2022 and 2023 will be updated twice a year, but the following growth rates remain the same.
      # Be careful when updating forecasts and remember to check for IMF revisions. 
      # If there are not IMF values (i.e., North Korea and Syria) then find a source with a value (i.e., CIA Factbook). We use that source to fill-in the missing data and extrapolate, assuming say, no growth is occurring in Syria at all. Reliable ones are hard to come across, for these, but we still want to have values at least in IFs.
    # IFs GDP and Growth Rates
      # We use IFs GDP VALUES when the World Bank and IMF do not have coverage for a country when establishing the 2011 base.
      # We use IFS GDP GROWTH RATES when the World Bank and IMF do not have historical coverage.
      # IFs DOES NOT have historical GDP growth variables from which we can pull directly.
      # HOWEVER, we can calculate growth rates from the historical GDP Values
      # How to do this...

#HOW TO CALCULATE GDP GROWTH RATES FROM IFs

  #open IFs, on the top list of features navigate to FLEXIBLE DISPLAYS 
  #select DISPLAY FORMAT from the menu
  #select USE ALL AVAILABLE HISTORICAL DATA
  #choose the variable "GDP (MER), HISTORY AND FORECAST - BILLION DOLLARS". This variable is based on seriesGDP2011
  #to check that you are pulling the proper data, select LIST FEATURES then EXPLAIN LIST and make sure that the Historic Analg read GDP2011
  #we don't want to forecast, only use data, so make sure your horizon is not set into the future (TIP: data in IFs appears in blue while forecasts appear in black)
  #now, select all the countries by highlighting Afghanistan (or the first country listed) and dragging to the bottom
  #click the table option and the table should be displaying the GDP values.
  #in order to get GDP growth, we need to know the percent change from year to year
  #IFs can calculate this for you, select DISPLAY OPTIONS, then PERCENT
  #now your dataset is complete
  #from here, you can save your data as a csv to use in R later *make sure the csv file is saved in the same directory as your working directory in R

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------

#EXAMPLE 1: AFGHANISTAN

  #the following can be copied for every country in IFs, we just need to change some values
    #lines of code that need to have individualized values for each country will follow the code with a #***

  #first we will get GDP in Current $ and GDP Growth (Annual %) from the World Bank; can do this either through the WDI package in R or from the World Bank's website and save as a .csv

  #GDP (current US $): https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
  GDP <- WDI(indicator=c("NY.GDP.MKTP.CD"))
  #next, delete countries that aren't in IFs:
  GDP <- GDP %>% filter(country != "Africa Eastern and Southern" & country !="Africa Western and Central" & country != "American Samoa" & country != "Andorra"& country != "Antigua and Barbuda" & country != "Arab World" & country != "Aruba" & country != "Bermuda" & country != "British Virgin Islands" & country != "Caribbean small states" & country != "Cayman Islands" & country != "Central Europe and the Baltics" & country != "Channel Islands" & country != "Curacao" & country != "Dominica" & country != "Early-demographic dividend" & country != "East Asia & Pacific" & country != "East Asia & Pacific (excluding high income)" & country != "East Asia & Pacific (IDA & IBRD countries)" & country != "Euro area" & country != "Europe & Central Asia" & country != "Europe & Central Asia (excluding high income)" & country != "Europe & Central Asia (IDA & IBRD countries)" & country != "European Union" & country != "Faroe Islands" & country != "Fragile and conflict affected situations" & country != "French Polynesia" & country != "Gibraltar" & country != "Greenland" & country != "Guam"& country != "Heavily indebted poor countries (HIPC)" & country != "High income" & country != "IBRD only" & country != "IDA & IBRD total" & country != "IDA blend" & country != "IDA only" & country != "IDA total" & country != "Isle of Man" & country != "Kiribati" & country != "Late-demographic dividend" & country !="Latin America & Caribbean" & country != "Latin America & Caribbean (excluding high income)" & country != "Latin America & the Caribbean (IDA & IBRD countries)" & country != "Least developed countries: UN classification" & country != "Lichtenstein" & country != "Low & middle income" & country != "Low income" & country != "Lower middle income" & country != "Macao SAR, China" & country != "Marshall Islands" & country != "Middle East & North Africa" & country != "Middle East & North Africa (excluding high income)" & country != "Middle East & North Africa (IDA & IBRD countries)" & country != "Middle income" & country != "Monaco" & country != "Nauru" & country != "New Caledonia" & country != "North America" & country != "Northern Mariana Islands" & country != "Not classified" & country != "OECD members" & country != "Other small states" & country != "Pacific island small states" & country != "Palau" & country != "Post-demographic dividend" & country != "Pre-demographic dividend"& country != "San Marino" & country != "Saint Maarten (Dutch part)" & country != "Small states"& country !="South Asia"& country !="South Asia (IDA & IBRD)"& country !="St. Kitts and Nevis"& country !="St. Martin (French part)" & country != "Sub-Saharan Africa" & country != "Sub-Saharan Africa (excluding high income)" & country != "Sub-Saharan Africa (IDA & IBRD countries)" & country != "Turks and Caicos Islands" & country != "Tuvalu" & country != "Upper middle income" & country != "Virgin Islands (U.S.)" & country != "World")
  #replace the names of countries to their IFs counterparts:
  GDP$country[GDP$country=="Brunei Darussalam"]<-"Brunei"
  GDP$country[GDP$country=="Cabo Verde"]<-"Cape Verde"
  GDP$country[GDP$country=="Congo, Dem. Rep."]<-"Congo, Democratic Republic of"
  GDP$country[GDP$country=="Congo, Rep."]<-"Congo, Republic of"
  GDP$country[GDP$country=="Egypt, Arab Rep."]<-"Egypt, Arab Republic of"
  GDP$country[GDP$country=="Eswatini"]<-"Swaziland"
  GDP$country[GDP$country=="Hong Kong SAR, China"]<-"Hong Kong"
  GDP$country[GDP$country=="Iran, Islamic Rep."]<-"Iran, Islamic Republic of"
  GDP$country[GDP$country=="Korea, Dem. People's Rep."]<-"Korea, Democratic People's Republic of"
  GDP$country[GDP$country=="Korea, Rep."]<-"Korea Republic of"
  GDP$country[GDP$country=="Lao PDR"]<-"Laos, People's Democratic Republic"
  GDP$country[GDP$country=="North Macedonia"]<-"Macedonia, Former Yugoslav Republic of"
  GDP$country[GDP$country=="South Sudan"]<-"Sudan South"
  GDP$country[GDP$country=="Venezuela, RB"]<-"Venezuela"
  GDP$country[GDP$country=="West Bank and Gaza"]<-"Palestine"
  GDP$country[GDP$country=="Yemen, Rep."]<-"Yemen, Republic of"
  
  #GDP Growth (annual %): https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG
  GDPgrowth <- WDI(indicator=c("NY.GDP.MKTP.KD.ZG"))
  #next, delete countries that aren't in IFs:
  GDPgrowth <- GDPgrowth %>% filter(country != "Africa Eastern and Southern" & country !="Africa Western and Central" & country != "American Samoa" & country != "Andorra"& country != "Antigua and Barbuda" & country != "Arab World" & country != "Aruba" & country != "Bermuda" & country != "British Virgin Islands" & country != "Caribbean small states" & country != "Cayman Islands" & country != "Central Europe and the Baltics" & country != "Channel Islands" & country != "Curacao" & country != "Dominica" & country != "Early-demographic dividend" & country != "East Asia & Pacific" & country != "East Asia & Pacific (excluding high income)" & country != "East Asia & Pacific (IDA & IBRD countries)" & country != "Euro area" & country != "Europe & Central Asia" & country != "Europe & Central Asia (excluding high income)" & country != "Europe & Central Asia (IDA & IBRD countries)" & country != "European Union" & country != "Faroe Islands" & country != "Fragile and conflict affected situations" & country != "French Polynesia" & country != "Gibraltar" & country != "Greenland" & country != "Guam"& country != "Heavily indebted poor countries (HIPC)" & country != "High income" & country != "IBRD only" & country != "IDA & IBRD total" & country != "IDA blend" & country != "IDA only" & country != "IDA total" & country != "Isle of Man" & country != "Kiribati" & country != "Late-demographic dividend" & country !="Latin America & Caribbean" & country != "Latin America & Caribbean (excluding high income)" & country != "Latin America & the Caribbean (IDA & IBRD countries)" & country != "Least developed countries: UN classification" & country != "Lichtenstein" & country != "Low & middle income" & country != "Low income" & country != "Lower middle income" & country != "Macao SAR, China" & country != "Marshall Islands" & country != "Middle East & North Africa" & country != "Middle East & North Africa (excluding high income)" & country != "Middle East & North Africa (IDA & IBRD countries)" & country != "Middle income" & country != "Monaco" & country != "Nauru" & country != "New Caledonia" & country != "North America" & country != "Northern Mariana Islands" & country != "Not classified" & country != "OECD members" & country != "Other small states" & country != "Pacific island small states" & country != "Palau" & country != "Post-demographic dividend" & country != "Pre-demographic dividend"& country != "San Marino" & country != "Saint Maarten (Dutch part)" & country != "Small states"& country !="South Asia"& country !="South Asia (IDA & IBRD)"& country !="St. Kitts and Nevis"& country !="St. Martin (French part)" & country != "Sub-Saharan Africa" & country != "Sub-Saharan Africa (excluding high income)" & country != "Sub-Saharan Africa (IDA & IBRD countries)" & country != "Turks and Caicos Islands" & country != "Tuvalu" & country != "Upper middle income" & country != "Virgin Islands (U.S.)" & country != "World")
  #replace the names of countries to their IFs counterparts:
  GDPgrowth$country[GDPgrowth$country=="Brunei Darussalam"]<-"Brunei"
  GDPgrowth$country[GDPgrowth$country=="Cabo Verde"]<-"Cape Verde"
  GDPgrowth$country[GDPgrowth$country=="Congo, Dem. Rep."]<-"Congo, Democratic Republic of"
  GDPgrowth$country[GDPgrowth$country=="Congo, Rep."]<-"Congo, Republic of"
  GDPgrowth$country[GDPgrowth$country=="Egypt, Arab Rep."]<-"Egypt, Arab Republic of"
  GDPgrowth$country[GDPgrowth$country=="Eswatini"]<-"Swaziland"
  GDPgrowth$country[GDPgrowth$country=="Hong Kong SAR, China"]<-"Hong Kong"
  GDPgrowth$country[GDPgrowth$country=="Iran, Islamic Rep."]<-"Iran, Islamic Republic of"
  GDPgrowth$country[GDPgrowth$country=="Korea, Dem. People's Rep."]<-"Korea, Democratic People's Republic of"
  GDPgrowth$country[GDPgrowth$country=="Korea, Rep."]<-"Korea Republic of"
  GDPgrowth$country[GDPgrowth$country=="Lao PDR"]<-"Laos, People's Democratic Republic"
  GDPgrowth$country[GDPgrowth$country=="North Macedonia"]<-"Macedonia, Former Yugoslav Republic of"
  GDPgrowth$country[GDPgrowth$country=="South Sudan"]<-"Sudan South"
  GDPgrowth$country[GDPgrowth$country=="Venezuela, RB"]<-"Venezuela"
  GDPgrowth$country[GDPgrowth$country=="West Bank and Gaza"]<-"Palestine"
  GDPgrowth$country[GDPgrowth$country=="Yemen, Rep."]<-"Yemen, Republic of"

  #next, we will merge these data frames together to make one data frame:
  completedataframe <- cbind.data.frame(GDP,GDPgrowth$NY.GDP.MKTP.KD.ZG)
  #we can use the completedataframe from above for every country; we just need to filter out the specific country
  
  #create a new data frame with only Afghanistan:
  Afghanistanexample <- completedataframe %>% filter(country == "Afghanistan") 
  #since Afghanistan is missing growth rate values from 1960 to 2001, we will get those from IFs following the instructions above
  Afghanistanmissinggrowthrates <- read.csv("IFsGDP.csv") 
  #IMPORTANT: we will be able to use this same csv file from IFs for every country and just filter out the country we need below
  #since we haven't changed the .csv we downloaded directly from IFs we need to format it to match our other data frames:
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates %>% row_to_names(row_number = 1)
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates[-1,]
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates[-1,]
  colnames(Afghanistanmissinggrowthrates)[1] <- "year"
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates %>% select("year","Afghanistan")
  Afghanistanmissinggrowthrates <- transform(Afghanistanmissinggrowthrates, year = as.numeric(year))
  #since our data frame above begins with 1960, we are going to flip it to match the Afghanistanexample dataframe so 1960 is the last row
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates %>% map_df(rev)
  #we are now going to change the column names:
  colnames(Afghanistanmissinggrowthrates)[2] <- "gdpgrowth"
  colnames(Afghanistanmissinggrowthrates)[1] <- "year"
  #and change the column names in the Afghanistan example to match, so that it is easier to blend the two data frames:
  colnames(Afghanistanexample)[5] <- "gdpgrowth" #NOTE: the five refers to the position of the column that you want to change the name of
  #we are now going to filter the year of the missing growth rates to begin before 2003, since growth rates are missing from 1960-2002 for Afghanistan (this will change with each country)
  Afghanistanmissinggrowthrates <- Afghanistanmissinggrowthrates %>% filter(year<2003)  #*** use the year after the last missing year here (since 2002 is the last missing year for Afghanistan we use 2003 here)
  #now we are going to replace the all of the NA values in "Afghanistanexample" with the missing values from IFs:
  Afghanistanexample <- Afghanistanexample %>% left_join(Afghanistanmissinggrowthrates,by=c("year")) %>% mutate(gdppgrowth = ifelse(is.na(gdpgrowth.x), gdpgrowth.y, gdpgrowth.x)) %>% select(-c(gdpgrowth.x, gdpgrowth.y))  
    # --> to double check that the growth rates line up, see if the 2003 GDP growth aligned with the World Bank's & if the 2002,2001,2000 growth rates align with the IFs values
  Afghanistanexample <- transform(Afghanistanexample, gdppgrowth = as.numeric(gdppgrowth))
  
  #As stated earlier, the IMF releases growth rates five years into the future. So, we will use the growth rates to forecast GDP from 2021 to the year most available in the future:
  #get the forecasted growth rates from the IMF WEO: https://www.imf.org/external/datamapper/NGDP_RPCH@WEO/OEMDC/ADVEC/WEOWORLD
  #we are going to scroll down and select "ALL COUNTRY DATA" -> "EXCEL FILE" and save that to wherever our working directory is in R
  IMFgrowthrates <- read_excel("IMFgrowthrates.xls")
  #since the first row is empty we will delete this:
  IMFgrowthrates <- IMFgrowthrates[-1,]
  #missing data is listed in the excel file as "no data" we need to turn that into NA to use:
  is.na(IMFgrowthrates) <- IMFgrowthrates == "no data"
  #filter out the years before 2021 since we already have those growth rates. IMPORTANT: look to see what the first and last years are , in this example it is 2021 & 2027
  IMFgrowthrates <- IMFgrowthrates %>% select("Real GDP growth (Annual percent change)", "2021","2022","2023","2024","2025","2026","2027") #***
  #filter out Afghanistan 
  IMFgrowthrates <- IMFgrowthrates %>% filter(`Real GDP growth (Annual percent change)`== "Afghanistan") #***
  IMFgrowthrates <- as.data.frame(t(IMFgrowthrates))
  IMFgrowthrates <- IMFgrowthrates %>% row_to_names(row_number = 1) 
  IMFgrowthrates$year <- row.names(IMFgrowthrates)
  IMFgrowthrates <- IMFgrowthrates[,c(2,1)]
  colnames(IMFgrowthrates)[2] <- "gdppgrowth"
  #NOTE: in this example the IMF didn't have values for Afghanistan so it will be NA 
  
  #next we will begin calculating the GDP in constant 2011 values using both forward and backward calculations; forward calculations for years after 2011 and backward calculations for years before 2011
  
  #forward calculations (2012-present):
  #formula: next year = (previous year's GDP * (100 + growth rate of year solving for)) / 100
  #ex: 2012 (GDP 2011 $) = (2011 GDP * (100 + 2012 growth rate)) / 100
  forwardcalculation <- Afghanistanexample %>% filter(year >= 2011)
  #we need to delete 2021 from the Afghanistanexample as the growth rate is missing from there but its in the IMFs
  forwardcalculation <- forwardcalculation[-1,]
  #since we are going to be using a for loop, we will need to reverse the order of the data frame so 2011 is at the top and the current year is at the bottom
  forwardcalculation <- forwardcalculation[nrow(forwardcalculation):1,]
  forwardcalculation <- forwardcalculation %>% select(year,gdppgrowth)
  #combine the forward calculation with the IMF forecasted growth rates:
  forwardcalculation <- rbind(forwardcalculation,IMFgrowthrates)
  rownames(forwardcalculation) <- NULL
  forwardcalculation$sreturnsloop <- 0
  #IMPORTANT: Will need to change the replace value in the next line of code (in this example 17805113119 for Afghanistan) for the 2011 GDP value for each individual country
  forwardcalculation$sreturnsloop<-replace(forwardcalculation$sreturnsloop, 1, 17805113119) #*** will need to change the 2011 GDP value for each country
  forwardcalculation <- transform(forwardcalculation, gdppgrowth = as.numeric(gdppgrowth))
  for(j in 2:nrow(forwardcalculation)){
    forwardcalculation$sreturnsloop[j] <- (forwardcalculation$sreturnsloop[j-1] * (100 + forwardcalculation$gdppgrowth[j])) / 100
  }
  
  
  #backward calculations (1960-2010):
  #formula: previous year = (gdp of next year / (100 + growth rate of next year)) * 100
  #ex: 2010 (GDP 2011 $) = (2011 GDP / (100 + 2011 growthrate)) * 100
  backwardcalculation <- Afghanistanexample %>% filter(year <= 2011)
  #since we use the next year's growth rate we shift the growth rate down so 2011's growth rate will be next to 2010, to do this we make 1960 equal to NA so we won't need 1960's growth rate anyways 
  is.na(backwardcalculation$gdppgrowth) <- backwardcalculation$year == 1960
  backwardcalculation$gdppgrowth <- lag(backwardcalculation$gdppgrowth)
  #use a for loop to fill in the rest of the GDP
  backwardcalculation$sreturnsloop <- 0
  # The for-loop will run from row 2 to nrow, i.e. the last row; so we need to fill in the 2011 value with its GDP
  backwardcalculation$sreturnsloop<-replace(backwardcalculation$sreturnsloop, 1, 17805113119) #*** will need to change the 2011 GDP value for each country
  for(i in 2:nrow(backwardcalculation)){
    backwardcalculation$sreturnsloop[i] <- (backwardcalculation$sreturnsloop[i-1] / (100 + backwardcalculation$gdppgrowth[i])) * 100
  }
  
  #next we will bind the two data frames together again
  #filter out just the calculated GDPs from the forward calculation and backward calculation
  forwardcalculation <- forwardcalculation %>% select(year,sreturnsloop)
  backwardcalculation <- backwardcalculation %>% select(year,sreturnsloop)
  #next transpose the data frames so the years are the name of the column:
  forwardcalculation <- t(forwardcalculation)
  backwardcalculation <- backwardcalculation %>% filter(year!=2011)
  backwardcalculation <- backwardcalculation[nrow(backwardcalculation):1,]
  backwardcalculation <- t(backwardcalculation)
  #next combine the data frames:
  GDPAfghanistan <- cbind(backwardcalculation,forwardcalculation)
  #make the first year with rows as your column names:
  GDPAfghanistan <- GDPAfghanistan %>% row_to_names(row_number = 1)
  #rename the column sreturnsloop to Afghanistan (change the name for each country):
  row.names(GDPAfghanistan) <- "Afghanistan"
  
  #GDPAfghanistan is your completed data frame with all the years in 2011 GDP calculated
  #you can save this as a .csv to open in excel to combine all countries in there, or you can keep it in R to combine all the dataframes in the end and then save it as a .csv!
  
  #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  #EXAMPLE 2: ALBANIA
  
  #since Afghanistan doesn't have forecast gdp growth rates, we will do an example for Albania
  #we will copy and paste the above code and change everything to Albania's values (these will be the lines of code with a *** next to them)
  #also rename the dataframes (ex: change Afghanistanmissinggrowthrates to Albaniamissinggrowthrates)
  
  #IMPORTANT: clear out the objects "backwardcalculation", "forwardcalculation", & "IMFgrowthrates" from the workspace since these still have Afghanistan's values saved in them; can do this by typing rm("backwardcalculation") in the console
  
  Albaniaexample <- completedataframe %>% filter(country == "Albania") 
  
  #since Albania is missing growth rate values from 1960 to 1980, we will get those from IFs following the instructions above
  Albaniamissinggrowthrates <- read.csv("IFsGDP.csv") 
  #IMPORTANT: we will be able to use this same csv file from IFs for every country and just filter out the country we need below
  #since we haven't changed the .csv we downloaded directly from IFs we need to format it to match our other data frames:
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates %>% row_to_names(row_number = 1)
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates[-1,]
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates[-1,]
  colnames(Albaniamissinggrowthrates)[1] <- "year"
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates %>% select("year","Albania") #***
  Albaniamissinggrowthrates <- transform(Albaniamissinggrowthrates, year = as.numeric(year))
  #since our data frame above begins with 1960, we are going to flip it to match the Afghanistanexample dataframe so 1960 is the last row
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates %>% map_df(rev)
  #we are now going to change the column names:
  colnames(Albaniamissinggrowthrates)[2] <- "gdpgrowth"
  colnames(Albaniamissinggrowthrates)[1] <- "year"
  #and change the column names in the Afghanistan example to match, so that it is easier to blend the two data frames:
  colnames(Albaniaexample)[5] <- "gdpgrowth" #NOTE: the five refers to the position of the column that you want to change the name of
  #we are now going to filter the year of the missing growth rates to begin before 1981, since growth rates are missing from 1960-1981 for Albania (this will change with each country)
  Albaniamissinggrowthrates <- Albaniamissinggrowthrates %>% filter(year<1981)  #***  use the year after the last missing year here (since 1980 is the last missing year for Albania we use 1980 here)
  #now we are going to replace the all of the NA values in "Afghanistanexample" with the missing values from IFs:
  Albaniaexample <- Albaniaexample %>% left_join(Albaniamissinggrowthrates,by=c("year")) %>% mutate(gdppgrowth = ifelse(is.na(gdpgrowth.x), gdpgrowth.y, gdpgrowth.x)) %>% select(-c(gdpgrowth.x, gdpgrowth.y))  
  # --> to double check that the growth rates line up, see if the 2003 GDP growth aligned with the World Bank's & if the 2002,2001,2000 growth rates align with the IFs values
  Albaniaexample <- transform(Albaniaexample, gdppgrowth = as.numeric(gdppgrowth))
  
  # As stated earlier, the IMF releases growth rates five years into the future. So, we will use the growth rates to forecast GDP from 2021 to the year most available in the future:
  #get the forecasted growth rates from the IMF WEO: https://www.imf.org/external/datamapper/NGDP_RPCH@WEO/OEMDC/ADVEC/WEOWORLD
  #we are going to scroll down and select "ALL COUNTRY DATA" -> "EXCEL FILE" and save that to wherever our working directory is in R
  IMFgrowthrates <- read_excel("IMFgrowthrates.xls")
  #since the first row is empty we will delete this:
  IMFgrowthrates <- IMFgrowthrates[-1,]
  #missing data is listed in the excel file as "no data" we need to turn that into NA to use:
  is.na(IMFgrowthrates) <- IMFgrowthrates == "no data"
  #filter out the years before 2021 since we already have those growth rates. IMPORTANT: look to see what the first and last years are , in this example it is 2021 & 2027
  IMFgrowthrates <- IMFgrowthrates %>% select("Real GDP growth (Annual percent change)", "2021","2022","2023","2024","2025","2026","2027") #***
  #filter out Afghanistan 
  IMFgrowthrates <- IMFgrowthrates %>% filter(`Real GDP growth (Annual percent change)`== "Albania") #***
  IMFgrowthrates <- as.data.frame(t(IMFgrowthrates))
  IMFgrowthrates <- IMFgrowthrates %>% row_to_names(row_number = 1) 
  IMFgrowthrates$year <- row.names(IMFgrowthrates)
  IMFgrowthrates <- IMFgrowthrates[,c(2,1)]
  colnames(IMFgrowthrates)[2] <- "gdppgrowth"
  #NOTE: in this example the IMF didn't have values for Afghanistan so it will be NA 
  
  
  #next we will begin calculating the GDP in constant 2011 values using both forward and backward calculations; forward calculations for years after 2011 and backward calculations for years before 2011
  
  #forward calculations (2012-present):
  #formula: next year = (previous year's GDP * (100 + growth rate of year solving for)) / 100
  #ex: 2012 (GDP 2011 $) = (2011 GDP * (100 + 2012 growth rate)) / 100
  forwardcalculation <- Albaniaexample %>% filter(year >= 2011) #***
  #we need to delete 2021 from the Afghanistanexample as the growth rate is missing from there but its in the IMFs
  forwardcalculation <- forwardcalculation[-1,]
  #since we are going to be using a for loop, we will need to reverse the order of the data frame so 2011 is at the top and the current year is at the bottom
  forwardcalculation <- forwardcalculation[nrow(forwardcalculation):1,]
  forwardcalculation <- forwardcalculation %>% select(year,gdppgrowth)
  #combine the forward calculation with the IMF forecasted growth rates:
  forwardcalculation <- rbind(forwardcalculation,IMFgrowthrates)
  rownames(forwardcalculation) <- NULL
  forwardcalculation$sreturnsloop <- 0
  #IMPORTANT: Will need to change the replace value in the next line of code (in this example 17805113119 for Afghanistan) for the 2011 GDP value for each individual country
  forwardcalculation$sreturnsloop<-replace(forwardcalculation$sreturnsloop, 1, 12890764531) #*** will need to change the 2011 GDP value for each country (this is found in the Afghanistanexample)
  forwardcalculation <- transform(forwardcalculation, gdppgrowth = as.numeric(gdppgrowth))
  for(j in 2:nrow(forwardcalculation)){
    forwardcalculation$sreturnsloop[j] <- (forwardcalculation$sreturnsloop[j-1] * (100 + forwardcalculation$gdppgrowth[j])) / 100
  }
  
  #backward calculations (1960-2010):
  #formula: previous year = (gdp of next year / (100 + growth rate of next year)) * 100
  #ex: 2010 (GDP 2011 $) = (2011 GDP / (100 + 2011 growthrate)) * 100
  backwardcalculation <- Albaniaexample %>% filter(year <= 2011)
  #since we use the next year's growth rate we shift the growth rate down so 2011's growth rate will be next to 2010, to do this we make 1960 equal to NA so we won't need 1960's growth rate anyways 
  is.na(backwardcalculation$gdppgrowth) <- backwardcalculation$year == 1960
  backwardcalculation$gdppgrowth <- lag(backwardcalculation$gdppgrowth)
  #use a for loop to fill in the rest of the GDP
  backwardcalculation$sreturnsloop <- 0
  # The for-loop will run from row 2 to nrow, i.e. the last row; so we need to fill in the 2011 value with its GDP
  backwardcalculation$sreturnsloop<-replace(backwardcalculation$sreturnsloop, 1, 12890764531) #*** will need to change the 2011 GDP value for each country
  for(i in 2:nrow(backwardcalculation)){
    backwardcalculation$sreturnsloop[i] <- (backwardcalculation$sreturnsloop[i-1] / (100 + backwardcalculation$gdppgrowth[i])) * 100
  }
  
  #next we will bind the two data frames together again
  #filter out just the calculated GDPs from the forward calculation and backward calculation
  forwardcalculation <- forwardcalculation %>% select(year,sreturnsloop)
  backwardcalculation <- backwardcalculation %>% select(year,sreturnsloop)
  #next transpose the data frames so the years are the name of the column:
  forwardcalculation <- t(forwardcalculation)
  backwardcalculation <- backwardcalculation %>% filter(year!=2011)
  backwardcalculation <- backwardcalculation[nrow(backwardcalculation):1,]
  backwardcalculation <- t(backwardcalculation)
  #next combine the data frames:
  GDPAlbania <- cbind(backwardcalculation,forwardcalculation)
  #make the first year with rows as your column names:
  GDPAlbania <- GDPAlbania %>% row_to_names(row_number = 1)
  #rename the column sreturnsloop to Afghanistan (change the name for each country):
  row.names(GDPAlbania) <- "Albania"
  
  #we can now combine Afghanistan and Albania and keep adding countries to this data frame:
  GDPconstant2011 <- as.data.frame(rbind(GDPAfghanistan,GDPAlbania))
  
  