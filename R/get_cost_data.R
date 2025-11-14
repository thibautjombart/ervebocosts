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
  ## some entries in this matrix are plain text, which is a problem; 
  ## we regard these as NAs
  out <- data.frame(lapply(out, function(e) suppressWarnings(as.numeric(e)))) # force convert to numeric
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




#' Get costs currency
#' 
#' This processes the 10 columns containing cost information for each row of the
#' original database.
#' 
#' @inheritParams get_cost_category
#' 
get_cost_currency <- function(x) {
  
  cols_to_keep <- grep(
    "currency_cost",
    names(x),
    value = TRUE
  )
  
  out <- x[, cols_to_keep]
  names(out) <- paste("cost_currency", seq_along(cols_to_keep), sep = "_")
  out
}



#' Get costs summary
#'
#' Obtain a text summary of cost estimates. This processes the 10 columns
#' containing cost information for each row of the original database.
#'
#' @inheritParams get_cost_category
#' 
get_cost_smry <- function(x) {
  temp <- get_cost_estimate(x)
  cost <- unlist(temp)
  cost[is.na(cost)] <- ""
  unit <- unlist(get_cost_currency(x))
  unit[is.na(unit)] <- ""
  main <- paste(unit, cost, sep = ": ")
  # main[is.na(cost)] <- ""
  
  lower <- unlist(get_cost_lower(x))
  upper <- unlist(get_cost_upper(x))
  ci <- sprintf("[%s - %s]", lower, upper)
  ci[is.na(lower)] <- ""
  
  out <- paste(main, ci)
  dim(out) <- dim(temp)
  out <- as.data.frame(out)
  names(out) <- paste("cost_smry", seq_len(ncol(temp)), sep = "_")
  out
}


