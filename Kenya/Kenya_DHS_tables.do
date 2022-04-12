/* /////////////////////////////////////////////////////////////////////////////
Name: 			Kenya_DHS_tables.do

Description: 	Replicates DHS prevalence tables for men and women
				Creates prevalence tables for whole population


Author:			Kathryn McDermott

Inputs:			Cleaned Kenya DHS 2014 data
Outputs: 		Excel files with tables of smoking prevalence	

Notes: 			Globals defined in Nigeria_DHS_DataPrep.do

Packages:		tabout					
///////////////////////////////////////////////////////////////////////////// */

use "$DataOUT/KDHS_mf_pooled.dta", clear


* Outcome variable of interest (Smoking variable)
local var_outcome smoke_cig smoke_pipe smokeless_chew smokeless_snuff smoke_oth any_smoke any_smokeless any_tobacco

* sub categories
local var_cat gender age_grp age_grp2 age_grp3 residence region education wealth


* Remove number labels for tables
numlabel, remove



* Create and Export  Tables ----------------------------------------------------


* Smoking prevelance for each categorial variable
* 95% CI

foreach var of local var_outcome {

	di " `var' by `var_cat' "
	
	cap tabout `var_cat'  `var'  if v012 <= 49 using "${output}/`var'_all_table.csv", 	///
		cells(  row ci) svy replace format(1p)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)

	di "male `var' by `var_cat' "

	 cap tabout `var_cat'  `var'  if v012 <= 49 & gender == 1 using "${output}/`var'_male_table.csv", 	///
		cells(  row ci) svy replace format(1p)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)
		
	di "female `var' by `var_cat' "

	 cap tabout `var_cat'  `var'  if v012 <= 49 & gender == 2 using "${output}/`var'_female_table.csv", 	///
		cells(  row ci) svy replace format(1p)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)
		
}	

* Export to excel file and format ----------------------------------------------

local var_outcome smoke_cig smoke_pipe smokeless_chew smokeless_snuff smoke_oth any_smoke any_smokeless any_tobacco

preserve

	foreach tab in all male female {
	
		local i 0
		foreach var of local var_outcome {
			
			cap import delimited "${output}/`var'_`tab'_table.csv", clear
			
			if _rc == 0 {
			
			di "`var'_`tab'_table.csv imported"
			
				*Change position of title
				replace v3 = v2 in 1
				
				* Only keep columns of interest
				drop v2 v4 v5
			
				
				local ++i
				
				rename * *_`i'
				
				rename v1_`i' v1
				gen id = _n

				
				tempfile temp`i'
				save `temp`i''
				
				di " `temp`i''"
			}
			
		}


		use `temp1', clear
		
		forval x = 2 / `i' {
			merge 1:1 id v1 using `temp`x'', gen(m`x')
			replace m`x' = .
		}
			
		replace id = .
		rename id m1
		
		
		* add in spaces between tables for readability
		gen id = _n
		gen start = v1[ _n - 1] == "Total"
		gen order = sum(start)
		expand 2 if v1 == "Total", gen(new1)
		bys new1 : replace id = 100 + _n if new1 == 1
		sort order id
		
		qui ds , has(type string)
		foreach var in `r(varlist)' {
			qui replace `var' = "" if new1 == 1
		}
		
		drop id start order new1
		
		
		* Export as xlsx
		export excel "${output}/Kenya_prevalence_`tab'.xlsx", replace
	}
	
restore


ddd
* Erase temp files -------------------------------------------------------------
local var_outcome smoke_cig  smoke_any

foreach var of local var_outcome {

	*erase temp csv files	
	erase "${output}/`var'_all_table.csv"
	erase "${output}/`var'_male_table.csv"
	erase "${output}/`var'_female_table.csv"
	
}




* Number of Smokers ------------------------------------------------------------
* Outcome variable of interest (Smoking variable)
local var_outcome smoke_cig smoke_pipe smokeless_chew smokeless_snuff any_tobacco

* sub categories
local var_cat gender age_grp age_grp2 residence region education wealth


* Remove number labels for tables
numlabel, remove




* Smoking prevelance for each categorial variable
* 95% CI

foreach var of local var_outcome {

	cap tabout `var_cat'  `var'  if v012 <= 49 using "${output}/number_`var'_all_table.csv", 	///
		cells(  freq) svy replace format(0c)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)


	cap tabout `var_cat'  `var'  if v012 <= 49 & gender == 1 using "${output}/number_`var'_male_table.csv", 	///
		cells(  freq) svy replace format(0c)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)

	cap tabout `var_cat'  `var'  if v012 <= 49 & gender == 2 using "${output}/number_`var'_female_table.csv", 	///
		cells(  freq) svy replace format(0c)  cisep("-")  						///
		percent style(csv) layout(cb) clab(% 95%_CI) lines(double)
		
}	

* Export to excel file and format ----------------------------------------------
local var_outcome smoke_cig smoke_pipe smokeless_chew smokeless_snuff

* sub categories
local var_cat gender age_grp residence region education wealth


preserve

	foreach tab in all male female {
	
		local i 0
		foreach var of local var_outcome {
			
			import delimited "${output}/number_`var'_`tab'_table.csv", clear
			
			
			*Change position of title
			replace v3 = v2 in 1
			
			* Only keep columns of interest
			drop v2 
		
			
			local ++i
			
			rename * *_`i'
			
			rename v1_`i' v1
			gen id = _n

			
			tempfile temp`i'
			save `temp`i''
			
			di " `temp`i''"
			
		}


		use `temp1', clear
		
		forval x = 2 / `i' {
			merge 1:1 id v1 using `temp`x'', gen(m`x')
			replace m`x' = .
		}
			
		replace id = .
		rename id m1
		
		
		* add in spaces between tables for readability
		gen id = _n
		gen start = v1[ _n - 1] == "Total"
		gen order = sum(start)
		expand 2 if v1 == "Total", gen(new1)
		bys new1 : replace id = 100 + _n if new1 == 1
		sort order id
		
		qui ds , has(type string)
		foreach var in `r(varlist)' {
			qui replace `var' = "" if new1 == 1
		}
		
		drop id start order new1
		
		
		* Export as xlsx
		export excel "${output}/number_smoke_`tab'.xlsx", replace
	}
	
restore

























