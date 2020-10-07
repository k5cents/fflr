library(testthat)
library(fflr)

test_that("outlooks return without league ID", {
  o <- player_outlook(lid = NULL)
  expect_s3_class(o, "tbl")
  expect_length(o, 6)
  expect_equal(length(unique(o$week)), ffl_week(1))
})
