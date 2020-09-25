library(testthat)
library(fflr)

test_that("all players can be listed without error", {
  p <- all_players()
  expect_s3_class(p, "tbl")
  expect_length(p, 17)
  expect_s3_class(p$pos, "factor")
  expect_type(p$id, "integer")
  # expect_type(p$first, "character")
  expect_type(p$start, "double")
})
