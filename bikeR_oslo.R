#! /usr/bin/env Rscript
#' bikeR_oslo.R
#' 
#' Version: 0.2
#' Author: github.com/ogtveit
#' Date: 2019-11-12
#' 
#' Get list of bike-rental stands in oslo and print: name - avaliable bikes - avaliable docks
#' API documentation: https://oslobysykkel.no/apne-data/sanntid


### Libraries ###
# load libraries, install if missing
if (!require('httr')) install.packages('httr', repos="https://cran.uib.no")
if (!require('jsonlite')) install.packages('jsonlite', repos="https://cran.uib.no")
if (!require('dplyr')) install.packages('dplyr', repos="https://cran.uib.no")


### Setup ###
client_header = "ogt-bikeR"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"
station_information_target <- "station_information.json"
station_status_target <- "station_status.json"


### Functions ###
source("./bikeR_functions.R")

# fetch from api on start
stations <- fetch_from_api()
fetched <- format(stations[[2]], format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Oslo")
stations <- stations[[1]]

# arrange and format output
stations <- stations %>%
  select(-station_id, -lat, -lon) %>%
  arrange(name) %>% # sort in alphabetic order
  rename("Station" = name, # relabel columns
         "Avaliable bikes" = num_bikes_available, 
         "Avaliable docks" = num_docks_available)

# print final output
print(paste("Oslo bysykkel station status, data updated:", fetched))
print(stations)
