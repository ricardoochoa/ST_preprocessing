# Connect to the DPS Geoserver and update the ST tool

# The following code will guide you in a step-by-step process to connect to the DPS Geoserver and update the ST tool. This tutorial considers that you are already familiar with the following concepts. If you are not, please visit the links.
# - [R](https://www.r-project.org/)
# - [RStudio](https://www.rstudio.com)
# - [Raster](https://en.wikipedia.org/wiki/Raster_graphics)
# - [Denpasar Geoportal](http://geoportal.denpasarkota.go.id/)
# - [Geoserver](http://geoserver.org/)

# Please consider that you might need to adjust Geoserver permits to allow WFS without authentication. 

## 1. Load required libraries
# In this tutorial we will use the following libraries:
# [raster](https://cran.r-project.org/web/packages/raster/raster.pdf): Title Geographic Data Analysis and Modeling Version 2.6-7, November 12, 2017
# [rgdal](https://cran.r-project.org/web/packages/rgdal/rgdal.pdf): Bindings for the 'Geospatial' Data Abstraction, Version 1.3-4, August 3, 2018
# [sp](https://cran.r-project.org/web/packages/sp/sp.pdf): Classes and Methods for Spatial Data, Version 1.3-1, June 5, 2018
# [maptools]()
# [leaflet](https://cran.r-project.org/web/packages/leaflet/leaflet.pdf): Create Interactive Web Maps with the JavaScript 'Leaflet', Version 2.0.2, August 27, 2018
# Run the following lines to load the libraries. 

# install.packages('raster')    # Run only once
# install.packages('rgdal')     # Run only once
# install.packages('sp')        # Run only once
# install.packages('maptools')  # Run only once
# install.packages('leaflet')   # Run only once
library(raster)
library(rgdal)
library(sp)
library(maptools)
library(leaflet)

## 2. Prepare basic inputs
# First of all, we connect to Denpasar's Geoserver and will import the data. For this tutorial we will use the Hospitals layer as an example. 
# Name of workspace in Geoserver
WORKSPACE <- "BAPPEDA"
# Name of layer in Geoserver
LAYER <- "kesehatan_pt_25k"
# URL of Geoserver
SERVER <- "http://geoportal.denpasarkota.go.id:8080/"

## 3. Import data
# We will import data using Geoserver's WFS. Data will be stored in a temporary directory, which we will delete once that the import is complete. 
# Built an URL from the inputs in the previous step. 
URL <- paste0(SERVER, "/geoserver/wfs?request=GetFeature&service=wfs&version=1.0.0&outputformat=SHAPE-ZIP&typename=", 
              WORKSPACE, ":", LAYER)
# Create a temporary directory
dir.create("temp")
# Download data to the temporary directory and extract it
download.file(url = URL, 
              destfile = "temp/temp.zip")
unzip(zipfile = "temp/temp.zip", exdir = "temp")
# Import spatial points
points <- readOGR(dsn = paste0("temp/", LAYER, "/", LAYER, ".shp"))
# Remove the temporary file
file.remove(paste("temp", list.files("temp"), sep = "/"), "temp")

## 3. Estimate the distance
# The distance estimation requires only a couple of lines. Please note that the **distanceFromPoints** function will estimate the shortest distance (in meters) to the nearest hospital. 
# Distance from points to each raster cell
distances <- distanceFromPoints(object = population, xy = points)
# "Mask" the raster to keep only those cells inside Denpasar metro area
distance_raster <- mask(x = distances, mask = population)

## 4. Plot
# We will plot the raster to ensure that results make sense. 
plot(distance_raster)

## 5. Save your raster file
# Save the raster file in your Suitability directory.
# Define where is your Suitability app located.
suitability_dir <- "Desktop/Suitability"
# Define the name of the city
city <- "Denpasar"
# If needed, define a different name for your raster. 
file_name <- "kesehatan_pt_25k.tif"
# The TIF file will be saved in the following directory.
file_path <- paste(suitability_dir, "_data", city, "layers", file_name, sep = "/")
# Finally, save the file. 
writeRaster(distance_raster, filename = file_path, overwrite = TRUE)

# That's it! Your layer has been updated. 
# You can repeat this code for other proximity layers. 
# Please note that you can contact us for any additional question via [moodle](moodle.up.technology). 

