library(testthat)
library(fflr)

test_that("all players can be listed without error", {
  skip_on_cran()
  p <- all_players(lid = NULL)
  expect_s3_class(p, "tbl")
  expect_length(p, 19)
  expect_s3_class(p$pos, "factor")
  expect_type(p$id, "integer")
  # expect_type(p$first, "character")
  expect_type(p$start, "double")
})
