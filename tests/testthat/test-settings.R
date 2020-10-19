library(testthat)
library(fflr)

# draft settings ----------------------------------------------------------

test_that("draft settings for a single season", {
  d <- draft_settings(252353, old = FALSE)
  expect_type(d, "list")
  expect_length(d, 8)
  expect_s3_class(d$date, "POSIXt")
  expect_type(d$order, "integer")
})

test_that("draft settings for past seasons", {
  d <- draft_settings(252353, old = TRUE)
  expect_s3_class(d, "tbl")
  expect_length(d, 8)
  expect_s3_class(d$date, "POSIXt")
  expect_type(d$order, "list")
})

# league info -------------------------------------------------------------

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

# league name -------------------------------------------------------------

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

# waiver setting ----------------------------------------------------------

test_that("waiver settings for a single season", {
  w <- waiver_settings(252353, old = FALSE)
  expect_type(w, "list")
  expect_length(w, 10)
  expect_type(w$budget, "integer")
  expect_type(w$process_days, "character")
  expect_type(w$order_reset, "logical")
  expect_true(w$order_reset)
})

test_that("waiver settings for past seasons", {
  w <- waiver_settings(252353, old = TRUE)
  expect_s3_class(w, "tbl")
  expect_length(w, 10)
  expect_equal(nrow(w), 5)
  expect_type(w$process_days, "list")
  expect_type(w$process_days[[1]], "character")
})

# fee settings ------------------------------------------------------------

test_that("fee settings for a single season", {
  f <- fee_settings(252353, old = FALSE)
  expect_type(f, "list")
  expect_length(f, 9)
  expect_type(f$entry, "double")
})

test_that("fee settings for past seasons", {
  f <- fee_settings(252353, old = TRUE)
  expect_s3_class(f, "tbl")
  expect_length(f, 9)
  expect_equal(nrow(f), 5)
  expect_type(f$entry, "double")
})

# roster settings ---------------------------------------------------------

test_that("roster settings for a single season", {
  r <- roster_settings(252353, old = FALSE)
  expect_type(r, "list")
  expect_length(r, 7)
  expect_named(r$slot_count)
})

test_that("roster settings for past seasons", {
  r <- roster_settings(252353, old = TRUE)
  expect_s3_class(r, "tbl")
  expect_length(r, 7)
  expect_equal(nrow(r), 5)
  expect_type(r$slot_count, "list")
  expect_s3_class(r$slot_count[[1]], "tbl")
})

# schedule settings -------------------------------------------------------

test_that("schedule settings for a single season", {
  s <- schedule_settings(252353, old = FALSE)
  expect_type(s, "list")
  expect_length(s, 9)
  expect_s3_class(s$match_sched, "tbl")
  expect_s3_class(s$divisions, "tbl")
})

test_that("schedule settings for past seasons", {
  s <- schedule_settings(252353, old = TRUE)
  expect_s3_class(s, "tbl")
  expect_length(s, 9)
  expect_equal(nrow(s), 5)
  expect_type(s$divisions, "list")
  expect_s3_class(s$divisions[[1]], "tbl")
  expect_type(s$match_sched, "list")
  expect_s3_class(s$match_sched[[1]], "tbl")
})

# scoring settings --------------------------------------------------------

test_that("scoring settings for a single season", {
  s <- score_settings(252353, old = FALSE)
  expect_type(s, "list")
  expect_length(s, 7)
  expect_s3_class(s$scoring, "tbl")
})

test_that("scoring settings for past seasons", {
  s <- score_settings(252353, old = TRUE)
  expect_s3_class(s, "tbl")
  expect_length(s, 7)
  expect_equal(nrow(s), 5)
  expect_type(s$scoring, "list")
  expect_s3_class(s$scoring[[1]], "tbl")
})

# trade settings ----------------------------------------------------------

test_that("trade settings for a single season", {
  t <- trade_settings(252353, old = FALSE)
  expect_type(t, "list")
  expect_length(t, 6)
  expect_s3_class(t$deadline, "POSIXt")
})

test_that("trade settings for past seasons", {
  t <- trade_settings(252353, old = TRUE)
  expect_s3_class(t, "tbl")
  expect_length(t, 6)
  expect_equal(nrow(t), 5)
  expect_s3_class(t$deadline, "POSIXt")
})
