# 3_data

# global variables
my_city <- 'CDMX'

# ---------- resolution: ghsl cell size (please choose one)
my_cell_size <- '1000m'
# my_cell_size <- '0250m'
# my_cell_size <- '0038m'

# ---------- crs: coordinate refference system (R will select the crs based on your selection of cell size)
my_crs <- 
  list ('1000m' = '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs', 
        '0250m' = '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs', 
        '0038m' = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
  )[[my_cell_size]]

# ---------- study area: define your study area with two points (lower-left and top-right)
# lower left:
lower_left <- SpatialPoints(coords = data.frame(x = -99.5106, 
                                                y = 18.92247), 
                            proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
# top right: 
top_right <- SpatialPoints(coords = data.frame(x = -98.5986, 
                                                y = 20.01847), 
                            proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

# If needed, transform your CRS (R will transform it if needed)
if(as.character(crs(lower_left)) != my_crs){
  lower_left <- spTransform(x = lower_left,
                            CRSobj = my_crs)
}

if(as.character(crs(top_right)) != my_crs){
  top_right <- spTransform(x = top_right,
                            CRSobj = my_crs)
}

# Create the extent (R will create it, based on your definition of study area) 
my_extent <- extent(c(as.data.frame(lower_left)$x, 
                      as.data.frame(top_right)$x, 
                      as.data.frame(lower_left)$y, 
                      as.data.frame(top_right)$y)) 

# spatial data
# ---------- built-up area
# file path for GHSL data
ghsl_file <- paste0('_data/ghsl/', my_cell_size, "/")
# import raster data
built_up <- stack(lapply(X = list.files(path = ghsl_file, 
                                    pattern = '*.tif', 
                                    full.names = T), 
                     FUN = raster))
# crop raster stack based on the definition of the study area
built_up <- crop(x = built_up, y = my_extent)
# verify if everything worked properly 
levelplot(built_up, main = my_city)

# ---------- land uses
residential_only_polygon <- readOGR("_data/morelia/lu_residential.shp")
residential_only_polygon <- spTransform(x = residential_only_polygon, CRSobj = my_crs)
residential_only <- rasterize(x = residential_only_polygon, y = built_up)
residential_only[!is.na(residential_only)] <- 1
levelplot(residential_only)
rm(residential_only_polygon)

# ---------- population
population_tabular <- data.frame(y = c(1990, 2000, 2014), 
                                 p = c(492901, 620532, 762431), # data retrived from conapo and inegi
                                 cell_sum = as.numeric(cellStats(x = built_up, stat = sum)))
population_tabular$coefficient <- population_tabular$p / population_tabular$cell_sum
population <- built_up * population_tabular$coefficient
levelplot(population)

# ---------- nighttime lights
load("_data/noaa/ntl_mx.RData")
ntl <- projectRaster(ntl_mx, crs=my_crs)
ntl <- resample(x = ntl, # new raster will keep this values
                y = built_up) # new raster will keep this extent
levelplot(ntl)

# ---------- slope
elevation <- get_elev_raster(locations = built_up, z = 9, src = "aws")
slope <- terrain(x = elevation)
slope <- resample(x = slope, # new raster will keep this values
                y = built_up) # new raster will keep this extent
levelplot(slope)

# ---------- roads
roads_osm <- readOGR("_data/osm/morelia/shape/roads.shp")
roads_osm <- spTransform(x = roads_osm, CRSobj = my_crs)
roads_osm <- as(roads_osm, "SpatialPointsDataFrame")
roads <- distanceFromPoints(object = built_up, xy = roads_osm)
levelplot(roads)


