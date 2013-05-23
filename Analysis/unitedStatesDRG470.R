## unitedStates.R

## Erich S. Huang
## Sage Bionetworks
## erich.huang@sagebase.org
## erich@post.harvard.edu

## REQUIRE 
require(synapseClient)
require(ggmap)
require(doMC)
require(png)

apiKey <- '9229d1a0df5e4c969d396d831496000b'

registerDoMC()

objEnt <- loadEntity('syn1834667')
cmsDat <- objEnt$objects$cmsDat
zipDat <- synGet('syn1855781')

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
subCmsDat <- cmsDat[cmsDat$DRG.Definition == studyTarget, ]

# need leading zeros on older zipcodes
newZips <- formatC(subCmsDat$Provider.Zip.Code, width = 5, format = 'd', flag = '0')
subCmsDat$Provider.Zip.Code <- newZips

# hospitalLocs <- lapply(as.character(subCmsDat$Provider.Zip.Code), geocode)
# avoid the google api limits by using a local file
zipTable <- read.csv(getFileLocation(zipDat), header = T)

# need leading zeros on older zipcodes
zipFive <- formatC(zipTable$zip, width = 5, format = "d", flag = "0")
rownames(zipTable) <- zipFive

hospLocations <- mclapply(subCmsDat$Provider.Zip.Code, function(zipcode){
  latLong <- zipTable[as.character(zipcode), 4:5]
})

hospLocsMat <- do.call(rbind, hospLocations)
colnames(hospLocsMat) <- c('lat', 'lon')
rownames(hospLocsMat) <- names(hospLocations)

# new dataframe with hospital locations and charge and payment data
drg470DF <- data.frame('lon' = hospLocsMat$lon,
                   'lat' = hospLocsMat$lat,
                   'charge' = subCmsDat$Average.Covered.Charges,
                   'payment' = subCmsDat$Average.Total.Payments,
                   'yield' = subCmsDat$Average.Total.Payments/subCmsDat$Average.Covered.Charges)

## lower right 22.796439,-62.182617
## upper left 49.553726,-125.332031

# mapDat <- get_cloudmademap(bbox = c(left = -125.332031, bottom = 22.796439, right = -62.182617, top = 49.553726), 
#                            highres = T, api_key = apiKey, maptype = 58916)
# too memory intensive

# mapDat <- get_map('united states', maptype = 'toner', color = 'bw', source = 'stamen')
# 
# usMap <- ggmap(mapDat)

# use raster map method
# get map from http://openstreetmap.gryph.de/bigmap.html
# Map is 8x4 tiles (2048x1024 px) at zoom 5, aspect 2.0:1
# Bbox is -135.00, 21.94, -45.00, 55.78 (l,b,r,t)

# zoom <- 5
# map <- readPNG(sprintf ('~/QuantWork/Cartography/usMap.png', zoom))
# map <- as.raster(apply(map, 2, rgb))
# 
# pxymin <- LonLat2XY(-135, 55.78, zoom, xpix = 2048, ypix = 1024)$Y # zoom + 8 gives pixels in the big map
# pxymax <- LonLat2XY(-45, 21.94, zoom, xpix = 2048, ypix = 1024)$Y
# 
# map <- map[pxymin : pxymax, ]
# 
# # set bounding box
# attr(map, "bb") <- data.frame (ll.lat = XY2LonLat (0, pxymax + 1, zoom+8)$lat, 
#                                ll.lon = -180, 
#                                ur.lat = round (XY2LonLat (0, pxymin, zoom+8)$lat), 
#                                ur.lon = 180)
# 
# class(map) <- c("ggmap", "raster")

# mapDat <- get_map('united states', maptype = 'hybrid', color = 'bw', source = 'google', zoom = )

# mapDat <- get_openstreetmap(bbox = c(left = -124,
#                                      bottom = 21.8,
#                                      right = -72.9,
#                                      top = 54),
#                             scale = 13987823)

# mapDat <- get_cloudmademap(bbox = c(left = -125.332031, bottom = 22.796439, right = -62.182617, top = 49.553726), 
#                            highres = F, api_key = apiKey, maptype = 58916, color = 'bw', zoom = 5)

mapDat <- get_stamenmap(bbox = c(left = -125.332031, bottom = 22.796439, right = -62.182617, top = 49.553726),
                        zoom = 5, maptype = 'terrain', crop = TRUE, color = 'bw')

usMap <- ggmap(mapDat)

altMapDat <- get_stamenmap(bbox = c(left = -125.332031, bottom = 22.796439, right = -62.182617, top = 49.553726),
                           zoom = 5, maptype = 'toner', crop = TRUE, color = 'bw')

altUsMap <- ggmap(altMapDat)

# plot points
chargeMap <- usMap + geom_point(aes(x = lon, y = lat, size = charge, colour = charge), data = drg470DF, alpha = 0.2) +
  scale_size(range = c(1, 25), guide = 'none') + scale_color_continuous(low = 'black', high = 'blue', guide = 'none')

# chargeDensMap <- usMap + 
#   stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
#                                         bins = 10, data = drg470DF, geom = 'polygon') +
#   scale_fill_gradient(low = 'blue', high = 'red')

paymentMap <- usMap + geom_point(aes(x = lon, y = lat, size = payment), data = drg470DF, colour = 'orange', alpha = 0.4) +
  scale_size(range = c(5, 25), guide = 'none')

paymentMap <- usMap + geom_point(aes(x = lon, y = lat, size = payment, colour = payment), data = drg470DF, alpha = 0.2) +
  scale_size(range = c(5, 25), guide = 'none') + scale_color_continuous(low = 'blue', high = 'orange', guide = 'none')

paymentMap <- altUsMap + geom_point(aes(x = lon, y = lat, size = payment), data = drg470DF, alpha = 0.2, colour = '#3399FF') +
  scale_size(range = c(1, 25), guide = 'none')

yieldMap <- usMap + geom_point(aes(x = lon, y = lat, size = yield), data = drg470DF, colour = 'green', alpha = 0.4) +
  scale_size(range = c(5, 25), guide = 'none')

yieldMap <- usMap + geom_point(aes(x = lon, y = lat, size = yield, colour = yield), data = drg470DF, alpha = 0.2) +
  scale_size(range = c(5, 25), guide = 'none') + scale_color_continuous(low = 'orange', high = 'red', guide = 'none')

yieldMap <- altUsMap + geom_point(aes(x = lon, y = lat, size = yield, colour = yield), data = drg470DF, alpha = 0.2) +
  scale_size(range = c(5, 25), guide = 'none') + scale_color_continuous(low = 'orange', high = 'red', guide = 'none')






