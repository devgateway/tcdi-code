** Dofile created by Terefe G
*** Purpose of the dofile: provide one way Tables on the predictors of cervical cancer screening in Ethiopia: evidence from NCD STEP survey 2015
*** Input data: EPHIA_merged_recoded_trimmed_Nov16.dta
*** Outcome: Table 

*====================================================================

use "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\02. Output\ETH_GATS_Recoded.dta", clear

cd "D:\01.Docs\02. Others\11. Personal\22.TCDI\12. Data\ETHGATS_2016\04.Output"

***************survey set the data
**Table 1-one way table-Jan 1, 2022

*svyset gatscluster [pweight=gatsweight], strata(GATSSTRATA)


*1.******weighted percent with uweighted numbers-table 1

tabout gender  place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoke  curr_smoked curr_smokeless tobacco_use using table1.txt, replace c(col ci) svy f(1) ///
style (htm) oneway percent body font(bold) npos(col) cisep(-) 
title("Table 1: Distribution of geographic, demographic and behavioural characteristics of adults ages 15 and above GATS Ethiopia, 2016.")

*2.**weighted percent with weighted numbers-table 1

tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoke  curr_smoked curr_smokeless tobacco_use using table1weighted.txt, replace c(col ci) svy f(1)style(htm) oneway percent stats(chi2) body font(bold) pop nwt(gatsweight) npos(col) cisep(-)

title("Table 1: Distribution of geographic, demographic and behavioural characteristics of adults ages 15 and above GATS Ethiopia, 2016.")


****Indicator 1- current tobacco smoke

*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoke  using table2curr_smoke.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) npos(col) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current tobacco smokers by selected characteristics – GATS Ethiopia, 2016.")


*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoke using table2curr_smokeweighted.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) pop nwt(gatsweight) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current tobacco smokers by selected characteristics – GATS Ethiopia, 2016.")


****Indicator 2- current daily tobacco smoke

*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoked  using table2curr_smoked.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) npos(col) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current daily tobacco smokers by selected characteristics – GATS Ethiopia, 2016.")


*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smoked using table2curr_smokedweighted.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) pop nwt(gatsweight) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current daily tobacco smokers by selected characteristics – GATS Ethiopia, 2016.")

****Indicator 3- current smokeless tobacco use

*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smokeless using table2curr_smokeless.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) npos(col) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current smokeless tobacco use smokers by selected characteristics – GATS Ethiopia, 2016.")


*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region curr_smokeless using table2curr_smokelessweighted.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) pop nwt(gatsweight) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current smokeless tobacco use by selected characteristics – GATS Ethiopia, 2016.")

****Indicator 4- current tobacco use

*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region tobacco_use using table2tobacco_use.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) npos(col) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current tobacco use by selected characteristics – GATS Ethiopia, 2016.")

*3.**weighted percent with weighted numbers-table 2
tabout gender place age_grp1 age_grp2 age_grp3 age_grp4 education region tobacco_use using table2tobacco_useweighted.txt, replace c(row ci) svy f(1)style(htm) percent stats(chi2) body font(bold) pop nwt(gatsweight) cisep(-)

title("Table 2: Percentage of adults ≥15 years old who are current tobacco use by selected characteristics – GATS Ethiopia, 2016.")