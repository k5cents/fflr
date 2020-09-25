library(testthat)
library(fflr)

test_that("API errors without league ID", {
  expect_error(ffl_api(lid = NULL))
})
