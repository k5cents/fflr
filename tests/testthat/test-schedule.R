library(testthat)
library(fflr)

test_that("schedule returns for current year", {
  s <- match_schedule(252353, old = FALSE)
  expect_s3_class(s, "tbl")
  expect_s3_class(s$home, "factor")
})

test_that("schedule returns for past years", {
  s <- match_schedule(252353, old = TRUE)
  expect_type(s, "list")
  expect_s3_class(s[[1]], "tbl")
  expect_length(s, 5)
})
