## overlayPaymentQualityDRG470.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)
require(ggmap)
require(mapproj)
require(doMC)

registerDoMC()

## LOAD DATA
workTable <- folderContents('syn1857079')

#                           entity.name  entity.id
# 1 US Map ggmap object (Stamen Terrain) syn1857082
# 2   US Map ggmap object (Stamen Toner) syn1857084
# 3                         drg470Subset syn1857080

subEnt <- loadEntity(workTable$entity.id[3])
mapEnt <- loadEntity(workTable$entity.id[2])
outcomeEnt <- synGet('syn1859363')
zipEnt <- synGet('syn1863902')

subTable <- subEnt$objects$subCmsDat
usMap <- mapEnt$objects$altUsMap
outcomeTab <- read.csv(getFileLocation(outcomeEnt), header = T)
zipTab <- read.delim(getFileLocation(zipEnt), header = F, sep = '\t')
colnames(zipTab) <- c('country', 'zip', 'city', 'stateName', 'stateCode', 'county', 'ctyCode', 'blank', 'lat', 'lon', 'blankB')

## SUBSET THE OUTCOME DATA
subOutcomeTab <- data.frame('provider' = outcomeTab$Provider.Number,
                            'zipcode' = outcomeTab$ZIP.Code,
                            'myoInfarct30D' = outcomeTab$Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack)

## STANDARDIZE ZIPCODES
# need leading zeros on older zipcodes
newZips <- formatC(subOutcomeTab$zipcode, width = 5, format = 'd', flag = '0')
subOutcomeTab$zipcode <- newZips

newZips <- formatC(zipTab$zip, width = 5, format = 'd', flag = '0')
zipTab$zip <- newZips

## zipTab HAS DUPLICATE ZIPS
# remove for simplicity
dupZips <- which(duplicated(zipTab$zip))
zipTab <- zipTab[-dupZips, ]
rownames(zipTab) <- zipTab$zip

## MATCH COORDINATES TO ZIPS
outcomeHospLocations <- mclapply(subOutcomeTab$zipcode, function(zipcode){
  latLong <- zipTab[zipcode, 9:10]
})

outcomeHospLocsMat <- do.call(rbind, outcomeHospLocations)

paymentHospLocations <- mclapply(subTable$Provider.Zip.Code, function(zipcode){
  latLong <- zipTab[zipcode, 9:10]
})

paymentHospLocsMat <- do.call(rbind, paymentHospLocations)

## CREATE OUTCOME DF WITH GEOCODES
subOutcomeTabFull <- data.frame(subOutcomeTab, outcomeHospLocsMat)

## CREATE PAYMENT DF WITH GEOCODES
subPaymentTabFull <- data.frame('provider' = subTable$Provider.Id,
                                'zipcode' = subTable$Provider.Zip.Code,
                                'payment' = subTable$Average.Total.Payments,
                                paymentHospLocsMat)

# make scale of payment similar to outcomes
subPaymentTabFull$payment <- subPaymentTabFull$payment/1000

## MAP PAYMENT DATA
paymentMap <- usMap + geom_point(aes(x = lon, y = lat, size = payment), data = subPaymentTabFull, alpha = 0.2, colour = '#3399FF') +
  scale_size(range = c(1, 25), guide = 'none')

overlayMap <- paymentMap + geom_point(aes(x = lon, y = lat, size = myoInfarct30D), 
                                      data = subOutcomeTabFull, alpha = 0.1, colour = 'red')


