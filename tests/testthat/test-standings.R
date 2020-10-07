library(testthat)
library(fflr)

test_that("standings returns for current year", {
  s <- score_summary(252353, old = FALSE)
  expect_s3_class(s, "tbl")
  expect_length(s, 16)
})

test_that("standings returns for past years", {
  s <- score_summary(252353, old = TRUE)
  expect_type(s, "list")
  expect_s3_class(s[[1]], "tbl")
  expect_length(s, 5)
  expect_true(all(is.na(s[[1]]$draft)))
  expect_true(all(!is.na(s[[5]]$draft)))
  expect_true(all(is.na(s[[5]]$current)))
})
