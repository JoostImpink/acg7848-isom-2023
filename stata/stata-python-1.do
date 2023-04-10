/*

	Topic: Using python in Stata

*/

// dataset to work with
use http://www.koopsom.com/dba/day1_sample.dta , clear

// python code: start with 'python', end with 'end', execute as one block

python

x=1
print('x is:', x)

end

// one one line: 'python:' and no end
python: y=2; print('y is:', y)

// list python objects that are in memory
python describe

// python will remember the variables throughout the session
python: print('x is', x, 'and y is', y)

// unless these are cleared 
python clear 
// throws error
python: print('x is', x, 'and y is', y)

// after most commands, Stata creates r and e variables that hold the result (in a predictable way)
sum ni, d

// return gives r
return list 

// ereturn gives e (set after estimation)
ereturn list

// r has several values, e is empty 

// show the value of r(p50) (50th percentile, or median)
// note the opening quote is a backtick (`) and the closing quote is a single straight quote (')
display `r(p50)'

// python: import modules
python 
#/*BASIC MODULES*/
import pandas as pd
import re, os
#/*STATA MODULES - 'sfi' makes stata objects available in python */
from sfi import Matrix
from sfi import Scalar
from sfi import ValueLabel
from sfi import Data, Frame, Macro
end

// python can get its hands on r 
python
median = Scalar.getValue('r(p50)') 
print("The median is", median)
end 

// or a function
python
def getResults( var ):
	median = Scalar.getValue('r(p50)') 
	mean = Scalar.getValue('r(mean)') 
	sd = Scalar.getValue('r(sd)') 
	p25 = Scalar.getValue('r(p25)') 
	p75 = Scalar.getValue('r(p75)') 
	return{
		'variable': var,
		'median' : median,
		'mean' : mean,
		'sd' : sd,
		'p25': p25,
		'p75': p75 
	}
end

// data structure to hold statistics
python: results = []

// get statistics and append it, one variable at a time
sum ni, d 
python: results.append ( getResults('ni') )
sum ceq, d 
python: results.append ( getResults('ceq') )
sum at, d 
python: results.append ( getResults('at') )

python: print(results)

// how about a correlation?
// pwcorr: pairwise correlation
pwcorr roa mtb , sig
// show what is being stored
return list 
// let's access the sigificance levels (p-values)
python
pvalues = Matrix.get('r(sig)') 
print("The p-values are", pvalues)
pvalue_0_1 = Matrix.get('r(sig)', 0, 1) 
print("The p-value is: ", pvalue_0_1)
end 


// using a loop in Stata
python: results = []

foreach v in ni ceq at {
	sum  `v' , d 
	python: results.append ( getResults("`v'") )	
}

python: print(results)

// nested loops

foreach v in ni ceq at {

	// start at 1, increment with steps of 1, through 5
	forvalues i = 1(1)5  {
		
		python: print("`v'", "`i'")
		
	}
}

// put unique values in a list
levelsof sich, local(levels)
// now loop through the list
foreach l of local levels {
	// do something else
	// like: command .... if sich == `l'
	pwcorr ni sale if sich == `l'
}

