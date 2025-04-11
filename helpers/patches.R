#' Patches for AccessMod functions
#' This file contains monkey patches for AccessMod functions that need fixes
#' in the API/containerized environment

#' Patch for disk space check function
if (exists("sysEvalFreeMbDisk")) {
  original_sysEvalFreeMbDisk <- sysEvalFreeMbDisk
  
  # Override with safe version
  sysEvalFreeMbDisk <- function() {
    tryCatch({
      disk_space <- original_sysEvalFreeMbDisk()
      if (is.na(disk_space)) {
        message("Warning: Disk space check returned NA, assuming sufficient space")
        return(1000000) # Return large value to pass any disk space check
      }
      return(disk_space)
    }, error = function(e) {
      message(paste("Warning: Error in disk space check:", e$message))
      return(1000000) # Return large value to pass any disk space check
    })
  }
  message("Patched sysEvalFreeMbDisk function for container environment")
}