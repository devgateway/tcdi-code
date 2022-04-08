* Cleaning GATS Keya 2014 data on 23 September 2021 doawnloaded from: https://extranet.who.int/ncdsmicrodata/index.php/catalog/249/get-microdata

clear all


global dg "/Users/vanessadd/Library/Mobile Documents/com~apple~CloudDocs/ARNALDA/REEP/Dev_Gateway/Kenya/Prevalence/GATS"
global DataIN "$dg/Data/Input"
global DataOUT "$dg/Data/Output"
global temp "$dg/Temp"
global DO "$dg/Code"
global output "$dg/Output"
global Dataset "GATSK2014.dta"

set maxvar 8000

use "$DataIN/${Dataset}", clear





*gender
ren A01 gender
replace gender=0 if gender ==2
lab define gender 1 "male" 0 "female"
label values gender gender

*Age
gen age_grp1 = .
replace age_grp1 = 1 if age >= 15 & age <= 19
replace age_grp1 = 2 if age >= 20 & age <= 24
replace age_grp1 = 3 if age >= 25 & age <= 29
replace age_grp1 = 4 if age >= 30 & age <= 34
replace age_grp1 = 5 if age >= 35 & age <= 39
replace age_grp1 = 6 if age >= 40 & age <= 44
replace age_grp1 = 7 if age >= 45 & age <= 49
replace age_grp1 = 8 if age >= 50 & age <= 54
replace age_grp1 = 9 if age >= 55 & age <= 59
replace age_grp1 = 10 if age >= 60 & age <= 64
replace age_grp1 = 11 if age >= 65 


lab define age1 1 "15-19" 2 "20-24" 3 "25-29" 4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49" 8 "50-54" 9 "55-59" 10 "60-64"  11 "65+"
label values age_grp1 age1


gen age_grp2 = .
replace age_grp2 = 1 if age >= 15 & age <= 24
replace age_grp2 = 2 if age >= 25 & age <= 34
replace age_grp2 = 3 if age >= 35 & age <= 44
replace age_grp2 = 4 if age >= 45 & age <= 54
replace age_grp2 = 5 if age >= 55 & age <= 64
replace age_grp2 = 6 if age >= 65


lab define age2 1 "15-24" 2 "25-34" 3 "35-49" 4 "50-59" 5 "60-64" 6 "65+"
label values age_grp2 age2

gen age_grp3=.
replace age_grp3 = 1 if age >= 15 & age <= 17
replace age_grp3 = 2 if age >= 18 & age <= 24
replace age_grp3 = 3 if age >= 25 & age <= 44
replace age_grp3 = 4 if age >= 45 & age <= 64
replace age_grp3 = 5 if age >= 65

lab define age3 1 "15-17" 2 "18-24" 3 "25-44" 4 "45-64" 5 "65+" 
label values age_grp3 age3

ren A04 education
* Primary completed includes those who completed primary and those in secondary who had not completed secondary
replace education =3 if education==4
replace education =4 if education>=5 & education<=8
lab define education 1 "No education" 2 "Primary incomplete" 3 "Primary complete"  4 "Secondary +" 
label values education education
numlabel, add
replace education =. if education ==77


*Smoking variables 
gen smk_tobacco=1 if B01<=2    //any SMOKED tobacco 
replace smk_tobacco=0 if B01>=3 
lab define smk_tobacco  1 "yes" 0 "no" 
label values smk_tobacco smk_tobacco 

gen smkless_tobacco=1 if C01<=2  // any SMOKELESS tobacco
replace smkless_tobacco=0 if C01>=3  & C01!=7
lab define smkless_tobacco 1 "yes" 0 "no" 
label values smkless_tobacco smkless_tobacco


gen any_tobacco =smk_tobacco   // includes smoke and smokeless
replace any_tobacco =smkless_tobacco if any_tobacco!=1 & smkless_tobacco>0
lab define any_tobacco  1 "yes" 0 "no" 
label values any_tobacco any_tobacco 


gen manuf_cigs=1 if B06a>0 &B06a!=.
replace manuf_cigs =1 if manuf_cigs==. & B06a1>0 &B06a1!=.
replace manuf_cigs = 1 if manuf_cigs==. & B10a >0 & B10a!=.
replace manuf_cigs=0 if manuf_cigs==.
lab define manuf_cigs 1 "yes" 0 "no" 
label values manuf_cigs manuf_cigs 

gen hand_rolled=1 if B06b>0  &B06b!=.
replace hand_rolled=1 if hand_rolled==. & B06b1>0 & B06b1!=.
replace hand_rolled =1 if hand_rolled==. & B10b>0 & B10b!=.
replace hand_rolled=0 if hand_rolled==.
lab define hand_rolled 1 "yes" 0 "no" 
label values hand_rolled hand_rolled 


gen any_cigs =1 if manuf_cigs ==1 & manuf_cigs!=.    // manufactured and RYO cigs
replace any_cigs=1 if any_cigs !=1 &  hand_rolled==1
replace any_cigs=0 if any_cigs==.
lab define any_cigs 1 "yes" 0 "no" 
label values any_cigs any_cigs


gen oral_snuff=1 if C06a>0 & C06a!=. 
replace oral_snuff =1 if  oral_snuff !=1 & C06a1>0 & C06a1!=999 &C06a1!=.
replace oral_snuff=1 if oral_snuff!=1 &C10a>0 &C10a!=999 & C10a!=.
replace oral_snuff=0 if oral_snuff==. 
replace oral_snuff=. if C06a1==999 &C06a==999 &C10a==999
lab define oral_snuff 1 "yes" 0 "no" 
label values oral_snuff oral_snuff

gen nasal_snuff=1 if C06b>0 &C06b!=999 &C06b!=.
replace nasal_snuff=1 if nasal_snuff!=1 &C06b1>0 &C06b1!=.
replace nasal_snuff=1 if nasal_snuff!=1 &C10b>0 & C10b!=.
replace nasal_snuff=0 if nasal_snuff==.
replace nasal_snuff=. if C06b1==999 & C06b==999 & C10b==999
lab define nasal_snuff 1 "yes" 0 "no" 
label values nasal_snuff nasal_snuff


gen any_snuff=oral_snuff
replace any_snuff=1 if any_snuff!=1 & nasal_snuff==1
replace any_snuff=1 if any_snuff==. & nasal_snuff==1 
lab define any_snuff 1 "yes" 0 "no" 
label values any_snuff any_snuff


*only includes chewing kuber
gen kuber=1 if C06c>0 & C06e!=. & C06e!=999
replace kuber =1 if kuber!=1 & C06c1 >0 &C06c1!=999 & C06c1!=.
replace kuber =0 if kuber==. 
replace kuber=. if C06c==999
lab define kuber 1 "yes" 0 "no" 
label values kuber kuber

*Only includes betel quid
gen chew_tobacco=1 if C06d>0 &C06d!=999 &C06d!=.
replace chew_tobacco=1 if chew_tobacco!=1 &C06d1>0 &C06d1!=999 &C06d1!=.
replace chew_tobacco=1 if chew_tobacco!=1 & C10c>0 & C10c!=.
replace chew_tobacco =0 if chew_tobacco==.
replace chew_tobacco=. if C06d==999
lab define chew_tobacco 1 "yes" 0 "no" 
label values chew_tobacco chew_tobacco


*includes kuber and betel quid 
gen kuber_chewing=chew_tobacco
replace kuber_chewing=1 if kuber_chewing!=1 & kuber==1 &kuber!=0
replace kuber_chewing=0 if kuber_chewing==.
lab define kuber_chewing 1 "yes" 0 "no" 
label values kuber_chewing kuber_chewing

* all chewing tobacco: snuff (oral), kuber, betel quid 
gen allchew_tobacco=oral_snuff
replace allchew_tobacco=1 if allchew_tobacco!=1 & kuber_chewing==1 &kuber_chewing!=.
lab define allchew_tobacco 1 "yes" 0 "no" 
label values allchew_tobacco allchew_tobacco



gen othr_smktobacco=1 if B10e>0 &B10e!=999 &B10e!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06d >0 & B06d!=999 & B06d!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06d1 >0 & B06d1!=999 & B06d1!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06e >0 &B06e!=999 & B06e!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06e1 >0 &B06e1!=999 & B06e1!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06f >0 & B06f!=999 & B06f!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06f1 >0 & B06f1!=999 & B06f1!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06g >0 & B06g!=999 & B06g!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10d >0 & B10d!=999 & B10d!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10f >0 & B10f!=999 & B10f!=.
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10g >0 & B10g!=999 & B10g!=.

replace othr_smktobacco =0 if othr_smktobacco==.
lab define othr_smktobacco 1 "yes" 0 "no" 
label values othr_smktobacco othr_smktobacco



lab define RESIDENCE 1 "Urban" 2 "Rural" 
label values RESIDENCE RESIDENCE


lab var manuf_cig "Manufactured cigarettes"  
lab var hand_rolled "Hand-rolled cigerettes"    
lab var any_cigs "Any cigerettes"    
lab var smk_tobacco "Any smoked tobacco"  
lab var oral_snuff "Snuff by mouth"   
lab var nasal_snuff "Snuff by nose"  
lab var any_snuff "Snuff by nose or mouth"
lab var smkless_tobacco "Any smokeless tobacco" 
lab var any_tobacco "Any type of tobacco" 
lab var kuber "Kuber"    
lab var chew_tobacco "Chewing tobacco/quid betel"   
lab var othr_smktobacco "Other smoking tobacco"  
lab var kuber_chewing "Betel quid and kuber chewing tobacco"  
lab var allchew_tobacco "Betel quid kuber snuff tobacco"  



lab var age_grp1 "Five year age group"
lab var age_grp2 "Ten year age group"
lab var age_grp3 "Other age group"

lab var education "Education"
lab var RESIDENCE "Rural_urban"


* Set survey design
rename gatscluster cluster
ren gatsstrata strata
svyset cluster [pweight=gatsweight], strata(strata) vce(linearized) singleunit(certainty)

save "$DataOUT/GATSK2014_av.dta", replace


