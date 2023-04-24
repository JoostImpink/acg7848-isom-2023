/*

	Topic: Using python in Stata - regression output

*/
use http://www.koopsom.com/dba/day2_hayn.dta , clear

// after most commands, Stata creates r and e variables that hold the result (in a predictable way)
reg ret e_p

// return gives r
return list 

// ereturn gives e (set after estimation)
ereturn list


// list just gives dimension of r(table), not the contents
// ask for it specifically (it holds coefficients and associated statistics)
matrix list r(table)

//--------------------------------------
//	Store Coefficients in a matrix
//--------------------------------------

*Store coefficients e(b) in a matrix called "coef"
matrix coef = e(b)

*Check defined matrices  ([rows, columns])
matrix dir

*Check contents of matrix
matrix list coef

*Drop matrix   
//matrix drop coef

*Alternatively, coefficient can be stored in local or global macro variables
reg ret e_p
local coef =  round(_b[e_p], 0.00001)
di "`coef'"

**========================================
**#	  PYTHON CODE
**========================================


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

**##  Accessing coefficient, e(N) and e(r2)
	
python
coef = Matrix.get('coef')             						#//Read matrix into list
nObs = Scalar.getValue('e(N)')     							#//Read number of obs
rsq =  Scalar.getValue('e(r2)')	   							#//Read R2
print("coeff", coef, "Number of obs: ", nObs, "rsq:", rsq)
end 

*CREATE DATAFRAME
python
coef = Matrix.get('coef')    
coef = coef[0][0]					#// Extract first coefficient (coefficient of first IV)
         					
nObs =  Scalar.getValue('e(N)')     #// Extract number of observations.							
rsq  =  Scalar.getValue('e(r2)')	#// Extract R2. Note: adjusted R2 can be accessed using e(r2_a) 

#//Put values to list of Dict
list_of_dict = [{"Coeff": coef, "R2": rsq, "Obs": nObs,}] 							

#//Create Dataframe
df = pd.DataFrame(list_of_dict)

#//Transpose
df = df.T

#//Check DataFrame
print(df.head())

end 

*SAVE RESULTS TO CSV
python 
#//Save DataFrame to CSV
csv_out = "temp - test_1.csv"
df.to_csv(csv_out)
end

*Open CSV (make sure to close before attempting to re-write)
python: os.startfile(csv_out)


**========================================
**##  USING PYTHON FUNCTIONS

*PYTHON: Create a blank list to store results
python: result_list=[]

*PYTHON: Define a function that adds results to list
*		 The python function makes it easy to add multiple resgression results
python 

def Results_to_List(mynote=""):
	"""
	The function extracts a pre-defined matrix called "coef", the r-squared, 
		and the number of observations after a regression; creates a dictionary;
		and adds the dictionary to the pre-defined list called "result_list".
	Parameters: mynote : str; optional note to describe the regression.
	"""
	coef = Matrix.get('coef')
	coef = coef[0][0]
	
	nObs = Scalar.getValue('e(N)')     							
	rsq =  Scalar.getValue('e(r2)')	
	
	#//Create Dictionary
	z = {"Note": mynote, "Coeff": coef, "R2": rsq, "Obs": nObs}
	
	#//Add Dictionary to List
	result_list.append(z)
	
end

*Print docstring
python: print(help(Results_to_List))


//-------------------------------------
// Example with multiple regressions:

*Initialize List
python: result_list=[]

*Regression (1)
reg ret e_p
	matrix coef = e(b)
	python: Results_to_List("All")
*Regression (2)
reg ret e_p if loss == 1
	matrix coef = e(b)
	python: Results_to_List("Loss")
*Regression (3)
reg ret e_p if loss == 0
	matrix coef = e(b)
	python: Results_to_List("Profit")
	
python: print(result_list)