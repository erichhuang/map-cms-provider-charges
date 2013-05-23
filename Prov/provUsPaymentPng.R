## provUsPaymentPng.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)
require(rGithubClient)

## SOURCE GITHUB REPO
cmsRepo <- getRepo('erichhuang/cms-provider-charge-data/')

repoURL <- getPermlink(cmsRepo, 'Analysis/unitedStatesDRG470.R')
scriptName <- basename(repoURL)

## GET INPUT ENTITIES
cmsDat <- getEntity('syn1834667')
zipDat <- getEntity('syn1855781')

## GENERATE FILE ENTITY WITH PROVENANCE
myOutputFile <- synStore(File("Plots/usPayment.png", parentId = 'syn1834666'), 
                         used = list(list(name = scriptName, url = repoURL, wasExecuted = T), 
                                     list(entity = cmsDat, wasExecuted = F),
                                     list(entity = zipDat, wasExecuted = F)),
                         activityName = "Generate US map with overlaid payment data", 
                         activityDescription = "Stamen toner map with ggmap overlay")