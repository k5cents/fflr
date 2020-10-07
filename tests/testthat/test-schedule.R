library(testthat)
library(fflr)

test_that("schedule returns for current year", {
  s <- match_schedule(252353, old = FALSE)
  expect_s3_class(s, "tbl")
  expect_type(s$home, "logical")
})

test_that("schedule returns for past years", {
  s <- match_schedule(252353, old = TRUE)
  expect_type(s, "list")
  expect_s3_class(s[[1]], "tbl")
  expect_length(s, 5)
})

test_that("NFL schedule returns for current year", {
  s <- pro_schedule()
  expect_length(s, 7)
  expect_s3_class(s, "tbl")
  expect_type(s$home, "logical")
  expect_type(s$future, "logical")
  expect_s3_class(s$pro, "factor")
  expect_s3_class(s$kickoff, "POSIXct")
})
