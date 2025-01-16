#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(stevedore)
  library(future)
  library(furrr)
  library(lubridate)
  library(pryr)
  library(fs)
  library(tidyverse) # For better CSV handling
})

# Configuration
ACCESSMOD_VERSION <- "5.8.3-alpha.1"
INACCESSMOD_VERSION <- "latest"
IMAGE_ACCESSMOD <- paste0("fredmoser/accessmod:", ACCESSMOD_VERSION)
IMAGE_INACCESSMOD <- paste0("fredmoser/inaccessmod:", INACCESSMOD_VERSION)
REQUIRED_FREE_MEMORY <- 2 * 1024 * 1024 * 1024 # 2GB in bytes
MAX_PARALLEL <- 4

# Create temporary directory for results
create_temp_dir <- function() {
  tmp_dir <- file.path(tempdir(), paste0("accessmod_batch_", format(Sys.time(), "%Y%m%d_%H%M%S")))
  dir.create(tmp_dir, recursive = TRUE, showWarnings = FALSE)
  return(tmp_dir)
}

# Write temporary result for a city
write_temp_result <- function(result, tmp_dir) {
  filename <- file.path(tmp_dir, paste0(result$city, ".csv"))
  write_csv(as_tibble(result), filename)
  return(filename)
}

# Clean up city directory
cleanup_city_dir <- function(city_name) {
  city_dir <- file.path("data", city_name)
  if (dir_exists(city_dir)) {
    message(sprintf("Cleaning up directory for city: %s", city_name))
    unlink(city_dir, recursive = TRUE)
  }
}

# Initialize Docker client
docker <- stevedore::docker_client()


# Function to check system resources
check_resources <- function() {
  # Get virtual memory info
  mem_info <- ps::ps_system_memory()
  free_mem <- mem_info$avail

  if (free_mem < REQUIRED_FREE_MEMORY) {
    stop(sprintf(
      "Insufficient free memory. Required: 2GB, Available: %.2f GB",
      free_mem / 1024 / 1024 / 1024
    ))
  }

  # Also check if system is under heavy memory pressure
  if (mem_info$percent > 90) {
    stop("System is under heavy memory pressure (>90% usage)")
  }
}

# Function to create required directories
build_dirs <- function(base_dir) {
  dirs <- c("location", "cache", "dbgrass", "logs", "config")
  for (dir in dirs) {
    dir.create(file.path(base_dir, dir), recursive = TRUE, showWarnings = FALSE)
  }
}

# Function to process a single step for a city
process_step <- function(city, step, docker) {
  tryCatch(
    {
      image <- if (step == "04_travel_time") IMAGE_ACCESSMOD else IMAGE_INACCESSMOD
      cmd <- if (step == "04_travel_time") c("/bin/bash", "-c", "/part/main.sh") else c("Rscript", "main.R")

      # Create unique data directory for this city
      city_data_dir <- file.path("data", city)
      build_dirs(city_data_dir)

      # Run Docker container
      # Create volume mappings in the correct format for stevedore
      volumes <- c(
        sprintf("%s:%s", paste0(getwd(), "/helpers"), "/helpers"),
        sprintf("%s:%s", paste0(getwd(), "/data"), "/data"),
        sprintf("%s:%s", paste0(getwd(), "/", step), "/part")
      )

      container <- docker$container$run(
        image = image,
        cmd = cmd,
        volumes = volumes,
        env = list(GPP_LOCATION = city),
        rm = TRUE
      )

      # Wait for container to finish
      status <- container$wait()
      container$remove()

      if (status$StatusCode != 0) {
        stop(paste("Container exited with status:", status$StatusCode))
      }

      return(TRUE)
    },
    error = function(e) {
      message(sprintf("Error processing %s for city %s: %s", step, city, e$message))
      cleanup_city_dir(city) # Clean up on error
      return(FALSE)
    }
  )
}

# Function to process a single city
process_city <- function(city_name, tmp_dir) {
  start_time <- Sys.time()
  steps <- c(
    "01_get_data", "02_build_merged_landcover",
    "03_create_start_points", "04_travel_time"
  )

  result <- list(
    city = city_name,
    done = FALSE,
    duration = NA_real_,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  )

  for (step in steps) {
    if (!process_step(city_name, step, docker)) {
      result$duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
      write_temp_result(result, tmp_dir)
      return(result)
    }
  }

  result$done <- TRUE
  result$duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  write_temp_result(result, tmp_dir)
  return(result)
}

# Main processing function
main <- function(batch_file = "batch_cities.csv") {
  # Create temporary directory
  tmp_dir <- create_temp_dir()
  on.exit(unlink(tmp_dir, recursive = TRUE)) # Cleanup on exit

  # Read batch file
  cities <- read_csv(batch_file, col_types = cols(
    city = col_character(),
    done = col_logical(),
    duration = col_double()
  )) %>%
    mutate(done = replace_na(done, FALSE))


  cities <- cities[1, ]

  total_cities <- nrow(cities)
  pending_cities <- cities %>% filter(!done)

  message(sprintf(
    "Processing %d cities (%d remaining)...",
    total_cities, nrow(pending_cities)
  ))

  # Set up parallel processing
  available_cores <- parallel::detectCores() - 2
  n_workers <- min(MAX_PARALLEL, available_cores)
  plan(multisession, workers = n_workers)

  # Process cities in parallel
  future_map(pending_cities$city, function(city_name) {
    # for (city_name in pending_cities$city) {
    check_resources()
    result <- process_city(city_name, tmp_dir)

    # Update progress
    message(sprintf(
      "[%s] %s: %s (%.1f seconds)",
      format(Sys.time(), "%H:%M:%S"),
      city_name,
      if (result$done) "SUCCESS" else "FAILED",
      result$duration
    ))
    # }
    return(result)
  }, .progress = TRUE)

  # Merge results and update batch file
  message("\nMerging results...")

  # Read all temporary results
  result_files <- list.files(tmp_dir, pattern = "\\.csv$", full.names = TRUE)
  results <- map_df(result_files, read_csv)

  # Update original data with new results
  updated_cities <- cities %>%
    left_join(results, by = "city") %>%
    mutate(
      done = coalesce(done.y, done.x),
      duration = coalesce(duration.y, duration.x)
    ) %>%
    select(city, done, duration)

  # Create backup of original file
  backup_file <- paste0(batch_file, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))
  file.copy(batch_file, backup_file)

  # Write updated results atomically
  tmp_batch_file <- paste0(batch_file, ".tmp")
  write_csv(updated_cities, tmp_batch_file)
  file.rename(tmp_batch_file, batch_file)

  # Print summary
  successful <- sum(updated_cities$done, na.rm = TRUE)
  message(sprintf(
    "\nProcessing complete: %d/%d successful",
    successful, total_cities
  ))
  message(sprintf("Backup saved as: %s", backup_file))
}

# Run the script
if (!interactive()) {
  main()
}
