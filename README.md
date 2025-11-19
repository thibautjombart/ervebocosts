
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

## Getting cost items

The main helper function extracts (where available) data on the
outbreaks and documented cost items:

``` r
x <- get_cost_items(raw_data)
x <- as.data.frame(x)
```

``` r
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
#>   item cost_category                               cost_summary cost_estimate
#> 1    1         other                   US Dollar, USD: 7.5e+08      750000000
#> 2    1         other                 US Dollar, USD: 143890000      143890000
#> 3    1         other US Dollar, USD:  [6739550567 - 6739550567]            NA
#> 4    1     personnel                                       <NA>            NA
#> 5    1     personnel                                       <NA>            NA
#> 6    2   vaccination                                       <NA>            NA
#>   cost_lower cost_upper
#> 1         NA         NA
#> 2         NA         NA
#> 3 6739550567 6739550567
#> 4         NA         NA
#> 5         NA         NA
#> 6         NA         NA
```

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
#>   item cost_category                         cost_summary cost_estimate
#> 1   10           ipc US Dollar, USD:  [1784000 - 1784000]            NA
#>   cost_lower cost_upper
#> 1    1784000    1784000
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
