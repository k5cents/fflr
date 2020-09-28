library(testthat)
library(fflr)

test_that("teams return for current year", {
  t <- league_teams(252353, old = FALSE)
  expect_type(t$owners, "list")
  expect_s3_class(t, "tbl")
})

test_that("teams return for all past years", {
  t <- league_teams(252353, old = TRUE)
  expect_type(t, "list")
  expect_s3_class(t[[1]], "tbl")
  expect_length(t, 5)
})
