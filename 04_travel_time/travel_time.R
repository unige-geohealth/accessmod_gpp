source("global.R")
source("/helpers/find_inaccessmod_layer.R")
source("/helpers/get_location.R")
source("/helpers/pop_vs_traveltime.R")

location <- get_location()

location_path <- "/data/location"
project_name <- sprintf("project_gpp_%s", location)

output_folder <- file.path(location_path, location, "output")
output_travel_time <- file.path(output_folder, "travel_time.tif")
output_nearest <- file.path(output_folder, "travel_nearest.tif")
output_pop_vs_time_data <- file.path(output_folder, "pop_vs_traveltime.csv")
output_pop_vs_time_plot <- file.path(output_folder, "pop_vs_traveltime.pdf")

dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

landcover_merged_path <- find_inaccessmod_layer(
  location,
  location_path,
  "rLandcoverMerged_pr.tif",
  copy = TRUE
)

population_path <- find_inaccessmod_layer(
  location,
  location_path,
  "rPopulation_pr.tif",
  copy = TRUE
)

facilities_path <- find_inaccessmod_layer(
  location,
  location_path,
  "vFacilities_pr.shp",
  copy = TRUE
)

#
# Default config should be updated
# - Empty HF table (default to all, no valdiation)
# - cucrent mapset/location
#
conf <- amAnalysisReplayParseConf(
  "/data/config/default.json"
)
conf$location <- project_name
conf$mapset <- project_name

#
# Start AccessMod Session
#
amGrassNS(
  mapset = project_name,
  location = project_name,
  {
    # layer names must
    # - match AccessMod classes in /www/dictionary/classes.json
    # - use two underscore to separate tags from class, and
    #   one between tags e.g. vFacility__test_a

    execGRASS(
      "r.in.gdal",
      band = 1,
      input = landcover_merged_path,
      output = "rLandCoverMerged__pr",
      title = "rLandCoverMerged__pr",
      flags = c("overwrite", "quiet")
    )

    execGRASS(
      "r.in.gdal",
      band = 1,
      input = population_path,
      output = "rPopulation__pr",
      title = "rPopulation__pr",
      flags = c("overwrite", "quiet")
    )

    execGRASS("v.in.ogr",
      flags = c("overwrite", "w", "2"), # overwrite, lowercase, 2d only,
      input = facilities_path,
      key = "cat",
      output = "vFacility__pr",
      snap = 0.0001
    )

    exportedDirs <- amAnalysisReplayExec(conf,
      exportDirectory = output_folder
    )

    #
    # Additional analysis
    # - Population Access to Green Areas by Travel Time
    # - table -> output
    # - plot -> output
    #
    popVsTime <- amGetRasterStatZonal(
      "rPopulation__pr",
      "rTravelTime__pr"
    )

    write.csv(popVsTime, output_pop_vs_time_data)
    plot_cumulative_sum(popVsTime, output_pop_vs_time_plot)
  }
)

print(sprintf("Data exported in %s", output_folder))
