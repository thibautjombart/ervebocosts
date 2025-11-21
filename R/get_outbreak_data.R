#' Get country information
#' 
#' This can be one or more countries.
#' 
#' @param x the imported database as returned by [import_data]
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
    out <- lapply(out, paste, collapse = ", ", sep = "")
    out <- unlist(out)
    out[out == ""] <- NA_character_
  }
  out
}





#' Get starting date of outbreak
#' 
#' @inheritParams get_locations

get_start_date <- function(x) {
  year <- x$outbreak_start_year_outbreak_1
  month <- x$outbreak_start_month_outbreak_1
  day <- x$outbreak_start_day_outbreak_1
  lubridate::ymd(paste(year, month, day, sep = "-"), quiet = TRUE)
}




  
#' Get ending date of outbreak
#' 
#' @inheritParams get_locations

get_end_date <- function(x) {
  year <- x$outbreak_end_year_outbreak_1
  month <- x$outbreak_end_month_outbreak_1
  day <- x$outbreak_end_day_outbreak_1
  lubridate::ymd(paste(year, month, day, sep = "-"), quiet = TRUE)
}





#' Get outbreak data
#' 
#' @inheritParams get_locations

get_outbreak_data <- function(x) {
  tibble(
    record_id = x$record_id,
    source_type = x$type_of_publication,
    source_type_other = x$please_specify_other_10,
    source_link = x$article_doi_or_url,
    pathogen = x$pathogen,
    locations = get_locations(x, TRUE), 
    year = x$outbreak_end_year_outbreak_1,
    start_date = get_start_date(x),
    end_date = get_end_date(x),
    cases = x$number_of_confirmed_cases_outbreak_1,
    deaths = x$number_of_deaths_outbreak_1,
    sdbs = x$number_of_safe_burials_outbreak_1,
    vaccinations = x$number_of_vaccines_administered_outbreak_1,
    tests = x$number_of_tests_carried_out_outbreak_1,
    admissions = x$number_of_etu_admissions_outbreak_1,
    contacts_traced = x$number_contacts_traced_outbreak_1
  )
}
