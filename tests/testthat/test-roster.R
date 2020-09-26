library(testthat)
library(fflr)

test_that("rosters return for current year", {
  r <- team_roster(252353, old = FALSE)
  expect_type(r, "list")
  expect_s3_class(r[[1]], "tbl")
  expect_length(r, 8)
})

test_that("rosters return for past years", {
  r <- team_roster(252353, old = TRUE)
  expect_type(r, "list")
  expect_type(r[[1]], "list")
  expect_length(r, 5)
  expect_length(r[[1]], 8)
})

test_that("slots are abbreviated", {
  x <- pos_abbrev(1:2)
  expect_equal(as.character(x), c("QB", "RB"))
  expect_s3_class(x, "factor")
})

test_that("positions are abbreviated", {
  x <- slot_abbrev(21)
  expect_equal(as.character(x), "IR")
  expect_s3_class(x, "factor")
})
