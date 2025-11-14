#' Get cost category
#' 
#' This processes the 10 columns containing cost information for each row of the
#' original database.
#' 
#' @param x the imported database as returned by [import_data]
#' 

get_cost_category <- function(x) {

  ## This sub-function finds the categories for a given cost number; in practice, 
  ## these can go from 1 to 10
  find_category_cost_n <- function(n = 1) {
    expr <- sprintf("cost_category_cost_%d_choice_", n)
    cols_to_keep <- grep(
      expr,
      names(x),
      value = TRUE
    )
    categories <- sub(expr, "", cols_to_keep)
    out <- apply(x[, cols_to_keep], 1, function(e) categories[e == "Checked"])
    out <- lapply(out, sort)
    out <- lapply(out, paste, collapse = ", ", sep = "")
    out <- unlist(out)
    out[out == ""] <- NA_character_
    out
  }
 
  res <- data.frame(lapply(1:10, find_category_cost_n))
  names(res) <- paste("cost_category", 1:10, sep = "_")
  res
}




#' Get costs estimates
#' 
#' This processes the 10 columns containing cost information for each row of the
#' original database.
#' 
#' @inheritParams get_cost_category
#' 
get_cost_estimate <- function(x) {
  
  cols_to_keep <- grep(
    "cost_estimate_or_mean_cost_",
    names(x),
    value = TRUE
  )
  
  out <- x[, cols_to_keep]
  names(out) <- paste("cost_estimate", seq_along(cols_to_keep), sep = "_")
  out
}




#' Get costs lower bound
#' 
#' This processes the 10 columns containing cost information for each row of the
#' original database.
#' 
#' @inheritParams get_cost_category
#' 
get_cost_lower <- function(x) {
  
  cols_to_keep <- grep(
    "cost_range_lower_bound_",
    names(x),
    value = TRUE
  )
  
  out <- x[, cols_to_keep]
  names(out) <- paste("cost_lower", seq_along(cols_to_keep), sep = "_")
  out
}




#' Get costs upper bound
#' 
#' This processes the 10 columns containing cost information for each row of the
#' original database.
#' 
#' @inheritParams get_cost_category
#' 
get_cost_upper <- function(x) {
  
  cols_to_keep <- grep(
    "cost_range_upper_bound_",
    names(x),
    value = TRUE
  )
  
  out <- x[, cols_to_keep]
  names(out) <- paste("cost_upper", seq_along(cols_to_keep), sep = "_")
  out
}


