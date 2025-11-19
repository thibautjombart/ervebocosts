#' Get summary of cost items 
#' 
#' This is the main function to extract information from the REDCap database.
#' It extracts data on the outbreaks, cost categories, and cost estimates.

get_cost_items <- function(x) {
  
  df_outbreak_data <- get_outbreak_data(x)
  
  df_categ <- cbind(
    df_outbreak_data, 
    get_cost_category(x)
  ) %>% 
    select(record_id, cost_category_1:cost_category_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_category") %>% 
    mutate(item = as.integer(gsub("cost_category_", "", item)))
  
  df_subcateg <- cbind(
    df_outbreak_data, 
    get_cost_subcategory(x)
  ) %>% 
    select(record_id, cost_subcategory_1:cost_subcategory_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_subcategory") %>% 
    mutate(item = as.integer(gsub("cost_subcategory_", "", item)))
  
  df_cost_smry <- cbind(
    df_outbreak_data, 
    get_cost_smry(x)
  ) %>% 
    select(record_id, cost_smry_1:cost_smry_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_summary") %>% 
    mutate(
      item = as.integer(gsub("cost_smry_", "", item)))
  
  df_cost_estimate <- cbind(
    df_outbreak_data, 
    get_cost_estimate(x)
  ) %>% 
    select(record_id, cost_estimate_1:cost_estimate_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_estimate") %>% 
    mutate(
      item = as.integer(gsub("cost_estimate_", "", item)))
  
  df_cost_lower <- cbind(
    df_outbreak_data, 
    get_cost_lower(x)
  ) %>% 
    select(record_id, cost_lower_1:cost_lower_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_lower") %>% 
    mutate(
      item = as.integer(gsub("cost_lower_", "", item)))
  
  df_cost_upper <- cbind(
    df_outbreak_data, 
    get_cost_upper(x)
  ) %>% 
    select(record_id, cost_upper_1:cost_upper_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_upper") %>% 
    mutate(
      item = as.integer(gsub("cost_upper_", "", item)))
  
 
  out <- right_join(df_outbreak_data, df_categ, by = "record_id")
  out <- full_join(out, df_subcateg, by = c("record_id", "item"))
  out <- full_join(out, df_cost_smry, by = c("record_id", "item"))
  out <- full_join(out, df_cost_estimate, by = c("record_id", "item"))
  out <- full_join(out, df_cost_lower, by = c("record_id", "item"))
  out <- full_join(out, df_cost_upper, by = c("record_id", "item"))
  
  out <- filter(out, !is.na(cost_category) | !is.na(cost_summary))
  out <- select(out, -item)
  out
}
