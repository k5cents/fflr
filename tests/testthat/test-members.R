library(testthat)
library(fflr)

test_that("members returns for current year", {
  m <- league_members(252353, old = FALSE)
  expect_s3_class(m, "tbl")
})

test_that("members returns for past years", {
  m <- league_members(252353, old = TRUE)
  expect_type(m, "list")
  expect_s3_class(m[[1]], "tbl")
  expect_length(m, 5)
})
