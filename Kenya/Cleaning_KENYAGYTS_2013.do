* Cleaning GATS Keya 2014 data on 23 September 2021 doawnloaded from: https://extranet.who.int/ncdsmicrodata/index.php/catalog/249/get-microdata

clear all


global dg "/Users/vanessadd/Library/Mobile Documents/com~apple~CloudDocs/ARNALDA/REEP/Dev_Gateway/Kenya/Prevalence/GYTS/GYTS_2013"
global DataIN "$dg/Data/Input"
global DataOUT "$dg/Data/Output"
global temp "$dg/Temp"
global DO "$dg/Data/Code"
global output "$dg/Output"
global Dataset "KENYAGYTS_13.dta"

set maxvar 8000

use "$DataIN/${Dataset}", clear





*gender
ren CR2 gender
replace gender=0 if gender ==2
lab define gender 1 "male" 0 "female"
*drop if gender==.
label values gender gender


*Age
ren CR1 age
gen age_grp = .
replace age_grp = 1 if age <= 2 & age !=.
replace age_grp = 2 if age >= 3 & age <= 5 & age !=.
replace age_grp = 3 if age >= 6 & age !=.
*replace age_grp=2 if age==.
lab define age 1 "0-12" 2 "13-15" 3 "16+" 
label values age_grp age




*Tobacco use
* Cigarettes
gen cig_tobacco=CR7    //Cigarettes
replace cig_tobacco=0 if cig_tobacco==1 & cig_tobacco!=.
replace cig_tobacco =1 if cig_tobacco >=2 & cig_tobacco!=.

*Other smoked tobacco excl. cigarettes
gen othr_smk_tobacco=CR10 //other SMOKED tobacco
replace othr_smk_tobacco=0 if CR10==2
*replace othr_smk_tobacco=1 if CR11>=3 &CR11!=.
*replace othr_smk_tobacco=1 if othr_smk_tobacco!=1 &SR3>=2 &SR3!=.
*replace othr_smk_tobacco=0 if CR10==. &SR3==1

/*
*Any smoked tobacco including cigarettes
gen any_smk_tobacco=CR7
replace any_smk_tobacco=0 if CR7==1 & CR7!=.
replace any_smk_tobacco =1 if CR7 >=2 & CR7!=.
replace any_smk_tobacco =1 if any_smk_tobacco!=1 &CR10==1  &CR10!=.

*/

*Smokeless
gen smkless_tobacco=CR14  // any SMOKELESS tobacco
replace smkless_tobacco=0 if CR14==2


*Any tobacco (smokeless and smoked)
/*
gen any_tobacco = any_smk_tobacco
replace any_tobacco=1 if any_tobacco!=1 &smkless_tobacco==1 & smkless_tobacco!=.
replace any_tobacco=smkless_tobacco if any_tobacco==. &smkless_tobacco!=.  


*/

lab define cig_tobacco  1 "yes" 0 "no" 
label values cig_tobacco cig_tobacco 

lab define othr_smk_tobacco 1 "yes" 0 "no" 
label values othr_smk_tobacco othr_smk_tobacco

lab define smkless_tobacco 1 "yes" 0 "no" 
label values smkless_tobacco smkless_tobacco

lab define any_smk_tobacco 1 "yes" 0 "no" 
label values any_smk_tobacco any_smk_tobacco

lab define any_tobacco 1 "yes" 0 "no" 
label values any_tobacco any_tobacco

lab var cig_tobacco "Cigarettes"
lab var othr_smk_tobacco "Other smoking tobacco excl. cigs"
lab var any_smk_tobacco "Any smoking tobacco"
lab var smkless_tobacco "Smokeless tobacco"
lab var any_tobacco "Any type of tobacco"


* Set survey design
svyset PSU [pweight=FinalWgt], strata(Stratum) vce(linearized) singleunit(certainty)


save "$DataOUT/GYTSK2013_av.dta", replace
