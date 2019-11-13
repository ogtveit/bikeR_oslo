#!/usr/bin/env Rscript
#' bikeR_oslo.R
#' 
#' Author: github.com/ogtveit
#' Date: 2019-11-12
#' 
#' Get list of bike-rental stands in oslo and print: name - avaliable bikes - avaliable docks
#' API documentation: https://oslobysykkel.no/apne-data/sanntid


### Libraries 
# install libraries if missing
if (!require('httr')) install.packages('httr')
if (!require('jsonlite')) install.packages('jsonlite')
if (!require('dplyr')) install.packages('dplyr')

# load libraries
library(httr)
library(jsonlite)
library(dplyr)


### Setup 
user_agent = "ogt-bikeR"


### Get JSON 
station_information <- GET("https://gbfs.urbansharing.com/oslobysykkel.no/station_information.json",  add_headers("user-agent" = user_agent))
station_status <- GET("https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json", add_headers("user-agent" = user_agent))

# stop if http error
if (http_error(station_information) | http_error(station_status)) {
  stop("Could not fetch JSON from https://gbfs.urbansharing.com/oslobysykkel.no/")
}

# extract and unpack data from JSON 
station_information <- fromJSON(content(station_information, as="text", encoding = "UTF-8"))$data$stations
station_status <- fromJSON(content(station_status, as="text", encoding = "UTF-8"))$data$stations

# join information and status tables
stations <- left_join(station_information, station_status, by="station_id") %>%
  select(name, num_bikes_available, num_docks_available) %>% # keep only name, free bikes, free dock
  arrange(name) %>% # sort in alphabetic order
  rename("Station" = name, # relabel columns
         "Avaliable bikes" = num_bikes_available, 
         "Avaliable docks" = num_docks_available)

# print final output
stations
