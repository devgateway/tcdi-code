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
install.packages(c("tidyverse", "haven", "survey"))


##### Load Libraries ####
library(tidyverse)
library(haven)
library(survey)

setwd("TCID/SouthAfrica/Analysis")


#### Create data for analysis ####
# Load data 
adult <-      read_dta("Adult_W5_Anon_V1.0.0.dta")
hhderived <-  read_dta("hhderived_W5_Anon_V1.0.0.dta")
link <-       read_dta("Link_File_W5_Anon_V1.0.0.dta")
indderived <- read_dta("indderived_W5_Anon_V1.0.0.dta")

# Join data frames
df <- inner_join(adult, indderived)
df <- left_join(df, hhderived, by = c("w5_hhid" = "w5_hhid"))
df <- left_join(df, link)


# filter data so that we keep the rows and columns we need
df <- df %>% 
  select(w5_hhid, pid, w5_a_hllfsmk, w5_best_age_yrs, w5_best_edu, w5_a_edschgrd, 
             w5_a_ed17curlev, w5_geo2011, w5_best_race, w5_best_gen, w5_wgt, w5_dc2001,
             cluster, w5_a_outcome) %>%
  filter(w5_a_hllfsmk >= 0 & w5_best_gen >= 0  &  w5_a_outcome == 1 & w5_best_age_yrs >= 15 & w5_wgt >0) 

##### Create variables for analysis #####
# smoking indicator
df <- df %>%
  mutate(smoke=ifelse(w5_a_hllfsmk== 1, 1,0)) 

# age groups 
df <- df %>%
  mutate(age_grp = ifelse(w5_best_age_yrs %in% 15:17, "15-17",
                          ifelse(w5_best_age_yrs %in% 18:24, "18-24",
                                 ifelse(w5_best_age_yrs %in% 25:54, "25-54", "55+"

                                                                               ))))
# Education
df$education <- NA
df$education[df$w5_best_edu == 0 | df$w5_best_edu == 25] <- "No schooling"
df$education[df$w5_best_edu>=1 & df$w5_best_edu<=7] <- "Primary School"
df$education[ df$w5_best_edu==16   & df$w5_a_edschgrd>=1 & df$w5_a_edschgrd<=7] <- "Primary School"
df$education[ df$w5_best_edu==18   & df$w5_a_edschgrd>=1 & df$w5_a_edschgrd<=7] <- "Primary School"

df$education[df$w5_best_edu>=8 & df$w5_best_edu<=11] <- "Incomplete Secondary" 

df$education[df$w5_best_edu==16 & 
               df$w5_a_edschgrd>=8 & df$w5_a_edschgrd<=11] <- "Incomplete Secondary" 

df$education[df$w5_best_edu==18 & 
               df$w5_a_edschgrd>=8 & df$w5_a_edschgrd<=11] <- "Incomplete Secondary" 

df$education[df$w5_best_edu == 14 | df$w5_best_edu == 27 | df$w5_best_edu == 28 |
             df$w5_best_edu == 30 | df$w5_best_edu == 31] <- "Incomplete Secondary" 

df$education[(df$w5_a_edschgrd == 14 | df$w5_a_edschgrd == 27 | df$w5_a_edschgrd == 28 |
               df$w5_a_edschgrd == 30 | df$w5_a_edschgrd == 31) &
               df$w5_best_edu==16] <- "Incomplete Secondary" 

df$education[(df$w5_a_edschgrd == 14 | df$w5_a_edschgrd == 27 | df$w5_a_edschgrd == 28 |
                df$w5_a_edschgrd == 30 | df$w5_a_edschgrd == 31) &
               df$w5_best_edu==18] <- "Incomplete Secondary" 

df$education[(df$w5_best_edu==16 | df$w5_best_edu==18) & (df$w5_a_edschgrd==12)] <- "Matric"
df$education[df$w5_best_edu == 12 | df$w5_best_edu == 15 | 
               df$w5_best_edu == 29 | df$w5_best_edu == 32] <- "Matric"
df$education[df$w5_best_edu == 17 | df$w5_best_edu == 19 | df$w5_best_edu == 20 | 
               df$w5_best_edu == 21 | df$w5_best_edu == 22 | df$w5_best_edu == 23] <- "Post Secondary"
df$education[!is.na(df$w5_a_ed17curlev)] <- "Still in School"



# Gender
df <- df %>%
  mutate(gender=ifelse(w5_best_gen == 1, "Male", "Female"))


# Race
df <- df %>%
  mutate(race = ifelse(w5_best_race ==1, "Black",
                       ifelse(w5_best_race == 2, "Coloured",
                              ifelse(w5_best_race == 3, "Indian / Asian", "White"
                                     ))))
df$race[df$w5_best_race <= 0] <- NA
  
  
df <- df %>%
  mutate(urban_rural = ifelse(w5_geo2011==2, "Urban", "Rural"))

  
#### Prevalence tables ####

# set survey design 
# Specify the strata, clusters and weights in the data
svyd <- svydesign(id =~ cluster, weights = ~w5_wgt, data = df, strata = ~w5_dc2001, nest=TRUE)


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

