/*
	Stata regressions
	
	OLS
	Logistic Regression
	Capturing output (coefficients, etc)
	Dealing with outliers
	 - winsorize
	 - Cook's distance
	 - ranked regression
	
*/

use http://www.koopsom.com/dba/day1_sample.dta , clear


// regression
reg ret roa mcap mtb growth

// i.
// adds dummies for each unique value (useful for categorial/factors)
reg ret roa mtb growth i.mcap_d i.fyear

// make loss dummy
gen loss = (ni < 0)

// partitioning
reg ret roa mtb growth i.mcap_d i.fyear if loss == 0
reg ret roa mtb growth i.mcap_d i.fyear if loss == 1

// winsorize
winsor ret, gen(ret_w) p(0.01)
winsor roa, gen(roa_w) p(0.01)
winsor mcap, gen(mcap_w) p(0.01)
winsor mtb, gen(mtb_w) p(0.01)
winsor growth, gen(growth_w) p(0.01)


// regressions raw (unwinsorized) variables


// regression winsorized variables
reg ret_w roa_w mcap_w mtb_w growth_w 
reg ret_w roa_w mcap_w mtb_w growth_w i.fyear
reg ret_w roa_w        mtb_w growth_w i.mcap_d i.fyear

// by the way, the regression is not set up very clean as there is some circularity
// if return is high, then mcap and mbt are also higher


/* Exporting multiple regressions */

// use eststo-esttab to make tables with multiple regressions output (one column for each regression)
// To install eststo:
// findit eststo // click on the link for 'st0085_1', then 'click here to install'

// Example: results for two different models exported to a csv file (you can actually click on the link)

eststo clear
eststo: reg ret_w roa_w mcap_w mtb_w growth_w 
eststo: reg ret_w roa_w mcap_w mtb_w growth_w i.fyear
eststo: reg ret_w roa_w        mtb_w growth_w i.mcap_d i.fyear

// make sure the folder exists
esttab using E:\temp_acg7848\stata_output_table.csv, b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) r2

// logistic regression (binary dependent variable)

logit loss ret_w mcap_w mtb_w growth_w i.fyear


// Dealing with outliers

// Winsorizing is a variable-by-variable approach 
// In a regression, you can still have leverage points (data points with
// a high influence) even if the data is winsorized
// For example, for 2 variables the values are in the 98th percentile

// Cook's distance, see Wikipedia https://en.wikipedia.org/wiki/Cook%27s_distance

// to detect outliers/leverage points you can utilize Cook's Distance in Stata.


// initial regression
reg ret_w roa_w mtb_w growth_w i.mcap_d i.fyear 
// compute cook's distance
predict cook, cooksd, if e(sample)
// rerun regression without leverage points
// cutoff: 4 / n-k, where n is number of observations and k is #independent variables (including intercept)
// number of observations in sample dataset
count
// rerun regression without leverage points
reg ret_w roa_w mtb_w growth_w i.mcap_d i.fyear if cook < 4/ (46805-8)
// browse leverage points that were excluded
browse if cook > 4/ (46805-8)

// Ranked regression

// Another way to deal with outliers is to use ranked regression. For each variable, all values are sorted from low to high, and the ranks (1, 2, 3, ...) are assigned in that order. Indicator variables do not need to be ranked.
// The rank transformation results in a variable that has a uniform distribution (it removes distance information).

egen ret_r = rank(ret)
egen mtb_r = rank(mtb)
egen growth_r = rank(growth)


sort ret
browse ret ret_r

reg ret_r mtb_r growth_r i.mcap_d i.fyear


