# helper_extract_from_json.R

#store object to validate
#saveRDS(station_information, here("tests/testthat", "valid_json.rds"))

# get valid 'application/json'-object
valid_application_json <- readRDS(here('tests/testthat', 'valid_json.rds'))
