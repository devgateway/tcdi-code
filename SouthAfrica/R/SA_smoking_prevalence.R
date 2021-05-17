########################################################################
# Name:         SA_smoking_prevalence.R
# Description:  Estimate smoking prevalence rates in South Africa
# Inputs:       NIDS data
# Outputs:      Prevalence tables
#
# Packages:     tidyverse
#               haven
#               survey
########################################################################

# install libraries if running for first time
# install.packages(c("tidyverse", "haven", "survey"))

##### Load Libraries ####
library(tidyverse)
library(haven)
library(survey)

setwd("TCID/SouthAfrica/Analysis")


#### Create data for analysis ####
# Load data 
adult <-      read_dta("SouthAfrica/data/Adult_W5_Anon_V1.0.0.dta")
hhderived <-  read_dta("SouthAfrica/data/hhderived_W5_Anon_V1.0.0.dta")
link <-       read_dta("SouthAfrica/data/Link_File_W5_Anon_V1.0.0.dta")
indderived <- read_dta("SouthAfrica/data/indderived_W5_Anon_V1.0.0.dta")

# Join data frames
nids <- inner_join(adult, indderived)
nids <- left_join(nids, hhderived, by = c("w5_hhid" = "w5_hhid"))
nids <- left_join(nids, link)

# filter data so that we keep the rows and columns we need
nids <- nids %>% 
  select(w5_hhid, pid, w5_a_hllfsmk, w5_best_age_yrs, w5_best_edu, w5_a_edschgrd, 
             w5_a_ed17curlev, w5_geo2011, w5_best_race, w5_best_gen, w5_wgt, w5_dc2001,
             cluster, w5_a_outcome) %>%
  filter(w5_a_hllfsmk >= 0 & w5_best_gen >= 0  &  w5_a_outcome == 1 & w5_best_age_yrs >= 15 & w5_wgt >0) 

##### Create variables for analysis #####
# smoking indicator
nids <- nids %>%
  mutate(smoke=ifelse(w5_a_hllfsmk== 1, 1,0)) 

# age groups 
nids <- nids %>%
  mutate(age_grp = ifelse(w5_best_age_yrs %in% 15:17, "15-17",
                          ifelse(w5_best_age_yrs %in% 18:24, "18-24",
                                 ifelse(w5_best_age_yrs %in% 25:54, "25-54", "55+"

                                                                               ))))
# Education
nids$education <- NA
nids$education[nids$w5_best_edu == 0 | nids$w5_best_edu == 25] <- "No schooling"
nids$education[nids$w5_best_edu>=1 & nids$w5_best_edu<=7] <- "Primary School"
nids$education[ nids$w5_best_edu==16   & nids$w5_a_edschgrd>=1 & nids$w5_a_edschgrd<=7] <- "Primary School"
nids$education[ nids$w5_best_edu==18   & nids$w5_a_edschgrd>=1 & nids$w5_a_edschgrd<=7] <- "Primary School"

nids$education[nids$w5_best_edu>=8 & nids$w5_best_edu<=11] <- "Incomplete Secondary" 

nids$education[nids$w5_best_edu==16 & 
               nids$w5_a_edschgrd>=8 & nids$w5_a_edschgrd<=11] <- "Incomplete Secondary" 

nids$education[nids$w5_best_edu==18 & 
               nids$w5_a_edschgrd>=8 & nids$w5_a_edschgrd<=11] <- "Incomplete Secondary" 

nids$education[nids$w5_best_edu == 14 | nids$w5_best_edu == 27 | nids$w5_best_edu == 28 |
             nids$w5_best_edu == 30 | nids$w5_best_edu == 31] <- "Incomplete Secondary" 

nids$education[(nids$w5_a_edschgrd == 14 | nids$w5_a_edschgrd == 27 | nids$w5_a_edschgrd == 28 |
               nids$w5_a_edschgrd == 30 | nids$w5_a_edschgrd == 31) &
               nids$w5_best_edu==16] <- "Incomplete Secondary" 

nids$education[(nids$w5_a_edschgrd == 14 | nids$w5_a_edschgrd == 27 | nids$w5_a_edschgrd == 28 |
                nids$w5_a_edschgrd == 30 | nids$w5_a_edschgrd == 31) &
               nids$w5_best_edu==18] <- "Incomplete Secondary" 

nids$education[(nids$w5_best_edu==16 | nids$w5_best_edu==18) & (nids$w5_a_edschgrd==12)] <- "Matric"
nids$education[nids$w5_best_edu == 12 | nids$w5_best_edu == 15 | 
               nids$w5_best_edu == 29 | nids$w5_best_edu == 32] <- "Matric"
nids$education[nids$w5_best_edu == 17 | nids$w5_best_edu == 19 | nids$w5_best_edu == 20 | 
               nids$w5_best_edu == 21 | nids$w5_best_edu == 22 | nids$w5_best_edu == 23] <- "Post Secondary"
nids$education[!is.na(nids$w5_a_ed17curlev)] <- "Still in School"



# Gender
nids <- nids %>%
  mutate(gender=ifelse(w5_best_gen == 1, "Male", "Female"))


# Race
nids <- nids %>%
  mutate(race = ifelse(w5_best_race ==1, "Black",
                       ifelse(w5_best_race == 2, "Coloured",
                              ifelse(w5_best_race == 3, "Indian / Asian", "White"
                                     ))))
nids$race[nids$w5_best_race <= 0] <- NA
  
  
nids <- nids %>%
  mutate(urban_rural = ifelse(w5_geo2011==2, "Urban", "Rural"))

  
#### Prevalence tables ####

# set survey design 
# Specify the strata, clusters and weights in the data
svyd <- svydesign(id =~ cluster, weights = ~w5_wgt, data = nids, strata = ~w5_dc2001, nest=TRUE)


# Calculate the prevalence rates and confidence intervals
age_grp_res <- svyby(~I(smoke),~age_grp, design=svyd, svyciprop, vartype="ci", method="logit")
gender_res <- svyby(~I(smoke),~gender, design=svyd, svyciprop, vartype="ci", method="logit")
education_res <- svyby(~I(smoke),~education, design=svyd, svyciprop, vartype="ci", method="logit")
urban_rural_res <- svyby(~I(smoke),~urban_rural, design=svyd, svyciprop, vartype="ci", method="logit")
total_res <- svyciprop(~I(smoke), design = svyd, method = "logit")

# Print results
age_grp_res
gender_res
education_res
urban_rural_res
total_res

# Calculate the prevalence rates and confidence intervals by gender
age_grp_res_gend <- svyby(~I(smoke),~age_grp+gender, design=svyd, svyciprop, vartype="ci", method="logit")
education_res_gend <- svyby(~I(smoke),~education+gender, design=svyd, svyciprop, vartype="ci", method="logit")
urban_rural_res_gend <- svyby(~I(smoke),~urban_rural+gender, design=svyd, svyciprop, vartype="ci", method="logit")

# Print results 
age_grp_res_gend
education_res_gend
urban_rural_res_gend




