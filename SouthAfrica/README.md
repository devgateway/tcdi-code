# South Africa
## Prevalence
This folder contains code that was used to calculate smoking prevalence rates for the Tobacco Control Data Initiative (TCDI) South Africa dashboard using data from National Income Dynamics Study (NIDS) 2017. Code in both Stata and R is provided.


### Data
We use 2017 National Income Dynamics Study Wave 5 data. This is a nationally representative sample of South Africans and include questions about smoking, age, gender, highest education, race and location that are used to calculate prevalence rates. The data are available for download from [DataFirst](https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/712).  
Both the Stata dofile and R script assume that the NIDS data has been downloaded.

### Code
#### R
##### Description
SA_smoking_prevalence.r
* Loads NIDS Data
* Creates variables used for analysis
* Creates prevalence tables

#### Required packages
* svy - estimates standard errors for survey data
* haven - loads stata data (default data format for NIDS)
* tidyverse - dplyr, mgaritrr are used in creating variables for analysis

##### Programming notes
Users should update file paths to the data.


#### Stata
##### Description
SA_smoking_prevalence.do
* Loads NIDS Data
* Creates variables used for analysis
* Creates prevalence tables

##### Programming notes
Users should update file paths the first section of the SA_smoking_prevalence.do file.
