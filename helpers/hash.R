library(digest)
library(jsonlite)

generate_hash <- function(data_list) {
  data_str <- toJSON(data_list)
  return(digest(data_str, algo = "md5"))
}
