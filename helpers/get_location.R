default_loc <- "Bern"

get_location <- function() {
  gpp_location <- Sys.getenv("GPP_LOCATION")
  if (gpp_location == "") {
    warning(
      sprintf(
        "No location found, using %s
        Please set the GPP_LOCATION environment variable.", default_loc
      )
    )
    gpp_location <- default_loc
  }

  return(gpp_location)
}
