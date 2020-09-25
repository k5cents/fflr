library(testthat)
library(fflr)

test_that("fantasy football seasons are listed", {
  s <- ffl_seasons()
  expect_s3_class(s, "tbl")
  expect_length(s, 6)
  expect_equal(nrow(s), 17)
})

test_that("fantasy games are listed", {
  g <- espn_games()
  expect_s3_class(g, "tbl")
  expect_length(g, 7)
  expect_equal(nrow(g), 4)
})

test_that("fantasy information is retrieved", {
  i <- ffl_info()
  expect_type(i, "list")
  expect_length(i, 6)
  expect_s3_class(i$start_date, "POSIXt")
  expect_type(ffl_week(), "double")
  expect_type(ffl_year(), "double")
})
