# test_get_json_from_api.R

context("get_json_from_api-function")

# expect correct request, url and header
test_that("it outputs a GET request with correct URL and client-identifier",{
  expect_equal(get_json_from_api(valid_json_target)$request$method, "GET")
  expect_equal(get_json_from_api(valid_json_target)$url, paste(api_base, station_information_target, sep=""))
  expect_header(get_json_from_api(valid_json_target), paste("Client-Identifier:", client_header))
})

# expect return object is "application/json"
test_that("return after success is application/json",{
  expect_equal(http_type(get_json_from_api(valid_json_target)), "application/json")
})

# expect http error if given wrong target
test_that("it throws error on wrong target",{
  expect_error(get_json_from_api(invalid_json_target), "HTTP Error")
})

