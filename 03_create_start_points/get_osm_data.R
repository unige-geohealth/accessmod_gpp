library(osmdata)
library(sf)
library(purrr)

# Function to get OSM data for a specific city
get_osm_data <- function(bbox) {
  bbox <- st_bbox(st_transform(st_as_sfc(bbox), 4326))

  query_park <- opq(bbox,timeout=60*5, osm_types = c("way", "relation")) %>%
    add_osm_features(features = list(
      "leisure" = "park",
      "leisure" = "nature_reserve",
      "natural" = "grassland",
      "natural" = "wood",
      "landuse" = "forest"
    )) %>%
    add_osm_feature(key = "access", value = "!private")

  data <- osmdata_sf(query_park)

  return(data)
}
