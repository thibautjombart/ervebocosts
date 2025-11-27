

#' Classify cost items by type
#'
#' @param x tibble with all processed raw data from RedCap
#'
#' @returns vector of cost classifications into Fixed, Fixed variable, Variable or Unknown
#' @export
#' 
classify_cost <- function(x){
  act_desc_a_fv <- c("Laboratory and Facility Strengthening", "Laboratory Set Up", "Isolation Unit Centre Set-Up",
                       "setup for patient treatment","opportunity cost for beds","Strengthening IPC/WASH in health centres, schools, and communities",
                       "Fit for purpose productive and motivated health workforce","Upgrading the Public health Reference Lab to a biosafety level three lab and two regional public Health laboratories",
                       "Laboratory and Facility Strengthening","Surveillance, Community Outreach and Coordination of these efforts",
                       "Isolation Unit Centre Set-Up","Laboratory Set-Up")
  
  act_desc_a_v <- c("Laboratory tests supplies","Treatment and Contact Tracing", "Surveillance, Community Outreach and Coordination of these efforts", "Food support to contacts and other affected beneficiaries")
  
  cost_class <- dplyr::case_when(
    !is.na(x$cost_type) & x$cost_type == "Unit cost" ~ "Variable",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "patient treatment days") ~ "Variable",
    !is.na(x$cost_subcategory) & str_detect(x$cost_subcategory, "Vaccine Kit") ~ "Variable",
    !is.na(x$cost_subcategory) & str_detect(x$cost_subcategory, "Vaccine Bundle") ~ "Variable",
    !is.na(x$cost_subcategory) & str_detect(x$cost_subcategory, "Treatment and Contact Tracing") ~ "Variable",
    !is.na(x$activities_description_b) & str_starts(x$activities_description_b, "Food support to contacts and other affected beneficiaries") ~ "Variable",
    !is.na(x$activities_description_a) & x$activities_description_a %in% act_desc_a_v ~ "Variable",
    
    !is.na(x$cost_category) & x$cost_category == "risk_communication" ~ "Fixed",
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Enhancement of quality service") ~ "Fixed",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Finalize construction of an Emergency Operations") ~ "Fixed",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Strengthen the National Drug Service") ~ "Fixed",
    !is.na(x$cost_category) & x$cost_category == "logistics, personnel" ~ "Fixed variable",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Europe Isolation Facility Preparation") ~ "Fixed",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "US Treatment Centre Preparation") ~ "Fixed",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Purchase of Telephones" ) & x$number_activities == 1 ~ "Fixed",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Purchase of Materials" ) & x$number_activities == 1 ~ "Fixed",
    !is.na(x$activities_description_a) & str_detect(x$activities_description_a, "Emergency Operations Centre" ) ~ "Fixed",
    !is.na(x$activities_description_a) & str_detect(x$activities_description_a, "EWARS Total" ) ~ "Fixed",
    !is.na(x$activities_description_a) & str_detect(x$activities_description_a, "Contingency planning to manage increased security and political risks" ) ~ "Fixed",
    
  
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "ETC Set") ~ "Fixed variable",
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "ETU Set") ~ "Fixed variable",
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "ETUs built") ~ "Fixed variable",
    !is.na(x$cost_type) & x$cost_type == "Operational" ~ "Fixed variable",
    !is.na(x$cost_category) & x$cost_category == "personnel" ~ "Fixed variable",
    !is.na(x$cost_type) & x$cost_type == "Setup" & x$activities_count_a == "1 ETC" ~ "Fixed variable",
    !is.na(x$cost_category) & x$cost_category == "logistics" & x$activities_count_a == "1 ETC" ~ "Fixed variable",
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Re-engineered health infrastructure") ~ "Fixed variable",
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Community Care Centre Set Up") ~ "Fixed variable",
    !is.na(x$activities_count_a) & (str_detect(x$activities_count_a, "Teams")| str_detect(x$activities_count_a, "teams")) ~ "Fixed variable",
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Additional costs for ETUs") ~ "Fixed variable",
    !is.na(x$cost_subcategory) & str_detect(x$cost_subcategory, "CUBE") ~ "Fixed variable",
    !is.na(x$activities_description_a) & x$activities_description_a %in% act_desc_a_fv ~ "Fixed variable",
    !is.na(x$activities_description_b) & str_starts(x$activities_description_b, "Contingency planning to manage increased security and political risks") ~ "Fixed",
    !is.na(x$cost_subcategory) & x$cost_subcategory == "Construction of cold room" ~ "Fixed variable",
    !is.na(x$cost_subcategory) & x$cost_subcategory == "Fit for purpose productive and motivated health workforce" ~ "Fixed variable",
  
    TRUE ~ "Unknown"
    # the following will be under Unknown
    #[1] "Additional operations and logistical support"                                                   
    #[2] "Strengthened tracking of contacts lost to follow-up including across health zones and provinces"
    #[3] "Strengthened information management and operational planning"                                   
    #[4] NA                                                                                               
    #[5] "Surveillance, Community Outreach and Coordination of these efforts"                             
    #[6] "Patient treatment outside the Directly Affected Region"           
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
  
  perspective <- dplyr::case_when(
    !is.na(x$cost_subcategory) & grepl("NHGDP Loss", x$cost_subcategory) ~ 0,
    !is.na(x$cost_subcategory) & grepl("GDP per Capita Loss", x$cost_subcategory) ~ 0,
    x$cost_class == "Unknown" ~ 0,
    !is.na(x$activities_description_a) & str_starts(x$activities_description_a, "Food") ~ 0,
    !is.na(x$cost_category) & str_starts(x$cost_category, "psychosocial") ~ 0,
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Death Benefit to families") ~ 0,
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "US Treatment Centre Preparation") ~ 0,
    !is.na(x$cost_subcategory) & str_starts(x$cost_subcategory, "Europe Isolation Facility Preparation") ~ 0,
    !is.na(x$cost_category_other) & x$cost_category_other=="Productivity Loss" ~ 0,
    !is.na(x$cost_category_other) & x$cost_category_other=="Opportunity Cost for Hospital Ward" ~ 0,
    !is.na(x$cost_category_other) & x$cost_category_other=="Food support to contacts and other affected beneficiaries" ~ 0,
    !is.na(x$cost_category_other) & x$cost_category_other=="Recovery and Economy" ~ 0,
    TRUE ~ 1
  )
  
  
  return(perspective)
}