library(sf)
library(stats)
library(dplyr)

get_cluster_points <- function(
  nature_areas,
  bbox,
  cluster_size = 10000,
  crs = 32632) {
  # Combine all features into one list, removing NULL elements
  features <- list(
    nature_areas$osm_lines,
    nature_areas$osm_multilines,
    nature_areas$osm_polygons,
    nature_areas$osm_multipolygons
  )
  features <- features[!sapply(features, is.null)]

  # Transform, use point, merge, cluster
  features <- lapply(features, st_transform, crs = crs)
  features <- lapply(features, function(f) {
    st_cast(f[, c()], "POINT")
  })
  features <- do.call(rbind, features)

  coordinates <- st_coordinates(features)
  kmeans_result <- kmeans(coordinates, centers = cluster_size)
  features$cluster <- kmeans_result$cluster
  features_cluster <- features %>%
    group_by(cluster) %>%
    summarize(geometry = st_centroid(st_union(geometry)))

  st_as_sf(features_cluster, crs = crs)
}
