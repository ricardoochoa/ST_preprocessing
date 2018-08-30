library(Rnightlights)
library(lubridate)
library(reshape2)

#(Optional performance enhancement if you have aria2c and gdal installed)
pkgOptions(cropMaskMethod = "gdal", extractMethod = "gdal", deleteTiles = TRUE)

#Optional performance enhancement. If extractMethod="rast" you can specify the number of
#CPU cores to use in parallel
pkgOptions(extractMethod = "rast", numCores=4)

ctry <- "IDN" #Indonesia
# ctry <- "PSE" #Palestinian Territory
# ctry <- "Mex" #Mexico

#download and process monthly VIIRS stats at the highest admin level
highestAdmLevelStats <- getCtryNlData(ctryCode = ctry, 
                                      admLevel = "highest",
                                      nlType = "VIIRS.M", 
                                      nlPeriods = nlRange("201401", "201412"), 
                                      nlStats = "sum",
                                      ignoreMissing=FALSE)

ntl_ps <- raster(Rnightlights:::getCtryRasterOutputFnamePath(ctry,"VIIRS.M", "201412"))
levelplot(log(ntl_ps))
save(ntl_ps, file = "_data/noaa/ntl_ps.RData")
