########################################################################
# Name:         Nigeria_tobacco_prevalence.R
# Description:  Estimate smoking prevalence rates in Nigeria
# Inputs:       Nigeria Demographic and Health Survey
#               UNPD Population estimates
# Outputs:      Prevalence tables
#
# Packages:     tidyverse
#               haven
#               survey
########################################################################

# install libraries if running for first time
# install.packages(c("tidyverse", "haven", "survey"))

library(tidyverse)
library(haven)
library(survey)


setwd("/Users/kathryn/Dropbox/TCDI_analysis/Nigeria")




#### Load Data ####
# UNPD
undp <- read.csv("Data/Input/UNPD/WPP2019_PopulationBySingleAgeSex_1950-2019.csv")

# DHS
# Data and for women and men loaded separately
f_ndhs <- read_dta("Data/Input/DHS/NGIR7ADT/NGIR7AFL.DTA")
m_ndhs <- read_dta("Data/Input/DHS/NGMR7ADT/NGMR7AFL.DTA")


#### Clean UNPD data ####
undp <- undp %>% 
  filter(Location == "Nigeria" & Time == "2018" & AgeGrp >= 15  & AgeGrp <= 59) %>% 
  mutate(female = ifelse(AgeGrp <= 49, PopFemale, NA))


fw <- sum(undp$female, na.rm=TRUE) * 1000
mw <- sum(undp$PopMale, na.rm=TRUE) * 1000




#### Clean female DHS ####

# Keep neccesary variables
f <- f_ndhs %>%
  select( caseid, v001, v002, v022, v021, v005,v463a, v463b, v463c,
                  v463d, v463e, v463f, v463g, v463h, v463i, v463x, v463z, v463aa,
                  v463ab, v464, v012, v013, v106, v107, v133, v149, v190, v191,
                  v190a, v191a, v024, v025, sstate)

# Rename variables
f <- f %>%
  rename(cluster = v001,  strata = v022, age_grp = v013, wealth = v190, 
         education = v106, zone = v024, residence = v025, age = v012)

# Reweight using UNDP data
f$wgt <- f$v005/1000000 * (fw/nrow(f))



# Create variables


f$gender <- "Female"



# Smoking variables
f$smoke_cig <- ifelse(f$v463a == 1 | f$v463e == 1, 1, 0)

f$smoke_oth <- ifelse(f$v463f == 1 | f$v463b == 1| f$v463g == 1, 1, 0)

f$smoke_any = ifelse(f$smoke_cig == 1 | f$smoke_oth == 1,  1, 0)

f$smokeless_chew = ifelse(f$v463c == 1,  1, 0)

f$smokeless_snuff_nose = ifelse(f$v463d == 1, 1, 0)

f$smokeless_snuff_mouth = ifelse(f$v463h == 1, 1, 0)

f$smokeless_betel = ifelse(f$v463i == 1, 1, 0)

f$smokeless_other = ifelse(f$v463x == 1, 1, 0)

f$smokeless_any = ifelse(f$smokeless_chew == 1 | f$smokeless_snuff_nose == 1 |
                           f$smokeless_snuff_mouth == 1 | f$smokeless_betel == 1 | 
                           f$smokeless_other == 1, 1, 0)

f$any_tobacco = ifelse(f$smoke_any == 1 | f$smokeless_any == 1, 1, 0)

f <- f %>%
  select(smoke_cig, smoke_oth, smoke_any, any_tobacco, gender, age_grp, age, 
         residence, zone, education, wealth, wgt, strata, cluster, smokeless_chew,
         smokeless_betel, smokeless_snuff_mouth, smokeless_snuff_nose, 
         smokeless_any)


#### Clean Male data ####

m <- m_ndhs %>%
  select(mcaseid, mv001, mv002, mv022, mv021, mv005, mv463aa, mv463ab, mv463ac, 
         mv463ad, mv464a, mv464b, mv464c, mv464d, mv464e, mv464f, mv464g, mv484a,
         mv484b, mv484c, mv484d, mv484e, mv484f, mv484g, mv464h, mv464i, mv464j, 
         mv464k, mv464l, mv484h, mv484i, mv484j, mv484k, mv484l, mv012, mv013, 
         mv106, mv107, mv133, mv149, mv190, mv191, mv190a, mv191a, mv024, mv025,
         smstate)


m <- m %>%
  rename(cluster = mv001,  strata = mv022, age_grp = mv013, wealth = mv190, 
         education = mv106, zone = mv024, residence = mv025, age = mv012)

m$wgt <- m$mv005/1000000 * (mw/nrow(m))

m$gender = "Male"


# smoking variables
m$smoke_cig = ifelse(m$mv484a > 0 | m$mv464a > 0 | m$mv484b > 0 | m$mv464b > 0 | m$mv484c > 0 
                     | m$mv464c > 0, 1, 0)


m$smoke_oth = ifelse(m$mv484d > 0 | m$mv464d > 0 | m$mv484e > 0 | m$mv464e > 0 | 
                       m$mv484f > 0 | m$mv464f > 0 |m$mv464g > 0 |m$mv484g > 0, 
                     1, 0)


m$smoke_any = ifelse(m$smoke_cig == 1 | m$smoke_oth == 1, 1, 0)

m$smokeless_chew <- ifelse(m$mv464j > 0 | m$mv484j > 0, 1, 0)

m$smokeless_snuff_nose = ifelse(m$mv464i > 0 | m$mv484i > 0, 1, 0)
m$smokeless_snuff_mouth = ifelse(m$mv464h > 0 | m$mv484h > 0, 1, 0)
m$smokeless_betel = ifelse(m$mv464k > 0 | m$mv484k > 0, 1, 0)
m$smokeless_other = ifelse(m$mv464l > 0 | m$mv484l > 0, 1, 0)


m$smokeless_any = ifelse(m$smokeless_chew == 1 | m$smokeless_snuff_nose == 1 |
                           m$smokeless_snuff_mouth == 1 | m$smokeless_betel == 1 | m$smokeless_other == 1, 
                         1, 0)

m$any_tobacco = ifelse(m$smoke_any == 1 | m$smokeless_any == 1, 1, 0)


m <- m %>%
  select(smoke_cig, smoke_oth, smoke_any, any_tobacco, gender, age_grp, age, 
         residence, zone, education, wealth, wgt, strata, cluster, smokeless_chew,
         smokeless_betel, smokeless_snuff_mouth, smokeless_snuff_nose, 
         smokeless_any) %>%
  filter(age <= 49)



# Append male and female data
ndhs <- rbind(f, m)


#### Prevalence tables ####

# set survey design 
# Specify the strata, clusters and weights in the data
svyd <- svydesign(id =~ cluster, weights = ~wgt, data = ndhs, strata = ~strata, nest=TRUE)


# Calculate the prevalence rates and confidence intervals for any type of tobacco use
age_grp_res <- svyby(~I(any_tobacco),~age_grp, design=svyd, svyciprop, vartype="ci", method="logit")
gender_res <- svyby(~I(any_tobacco),~gender, design=svyd, svyciprop, vartype="ci", method="logit")
education_res <- svyby(~I(any_tobacco),~education, design=svyd, svyciprop, vartype="ci", method="logit")
wealth_res <- svyby(~I(any_tobacco),~wealth, design=svyd, svyciprop, vartype="ci", method="logit")
zone_res <- svyby(~I(any_tobacco),~zone, design=svyd, svyciprop, vartype="ci", method="logit")
residence_res <- svyby(~I(any_tobacco),~residence, design=svyd, svyciprop, vartype="ci", method="logit")
total_res <- svyciprop(~I(any_tobacco), design = svyd, method = "logit")

# Print results
age_grp_res
gender_res
education_res
wealth_res
zone_res
residence_res
total_res
