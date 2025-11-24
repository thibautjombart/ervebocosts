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


#' get cost category other
#' 
#' Unlike categories, these are free-text, not text boxes. Why be consistent, 
#' huh?
get_cost_category_other <- function(x) {
  to_keep <- grep("please_specify_other_cost", names(x))
  out <- x[, to_keep]
  out
}

#' Get cost sub-category
#' 
#' Unlike categories, these are free-text, not text boxes. Why be consistent, 
#' huh?
get_cost_subcategory <- function(x) {
  to_keep <- grep("subcategory", names(x))
  out <- x[, to_keep]
  names(out) <- gsub("subcategory_cost", "subcategory", names(out)) 
  out
}


#' Get cost type
#' 
#' Unlike categories, these are free-text, not text boxes. Why be consistent, 
#' huh?
get_cost_type <- function(x) {
  to_keep <- grep("cost_type", names(x))
  out <- x[, to_keep]
  out
}

#' Get number of activities covered
#' 
#' numeric value of number of activities 
get_number_activities <- function(x) {
  to_keep <- grep("number_of_activities_captured_in_this_cost_cost_", names(x))
  out <- x[, to_keep]
  out
}

#' Get activities covered
#' 
#' strange mix of numeric and text 
get_activities <- function(x,string='a') {
  to_keep <- grep(paste0("please_specify_activities_within_this_cost_activity_",string,"_cost"), names(x))
  out <- x[, to_keep]
  out <- mutate_all(out, as.character)
  out
}

#' Get activity count for sub-activities
#' 
#' again strange mix of characters and doubles
get_activities_count <- function(x,string='a') {
  
  if(string=='e')
  {
    to_keep <- grep(paste0("please_specify_the_activity_count_associated_with_this_activity_activity_",string,"_cost"), names(x))
  } else {
    to_keep <- grep(paste0("please_specify_the_activity_count_associated_with_this_cost_activity_",string,"_cost"), names(x))
  }
  
  out <- x[, to_keep]
  out <- mutate_all(out, as.character)
  out
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
  out <- mutate_all(out, as.numeric)
  
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
  out <- mutate_all(out, as.numeric)
  
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
  out <- mutate_all(out, as.numeric)
  
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
  
  missing_entries <- out == ":  "
  out[missing_entries] <- NA
  out
}


