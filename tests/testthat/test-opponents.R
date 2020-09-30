library(testthat)
library(fflr)

test_that("opponent ranks are tidy table", {
  o <- opponent_ranks(NULL)
  expect_s3_class(o, "tbl")
  expect_type(o$rank, "integer")
  expect_type(o$avg, "double")
  expect_length(o, 4)
  expect_equal(nrow(o), (nrow(fflr::nfl_teams) - 1) * 6)
})
