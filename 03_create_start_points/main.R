library(sf)
source("/helpers/get_inaccessmod_layer.R")
source("./get_cluster_points.R")
source("./get_osm_data.R")

location <- "Bern"

cached <- sprintf("/tmp/osmdata_6_%s", location)
location_path <- "/data/location"
file_out <- "vFacilities_pr.shp"
file_border <- "vBorders_pr.shp"

out_dir <- file.path(location_path, location, "facilities")
out_file <- file.path(out_dir, file_out)
borders_sf <- get_inaccessmod_layer(location, location_path, file_border)
bbox <- st_bbox(borders_sf)
crs <- st_crs(borders_sf)


if (file.exists(cached)) {
  data <- readRDS(cached)
} else {
  data <- get_osm_data(bbox)
  saveRDS(data, cached)
}

points <- get_cluster_points(data, bbox, cluster_size = 10000, crs = crs)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

st_write(points, out_file, "ESRI Shapefile")
