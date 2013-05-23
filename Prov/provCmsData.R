## provCmsData.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)
require(rGithubClient)

## SOURCE CONVENIENCE FUNCTIONS
sourceRepoFile('erichhuang/rStartup', 'startupFunctions.R')

## DATA OUTPUTS
fileEnt <- getEntity('syn1834669')
objEnt <- getEntity('syn1834667')


## DEFINE ACTIVITY
cmsLink <- 'http://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/IPPS_DRG_CSV.zip'

cmsAct <- Activity(name = 'Download CMS Provider Charge Data',
                       used = list(
                         list(url = cmsLink, name = basename(cmsLink), wasExecuted = F)
                       ))

cmsAct <- createEntity(cmsAct)

# An object of class "Activity"
# Slot "properties":
#   $id
# [1] "1834672"
# 
# $name
# [1] "Download CMS Provider Charge Data"
# 
# $description
# NULL
# 
# $etag
# [1] "ee0340c2-b3c0-45af-b5ce-963fad20034e"
# 
# $createdOn
# [1] "2013-05-08T20:18:06.392Z"
# 
# $modifiedOn
# [1] "2013-05-08T20:18:06.392Z"
# 
# $createdBy
# [1] "273956"
# 
# $modifiedBy
# [1] "273956"
# 
# $used
# $used[[1]]
# $used[[1]]$concreteType
# [1] "org.sagebionetworks.repo.model.provenance.UsedURL"
# 
# $used[[1]]$wasExecuted
# [1] FALSE
# 
# $used[[1]]$name
# [1] "IPPS_DRG_CSV.zip"
# 
# $used[[1]]$url
# [1] "http://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/IPPS_DRG_CSV.zip"

targetEnts <- list(fileEnt, objEnt)

generatedByList(entityList = targetEnts, activity = cmsAct)