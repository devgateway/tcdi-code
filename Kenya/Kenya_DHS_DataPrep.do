/* /////////////////////////////////////////////////////////////////////////////
Name: 			Kenya_DHS_DataPrep.do

Description: 	Creates dataset for analysing smoking prevalence rates


Author:			Kathryn McDermott

Inputs:			Kenya DHS 2018 (Male and Female)
Outputs: 		Pooled male and female data. 	

Notes: 			DHS weight are normalised to that the weights reflect the number
				of people in the sample, not the number of people in the 
				population. Each dataset is weight for the specific population
				in that dataset. On order to get population estimates (not
				just male / female), male and female data should be pooled. 
				Weights should be adjusted so that they reflect the population
				totals. This is done using United Nations Population Dynamics as
				recommended in DHS sampling manual page 28.(ICF International. 
				2012. Demographic and Health Survey Sampling and Household 
				Listing Manual. MEASURE DHS, Calverton, Maryland, U.S.A.: ICF 
				International)
				
				Two different questionnaires were asked to women in Kenya - a
				long survey and a short survey. Only those who were asked the 
				long survey were asked about smoking. More information can be 
				found in the Kenya DHS report (Kenya National Bureau of Statistics, 
				Ministry of Health/Kenya, National AIDS Control Council/Kenya, 
				Kenya Medical Research Institute, National Council for Population 
				and Development/Kenya, and ICF International. 2015. Kenya 
				Demographic and Health Survey 2014. Rockville, MD, USA: Kenya 
				National Bureau of Statistics, Ministry of Health/Kenya, National 
				AIDS Control Council/Kenya, Kenya Medical Research Institute,
				National Council for Population and Development/Kenya, and ICF 
				International.)
				
				

Packages:							
///////////////////////////////////////////////////////////////////////////// */


clear all

global country "Kenya"

global dg "/Users/kathryn/Dropbox/TCDI_analysis/$country"
global DataIN "$dg/Data/Input"
global DataOUT "$dg/Data/Output"
global temp "$dg/Temp"
global DO "$dg/Code"
global output "$dg/Output"
global MALE "KEMR72DT/KEMR72FL.DTA"
global FEMALE "KEIR72DT/KEIR72FL.DTA"
global HOUSEHOLD "KEHR72DT/KEHR72FL.DTA"

set maxvar 8000





import delimited "$DataIN/UNPD/WPP2019_PopulationBySingleAgeSex_1950-2019.csv", clear

keep if location == "Kenya" & time == 2014

drop if agegrp < 15 | agegrp > 54

replace popfemale = . if agegrp > 49

collapse (sum) popfemale popmale

replace popfemale = popfemale * 1000
replace popmale = popmale * 1000


sum popfemale
local pop_female = round(`r(mean)', 0.1)

sum popmale
local pop_male = round(`r(mean)', 0.1)






***** Figures for de-normalizing weights data
/*
 foreach x in MALE FEMALE {

	if "`x'" == "MALE" {
		import excel "$DataIN/UNPD/WPP2019_POP_F07_2_POPULATION_BY_AGE_MALE.xlsx", clear
	}
	else {
		import excel "$DataIN/UNPD/WPP2019_POP_F07_3_POPULATION_BY_AGE_FEMALE.xlsx", clear
		
}
 
	 drop if H == ""

	 ds
	 foreach var in `r(varlist)' {
		 rename `var' `=strtoname(`var'[1])'
	 }

	rename *, lower

	keep if region__subregion__country_or_ar == "${country}"
	keep if reference_date__as_of_1_july_ == "2015"
	rename _* age_*

	destring age*, replace
	
	egen double age_15_49 = rowtotal(age_15_19 age_20_24 age_25_29 age_30_34 age_35_39 age_40_44 age_45_49 )
	replace age_15_49 = age_15_49 * 1000
	
	egen double age_15_54 = rowtotal(age_15_19 age_20_24 age_25_29 age_30_34 age_35_39 age_40_44 age_45_49 age_50_54)

	replace age_15_54 = age_15_54 * 1000
	
	
	if "`x'" == "MALE" {
		sum age_15_54
	}
	else {
		sum age_15_49
	}
		
	
	local pop_`x' = round(`r(mean)', 0.1)

}

local pop_total = `pop_FEMALE' + `pop_MALE'

di "F : `pop_FEMALE', M : `pop_MALE'"
F : 12106417, M : 12585118
*/




* Load household data ----------------------------------------------------------
/*
In Kenya, a subset of women were asked questions about smoking. These are the
same households that where men were interviewed. These households can be
identified using the variable hv027.
*/

use "$DataIN/DHS/${HOUSEHOLD}", clear
keep hv001 hv002 hv027 
rename hv001 v001
rename hv002 v002


* Merge to female data ---------------------------------------------------------

merge 1:m v001 v002 using "$DataIN/DHS/${FEMALE}"

keep if _merge == 3


* relevant variables
keep caseid v001 v002 v022 v021 v005 hv027 /// sampling vars
	v463a v463b v463c v463d v463e v463f v463x v463z v464 /// smoking vars
	v012 v013 /// age
	v106 v107 v133 v149 /// education
	v190 v191  /// wealth
	v024 v025	// geography
	

gen data = "women"

* Sampling variables
rename v001 cluster
rename v022 strata

gen wt = v005/1000000 


* smoking variables

gen smoke_cig = v463a == 1 

gen smoke_pipe = v463b == 1

gen smokeless_chewing = v463c == 1

gen smokeless_snuff = v463d == 1

gen smoke_waterpipe = v463f == 1

gen smoke_oth = v463x == 1

gen no_tobacco =  v463z == 1


gen any_tobacco = smoke_cig == 1 | smoke_pipe == 1 | smokeless_chewing == 1	///
	| smokeless_snuff == 1 | smoke_waterpipe == 1 | smoke_oth == 1

gen any_smoke = smoke_cig == 1 | smoke_pipe == 1 | smoke_oth == 1 |smoke_waterpipe == 1
gen any_smokeless = smokeless_chewing == 1 | smokeless_snuff == 1



* Replace smoking variables with missing for women who were not asked smoking questions
foreach var in smoke_cig smoke_pipe smokeless_chewing smokeless_snuff smoke_waterpipe smoke_oth no_tobacco {
	replace `var' = . if v463a == . // This line of code is necessary to make the numbers line up to the ones in the DHS report
	replace `var' = 0 if `var' == . & hv027 == 1
}

keep if hv027 == 1

* Weight variables should only be rescaled after unncessary sample dropped
count
gen wgt = v005/1000000 * (`pop_female'/`r(N)')


* Save temp files
tempfile temp
save `temp'
	
* Loade male data --------------------------------------------------------------	
use "$DataIN/DHS/${MALE}", clear

* rename variables so that they match the female data	
rename mv* v*	
rename mcaseid caseid

* Keep relevant variables
keep  caseid v001 v002 v022 v021 v005	/// sampling vars
	v463a v463b v463c v463d v463e v463x v463z v464 /// smoking vars
	v012 v013 /// age
	v106 v107 v133 v149 /// education
	v190 v191   /// wealth
	v024 v025	// geography

gen data = "men"


* Sample variables
rename v001 cluster
rename v022 strata

count
gen wgt = v005/1000000 * (`pop_male'/`r(N)')

gen wt = v005/1000000

* smoking variables

gen smoke_cig = v463a == 1 

gen smoke_pipe = v463b == 1

gen smokeless_chewing = v463c == 1

gen smokeless_snuff = v463d == 1

gen smoke_waterpipe = v463e == 1

gen smoke_oth = v463x == 1

gen no_tobacco =  v463z == 1

gen any_tobacco = smoke_cig == 1 | smoke_pipe == 1 | smokeless_chewing == 1	///
	| smokeless_snuff == 1 | smoke_waterpipe == 1 | smoke_oth == 1
	
gen any_smoke = smoke_cig == 1 | smoke_pipe == 1 | smoke_oth == 1 |smoke_waterpipe == 1
gen any_smokeless = smokeless_chewing == 1 | smokeless_snuff == 1


* Append to female data -------------------------------------------------------
append using `temp'
* Set survey design
svyset cluster [w=wgt] , strata(strata)



gen gender = 1 if data == "men"
replace gender = 2 if data == "women"
lab define gender 1 "Male" 2 "Female"
lab values gender gender

gen age_grp2 = .
replace age_grp2 = 1 if v012 >= 15 & v012 <= 24
replace age_grp2 = 2 if v012 >= 25 & v012 <= 44
replace age_grp2 = 3 if v012 >= 45 & v012 <= 49
lab define age2 1 "15-24" 2 "25-44" 3 "45-49"
label values age_grp2 age2


gen age_grp3 = .
replace age_grp3 = 1 if v012 >= 15 & v012 <= 24
replace age_grp3 = 2 if v012 >= 25 & v012 <= 34
replace age_grp3 = 3 if v012 >= 35 & v012 <= 44
replace age_grp3 = 4 if v012 >= 45 & v012 <= 49
lab define age3 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-49"
label values age_grp3 age3




gen education = .
replace education = 1 if v149 == 0
replace education = 2 if v149 == 1
replace education = 3 if v149 == 2
replace education = 4 if v149 == 3 | v149 == 4 | v149 == 5
lab define education 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary +"
label values education education



* Rename vars 

rename v013 age_grp
rename v190 wealth
rename v024 region
rename v025 residence
rename v106 education2


* Label variables
lab var smoke_cig "Cigarettes"
lab var smoke_pipe "Pipe"
lab var smokeless_chew "Chewing tobacco"
lab var smokeless_snuff "Snuff"
lab var any_tobacco "Any type of tobacco"
lab var any_smoke "Smokes any type of tobacco"
lab var any_smokeless "Uses any type of smokeless tobacco"
lab var smoke_oth "Smokes other types of tobacco"

lab var age_grp "Age"
lab var wealth "Wealth Quintile"
lab var education "Education"
lab var region "Region"
lab var residence "Residence"
lab var age_grp2 "Age V2"


keep smoke_pipe smoke_cig smokeless_chewing smokeless_snuff smoke_waterpipe ///
	smoke_oth any_tobacco any_smoke any_smokeless gender age_grp2 age_grp3 ///
	education cluster caseid age_grp strata region residence education2 wealth wgt v012

save "$DataOUT/KDHS_mf_pooled.dta", replace



