library(fs)


#' Find InAccessMod Layer
#'
#' This function searches for a specific file within a set of predefined
#' folders and returns the path to the file if found.
#'
#' @param location A character string specifying the location to search within.
#' @param base A character string specifying the base directory.
#' @param filename A character string specifying the name of the file to find.
#' @param copy A logical indicating whether to copy the file (default is FALSE).
#' @return A character string with the path to the found file.
find_inaccessmod_layer <- function(location, base, filename, copy = FALSE) {
  folders <- c("data/zToAccessMod", "facilities", "landcover")

  for (folder in folders) {
    path <- file.path(base, location, folder)

    if (!dir.exists(path)) {
      next
    }

    # Handle the specific case for 'data/zToAccessMod'
    if (folder == "data/zToAccessMod") {
      dirs <- list.dirs(path, full.names = TRUE, recursive = FALSE)

      if (length(dirs) == 0) {
        next
      }

      dirs <- sort(dirs, TRUE)
      path_file <- file.path(dirs[1], filename)
    } else {
      path_file <- file.path(path, filename)
    }

    if (file.exists(path_file)) {
      if (copy == TRUE) {
        path_file <- create_temp_copy(path_file)
      }
      return(path_file)
    }
  }

  stop(sprintf("%s missing in all specified folders", filename))
}

#' Create Temporary Copy of a File/Multifile Dataset
#'
#' This function creates a temporary copy of a multi-file dataset, copying all associated files with the same base name.
#'
#' @param file_path A character string specifying the path to the main file of the dataset.
#' @return A character string with the path to the temporary copy of the main file.
create_temp_copy <- function(file_path) {
  if (!file_exists(file_path)) {
    stop("The specified file does not exist.")
  }

  base_name <- path_ext_remove(path_file(file_path))
  dir_name <- path_dir(file_path)
 
  temp_dir <- tempdir(TRUE)

  matching_files <- dir_ls(dir_name, regexp = sprintf("%s\\.", base_name))

  for (file in matching_files) {
    file_copy(file, path(temp_dir, path_file(file)), overwrite = TRUE)
  }

  temp_file <- path(temp_dir, path_file(file_path))

  if (!file_exists(temp_file)) {
    stop("The file was not copied successfully.")
  }

  return(temp_file)
}
