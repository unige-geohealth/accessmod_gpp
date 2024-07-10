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

# Function to get command line arguments
get_arg <- function(arg_name, default = NULL) {
  args <- commandArgs(trailingOnly = TRUE)
  arg_index <- match(arg_name, args)
  if (!is.na(arg_index) && arg_index < length(args)) {
    return(args[arg_index + 1])
  }
  return(default)
}

