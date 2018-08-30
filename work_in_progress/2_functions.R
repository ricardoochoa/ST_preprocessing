# get_elevation_zoom
# estimates the best zoom in elevatr (aws) based on bounding box
get_elevation_zoom <- function(X1, Y1, X2, Y2, C){
  
  # X1 = as.data.frame(lower_left)$x
  # Y1 = as.data.frame(lower_left)$y 
  # X2 = as.data.frame(top_right)$x 
  # Y2 = as.data.frame(top_right)$y 
  # C = my_crs
  
  distance = 
    as.numeric(
      t(spDists(
        SpatialPoints(coords = data.frame(x = X1, y = Y1), proj4string=CRS(C)),
        SpatialPoints(coords = data.frame(x = X2, y = Y2), proj4string=CRS(C))))
    )
  # distance
  
  tmp = read.csv("_data/aws/zoom_resolution.csv")
  tmp$difference = abs(distance - tmp$Latitude_60 * 500)
  
  # tmp
  
  zoom = tmp[which(tmp$difference == min(tmp$difference)),"zoom"]
  
  # zoom

  return(zoom)
  
  # rm(X1, Y1, X2, Y2, C, distance, tmp, zoom)
}
