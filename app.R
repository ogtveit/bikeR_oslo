#! /usr/bin/env Rscript
#' app.R
#' 
#' Version: 0.2
#' Author: github.com/ogtveit
#' Date: 2019-11-20
#' 
#' Get list of bike-rental stands in oslo and print: name - avaliable bikes - avaliable docks
#' API documentation: https://oslobysykkel.no/apne-data/sanntid


### Libraries ###
# install libraries if missing
if (!require('httr')) install.packages('httr', repos="https://cran.uib.no")
if (!require('jsonlite')) install.packages('jsonlite', repos="https://cran.uib.no")
if (!require('dplyr')) install.packages('dplyr', repos="https://cran.uib.no")
if (!require('shiny')) install.packages('shiny', repos="https://cran.uib.no")
if (!require('shinydashboard')) install.packages('shinydashboard', repos="https://cran.uib.no")
if (!require('leaflet')) install.packages('leaflet', repos="https://cran.uib.no")


### Setup ###
client_header = "ogt-bikeR_shiny"
api_base = "https://gbfs.urbansharing.com/oslobysykkel.no/"
station_information_target <- "station_information.json"
station_status_target <- "station_status.json"


### Load functions ###
source("./bikeR_functions.R", local = TRUE)

# geolocation js-script
# https://github.com/AugustT/shiny_geolocation
geolocation_js <- '
      $(document).ready(function () {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
        function onError (err) {
          Shiny.onInputChange("geolocation", false);
        }
              
        function onSuccess (position) {
          setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("lat", coords.latitude);
            Shiny.onInputChange("long", coords.longitude);
          }, 1100)
        }
      });
              '


### Shiny ###
## Shiny UI setup ##
ui <- dashboardPage(
  dashboardHeader(title = "Oslo bysykkel station status version 0.2"),
  
  dashboardSidebar(
    actionButton("refresh_button",label = "Reload API"),
    p(),
    textOutput("text"),
    p(),
    htmlOutput("author"),
    # add in geolocation-js:
    tags$script(geolocation_js)
  ),
  
  dashboardBody(
    leafletOutput("bike_station_map", height = "calc(100vh - 80px)")
  )
)
  
  
## Shiny server setup ##
server <- function(input, output, session) {
  # fetch from api on server start
  stations <- fetch_from_api()
  fetched <- format(stations[[2]], format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Oslo")
  stations <- stations[[1]]
  
  # make reactive variable with data and fetched_at
  RV <- reactiveValues(data = stations, timestamp = fetched, toofast = NULL, markerIds = stations$station_id)  
  
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
  )}
  
  # create iconset
  icons <- create_icons(stations$num_bikes_available)
  
  # render leaflet map in dashboardBody
  output$bike_station_map <- renderLeaflet({
    leaflet(RV$data) %>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>%
      addTiles() %>%
      # add markers at bike station coordinates:
      addAwesomeMarkers( 
        layerId = RV$markerIds,
        group = "station_markers",
        lng = ~lon, 
        lat = ~lat,
        popup = ~paste('<b>',name,'</b><br />',
                       'Free bikes: ', num_bikes_available,'<br />',
                       'Free docks: ', num_docks_available),
        icon=icons # <- using green/red colors created above
        )
    })
  
  # reactive text field in sidebar
  output$text <- renderText(paste("Data updated at: ", strftime(RV$timestamp, format = "%H:%M:%S", tz = "Europe/Oslo"), "CET"))
  
  # static html area in sidebar
  output$author <- renderUI(HTML(paste(RV$toofast, "Created by: ogtveit<br />Created on: 2019-11-20")) )
  
  # refresh button action (fetch and update reactive variables; if not too fast)
  observeEvent(input$refresh_button,{
    # only fetch new data is >= 10 seconds since last:
    if (difftime(format(Sys.time(), tz="Europe/Oslo"),RV$timestamp, units="secs") >= 10){ 
      
      # fetch from api and update reactive variable
      stations <- fetch_from_api()
      RV$data <- stations[[1]]
      RV$timestamp <- format(stations[[2]], format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Oslo")
      RV$toofast <- NULL # remove "too fast" message
      RV$markerIds <- stations[[1]]$station_id # IF station_ids change
      
      # update icons object, with colors that fit bike avaliability
      icons <- create_icons(stations[[1]]$num_bikes_available)
      
      # update map with new markers
      updated_map <- leafletProxy('bike_station_map', data = RV$data) %>%
        removeMarker(layerId = RV$markerIds) %>%
        addAwesomeMarkers(
          layerId = RV$markerIds,
          group = "station_markers",
          lng = ~lon, 
          lat = ~lat,
          popup = ~paste('<b>',name,'</b><br />',
                         'Free bikes: ', num_bikes_available,'<br />',
                         'Free docks: ', num_docks_available),
          icon=icons)
      
      # re-add geolocation marker, if geolocation avaliable
      if (isTRUE(input$geolocation)) (
        addMarkers(updated_map, layerId = "geo_marker", lat = input$lat, lng = input$long)
      )
      
      } 
    else {
      # if <10s since last API timestam
      RV$toofast <- "Warning: refreshed too fast! (<10s)<br />"
    }
  },ignoreInit = TRUE)
  
  # when (if ever) geolocation is avaliable:
  observe({
    if(isTRUE(input$geolocation)) (
      leafletProxy("bike_station_map") %>%
        addMarkers(layerId = "geo_marker", lat = input$lat, lng = input$long)
    )
  })
}

# launch shiny server
shinyApp(ui, server)
