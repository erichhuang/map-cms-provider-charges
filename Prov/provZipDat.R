## provZipDat.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)

myOutputFile <- synStore(File("~/QuantWork/Cartography/zipcode.csv", parentId='syn1834666'), 
                         used=list(list(name="zipcode.csv", url="http://mappinghacks.com/data/zipcode.zip", wasExecuted=F)),
                         activityName="Downloaded US zipcode geocode data", 
                         activityDescription="A .csv file that maps US zipcodes to latitude/longitude centroids")