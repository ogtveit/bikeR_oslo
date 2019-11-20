#! /usr/bin/env Rscript

#' test regime for bikeR_oslo
#' test functions in bikeR_functions.R

library(httr)
library(jsonlite)
library(testthat)
library(here)
library(httptest)

### Test setup ###
client_header = "ogt-bikeR_test"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"
station_information_target <- "station_information.json"
station_status_target <- "station_status.json"

source(here("bikeR_functions.R"))
test_results <- test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)
