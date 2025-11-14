#' Get pathogen information
#' 
#' @param x the imported database as returned by [import_data]
get_pathogen <- function(x) {
  select(x, "pathogen")
}


#' Get country information
#' 
#' This can be one or more countries.
#' 
#' @inheritParams get_pathogen
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


#' Get starting date of outbreak
#' 
#' @inheritParams get_pathogen

get_start_date <- function(x) {
  year <- x$outbreak_start_year_outbreak_1
  month <- x$outbreak_start_month_outbreak_1
  day <- x$outbreak_start_day_outbreak_1
  lubridate::ymd(paste(year, month, day, sep = "-"), quiet = TRUE)
}




#' Get ending date of outbreak
#' 
#' @inheritParams get_pathogen

get_end_date <- function(x) {
  year <- x$outbreak_end_year_outbreak_1
  month <- x$outbreak_end_month_outbreak_1
  day <- x$outbreak_end_day_outbreak_1
  lubridate::ymd(paste(year, month, day, sep = "-"), quiet = TRUE)
}


