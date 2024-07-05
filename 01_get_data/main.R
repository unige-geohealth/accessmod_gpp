library(dplyr) # mising for osm
library(sf) # if not loaded here, initiat_project fails
library(inAccessMod)
source("/helpers/get_location.R")

location <- get_location() 
wd <- normalizePath("/data/location/")

# iso3string <- "CHE"

if (file.exists(location)) {
  print("unlink previous location ")
  unlink(normalizePath(location), recursive = TRUE)
}
initiate_project(
  wd,
  city = TRUE,
  name = location,
  # iso = iso3string,
  allowInteractivity = FALSE
)

set_projection(
  wd,
  location,
  mostRecent = TRUE,
  alwaysSet = TRUE,
  bestCRS = TRUE,
  allowInteractivity = FALSE
)

download_dem(
  wd,
  location,
  alwaysDownload = TRUE,
  mostRecent = TRUE
)
download_population(
  wd,
  location,
  allowInteractivity = FALSE
)
download_landcover(
  wd,
  location,
  alwaysDownload = TRUE,
  mostRecent = TRUE
)

download_osm(wd, location, "roads")
download_osm(wd, location, "waterLines")
download_osm(wd, location, "waterPolygons")


process_inputs(
  wd,
  location, "All",
  mostRecent = TRUE,
  alwaysProcess = TRUE,
  defaultMethods = TRUE,
  changeRes = FALSE,
  popCorrection = TRUE,
  gridRes = 2000,
  allowInteractivity = FALSE
)
compile_processed_data(
  wd,
  location,
  mostRecent = TRUE
)


browser()
