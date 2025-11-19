
# Welcome to the ERVEBOCOSTS repository

This repository is dedicated to …

## Getting started

You initially need to clone the repository:

``` bash
git clone git@github.com:thibautjombart/ervebocosts.git
cd ervebocosts
```

If you have done so already, make sure you use the latest version of
*main* branch by typing, in a terminal opened in the root folder:

``` bash
git checkout main
git pull
```

The infrastructure is compatible with **R** version 4.5.2. Initially,
you will need to ensure all required packages are installed on your
computer. To ensure this the first time you use the infrastructure, use:

``` r
if (!require(here)) install.packages("here")
if (!require(rio)) install.packages("rio")
if (!require(tibble)) install.packages("tibble")
if (!require(magrittr)) install.packages("magrittr")
```

## Content of the repository

The main files and folders of the repository include:

- `README.Rmd`: the *rmarkdown* file generating the `README.md`
- `README.md`: this file, serving as main documentation for the
  repository
- `data/`: folder containing the cost data
- `R/`: folder containing R helper functions to exploit the data

## Loading helper functions

To load helper functions, use:

``` r
if (!require(devtools)) {
  install.packages("devtools")
}
devtools::install_deps(dependencies = TRUE, upgrade = "never")
devtools::load_all()
library(dplyr)
library(tibble)
library(tidyr)
```

## Accessing cost data

Cost data are stored as an export of a REDCap database, which is awkward
to use as-is. We provide a series of functions for importing and
processing the data in more usable formats. First, we import the data
using the helper function `import_data()`

``` r
raw_data <- import_data()
```

``` r
head(raw_data)
#> # A tibble: 6 × 2,719
#>   record_id survey_identifier survey_timestamp name_of_extractor
#>       <dbl> <lgl>             <chr>            <chr>            
#> 1         1 NA                [not completed]  <NA>             
#> 2         2 NA                [not completed]  test             
#> 3         3 NA                [not completed]  TEST             
#> 4         4 NA                [not completed]  Gemma Gilani     
#> 5         5 NA                [not completed]  Gemma Gilani     
#> 6         6 NA                [not completed]  Carl Pearson     
#> # ℹ 2,715 more variables: extractor_e_mail_address <chr>,
#> #   by_submitting_your_entry_you_confirm_that_all_data_entered_in_this_form_is_accurate_to_the_best_of_your_knowledge_choice_by_ticking_this_box_i_confirm <chr>,
#> #   pathogen <chr>, please_specify_other_8 <chr>, type_of_publication <chr>,
#> #   please_specify_other_10 <chr>, first_author_first_name_or_initial_s <chr>,
#> #   first_author_surname_or_organization <chr>, article_title <chr>,
#> #   article_doi_or_url <chr>, year_publication <dbl>, journal_name <chr>,
#> #   would_you_like_to_extract_outbreak_information_from_this_article <chr>, …
```

The content of the original database is outlined in the file
`database_content.md`.

## Extracting cost items

The main helper function extracts (where available) data on the
outbreaks and documented cost items:

``` r
x <- get_cost_items(raw_data)
x <- as.data.frame(x)
```

``` r
dim(x)
#> [1] 269  19
head(x)
#>   record_id pathogen                        locations year start_date
#> 1         6    Ebola                             <NA>   NA       <NA>
#> 2        14    Ebola democratic_republic_of_the_congo 2020 2018-08-01
#> 3        20    Ebola    guinea, liberia, sierra_leone 2016       <NA>
#> 4        24    Ebola                             <NA>   NA       <NA>
#> 5        25    Ebola                             <NA>   NA       <NA>
#> 6        25    Ebola                             <NA>   NA       <NA>
#>     end_date cases deaths sdbs vaccinations  tests admissions contacts_traced
#> 1       <NA>    NA     NA   NA           NA     NA         NA              NA
#> 2 2020-06-20  3481   2299   NA       301785 244193       1264            2687
#> 3       <NA>    NA  11310   NA           NA     NA         NA              NA
#> 4       <NA>    NA     NA   NA           NA     NA         NA              NA
#> 5       <NA>    NA     NA   NA           NA     NA         NA              NA
#> 6       <NA>    NA     NA   NA           NA     NA         NA              NA
#>   cost_category            cost_subcategory
#> 1         other                    Military
#> 2         other                        <NA>
#> 3         other Non-Health Worker Mortality
#> 4     personnel                        <NA>
#> 5     personnel                        <NA>
#> 6   vaccination                        <NA>
#>                                 cost_summary cost_estimate cost_lower
#> 1                   US Dollar, USD: 7.5e+08      750000000         NA
#> 2                 US Dollar, USD: 143890000      143890000         NA
#> 3 US Dollar, USD:  [6739550567 - 6739550567]            NA 6739550567
#> 4                                       <NA>            NA         NA
#> 5                                       <NA>            NA         NA
#> 6                                       <NA>            NA         NA
#>   cost_upper
#> 1         NA
#> 2         NA
#> 3 6739550567
#> 4         NA
#> 5         NA
#> 6         NA
```

This `data.frame` contains 269 cost items (rows) broken down as:

- `record_id`: unique ID of the record in the original REDCap database
- `pathogen`: name of the pathogen the cost was recorded for
- `locations`: all locations of the recorded costs
- `year`: year the cost item was recorded
- `start_data`: if the cost item was recorded during an outbreak, the
  starting date of the outbreak
- `end_data`: if the cost item was recorded during an outbreak, the end
  date of the outbreak
- `cases`: if the cost item was recorded during an outbreak, the number
  of confirmed cases
- `deaths`: if the cost item was recorded during an outbreak, the number
  of deaths
- `sdbs`: if the cost item was recorded during an outbreak, the number
  of safe and dignified burials (SDBs)
- `vaccination`: if the cost item was recorded during an outbreak, the
  number of vaccine doses administered
- `tests`: if the cost item was recorded during an outbreak, the number
  of tests performed
- `admissions`: if the cost item was recorded during an outbreak, the
  number of admissions to healthcare facilities
- `contact_traced`: if the cost item was recorded during an outbreak,
  the number of contacts traced
- `cost_category`: the type of activity the cost corresponds to
- `cost_category`: finer-grain precisions on the activity the cost
  corresponds to
- `cost_summary`: a text-summary of the cost estimates and confidence
  intervals, if available, including currency used
- `cost_estimate`: the numerical value of the central estimate of the
  cost
- `cost_lower`: the numerical value of the lower bound of the cost
- `cost_upper`: the numerical value of the upper bound of the cost

To subset data, we can use `dply::filter`. For instance, we can get data
on Ebola-specific costs for IPC since 2018 using:

``` r
x %>% 
  filter(pathogen == "Ebola", 
         year >= 2018, 
         cost_category == "ipc"
         )
#>   record_id pathogen                        locations year start_date
#> 1        29    Ebola democratic_republic_of_the_congo 2018 2018-08-08
#>     end_date cases deaths sdbs vaccinations tests admissions contacts_traced
#> 1 2018-12-09  9862     NA  666        43552    NA        132           27500
#>   cost_category
#> 1           ipc
#>                                                     cost_subcategory
#> 1 Strengthening IPC/WASH in health centres, schools, and communities
#>                           cost_summary cost_estimate cost_lower cost_upper
#> 1 US Dollar, USD:  [1784000 - 1784000]            NA    1784000    1784000
```

The list of documented cost categories in the database is:

``` r
pull(x, "cost_category") %>% unique() %>% sort()
#>  [1] "burials"                                      
#>  [2] "case_management"                              
#>  [3] "case_management, ipc"                         
#>  [4] "case_management, ipc, logistics, psychosocial"
#>  [5] "case_management, surveillance"                
#>  [6] "ipc"                                          
#>  [7] "ipc, logistics"                               
#>  [8] "laboratory"                                   
#>  [9] "logistics"                                    
#> [10] "logistics, personnel"                         
#> [11] "logistics, risk_communication, surveillance"  
#> [12] "other"                                        
#> [13] "personnel"                                    
#> [14] "personnel, vaccination"                       
#> [15] "psychosocial"                                 
#> [16] "risk_communication"                           
#> [17] "surveillance"                                 
#> [18] "vaccination"
```

\`

The list of documented cost subcategories in the database is:

``` r
pull(x, "cost_subcategory") %>% unique() %>% sort()
#>   [1] "Access to basic (including non-Ebola health services)"                                                               
#>   [2] "Access to Basic (Including Non-Ebola Health Services)"                                                               
#>   [3] "Access to Basic (including non-Ebola Health_ services"                                                               
#>   [4] "Access to Basic (including non-Ebola) health serivces"                                                               
#>   [5] "Additional costs for ETUs"                                                                                           
#>   [6] "Additional Deaths form Non-EVD Diseases due to diverted healthcare resources and workers"                            
#>   [7] "Additional Maternal and U5 Deaths directly attributable to EVD Health Worker Mortality"                              
#>   [8] "Additional operations and logistical support"                                                                        
#>   [9] "Air Travel Screening"                                                                                                
#>  [10] "Ambulance Rental"                                                                                                    
#>  [11] "Awareness Campaigns"                                                                                                 
#>  [12] "Awareness Campains"                                                                                                  
#>  [13] "Backstage costs"                                                                                                     
#>  [14] "Backstage Costs"                                                                                                     
#>  [15] "Biosecure Emergency Care Unit (CUBE)"                                                                                
#>  [16] "Boot Covers"                                                                                                         
#>  [17] "Buckets"                                                                                                             
#>  [18] "Burial Team"                                                                                                         
#>  [19] "Burials"                                                                                                             
#>  [20] "Burials Teams"                                                                                                       
#>  [21] "Call Alert System"                                                                                                   
#>  [22] "Care for Persons with Ebola and Infection Control"                                                                   
#>  [23] "Caregiver Deaths"                                                                                                    
#>  [24] "Cash Incentives for workers"                                                                                         
#>  [25] "Cash Incentives for Workers"                                                                                         
#>  [26] "Communication Costs"                                                                                                 
#>  [27] "Community Care Centre Set Up"                                                                                        
#>  [28] "Community Outreach"                                                                                                  
#>  [29] "Comprehensive Information, research, and communication management"                                                   
#>  [30] "Construction of an Emergency Operations Centre"                                                                      
#>  [31] "Construction of cold room"                                                                                           
#>  [32] "Contact Tracing"                                                                                                     
#>  [33] "Control Infections"                                                                                                  
#>  [34] "Cost of fule and security"                                                                                           
#>  [35] "Costs of fuel and security"                                                                                          
#>  [36] "Coveralls"                                                                                                           
#>  [37] "Cross-Cutting Enabling Functions"                                                                                    
#>  [38] "Death Benefit to families of health workers killed by EVD"                                                           
#>  [39] "Delayed Personnel Costs"                                                                                             
#>  [40] "Deployed Personnel Costs"                                                                                            
#>  [41] "Deployment of Non-US Military Personnel"                                                                             
#>  [42] "Deployment of US Military Personnel"                                                                                 
#>  [43] "Doctor Annual Pay"                                                                                                   
#>  [44] "Enhancement of quality service delivery systems"                                                                     
#>  [45] "Epidemic preparedness and response system"                                                                           
#>  [46] "ETC"                                                                                                                 
#>  [47] "ETC Construction/Facility Modifications"                                                                             
#>  [48] "ETC Set-Up"                                                                                                          
#>  [49] "ETC Unit Planning"                                                                                                   
#>  [50] "ETU Set-Up"                                                                                                          
#>  [51] "ETU Set Up"                                                                                                          
#>  [52] "Europe Isolation Facility Preparation"                                                                               
#>  [53] "EWARS Total"                                                                                                         
#>  [54] "Face Shields"                                                                                                        
#>  [55] "Field Coordination Team"                                                                                             
#>  [56] "Fit for purpose productive and motivated health workforce"                                                           
#>  [57] "Fuel"                                                                                                                
#>  [58] "GDP per Capita Loss"                                                                                                 
#>  [59] "Gloves"                                                                                                              
#>  [60] "Gown"                                                                                                                
#>  [61] "Green Numbers"                                                                                                       
#>  [62] "Hand Sanitiser"                                                                                                      
#>  [63] "Health Worker Deployments"                                                                                           
#>  [64] "Health Worker Salary"                                                                                                
#>  [65] "In-country personnel costs"                                                                                          
#>  [66] "Infrared Thermometers"                                                                                               
#>  [67] "Interagenecy Collaboration Personnel Costs"                                                                          
#>  [68] "Isolation Unit Centre"                                                                                               
#>  [69] "Isolation Unit Centre Set-Up"                                                                                        
#>  [70] "Laboratory and Facility Strengthening"                                                                               
#>  [71] "Laboratory Equipment in ETC"                                                                                         
#>  [72] "Laboratory Set-Up"                                                                                                   
#>  [73] "Laboratory tests supplies"                                                                                           
#>  [74] "Leadership and Governance capacity"                                                                                  
#>  [75] "Logistics & Supplies"                                                                                                
#>  [76] "Long-term Sequelae"                                                                                                  
#>  [77] "Management capacity for medical supplies and diagnostics"                                                            
#>  [78] "Masks"                                                                                                               
#>  [79] "Medical Care for Responders"                                                                                         
#>  [80] "Messaging"                                                                                                           
#>  [81] "Midwife Annual Pay"                                                                                                  
#>  [82] "Military"                                                                                                            
#>  [83] "Mortality; Doctors and Midwives"                                                                                     
#>  [84] "Mortality; Health Worker"                                                                                            
#>  [85] "Mortality; Non Health Workers"                                                                                       
#>  [86] "Mortality; Nurses"                                                                                                   
#>  [87] "N95 Respirators"                                                                                                     
#>  [88] "NHGDP Loss"                                                                                                          
#>  [89] "NHGDP Loss ≥ 45 years"                                                                                               
#>  [90] "NHGDP Loss, ≥ 45 years"                                                                                              
#>  [91] "NHGDP Loss, 0-14 years"                                                                                              
#>  [92] "NHGDP Loss, 0-14 Years"                                                                                              
#>  [93] "NHGDP Loss, 15-44 years"                                                                                             
#>  [94] "NHGDP Loss, All Ages"                                                                                                
#>  [95] "Non-Health Worker Mortality"                                                                                         
#>  [96] "Non-PPE and Non-Laboratory Supplies and Equipment"                                                                   
#>  [97] "Non-PPE Equipment and Non-Laboratory Supplies and Equipment"                                                         
#>  [98] "Nurse Annual Pay"                                                                                                    
#>  [99] "Operational"                                                                                                         
#> [100] "Partner Costs"                                                                                                       
#> [101] "Patient treatment outside the Directly Affected Region"                                                              
#> [102] "Personal cost for treating EVD case"                                                                                 
#> [103] "PPE supplies for ETC"                                                                                                
#> [104] "PPE Supplies for ETC"                                                                                                
#> [105] "Preparation for deployment costs"                                                                                    
#> [106] "Preventing Spread to Other Countries"                                                                                
#> [107] "Prime Staff Data Managers"                                                                                           
#> [108] "Procurement"                                                                                                         
#> [109] "Provision of Food Security adn Nutrition Care for Persons with Ebola and Infection Control"                          
#> [110] "Provision of Food Security and Nutrition"                                                                            
#> [111] "Provision of Food Security and Nutrition Care for Persons with Ebola and Infection Contorl"                          
#> [112] "Provision of Food Security and Nutrition Care for Persons with Ebola and Infection Control"                          
#> [113] "Purchase of Materials"                                                                                               
#> [114] "Purchase of Telephones"                                                                                              
#> [115] "Re-engineered health infrastructure"                                                                                 
#> [116] "Reliable Supplies of Material and Equipment"                                                                         
#> [117] "Reliable Supplies of Materials and Equipment"                                                                        
#> [118] "School Closures"                                                                                                     
#> [119] "Screening"                                                                                                           
#> [120] "Soap"                                                                                                                
#> [121] "Social Mobilisation and Community Engagement"                                                                        
#> [122] "Staff and vaccine cold-chain"                                                                                        
#> [123] "Staff Training"                                                                                                      
#> [124] "Staff Training for ETC"                                                                                              
#> [125] "Strengthened information management and operational planning"                                                        
#> [126] "Strengthened tracking of contacts lost to follow-up including across health zones and provinces"                     
#> [127] "Strengthening deepening risk communications and community engagement in acute response zones"                        
#> [128] "Strengthening IPC/WASH in health centres, schools, and communities"                                                  
#> [129] "Subnational Technical Services"                                                                                      
#> [130] "Surgical Hoods"                                                                                                      
#> [131] "Surveillance, Community Outreach and Coordination of these efforts"                                                  
#> [132] "Sustainable Community Engagement"                                                                                    
#> [133] "Transport and Fuel"                                                                                                  
#> [134] "Travel costs for Atlanta Personnel"                                                                                  
#> [135] "Travel Costs for Atlanta Personnel"                                                                                  
#> [136] "Treating"                                                                                                            
#> [137] "Treatment and Contact Tracing"                                                                                       
#> [138] "Upgrading the Public health Reference Lab to a biosafety level three lab and two regional public Health laboratories"
#> [139] "US Treatment Centre Preparation"                                                                                     
#> [140] "Vaccine Bundle"                                                                                                      
#> [141] "Vaccine Kit"                                                                                                         
#> [142] "Vaccine Storage and Management"
```
