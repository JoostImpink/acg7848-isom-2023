/*

	Topics:
	- winsorizing
	- 
	... deciles
	

*/

use http://www.koopsom.com/dba/day1_sample.dta , clear

// generate variable using condition
gen loss = (ni < 0)

// Generate dummy variables
tabulate fyear, gen(dfyear)


// winsorize variables

// installing winsor
// findit winsor  
// select: winsor from http://fmwww.bc.edu/RePEc/bocode/w
// help for winsor: http://fmwww.bc.edu/repec/bocode/w/winsor.html

winsor ret, gen(ret_w) p(0.01)
winsor roa, gen(roa_w) p(0.01)
winsor mcap, gen(mcap_w) p(0.01)
winsor mtb, gen(mtb_w) p(0.01)
winsor growth, gen(growth_w) p(0.01)

// compare; sum (summarize) ', d' for details 
sum ret
sum ret, d
sum ret_w, d

// sort by ret
sort ret
browse ret ret_w

// binning

// create deciles

xtile ret_d = ret,nq(10)

// create deciles by year (because there are bull and bear markets)

gen ret_d2 = .
egen group = group(fyear) // group by year
su group, meanonly

forval i = 1/`r(max)' {
          xtile decile_temp =ret if group==`i', nq(10)   
          replace ret_d2 = decile_temp if group == `i'
          drop decile_temp
}

// average ret_w by fyear
// egen: 'extended' generate (more flexible than 'gen' function)
egen ret_w_avg = mean(ret_w), by(fyear)
