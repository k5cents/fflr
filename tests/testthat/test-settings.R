library(testthat)
library(fflr)

test_that("draft settings for a single season", {
  d <- draft_settings(252353, old = FALSE)
  expect_type(d, "list")
  expect_length(d, 7)
  expect_s3_class(d$date, "POSIXt")
  expect_type(d$order, "integer")
})

test_that("draft settings for past seasons", {
  d <- draft_settings(252353, old = TRUE)
  expect_s3_class(d, "tbl")
  expect_length(d, 7)
  expect_s3_class(d$date, "POSIXt")
  expect_type(d$order, "list")
})

test_that("league info for a single season", {
  d <- league_info(252353, old = FALSE)
  expect_type(d, "list")
  expect_length(d, 6)
  expect_true(d$public)
  expect_type(d$year, "integer")
})

test_that("league info for past seasons", {
  d <- league_info(252353, old = TRUE)
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 5)
})

test_that("named vector of past seasons for league", {
  d <- league_size(252353, old = TRUE)
  expect_length(d, 5)
  expect_type(d, "integer")
  expect_named(d)
})

test_that("league name returns as single character element", {
  d <- league_name(252353)
  expect_length(d, 1)
  expect_type(d, "character")
})
