#' Import cost data
#'
import_data <- function() {
  file_path <- here::here("data", "ebola_cost_data.xlsx")
  x <- rio::import(file_path) %>% 
    tibble()
  names(x) <- epitrix::clean_labels(names(x))
  x
}