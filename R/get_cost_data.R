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
