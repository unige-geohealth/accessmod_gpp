##' Title: Data preparation of the merged landcover that is used as input to the accessibility analysis.
##' Description: In this R-script we merge all the previously prepared topographic layers into one overarching landcover layer.
##' Author: Fleur Hierink, (fleur.hierink@unige.ch)
##' Date: 14-02-2022
##' Institute: Institute for Environmental Sciences & Institute of Global Health
##' University: University of Geneva



library(sf)
library(dplyr)
library(terra)

# Steps for the merged land cover:
# official road classes that can be found in data
road_classes <- c(
  "motorway", "trunk", "primary", "secondary", "tertiary",
  "unclassified", "residential", "motorway_link", "trunk_link",
  "primary_link", "secondary_link", "tertiary_link", "living_street",
  "service", "pedestrian", "track", "road", "footway", "bridleway",
  "steps", "path", "cycleway", "raceway", "unclassified", "bridge"
)

# list to reclassify road names into integer values
reclass_roads <- list(
  "trunk" = 1001,
  "trunk_link" = 1002,
  "primary" = 1003,
  "primary_link" = 1004,
  "motorway" = 1005,
  "motorway_link" = 1006,
  "secondary" = 1007,
  "secondary_link" = 1008,
  "tertiary" = 1009,
  "tertiary_link" = 1010,
  "road" = 1011,
  "raceway" = 1012,
  "residential" = 1013,
  "living_street" = 1014,
  "service" = 1015,
  "track" = 1016,
  "pedestrian" = 1017,
  "path" = 1018,
  "footway" = 1019,
  "piste" = 1020,
  "bridleway" = 1021,
  "cycleway" = 1022,
  "steps" = 1023,
  "unclassified" = 1024,
  "bridge" = 1025
)



merge_landcover <- function(population_ref, landcover, roads, water_lines, water_polygons) {
  grid_landcov <- rast(population_ref)

  roads_new <- roads %>%
    group_by(highway) %>%
    summarize() %>%
    filter(highway %in% as.factor(road_classes)) %>%
    mutate(
      class = recode(highway, !!!reclass_roads),
      class = as.integer(class)
    )

  # rasterize roads to 100 meters
  roads_rast <- terra::rasterize(
    roads_new,
    grid_landcov,
    "class",
    touches = TRUE
  )

  # give all rivers and integer class 1 so that later they can be classified as barriers
  water_lines_new <- water_lines %>% # load water lines
    group_by(waterway) %>%
    summarize() %>%
    filter(waterway == "river") %>% # filter only hydrography lines classified as river
    mutate(class = 1)

  # rasterize water lines
  water_lines_rast <- terra::rasterize(
    water_lines_new,
    grid_landcov,
    field = "class",
    touches = TRUE
  )

  # make background value NA
  values(water_lines_rast)[values(water_lines_rast) == 0] <- NA

  # give all rivers and lakes integer class 1 so that later they can be classified as barriers
  water_polygons_new <- water_polygons %>%
    mutate(class = 1)

  # rasterize water polygons
  water_polygons_rast <- terra::rasterize(
    water_polygons_new,
    grid_landcov,
    "class",
    touches = TRUE
  )
  # make background value NA
  values(water_polygons_rast)[values(water_polygons_rast) == 0] <- NA

  # add in the following sequence from bottom to top all the raster layers (landcover, water lines, water polygons, roads)
  landcover_merge <- terra::merge(
    water_lines_rast,
    landcover
  )
  landcover_merge <- terra::merge(
    water_polygons_rast,
    landcover_merge
  )
  landcover_merge <- terra::merge(
    roads_rast,
    landcover_merge
  )
  # all values that are 1 represent waterbodies, remove these values to make them barriers
  values(landcover_merge)[values(landcover_merge) == 1] <- NA
  landcover_merge
}
