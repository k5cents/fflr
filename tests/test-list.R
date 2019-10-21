library(fflr)
library(testthat)

testthat::test_that("fantasy_data returns a list", {
  data <- fantasy_data(252353)
  expect_type(data, "list")
})
