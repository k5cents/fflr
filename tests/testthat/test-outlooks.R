library(testthat)
library(fflr)

test_that("outlooks return without league ID", {
  o <- player_outlook(lid = NULL, limit = 10)
  expect_s3_class(o, "tbl")
  expect_length(o, 6)
})
