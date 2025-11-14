#' Format numbers into labels K, M, etc.
#' 
#' This function is used to make more human-readable labels for large numbers.
#' 
#' @export
#' @param x a `numeric` vector for which labels should be generated
#' @param show_1_as_0 a `logical` indicating whether 1s should be shown as 0s; 
#' this is only really useful when a log-transformation has been used and 1s 
#' are in fact 0s.
label_numbers <- function(x, show_1_as_0 = FALSE) {
  out <- scales::label_number(scale_cut = scales::cut_long_scale())(x)
  if (show_1_as_0) {
    out[out=="1"] <- "0"
  }
  out
}
