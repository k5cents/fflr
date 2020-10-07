library(testthat)
library(fflr)

test_that("messages return for current year", {
  m <- league_messages(252353, old = FALSE)
  expect_s3_class(m, "tbl")
  expect_length(m, 7)
  expect_s3_class(m$date, "POSIXct")
  expect_type(m$view_by, "list")
})

test_that("messages fail for all past years", {
  expect_error(league_messages(252353, old = TRUE))
})
