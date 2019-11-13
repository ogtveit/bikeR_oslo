#! /usr/bin/env Rscript
#' app.R
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
library(shiny)
library(DT)


### Setup ###
client_header = "ogt-bikeR"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"


### data-fetch function ###
fetch_from_api <- function() {
  #' fetch_from_api() gets JSON from api_base
  #' function returns list with two objects: stations, fetched at
  #' stations is data.frame with joined information from station_informasjon.json and station_status.json
  #' fetched_at is timestamp of fetch

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
  list(stations, fetched_at)
}


### Shiny ###
ui <- fluidPage(
  titlePanel("Oslo bysykkel station status"),
  sidebarLayout(
    sidebarPanel(
      actionButton("refresh_button",label = "Refresh"),
      textOutput("text"),
      textOutput("author")
    ),
    mainPanel(
        dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  stations <- fetch_from_api()
  RV <- reactiveValues(data = stations[[1]], timestamp = stations[[2]])
  
  output$text <- renderText(paste("Fetched on: ", RV$timestamp, "GMT"))
  output$author <- renderText("Created by: ogtveit, on: 2019-11-13")
  output$table <- DT::renderDataTable(RV$data, options = list(pageLength = 25))
  
  observeEvent(input$refresh_button,{
    stations <- fetch_from_api()
    RV$data <- stations[[1]]
    RV$timestamp <- stations[[2]] 
  },ignoreInit = TRUE)
}

shinyApp(ui, server)
