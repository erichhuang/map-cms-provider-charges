## firstPass.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)
require(ggmap)
require(doMC)

registerDoMC()

objEnt <- loadEntity('syn1834667')
cmsDat <- objEnt$objects$cmsDat

## SUBSET THE DATA
# find the levels of the DRG codes
drgLevels <- levels(cmsDat$DRG.Definition)

# let's find the DRG that has the most discharges
drgDischarges <- mclapply(drgLevels, function(x){
  matchRows <- grep(x, cmsDat$DRG.Definition)
  subSet <- cmsDat[matchRows, 'Total.Discharges']
})
names(drgDischarges) <- drgLevels

totalDischarges <- mclapply(drgDischarges, sum)
totalDischarges <- unlist(totalDischarges)
studyTarget <- names(drgDischarges)[which.max(totalDischarges)]

# studyTarget
# [1] "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC"

# so let's subset on DRG 470
subCmsDat <- cmsDat[cmsDat$DRG.Definition == studyTarget & cmsDat$Provider.State == 'WA', ]

# # so we have a ragged list, let's pad with NAs and convert to matrix
# maxLength <- max(sapply(drgDischarges, length))
# paddedList <- mclapply(drgDischarges, function(x){
#   c(x, rep(NA, maxLength - length(x)))
# })
# drgDischargeMat <- as.data.frame(do.call(rbind, paddedList))
# drgDischargeMat <- data.frame('drg' = rownames(drgDischargeMat), drgDischargeMat)
# mDrgDcMat <- melt(drgDischargeMat)
# 
# dcDensPlot <- ggplot(mDrgDcMat, aes(value, fill = factor(drg))) + geom_density(alpha = 0.2)

# focus on western washington
# waLoc <- geocode('bainbridge island, washington')
# waMap <- qmap(as.numeric(waLoc), source = 'stamen', maptype = 'toner', zoom = 10)

# top left 47.801625,-122.786636
# bottom right 47.421119,-121.888504

mapDat <- get_cloudmademap(bbox = c(left = -122.786636, bottom = 47.421119, right = -121.888504, top = 47.801625), 
                        highres = T, api_key = apiKey, maptype = 58916)

waMap <- ggmap(mapDat)

# locate all the zipcodes
hospitalLocs <- lapply(as.character(subCmsDat$Provider.Zip.Code), geocode)
hospLocsMat <- do.call(rbind, hospitalLocs)
colnames(hospLocsMat) <- c('lon', 'lat')

# new dataframe with hospital locations and charge and payment data
waDF <- data.frame('lon' = hospLocsMat$lon,
                   'lat' = hospLocsMat$lat,
                   'charge' = subCmsDat$Average.Covered.Charges,
                   'payment' = subCmsDat$Average.Total.Payments,
                   'yield' = subCmsDat$Average.Total.Payments/subCmsDat$Average.Covered.Charges)

# plot points
chargeMap <- waMap + geom_point(aes(x = lon, y = lat, size = charge), data = waDF, colour = 'red', alpha = 0.4) +
  scale_size(range = c(5, 25), guide = 'none')

paymentMap <- waMap + geom_point(aes(x = lon, y = lat, size = payment), data = waDF, colour = 'orange', alpha = 0.4) +
  scale_size(range = c(5, 25), guide = 'none')

yieldMap <- waMap + geom_point(aes(x = lon, y = lat, size = yield), data = waDF, colour = 'green', alpha = 0.4) +
  scale_size(range = c(5, 25), guide = 'none')
