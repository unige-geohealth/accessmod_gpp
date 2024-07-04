library(sf)

get_borders <- function(location, base, filename) {
  path <- file.path(base, location, "data", "zToAccessMod")

  if (!dir.exists(path)) {
    stop(sprintf("%s do not exists", path))
  }

  dirs <- list.dirs(path, full.names = TRUE, recursive = FALSE)

  if (length(dirs) == 0) {
    stop(sprintf("No temp folder for %s", path))
  }

  dirs <- sort(dirs, TRUE)

  path_file <- file.path(dirs[1], filename)
  if (!file.exists(path_file)) {
    stop(sprintf("vBorders missnig in %s", path_file))
  }
  st_read(path_file)
}
