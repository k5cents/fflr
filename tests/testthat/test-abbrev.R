tm <- league_teams("42654852")

test_that("team abbreviation", {
  x <- team_abbrev(1, tm)
  expect_length(x, 1)
  expect_s3_class(x, "factor")
  expect_equal(as.character(x), "AUS")
})

test_that("team un-abbreviation", {
  x <- team_unabbrev("AUS", tm)
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})

test_that("team abbreviation errors", {
  expect_error(team_abbrev(1, mtcars))
})

# -------------------------------------------------------------------------

test_that("slot abbreviation", {
  x <- slot_abbrev(0)
  expect_length(x, 1)
  expect_s3_class(x, "factor")
  expect_equal(as.character(x), "QB")
})

test_that("slot un-abbreviation", {
  x <- slot_unabbrev("QB")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 0)
})

test_that("slot abbreviation errors", {
  expect_error(slot_abbrev("test"))
})

# -------------------------------------------------------------------------

test_that("position abbreviation", {
  x <- pos_abbrev(1)
  expect_length(x, 1)
  expect_s3_class(x, "factor")
  expect_equal(as.character(x), "QB")
})

test_that("position un-abbreviation", {
  x <- pos_unabbrev("QB")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})

# -------------------------------------------------------------------------

test_that("position abbreviation", {
  x <- pro_abbrev(1)
  expect_length(x, 1)
  expect_s3_class(x, "factor")
  expect_equal(as.character(x), "Atl")
})

test_that("position un-abbreviation", {
  x <- pro_unabbrev("Atl")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})

# -------------------------------------------------------------------------

test_that("position abbreviation", {
  x <- stat_abbrev(1)
  expect_length(x, 1)
  expect_equal(x, "PC")
})

test_that("position un-abbreviation", {
  x <- stat_unabbrev("PC")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})
