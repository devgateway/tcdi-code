******====================================================================
*** Date: 24 Jan 2022
*** Dofile created by Terefe Gelibo
*** Purpose of the dofile: To clean and recode GATS2016 data
*** Input data: ETH_GATS_Public_Use_24Oct2018.dta
*			    		    
*** output data:ETH_GATS_Recoded.dta
			
****====================================================================

clear 

set more off

log using "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\ETHGATS_2016\04.Output\ETHGATS_Cleaning.log", append

capture log close

 
 use "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\ETHGATS_2016\02. Data\ETH_GATS_Public_Use_24Oct2018.dta", clear
 
 cd "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\ETHGATS_2016\04.Output"
 

**A. Create analytical Variables
*1. Gender
gen gender=A01
replace gender=0 if gender ==2
lab define gender 1 "male" 0 "female"
label values gender gender
lab var gender "sex of the respondent"


*2. Residence
gen  place=Residence
lab define  place 1 "Urban" 2 "Rural" 
label values  place  place
lab var  place "Rural_urban residence"

*3.  Age

*3.1. Five year age group

gen age=AGE
gen age_grp1 = .
replace age_grp1 = 1 if age >= 15 & age < 20
replace age_grp1 = 2 if age >= 20 & age < 25
replace age_grp1 = 3 if age >= 25 & age < 30
replace age_grp1 = 4 if age >= 30 & age < 35
replace age_grp1 = 5 if age >= 35 & age < 40
replace age_grp1 = 6 if age >= 40 & age < 45
replace age_grp1 = 7 if age >= 45 & age < 50
replace age_grp1 = 8 if age >= 50 & age < 55
replace age_grp1 = 9 if age >= 55 & age < 60
replace age_grp1 = 10 if age >= 60 & age < 65
replace age_grp1 = 11 if age >= 65 
lab define age1 1 "15-19" 2 "20-24" 3 "25-29" 4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49" 8 "50-54" 9 "55-59" 10 "60-64"  11 "65+"
label values age_grp1 age1
lab var age_grp1 "Five year age group of respondents" 

*3.2. Ten year age group
gen age_grp2 = .
replace age_grp2 = 1 if age >= 15 & age < 25
replace age_grp2 = 2 if age >= 25 & age < 35
replace age_grp2 = 3 if age >= 35 & age < 45
replace age_grp2 = 4 if age >= 45 & age < 55
replace age_grp2 = 5 if age >= 55 & age < 65
replace age_grp2 = 6 if age >= 65
lab define age2 1 "15-24" 2 "25-34" 3 "35-49" 4 "50-59" 5 "60-64" 6 "65+"
label values age_grp2 age2
lab var age_grp2 "Ten year age group of respondents" 

*3.3. other age group
gen age_grp3=.
replace age_grp3 = 1 if age >= 15 & age < 18
replace age_grp3 = 2 if age >= 18 & age < 25
replace age_grp3 = 3 if age >= 25 & age < 45
replace age_grp3 = 4 if age >= 45 & age < 65
replace age_grp3 = 5 if age >= 65
lab define age3 1 "15-17" 2 "18-24" 3 "25-44" 4 "45-64" 5 "65+" 
label values age_grp3 age3
lab var age_grp3 "Other age group of respondents" 

*3.4.Age group from GATS report
gen age_grp4=.
replace age_grp4 = 1 if age >= 15 & age < 25
replace age_grp4 = 2 if age >= 25 & age < 45
replace age_grp4 = 3 if age >= 45 & age < 65
replace age_grp4 = 4 if age >= 65
lab define age4 1 "15-24" 2 "25-44" 3 "45-64" 4 "65+" ,modify
label values age_grp4 age4
lab var age_grp4 "Age group of respondents-GATS report" 


*4. Education
gen education=A04
* Primary completed includes those who completed primary and those in secondary who had not completed secondary
replace education =3 if education==4
replace education =4 if education>=5 & education<=8
lab define education 1 "No education" 2 "Primary incomplete" 3 "Primary complete"  4 "Secondary complete or more" 
label values education education
numlabel, add
replace education =. if education ==77|education==99
lab var education "Education"

4. Region
gen region=.
*The 11 adminstrative regions- a vaible created from the EA codes. 
replace region =1 if EA<=38
replace region =2 if EA>=39 & EA <=70
replace region =3 if EA>=71 & EA <=114
replace region =4 if EA>=115 & EA <=160
replace region =5 if EA>=161 & EA <=196
replace region =6 if EA>=197 & EA <=227
replace region =7 if EA>=228 & EA <=269
replace region =8 if EA>=270 & EA <=298
replace region =9 if EA>=299 & EA <=326
replace region =10 if EA>=327 & EA <=346
replace region =11 if EA>=347 & EA <=375
lab define region 1 "Tigray" 2 "Afar" 3 "Amhara "  4 "Oromia"  5 "Somali"  6 "Benishangul" 7 "SNNPR" 8 "Gambela" 9 "Harari" 10 "Addis Ababa" 11 "Dire Dawa", modify
label values region region

*5. Smoking variables 

*5.1 Current tobacco smokers
gen curr_smoke=1 if B01<=2    //current tobacco smoker 
replace curr_smoke=0 if B01>=3 
lab define curr_smoke  1 "yes" 0 "no" , modify
label values curr_smoke curr_smoke 
lab var curr_smoke " Prevalence of current tobacco smokers"


*5.2 Current daily tobacco smokers
gen curr_smoked=1 if B01<=1    //current tobacco smoker 
replace curr_smoked=0 if B01>=2 
lab define curr_smoked  1 "yes" 0 "no" , modify
label values curr_smoked curr_smoked 
lab var curr_smoked " Prevalence of current dialy tobacco smokers"


*5.3. current Smokeless tobacco use
gen curr_smokeless=1 if C01<=2  // any SMOKELESS tobacco
replace curr_smokeless=0 if C01>=3  & C01!=7
lab define curr_smokeless 1 "yes" 0 "no" 
label values curr_smokeless curr_smokeless
lab var curr_smokeless " Prevalence of current smokeless tobacco use"


*5.4. Current tobacco use
gen tobacco_use =.   // includes smoke and smokeless
replace tobacco_use =1 if  curr_smoke==1| curr_smokeless==1 
replace tobacco_use=0 if curr_smoke==0 & curr_smokeless==0
lab define tobacco_use  1 "yes" 0 "no" 
label values tobacco_use tobacco_use 
lab var tobacco_use " Prevalence of current tobacco use"

*5.5. Cigarettes
ren B06A B06a
ren B06A1 B06a1
ren B06B B06b
ren B06B1 B06b1
ren B10A B10a
ren B10B B10b

*5.4.1 prevalenec of current manufactured cigarettes smokers
gen manuf_cigs=1 if B06a>0 &B06a<888
replace manuf_cigs =1 if manuf_cigs==. & B06a1>0 &B06a1<888
replace manuf_cigs = 1 if manuf_cigs==. & B10a >0 & B10a<888
replace manuf_cigs=0 if manuf_cigs==.
lab define manuf_cigs 1 "yes" 0 "no" 
label values manuf_cigs manuf_cigs
lab var manuf_cig "Prevalenec of current manufactured cigarette smokers"  
 

gen hand_rolled=1 if B06b>0  &B06b<888
replace hand_rolled=1 if hand_rolled==. & B06b1>0 & B06b1<888
replace hand_rolled =1 if hand_rolled==. & B10b>0 & B10b<888
replace hand_rolled=0 if hand_rolled==.
lab define hand_rolled 1 "yes" 0 "no" 
label values hand_rolled hand_rolled 

gen any_cigs =1 if manuf_cigs ==1 & manuf_cigs!=.    // manufactured and RYO cigs
replace any_cigs=1 if any_cigs !=1 &  hand_rolled==1
replace any_cigs=0 if any_cigs==.
lab define any_cigs 1 "yes" 0 "no" 
label values any_cigs any_cigs

***5.5. * Snuff, chewing tobacco
ren C06A C06a
ren C06A1 C06a1
ren C10A C10a

gen any_snuff=1 if C06a>0 & C06a<888 
replace any_snuff =1 if  any_snuff !=1 & C06a1>0 & C06a1<888
replace any_snuff=1 if any_snuff!=1 &C10a>0 &C10a<888.
replace any_snuff=0 if any_snuff==. 
replace any_snuff=. if C06a1>=888 &C06a>=888 &C10a>=888
lab define any_snuff 1 "yes" 0 "no" 
label values any_snuff any_snuff

ren C06C C06c
ren C06C1 C06c1
ren C06D C06d
ren C06D1 C06d1
ren C10C C10c

*only includes chewing kuber
gen kuber=1 if C06c>0 /*& C06e!=. & C06e!=999*/ & C06c<888
replace kuber =1 if kuber!=1 & C06c1 >0 & C06c1<888
replace kuber =0 if kuber==. 
replace kuber=. if C06c>=888
lab define kuber 1 "yes" 0 "no" 
label values kuber kuber

*Only includes betel quid
gen chew_tobacco=1 if C06d>0 &C06d!=999 &C06d!=.
replace chew_tobacco=1 if chew_tobacco!=1 & C06d1!="" & C06d1!=" "
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

/* all chewing tobacco: snuff (oral), kuber, betel quid 
gen allchew_tobacco=oral_snuff
replace allchew_tobacco=1 if allchew_tobacco!=1 & kuber_chewing==1 &kuber_chewing!=.
lab define allchew_tobacco 1 "yes" 0 "no" 
label values allchew_tobacco allchew_tobacco*/

ren B06D B06d
ren B06E B06e
ren B06F B06f
ren B06G B06g
ren B10D B10d
ren B10E B10e
ren B10F B10f
ren B10G B10g

gen othr_smktobacco=1 if B10e>0 &B10e<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06d >0 & B06d<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06e >0 &B06e<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06f >0 & B06f<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B06g >0 & B06g<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10d >0 & B10d<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10f >0 & B10f<888
replace  othr_smktobacco  =1 if  othr_smktobacco !=1 & B10g >0 & B10g<888

replace othr_smktobacco =0 if othr_smktobacco==.
lab define othr_smktobacco 1 "yes" 0 "no" 
label values othr_smktobacco othr_smktobacco


*6. Label variables
*lab var manuf_cig "Manufactured cigarettes"  
*lab var hand_rolled "Hand-rolled cigerettes"    
*lab var any_cigs "Any cigerettes"    
*lab var smk_tobacco "Any smoked tobacco"  
*lab var oral_snuff "Snuff by mouth"   
*lab var nasal_snuff "Snuff by nose"  
*lab var any_snuff "Snuff by nose or mouth"
*lab var smkless_tobacco "Any smokeless tobacco" 
*lab var any_tobacco "Any type of tobacco" 
*lab var kuber "Kuber"    
*lab var chew_tobacco "Chewing tobacco/quid betel"   
*lab var othr_smktobacco "Other smoking tobacco"  
*lab var kuber_chewing "Betel quid and kuber chewing tobacco"  
*lab var allchew_tobacco "Betel quid kuber snuff tobacco"  
*lab var age_grp1 "Five year age group"
*lab var age_grp2 "Ten year age group"
*lab var age_grp3 "Other age group"



*7. Set survey design
rename gatscluster EA
ren GATSSTRATA region

svyset EA [pweight=gatsweight], strata(region) vce(linearized) singleunit(certainty)


***save the data
save "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\ETHGATS_2016\02. Data\ETH_GATS_Recoded.dta" , replace


