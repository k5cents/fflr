library(testthat)
library(fflr)

test_that("draft settings for a single season", {
  s <- league_status(252353, old = FALSE)
  expect_type(s, "list")
  expect_length(s, 12)
  expect_s3_class(s$waiver_next, "POSIXt")
  expect_s3_class(s$waiver_status$date, "POSIXt")
  expect_s3_class(s$waiver_status, "tbl")
})

test_that("draft settings for past seasons", {
  s <- league_status(252353, old = TRUE)
  expect_s3_class(s, "tbl")
  expect_length(s, 12)
  expect_s3_class(s$waiver_next, "POSIXt")
  expect_type(s$past_years, "list")
  expect_type(s$past_years[[1]], "integer")
})
