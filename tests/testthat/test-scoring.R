library(testthat)
library(fflr)

test_that("weekly scoring returns for current year", {
  w <- week_scores(252353, old = FALSE)
  expect_s3_class(w, "tbl")
  expect_length(w, 8)
})

test_that("weekly scoring returns for past years", {
  w <- week_scores(252353, old = TRUE)
  expect_type(w, "list")
  expect_s3_class(w[[1]], "tbl")
  expect_length(w, 5)
})
