library(testthat)
library(fflr)

test_that("rosters return for current year", {
  t <- moves_summary(252353, old = FALSE)
  expect_s3_class(t, "tbl")
  expect_length(t, 11)
})

test_that("rosters return for past years", {
  t <- moves_summary(252353, old = TRUE)
  expect_type(t, "list")
  expect_length(t, 5)
  expect_length(t[[1]], 11)
  expect_s3_class(t[[1]], "tbl")
})
