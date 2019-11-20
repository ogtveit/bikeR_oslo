# test_extract_from_json.R

context("extract_from_json-function")

# expect function with valid json content return data.frame
test_that("valid json returns data.frame",{ 
  expect_is(extract_from_json(valid_application_json), "data.frame")
})

# expect function with other content -> descriptive error
test_that("invalid content raises error",{ 
  expect_error(extract_from_json("invalid content"), "is.response")
})
