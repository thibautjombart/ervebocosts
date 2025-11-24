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
  
  df_cate_other <- cbind(
    df_outbreak_data, 
    get_cost_category_other(x)
  ) %>% 
    select(record_id, please_specify_other_cost_1:please_specify_other_cost_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_category_other") %>% 
    mutate(item = as.integer(gsub("please_specify_other_cost_", "", item)))
  
  df_subcateg <- cbind(
    df_outbreak_data, 
    get_cost_subcategory(x)
  ) %>% 
    select(record_id, cost_subcategory_1:cost_subcategory_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_subcategory") %>% 
    mutate(item = as.integer(gsub("cost_subcategory_", "", item)))
  
  df_cost_type <- cbind(
    df_outbreak_data, 
    get_cost_type(x)
  ) %>% 
    select(record_id, cost_type_cost_1:cost_type_cost_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "cost_type") %>% 
    mutate(item = as.integer(gsub("cost_type_cost_", "", item)))
  
  df_number_activities <- cbind(
    df_outbreak_data, 
    get_number_activities(x)
  ) %>% 
    select(record_id, number_of_activities_captured_in_this_cost_cost_1:number_of_activities_captured_in_this_cost_cost_10) %>% 
    pivot_longer(-record_id, names_to = "item", values_to = "number_activities") %>% 
    mutate(item = as.integer(gsub("number_of_activities_captured_in_this_cost_cost_", "", item)))
  
  number_of_nested_activities <- 10
  letters_in              <- letters[1:number_of_nested_activities]
  
  nested_activities_list <- list()
  nested_activities_count_list <- list()
  
  for(i in 1:number_of_nested_activities)
  {
    tmp_activity <- cbind(
      df_outbreak_data, 
      get_activities(x,letters_in[i])
    ) %>% 
      select(record_id, !!sym(paste0("please_specify_activities_within_this_cost_activity_",letters_in[i],"_cost_1")):!!sym(paste0("please_specify_activities_within_this_cost_activity_",letters_in[i],"_cost_10"))) %>% 
      pivot_longer(-record_id, names_to = "item", values_to = paste0("activities_description_",letters_in[i])) %>% 
      mutate(item = as.integer(gsub(paste0("please_specify_activities_within_this_cost_activity_",letters_in[i],"_cost_"), "", item)))
    
    nested_activities_list[[i]] <- tmp_activity
    
    if(letters_in[i]=='e')
    {
      tmp_activity_count <- cbind(
        df_outbreak_data, 
        get_activities_count(x,letters_in[i])
      ) %>% 
        select(record_id, !!sym(paste0("please_specify_the_activity_count_associated_with_this_activity_activity_",letters_in[i],"_cost_1")):!!sym(paste0("please_specify_the_activity_count_associated_with_this_activity_activity_",letters_in[i],"_cost_10"))) %>% 
        pivot_longer(-record_id, names_to = "item", values_to = paste0("activities_count_",letters_in[i])) %>% 
        mutate(item = as.integer(gsub(paste0("please_specify_the_activity_count_associated_with_this_activity_activity_",letters_in[i],"_cost_"), "", item)))
      
    } else {
      tmp_activity_count <- cbind(
        df_outbreak_data, 
        get_activities_count(x,letters_in[i])
      ) %>% 
        select(record_id, !!sym(paste0("please_specify_the_activity_count_associated_with_this_cost_activity_",letters_in[i],"_cost_1")):!!sym(paste0("please_specify_the_activity_count_associated_with_this_cost_activity_",letters_in[i],"_cost_10"))) %>% 
        pivot_longer(-record_id, names_to = "item", values_to = paste0("activities_count_",letters_in[i])) %>% 
        mutate(item = as.integer(gsub(paste0("please_specify_the_activity_count_associated_with_this_cost_activity_",letters_in[i],"_cost_"), "", item)))
    }
    
    nested_activities_count_list[[i]] <- tmp_activity_count
  }
  
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
  out <- full_join(out, df_cate_other, by = c("record_id", "item"))
  out <- full_join(out, df_subcateg, by = c("record_id", "item"))
  out <- full_join(out, df_cost_type, by = c("record_id", "item"))
  out <- full_join(out, df_number_activities, by = c("record_id", "item"))
  
  for(i in 1:number_of_nested_activities)
  {
    out <- full_join(out, nested_activities_list[[i]], by = c("record_id", "item"))
    out <- full_join(out, nested_activities_count_list[[i]], by = c("record_id", "item"))
  }
  
  out <- full_join(out, df_cost_smry, by = c("record_id", "item"))
  out <- full_join(out, df_cost_estimate, by = c("record_id", "item"))
  out <- full_join(out, df_cost_lower, by = c("record_id", "item"))
  out <- full_join(out, df_cost_upper, by = c("record_id", "item"))
  
  out <- filter(out, !is.na(cost_category) | !is.na(cost_summary))
  out <- select(out, -item)
  out
}
