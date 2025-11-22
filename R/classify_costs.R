

#' Classify cost items by type
#'
#' @param x tibble with all processed raw data from RedCap
#'
#' @returns vector of cost classifications into Fixed, Fixed variable, Variable or Unknown
#' @export
#' 
classify_cost <- function(x){
  cost_class <- dplyr::case_when(
    !is.na(x$cost_type) & x$cost_type == "Unit cost" ~ "Variable",
    !is.na(x$number_activities) & x$number_activities > 1 ~ "Fixed Variable",
    !is.na(x$number_activities) & x$number_activities == 1 ~ "Fixed",
    TRUE ~ "Unknown"
  )
  return(cost_class)
}

#' Title cost_in_perspective
#' Determine if cost is in analysis perspective
#'
#' @param x tibble with all processed raw data from RedCap
#'
#' @returns vector of zero or one if the cost item is in the perspective of the analysis
#' @export
#'
cost_in_perspective <- function(x){
  perspective <- rep(1, nrow(x))
  
  for(i in 1:nrow(x)){
    cost_cat <- x$cost_subcategory[i]
    
    ## PLACEHOLDER ONLY: JS to fill in logic
    
    if(!is.na(cost_cat) & grepl("NHGDP Loss", cost_cat)){
      perspective[i] <- 0
    } else if(!is.na(cost_cat) & grepl("GDP per Capita Loss", cost_cat)){
      perspective[i] <- 0
    } 
  }
  
  return(perspective)
}