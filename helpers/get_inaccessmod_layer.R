library(sf)
library(terra)

get_inaccessmod_layer <- function(location, base, filename, raster = FALSE) {
  path_file <- find_inaccessmod_layer(location, base, filename)
  if (raster) {
    rast(path_file)
  } else {
    st_read(path_file)
  }
}
