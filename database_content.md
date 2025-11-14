# List of main accessible information

## Outbreak data

- pathogen: column `pathogen`

- location the data was collected for: look for columns named `outbreak_location_country_outbreak_1_choice_[country]` that has a value 'checked'; 
check other location info in "outbreak_location_province_state_region_outbreak_1" and
"outbreak_location_village_municipality_city_outbreak_1" 

- when the outbreak started: columns `grep("outbreak_start", names(x), value = TRUE)`

- when the outbreak stopped: columns `grep("outbreak_end", names(x), value = TRUE)`

- number of confirmed cases: column "number_of_confirmed_cases_outbreak_1"

- number of deaths: column "number_of_deaths_outbreak_1" 

- number of SDBs: column "number_of_safe_burials_outbreak_1"  

- number of vaccinated: column "number_of_vaccines_administered_outbreak_1"

- number of tests: column "number_of_tests_carried_out_outbreak_1"

- number of ETU admissions: column "number_of_etu_admissions_outbreak_1"  

- number of contacts traced: column "number_contacts_traced_outbreak_1"  

## Cost data:

- cost category: columns `grep("cost_category", names(x), value = TRUE)`

- cost estimate mean: columns `grep("cost_estimate_or_mean_cost_", names(x), value = TRUE)`

- cost estimate lower bound: columns `grep("cost_range_lower_bound_", names(x), value = TRUE)`

- cost estimate upper bound: columns `grep("cost_range_upper_bound_", names(x), value = TRUE)`

- currency: columns `grep("currency_cost", names(x), value = TRUE)`
