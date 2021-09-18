# draft settings ----------------------------------------------------------

test_that("draft settings for a single season", {
  d <- draft_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(d, "data.frame")
  expect_length(d, 13)
  expect_s3_class(d$availableDate, "POSIXt")
  expect_type(d$pickOrder, "list")
})

# league info -------------------------------------------------------------
Sys.sleep(runif(1, 1, 2))

test_that("league info for a single season", {
  d <- league_info("42654852", leagueHistory = FALSE)
  expect_s3_class(d, "data.frame")
  expect_length(d, 6)
  expect_true(d$isPublic)
  expect_type(d$seasonId, "integer")
})

# league size -------------------------------------------------------------

test_that("named vector of past seasons for league", {
  d <- league_size("252353", leagueHistory = TRUE)
  expect_s3_class(d, "data.frame")
  expect_length(d, 2)
  expect_type(d$size, "integer")
})

# league name -------------------------------------------------------------

test_that("league name returns as a data frame", {
  d <- league_name("42654852")
  expect_length(d, 1)
  expect_type(d, "character")
})

# waiver setting ----------------------------------------------------------
Sys.sleep(runif(1, 1, 2))

test_that("acquisition settings for a single season", {
  w <- acquisition_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(w, "data.frame")
  expect_length(w, 10)
  expect_type(w$acquisitionBudget, "integer")
  expect_type(w$waiverProcessDays, "list")
  expect_type(w$waiverOrderReset, "logical")
  expect_true(w$waiverOrderReset)
})

# fee settings ------------------------------------------------------------

test_that("fee settings for a single season", {
  f <- finance_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(f, "data.frame")
  expect_length(f, 9)
  expect_type(f$entryFee, "double")
})

# roster settings ---------------------------------------------------------

test_that("roster settings for a single season", {
  r <- roster_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(r, "data.frame")
  expect_length(r, 8)
  expect_s3_class(r$lineupSlotCounts[[1]], "data.frame")
})

# schedule settings -------------------------------------------------------
Sys.sleep(runif(1, 1, 2))

test_that("schedule settings for a single season", {
  s <- schedule_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(s, "data.frame")
  expect_length(s, 10)
  expect_s3_class(s$matchupPeriods[[1]], "data.frame")
  expect_s3_class(s$divisions[[1]], "data.frame")
})

# scoring settings --------------------------------------------------------

test_that("scoring settings for a single season", {
  s <- scoring_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(s, "data.frame")
  expect_length(s, 7)
})

# trade settings ----------------------------------------------------------

test_that("trade settings for a single season", {
  t <- trade_settings("42654852", leagueHistory = FALSE)
  expect_s3_class(t, "data.frame")
  expect_length(t, 6)
  expect_s3_class(t$deadlineDate, "POSIXt")
  expect_type(t$allowOutOfUniverse, "logical")
  expect_false(t$allowOutOfUniverse)
})
