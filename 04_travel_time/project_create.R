library(fs)
source("global.R")
source("/helpers/find_inaccessmod_layer.R")
source("/helpers/get_location.R")

location <- get_location()
location_path <- "/data/location"
project_name <- sprintf("project_gpp_%s", location)
project_db <- file.path("/data/dbgrass/", project_name)

if (dir_exists(project_db)) {
  dir_delete(project_db)
}

dem_path <- find_inaccessmod_layer(
  location,
  location_path,
  "rDEM_pr.tif",
  copy = TRUE
)
browser()

amGrassNS(
  mapset = "demo",
  location = "demo",
  {
    amProjectCreateFromDem(
      data.frame(
        datapath = dem_path,
        name = basename(dem_path),
        size = 1
      ),
      project_name
    )
  }
)
print(sprintf("Project %s created", project_name))
