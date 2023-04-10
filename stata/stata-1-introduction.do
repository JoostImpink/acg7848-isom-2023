/*
	Stata - Introduction
	
	Stata using UF Apps: https://login.apps.ufl.edu/
	
	Topics:
	- loading data
		use: loading data
	- inspecting data 
		count
		tab: tabulate (categorial/factor variables)
	- descriptive statistics
		tabstat: mean, median, standard deviation, min, max, etc
*/

// use: load dataset, from disk or online
// load sample dataset 
use http://www.koopsom.com/dba/day1_sample.dta , clear

// to run a line, select it, and press 'control D'
// you can also select the line, then in top menu, select 'Tools', and 'Execute (do)'

// see all variables
browse

// see some variables
browse gvkey fyear ret growth mcap_d

// see some variables with some condition (== means condition/filter)
browse gvkey fyear ret growth mcap_d if mcap_d == 3

// how many obs
count

// how many obs for condition/filter
count if mcap_d == 3

// obs by year
tab fyear

// obs by sic2
tab sic2

// descriptive statistics
tabstat ret roa mcap mtb growth , stats (n mean min p10 p25 p50 p75 p90 max sd) col(stat)
//typically
tabstat ret roa mcap mtb growth , stats (n mean p25 p50 p75 sd) col(stat)

// exporting descriptive statistics
estpost tabstat ret roa mcap mtb growth , stats (n mean min p10 p25 p50 p75 p90 max sd) col(stat) 
// export: make sure path/folder exists (on UF Apps you would be on the M drive)
esttab . using E:\temp_acg7848\sample_descriptives.csv ,  replace cells(" min p50 mean max sd ")

// correlation table
pwcorr ret roa mcap mtb growth 
pwcorr ret roa mcap mtb growth ,sig



