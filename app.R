#! /usr/bin/env Rscript
#' app.R
#' 
#' Version: 0.2
#' Author: github.com/ogtveit
#' Date: 2019-11-19
#' 
#' Get list of bike-rental stands in oslo and print: name - avaliable bikes - avaliable docks
#' API documentation: https://oslobysykkel.no/apne-data/sanntid


### Libraries ###
# install libraries if missing
if (!require('httr')) install.packages('httr', repos="https://cran.uib.no")
if (!require('jsonlite')) install.packages('jsonlite', repos="https://cran.uib.no")
if (!require('dplyr')) install.packages('dplyr', repos="https://cran.uib.no")
if (!require('shiny')) install.packages('shiny', repos="https://cran.uib.no")
if (!require('leaflet')) install.packages('leaflet', repos="https://cran.uib.no")

# load libraries
library(httr)
library(jsonlite)
library(dplyr)
library(shiny)
library(leaflet)


### Setup ###
client_header = "ogt-bikeR_shiny"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"
station_information_target <- "station_information.json"
station_status_target <- "station_status.json"


### Functions ###
# GET the json from given target
get_json_from_api <- function(json_target) {
  fetch <- GET(paste(api_base, json_target, sep=""),  add_headers("Client-Identifier" = client_header))
  if (http_error(fetch)) stop(paste("HTTP Error when fetching ", json_target))
  fetch
}

# extract list of lists from json objects
extract_from_json <- function(json){
  fromJSON(content(json, as="text", encoding = "UTF-8"))$data$stations
}

### main data-fetch function ###
fetch_from_api <- function() {
  #' fetch_from_api() gets JSON from api_base
  #' function returns list with two objects: stations, fetched at
  #' stations is data.frame with joined information from station_informasjon.json and station_status.json
  #' fetched_at is timestamp of fetch

  # Get JSON 
  station_information <- get_json_from_api(station_information_target)
  station_status <- get_json_from_api(station_status_target)
  
  # save timestamp from _status
  fetched_at <- station_status$date
  
  # extract data from JSON and unpack
  station_information <- extract_from_json(station_information)
  station_status <- extract_from_json(station_status)
  
  # join information and status
  stations <- left_join(station_information, station_status, by="station_id") %>%
    select(name, num_bikes_available, num_docks_available, lat, lon) # keep only name, free bikes, free dock # v.2 lat,lon
  
  list(stations, fetched_at)
}


### Shiny ###
ui <- fluidPage(
  titlePanel("Oslo bysykkel station status version 0.2"),
  
  sidebarLayout(position = 'right',
    sidebarPanel(
      actionButton("refresh_button",label = "Refresh"),
      p(),
      textOutput("text"),
      p(),
      htmlOutput("author")
    ),
    mainPanel(
        leafletOutput("bike_station_map")
    )
  )
)

server <- function(input, output, session) {
  # fetch from api on server start
  stations <- fetch_from_api()
  fetched <- format(stations[[2]], format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Oslo")
  stations <- stations[[1]]
  
  # make reactive variable with data and fetched_at
  RV <- reactiveValues(data = stations, timestamp = fetched, toofast = NULL)  
  
  # function for iconset -  color markers according to avaliable bikes
  create_icons <- function(bikelist){
    awesomeIcons( 
      icon = 'bicycle',
      iconColor = 'black',
      library = 'fa', 
      markerColor = ifelse(
        bikelist >0, 
        'green', 
        'red')
    )
  }
  
  # create iconset
  icons <- create_icons(stations$num_bikes_available)
  
  # render leaflet map in mainpanel
  output$bike_station_map <- renderLeaflet({
    leaflet(RV$data) %>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>%
      addTiles() %>%
      addAwesomeMarkers(
        lng = ~lon, 
        lat = ~lat,
        popup = ~paste('<b>',name,'</b><br />',
                       'Free bikes: ', num_bikes_available,'<br />',
                       'Free docks: ', num_docks_available),
        icon=icons
      )
  })
  
  # reactive text field in sidebar
  output$text <- renderText(paste("Data updated at: ", RV$timestamp))
  
  # static html area in sidebar
  output$author <- renderUI(HTML(paste(RV$toofast, "Created by: ogtveit<br />Created on: 2019-11-19")) )
  
  # refresh button action (fetch and update reactive variables; if not too fast)
  observeEvent(input$refresh_button,{
    if (difftime(Sys.time(),RV$timestamp, units="secs") >= 10){ # only fetch new data is >= 10 seconds since last 
      stations <- fetch_from_api() # fetch from api
      RV$data <- stations[[1]] # update reactive data
      RV$timestamp <- format(stations[[2]], format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Oslo")
      RV$toofast <- NULL # remove "too fast" message
      icons <- create_icons(stations[[1]]$num_bikes_available) # update colors
      } 
    else {
      RV$toofast <- "Warning: refreshed too fast! (<10s)<br />"
    }
  },ignoreInit = TRUE)
}

# launch shiny server
shinyApp(ui, server)
