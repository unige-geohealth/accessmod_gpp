library(fs)
global_cache <- "/tmp/am_global.RData"

if (file_exists(global_cache)) {
  load(global_cache)
} else {
  source("global.R")
}

source("/helpers/find_inaccessmod_layer.R")
source("/helpers/get_location.R")
source("/helpers/pop_vs_traveltime.R")


location <- get_arg("--location", default = get_location())
scenario <- get_arg("--scenario", default = NULL)




location_path <- "/data/location"
project_name <- sprintf("project_gpp_%s", location)

conf <- amAnalysisReplayParseConf(
  "/data/config/default.json"
)
conf$location <- project_name
conf$mapset <- project_name

if (isNotEmpty(scenario)) {
  conf$args$tableScenario <- jsonlite::fromJSON(scenario)
}



output_folder <- file.path(location_path, location, "output")
output_nearest <- file.path(output_folder, "travel_nearest.tif")
output_travel_time <- file.path(output_folder, "travel_time.tif")
output_travel_time_wgs84 <- file.path(output_folder, "travel_time_wgs84.tif")
output_travel_time_png <- file.path(output_folder, "travel_time.png")
output_pop_vs_time_data <- file.path(output_folder, "pop_vs_traveltime.csv")
output_pop_vs_time_plot <- file.path(output_folder, "pop_vs_traveltime.pdf")
proj_4 <- NULL
bbox <- jsonlite::toJSON(list())
pop_vs_time <- data.frame()

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
    if (!amRastExists("rLandCoverMerged__pr")) {
      execGRASS(
        "r.in.gdal",
        band = 1,
        input = landcover_merged_path,
        output = "rLandCoverMerged__pr",
        title = "rLandCoverMerged__pr",
        flags = c("overwrite", "quiet")
      )
    }

    if (!amRastExists("rPopulation__pr")) {
      execGRASS(
        "r.in.gdal",
        band = 1,
        input = population_path,
        output = "rPopulation__pr",
        title = "rPopulation__pr",
        flags = c("overwrite", "quiet")
      )
    }


    if (!amVectExists("rLandCoverMerged__pr")) {
      execGRASS("v.in.ogr",
        flags = c("overwrite", "w", "2"), # overwrite, lowercase, 2d only,
        input = facilities_path,
        key = "cat",
        output = "vFacility__pr",
        snap = 0.0001
      )
    }

    exportedDirs <- amAnalysisReplayExec(conf,
      exportDirectory = output_folder
    )

    #
    # Additional analysis
    # - Population Access to Green Areas by Travel Time
    # - table -> output
    # - plot -> output
    #
    pop_vs_time <- amGetRasterStatZonal(
      "rPopulation__pr",
      "rTravelTime__pr"
    )

    write.csv(pop_vs_time, output_pop_vs_time_data)
    plot_cumulative_sum(pop_vs_time, output_pop_vs_time_plot)


    #
    # Export tt as tif
    #
    proj_4 <- paste(execGRASS("g.proj", flags = c("j"), intern = TRUE), collapse = " ")

    execGRASS("r.colors",
      flags = c("n"),
      map = "rTravelTime__pr",
      color = "viridis"
    )


    execGRASS("r.out.gdal",
      flags = c("overwrite", "f", "m"),
      input = "rTravelTime__pr",
      output = output_travel_time,
      format = "GTiff",
      createopt = "TFW=YES"
    )
    execGRASS("r.out.gdal",
      flags = c("overwrite", "f", "c", "m"),
      input = "rNearest__pr",
      output = output_nearest,
      format = "GTiff",
      createopt = "TFW=YES"
    )

    system(sprintf(
      "gdalwarp -t_srs EPSG:4326 -r mode -overwrite  %s %s",
      output_travel_time,
      output_travel_time_wgs84
    ))

    system(sprintf(
      "gdal_translate -of PNG %s %s",
      output_travel_time_wgs84,
      output_travel_time_png
    ))


    rr <- raster(output_travel_time_wgs84)
    bbox <- as.list(raster::extent(rr))
  }
)

result <- list(
  bbox = bbox,
  pop_vs_time_data = output_pop_vs_time_data,
  pop_vs_time_plot = output_pop_vs_time_plot,
  travel_time = output_travel_time,
  travel_time_wgs84 = output_travel_time_wgs84,
  travel_time_png = output_travel_time_png,
  nearest = output_nearest,
  proj_4 = proj_4,
  thresholds = pop_vs_time$zone
)


print(jsonlite::toJSON(result, auto_unbox = TRUE))
