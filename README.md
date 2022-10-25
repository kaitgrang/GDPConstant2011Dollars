# GDPConstant2011Dollars
GDP in Constant 2011 US Dollars

UPDATING GDP (CONSTANT 2011) IN THE INTERNATIONAL FUTURE'S MODEL (IFs):

# BACKGROUND:
Quarterly, we update the GDP series in IFs by using a special process that involves pulling data from the World Bank and the IMF.
The GDP values we have in IFs are based on constant 2011 prices, whereas the World Bank is based on constant 2010 prices.
If one country has a different World Bank historical value, all the countries must be updated.
Why?: (1) We do not necessarily know which country's historical series was revised. (2) If we have a method to update one or do not not which changed, we update all anyway.

# THREE SOURCES:

For this process, three sources are required:
  
Primary Source: WORLD BANK DEVELOPMENT INDICATORS (WDI)
     
- GDP in US Current $:  https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
       
- GDP Growth (based on constant price ):https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG

Secondary & Forecasting Source: IMF World Economic Outlook (WEO)
     
- GDP in US Current $
       
- GDP Growth (Based on Constant Price)
       
- GDP Growth Rates (Still Constant Price)

# Use of the Three Sources:
  
 WORLD BANK GDP in US Current $  
 - We use WB GDP values in current $ as the primary source to establish the 2011 constant $GDP base.
 - We start by pulling the most up to date GDP value for the year 2011 for all countries.
 - From here, we apply GDP growth rates to the 2011 GDP value both into the future and historically.
 - IF the World Bank doesn't have 2011 GDP data for certain countries, use IMF values, if there are no IMF values, we pull from IFs.

WORLD BANK GDP Growth (Annual %) Constant Price
 - The World Bank has GDP growth data from 1960 to the current year -1 (ie. if it is 2021, the Worl Bank will have data from 1960 to the current year)
 - If a country does not have full coverage, use IMF GDP growth rates. Though, the IMF only has historical vales back to 1980; therefore, we use IFs          GDP growth rates to cover the rest of the missing historical values.
 - NOTE: not all countries will have data back to 1960, this is because some countries did not exist until later in time. 
 
IMF GDP in US Current $
- As stated above, we use IMF GDP for those countries that are not covered or are missing from the World Bank. 
- For example, the World Bank does not have data for Taiwan. In this case we would use the 2011 Current GDP from the IMF

IMF GDP Growth (Annual %) Constant Price
- As stated above, we use IMF GDP growth rates as a secondary source when the WB does not have data both into the future and historically
- We use IMF growth rates starting from the last available year from the WB (EX: if WB ends in 2018, start 2019 with IMF growth rate OR if WB ends in 1999, start in 1998 with IMF growth rate)
- The IMF also publishes forecasts of GDP growth rates 5 years into the future (EX: if it is 2021, they have GDP growth rates into 2026). We want to          include these forecasts in our data. This is where it can get tricky. The IMF updates its forecasts for big economies twice a year (in April and            July). 
- These updates are only for big economies (usually around 30 countries) and only include revisions for the next 2 years. 
- Going back to our example, if IMF releases forecasts for 2022-2026, the years 2022 and 2023 will be updated twice a year, but the following growth          rates remain the same.
- Be careful when updating forecasts and remember to check for IMF revisions. 
- If there are not IMF values (i.e., North Korea and Syria) then find a source with a value (i.e., CIA Factbook). We use that source to fill-in the          missing data and extrapolate, assuming say, no growth is occurring in Syria at all. Reliable ones are hard to come across, for these, but we still          want to have values at least in IFs.

IFs GDP and Growth Rates
- We use IFs GDP VALUES when the World Bank and IMF do not have coverage for a country when establishing the 2011 base.
- We use IFS GDP GROWTH RATES when the World Bank and IMF do not have historical coverage.
- IFs DOES NOT have historical GDP growth variables from which we can pull directly.
- HOWEVER, we can calculate growth rates from the historical GDP Values

How to do this...

# HOW TO CALCULATE GDP GROWTH RATES FROM IFs

- open IFs, on the top list of features navigate to FLEXIBLE DISPLAYS 
- select DISPLAY FORMAT from the menu
- select USE ALL AVAILABLE HISTORICAL DATA
- choose the variable "GDP (MER), HISTORY AND FORECAST - BILLION DOLLARS". This variable is based on seriesGDP2011
- to check that you are pulling the proper data, select LIST FEATURES then EXPLAIN LIST and make sure that the Historic Analg read GDP2011
- we don't want to forecast, only use data, so make sure your horizon is not set into the future (TIP: data in IFs appears in blue while forecasts appear     in black)
- now, select all the countries by highlighting Afghanistan (or the first country listed) and dragging to the bottom
- click the table option and the table should be displaying the GDP values
- in order to get GDP growth, we need to know the percent change from year to year
- IFs can calculate this for you, select DISPLAY OPTIONS, then PERCENT
- now your dataset is complete
- from here, you can save your data as a csv to use in R later *make sure the csv file is saved in the same directory as your working directory in R

#----------------------------------------------------------------------------------------------
