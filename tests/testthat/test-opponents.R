library(testthat)
library(fflr)

test_that("opponent teams listed by average points", {
  o <- opponent_rank(type = "avg")
  expect_s3_class(o, "tbl")
  expect_type(o$qb, "double")
  expect_length(o, 8)
})

test_that("opponent teams listed by rank", {
  o <- opponent_rank(type = "rank")
  expect_s3_class(o, "tbl")
  expect_true(all(as.integer(o$qb) == o$qb))
  expect_length(o, 8)
})
