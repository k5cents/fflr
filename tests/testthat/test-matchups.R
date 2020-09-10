library(testthat)
library(fflr)

test_that("matchups returns for current year", {
  m <- weekly_matchups(252353, old = FALSE)
  expect_s3_class(m, "tbl")
})

test_that("matchups returns for past years", {
  m <- weekly_matchups(252353, old = TRUE)
  expect_type(m, "list")
  expect_s3_class(m[[1]], "tbl")
  expect_length(m, 5)
})
