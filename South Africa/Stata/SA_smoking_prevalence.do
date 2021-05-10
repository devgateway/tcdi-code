
/* /////////////////////////////////////////////////////////////////////////////
Name: 			DG_smoking _prevalence_rates_2017_var_creation.do			
Description: 	Creates variables related to smoking prevalance rates
Inputs:			NIDS Wave 5
Outputs: 		

Notes: 						
///////////////////////////////////////////////////////////////////////////// */

* Set globals ------------------------------------------------------------------

global dg "TCDI/SouthAfrica/Analysis"		// file path
global DataIN "$dg/Data/Input/NIDS"			// Input data
global DataOUT "$dg/Data/Output"			// Output data
global VersionIN "W5_Anon_V1.0.0"			// NIDS wave
global DO "$dg/Code"						// Code
global output "$dg/Output" 					// Outputs                                                  


* Import data ---------------------------------------------------------------

// NIDS has several datasets that should be merged to form the analysis dataset

* Open data
use "$DataIN/Adult_$VersionIN.dta", clear
gen dataset= "Adult" 


merge m:1 w5_hhid using "$DataIN/hhderived_$VersionIN.dta"
drop _merge

drop if pid == .
merge 1:1 pid using "$DataIN/Link_File_W5_Anon_V1.0.0.dta"
drop _merge

merge 1:1 w5_hhid pid using "$DataIN/indderived_$VersionIN.dta"


* Drop unnecessary observations and variables. 

* Drop survey non respondents
keep if w5_a_outcome == 1

* Only keep adults
keep if dataset == "Adult"

* Drop respondent who were not asked about smoking
drop if w5_a_hllfsmk<=-3 
drop if w5_a_hllfsmk==.

* Drop if gender data is missing
drop if w5_best_gen < 0


* Only keep necesary variables
#d;	
	keep w5_hhid w5_a_popgrp w5_a_lvbfdc_2011 w5_a_bhali3 pid w5_a_popgrp_o 
		w5_a_lvbfcc w5_a_bhdod_y3 w5_best_age_yrs w5_a_parhpid w5_a_bhbrth 
		w5_a_bhmem3 w5_best_race w5_a_mar w5_a_bhcnt1con w5_a_bhres3 w5_best_gen 
		w5_a_mary_m w5_a_bhlive_n w5_a_bhchild_id4 w5_best_edu w5_a_mary_l 
		w5_a_bhali w5_a_bhgen4 w5_lo_edu w5_a_evmar w5_a_bhali_n w5_a_bhdob_m4
		w5_v_ass_i_extu w5_a_curmarst w5_a_bhdth w5_a_bhdob_y4 
		w5_ind_networth_i_extu w5_a_timewid w5_a_bhdth_n w5_a_bhali4
		w5_pi_net_worth_i_extu w5_a_timediv w5_a_bhprg w5_a_bhdod_m4 w5_geo2011 
		w5_a_lng w5_a_bhchild_id1 w5_a_bhdod_y4 w5_wgt w5_a_lng_o w5_a_bhgen1 
		w5_a_bhmem4 w5_hhsizer w5_a_slpw w5_a_bhdob_m1 w5_a_bhres4 w5_hhincome 
		w5_a_slpm w5_a_bhali1 w5_a_bhchild_id5 w5_expenditure w5_a_lvevoth 
		w5_a_bhdod_m1 w5_a_bhgen5 w5_a_outcome w5_a_brnprov w5_a_bhdod_y1 
		w5_a_bhdob_m5 w5_a_intrv_d w5_a_brnprov_flg w5_a_bhmem1 w5_a_bhdob_y5
		w5_a_intrv_m w5_a_brndc_2001 w5_a_bhres1 w5_a_bhali5 w5_a_intrv_y 
		w5_a_brndc_2001_flg w5_a_bhchild_id2 w5_a_bhdod_m5 w5_a_refexpl 
		w5_a_brndc_2011 w5_a_bhgen2 w5_a_bhdod_y5 w5_a_refexpl_o w5_a_ed17curlev
		w5_a_brndc_2011_flg w5_a_bhdob_m2 w5_a_bhmem5 w5_a_refint w5_a_brncc 
		w5_a_bhdob_y2 w5_a_bhres5 w5_a_refgen w5_a_brncc_flg w5_a_bhdod_m2 
		w5_a_bhchild_id6 w5_a_refage w5_a_lv94prov w5_a_bhdod_y2 w5_a_bhgen6 
		w5_a_intrv_c w5_a_lv94prov_flg w5_a_bhmem2 w5_a_bhdob_m6 w5_a_sample 
		w5_a_lv15prov w5_a_bhres2 w5_a_bhdob_y6 w5_a_duration w5_a_lv15prov_flg 
		w5_a_bhchild_id3 w5_a_hllfsmk w5_a_dob_m w5_a_moveyr w5_a_bhgen3 
		w5_a_hllfsmkreg w5_a_dob_y w5_a_lvbfprov w5_a_bhdob_m3 w5_a_asacc_brac4 
		w5_a_gen w5_a_lvbfdc_2001 w5_a_bhdob_y3 w5_a_edschgrd dataset w5_a_edterlev
		cluster w5_dc2001;
#d cr



** Create variables ---------------------------------------------------------

* Age groups
gen age_grp =1 if w5_best_age_yrs>=15 & w5_best_age_yrs<18
replace age_grp =2 if w5_best_age_yrs>=18 & w5_best_age_yrs<25
replace age_grp =3 if w5_best_age_yrs>=25 & w5_best_age_yrs<55
replace age_grp =4 if w5_best_age_yrs>=55 & w5_best_age_yrs!=.
label def age_grp  1 "15-17" 2 "18-24" 3 "25-54" 4 "55+"
label val age_grp  age_grp



* Education
 
gen ed = .
replace ed = 1 if w5_best_edu == 0 | w5_best_edu == 25 /*no school*/

// primary school
replace ed = 2 if w5_best_edu>=1 & w5_best_edu<=7
replace ed = 2 if (w5_best_edu==16 |  w5_best_edu==18 ) & (w5_a_edschgrd>=1 & w5_a_edschgrd<=7)

// incompl secondary school
replace ed = 3 if w5_best_edu>=8 & w5_best_edu<=11
replace ed = 3 if (w5_best_edu==16 |  w5_best_edu==18 ) & (w5_a_edschgrd>=8 & w5_a_edschgrd<=11)
replace ed = 3 if inlist(w5_best_edu, 14, 27, 28, 30, 31)
replace ed = 3 if (w5_best_edu==16 |  w5_best_edu==18 ) & inlist( w5_a_edschgrd, 14, 27, 28, 30, 31)

// matric
replace ed = 4 if (w5_best_edu==16|w5_best_edu==18) & (w5_a_edschgrd==12)
replace ed = 4 if inlist(w5_best_edu, 12, 15, 29, 32)

// post secondary school
replace ed = 5 if inlist(w5_best_edu, 17, 19, 20, 21, 22, 23) 

// still in education
replace ed = 6 if w5_a_ed17curlev!=.

label def ed 1 "Gr 0 or less" 2 "G1-G7" 3 "G8-G11" 4 "G12" 5 "Post-matric" 6 "Still in educ"
label val ed ed 



* Geography type

gen byte urban =1 if w5_geo2011==2 &w5_geo2011!=. &w5_geo2011!=-3 &w5_geo2011!=-5
replace urban =0 if w5_geo2011!=2 &w5_geo2011!=-3 &w5_geo2011!=-5 &w5_geo2011!=.

label define urban 1 "1. urban" 0 "0. rural", replace
label values urban urban
tab urban,m

* Rename variables
ren w5_best_age_yrs age 
ren w5_best_race race 
ren w5_best_gen gender
ren w5_best_edu highest_education
ren w5_wgt survey_weight
ren w5_a_hllfsmk smoke
ren pid person_identifier
ren w5_geo2011 rural_urban
ren w5_dc2001 strata


* Recode Smoke so that Yes = 1 No = 0
replace smoke = 0 if smoke == 2
lab define smoke 0 "0. No" 1 "1. Yes"
label values smoke smoke

svyset cluster [w=survey_weight], strata(strata) 
rename ed education_categories
*save "$temp/Adult.dta", replace

* Export micro data ***********************************************************



* Keep data used in analysis
keep if age >= 15
keep if gender > 0
keep age_grp person_identifier smoke	rural_urban	urban survey_weight		///
	gender race race2	education_cat	 w5_a_edterlev w5_a_ed17curlev 		///
	w5_a_edschgrd highest_education age cluster strata



tab education_cat, gen(educ)
rename educ1 educ_no_schooling
rename educ2 educ_primary_school
rename educ3 educ_incmp_seconary_school
rename educ4 educ_matric
rename educ5 educ_post_secondary
rename educ6 educ_inschool

tab age_grp, gen(age_grp)

rename age_grp1 age_grp_18_24
rename age_grp2 age_grp_25_54
rename age_grp3 age_grp_55plus

gen male = 1 if gender == 1 & gender > 0 
gen female = 1 if gender == 2

gen smoke_code = smoke ==1

gen rural = urban == 0

gen african = race == 1 if race > 0
gen coloured = race == 2 if race > 0
gen asian_indian = race == 3 if race > 0 
gen white = race == 4 if race > 0 
gen asian_indian_white = race == 3 | race == 4 if race > 0 


replace race = . if race <=0

rename w5_a_edterlev educ_highest_tertiary
rename w5_a_ed17curlev educ_current_level
rename w5_a_edschgrd educ_highest_school_grade
lab var urban

*label val educ_highest_tertiary educ_current_level educ_highest_school_grade highest_education
numlabel, remove


preserve 
	keep person_identifier rural_urban survey_weight smoke age race gender highest_education educ_highest_school_grade educ_current_level  

	 
	order person_identifier rural_urban survey_weight smoke age race gender highest_education educ_highest_school_grade educ_current_level  

	*order highest_educ educ_highest_tertiary educ_current_level educ_highest_school_grade age, last


	export  excel "$DataOUT/DG_smoking_prevalence_TCDI_micro_data.xlsx", replace firstrow(var)
restore

preserve

keep person_identifier survey_weight smoke_code  rural urban age_grp age_grp_18_24 ///
	age_grp_25_54 age_grp_55plus african coloured asian_indian_white male female	///
	education_categories educ_no_schooling educ_primary_school 					///
	educ_incmp_seconary_school educ_matric educ_post_secondary educ_inschool
	
	
order person_identifier survey_weight smoke_code  rural urban age_grp age_grp_18_24 ///
	age_grp_25_54 age_grp_55plus african coloured asian_indian_white male female	///
	education_categories educ_no_schooling educ_primary_school 					///
	educ_incmp_seconary_school educ_matric educ_post_secondary educ_inschool
	
	
	export  excel "$DataOUT/DG_smoking_prevalence_NIDS_created_vars.xlsx", replace firstrow(var)
	
restore

	
	
