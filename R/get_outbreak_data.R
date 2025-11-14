#' Get pathogen information
get_pathogen <- function(x) {
  select(x, "pathogen")
}


#' Get country information
#' 
#' This can be one or more countries.
#' 
#' @param x the imported database
#' @param concatenate a `logical` indicating if several countries should be 
#' collapsed into a single character string

get_locations <- function(x, concatenate = FALSE) {
  cols_to_keep <- grep(
    "outbreak_location_country_outbreak_1_choice_", 
    names(x),
    value = TRUE
  )
  countries <- sub(
    "outbreak_location_country_outbreak_1_choice_", 
    "", 
    cols_to_keep
  )
  out <- apply(x[, cols_to_keep], 1, function(e) countries[e == "Checked"])
  if (concatenate) {
    out <- lapply(temp, paste, collapse = ", ", sep = "")
    out <- unlist(out)
    out[out == ""] <- NA_character_
  }
  out
}

