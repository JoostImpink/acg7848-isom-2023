/*

	time series/panel data
	
	
	tsset: specify identifier (firm, country, etc) and time (year, quarter, day)
*/

// the Hayn dataset is online, and can be loaded:
use http://www.koopsom.com/dba/day2_hayn.dta , clear

// make time-series
destring  gvkey, replace
tsset gvkey fyear

//winsorize
winsor size, gen(size_w) p(0.01)
winsor e_p, gen(e_p_w) p(0.01)
winsor ch_e_p, gen(ch_e_p_w) p(0.01)
winsor ret, gen(ret_w) p(0.01)

// lagged, differences, leading variables
gen size_lag = L.size_w
gen size_diff = D.size_w
gen size_lead = F.size_w

browse gvkey fyear size size_lag size_diff size_lead

// L., D., F. can be used in a regression (no need to create new variables)
reg ret e_p ch_e_p i.fyear L.size i.fyear
// with firm effects
xtreg  ret e_p ch_e_p i.fyear L.size_w  i.fyear , fe

// logistic regression
logit loss ret_w L.size_w i.fyear
// logistic regression with firm fixed effects 
xtlogit loss ret_w L.size_w i.fyear, fe 





