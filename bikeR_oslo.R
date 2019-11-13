#! /usr/bin/env Rscript
#' bikeR_oslo.R
#' 
#' Author: github.com/ogtveit
#' Date: 2019-11-12
#' 
#' Get list of bike-rental stands in oslo and print: name - avaliable bikes - avaliable docks
#' API documentation: https://oslobysykkel.no/apne-data/sanntid


### Libraries ###
# install libraries if missing
if (!require('httr')) install.packages('httr')
if (!require('jsonlite')) install.packages('jsonlite')
if (!require('dplyr')) install.packages('dplyr')

# load libraries
library(httr)
library(jsonlite)
library(dplyr)


### Setup ###
client_header = "ogt-bikeR"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"


### Start ###
# Get JSON 
station_information <- GET(paste(api_base, "station_information.json", sep=""),  add_headers("client-name" = client_header))
station_status <- GET(paste(api_base, "station_status.json", sep=""), add_headers("client-name" = client_header))

fetched_at <- station_information$date

# stop if http error
if (http_error(station_information) | http_error(station_status)) {
  stop("HTTP Error when fetching JSON from https://gbfs.urbansharing.com/oslobysykkel.no/")
}

# extract data from JSON and unpack
station_information <- fromJSON(content(station_information, as="text", encoding = "UTF-8"))$data$stations
station_status <- fromJSON(content(station_status, as="text", encoding = "UTF-8"))$data$stations

# join information and status
stations <- left_join(station_information, station_status, by="station_id") %>%
  select(name, num_bikes_available, num_docks_available) %>% # keep only name, free bikes, free dock
  arrange(name) %>% # sort in alphabetic order
  rename("Station" = name, # relabel columns
         "Avaliable bikes" = num_bikes_available, 
         "Avaliable docks" = num_docks_available)

# print final output
stations

### Shiny output ###
# library(shiny)
# 
# ui <- fluidPage(
#   titlePanel("Oslo bysykkel station status"),
#   textOutput("text"),
#   tableOutput("static")
# )
# 
# server <- function(input, output, session) {
#   output$text <- renderText(paste("Station status fetched at: ", fetched_at))
#   output$static <- renderTable(stations)
# }
# 
# shinyApp(ui, server)
