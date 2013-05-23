## provHospitalOutcomes.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)

myOutputFile <- synStore(File("~/QuantWork/data.store/cmsMedicare/Hospital_Outcome_Of_Care_Measures.csv", parentId = 'syn1834666'), 
                         used = list(list(name="Hospital_Outcome_Of_Care_Measures.csv", url = "https://data.medicare.gov/Hospital-Compare/Hospital-Outcome-Of-Care-Measures/mzvd-scrs", wasExecuted=F)),
                         activityName="Download US Data.Medicare.Gov Hospital outcome data", 
                         activityDescription="A .csv file that outcomes by hospital")