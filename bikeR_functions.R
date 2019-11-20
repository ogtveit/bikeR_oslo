# bike_functions.R

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
    select(name, num_bikes_available, num_docks_available, lat, lon) # keep only name, free bikes, free dock
  
  list(stations, fetched_at)
}