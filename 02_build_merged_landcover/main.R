# libraries
library(terra)
source("./merge_landcover.R")
source("/helpers/find_inaccessmod_layer.R")
source("/helpers/get_inaccessmod_layer.R")
source("/helpers/get_location.R")

location <- get_location()
location_path <- "/data/location"
out_file <- "rLandcoverMerged_pr.tif"
out_dir <- file.path(location_path, location, "landcover")
out_path <- file.path(out_dir, out_file)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

population <- get_inaccessmod_layer(
  location,
  location_path,
  "rPopulation_pr.tif",
  raster = TRUE
)

landcover <- get_inaccessmod_layer(
  location,
  location_path,
  "rLandcover_pr.tif",
  raster = TRUE
)
roads <- get_inaccessmod_layer(
  location,
  location_path,
  "vRoads_pr.shp"
)

water_lines <- get_inaccessmod_layer(
  location,
  location_path,
  "vWaterLines_pr.shp"
)

water_polygons <- get_inaccessmod_layer(
  location,
  location_path,
  "vWaterPolygons_pr.shp"
)

admin <- get_inaccessmod_layer(
  location,
  location_path,
  "vBorders_pr.shp"
)


landcover_merged <- merge_landcover(
  population_ref = population,
  landcover = landcover,
  roads = roads,
  water_lines = water_lines,
  water_polygons = water_polygons
)

writeRaster(
  landcover_merged, out_path,
  overwrite = TRUE
)
