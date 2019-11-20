# test_fetch_from_api.R

context("fetch_from_api-function")

# expect to get list with two objects: list of lists and timestamp
test_that("returns list with data.frame and posixct",{ 
  expect_is(fetch_from_api(), "list")
  expect_is(fetch_from_api()[[1]], "data.frame")
  expect_is(fetch_from_api()[[2]], "POSIXct")
})


# return[[1]]: name, num_bikes_available, num_docks_available, lat,lon
test_that("data.frame have correct columns",{ 
  expect_equal(colnames(fetch_from_api()[[1]]), c("name", "num_bikes_available", "num_docks_available", "lat", "lon"))
})

