library(testthat)
library(fflr)

test_that("draft returns for current year", {
  d <- draft_picks(252353, old = FALSE)
  expect_s3_class(d, "tbl")
})

test_that("draft returns for past years", {
  d <- draft_picks(252353, old = TRUE)
  expect_type(d, "list")
  expect_s3_class(d[[1]], "tbl")
  expect_length(d, 5)
})

test_that("snake draft with v3 API using different league", {
  d <- draft_picks(46920214, old = FALSE)
  expect_s3_class(d, "tbl")
})
