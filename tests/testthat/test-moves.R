library(testthat)
library(fflr)

test_that("movies returns for current year", {
  m <- roster_moves(252353, old = FALSE)
  expect_s3_class(m, "tbl")
  expect_length(m, 14)
  expect_s3_class(m$date, "POSIXct")
  expect_equal(unique(nchar(m$tx)), 8)
  expect_s3_class(m$from_slot, "factor")
})

test_that("moves error for past years", {
  expect_error(roster_moves(252353, old = TRUE))
})
