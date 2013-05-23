## provZipDat.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)

myOutputFile <- synStore(File("~/QuantWork/Cartography/Zipcode/infochimps_dataset_11891_download_15361-tabular 2/US.txt", parentId='syn1834666'), 
                         used=list(list(name="US.txt", url="http://www.infochimps.com/datasets/geonamesorg-postal-code-files-us-zip-code-geolocations/downloads/149071", wasExecuted=F)),
                         activityName="Download Geonames.org US zipcode geocode data", 
                         activityDescription="A .txt file that maps US zipcodes to latitude/longitude")