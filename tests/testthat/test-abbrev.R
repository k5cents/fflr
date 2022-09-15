tm <- league_teams("42654852")

# team --------------------------------------------------------------------

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
  expect_error(team_unabbrev("test", tm))
})

# slot --------------------------------------------------------------------

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
  expect_error(slot_unabbrev("test"))
})

# pos ---------------------------------------------------------------------

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

test_that("position abbreviation errors", {
  expect_error(pos_abbrev("test"))
  expect_error(pos_unabbrev("test"))
})

# pro-team ----------------------------------------------------------------

test_that("pro-team abbreviation", {
  x <- pro_abbrev(1)
  expect_length(x, 1)
  expect_s3_class(x, "factor")
  expect_equal(as.character(x), "Atl")
})

test_that("pro-team un-abbreviation", {
  x <- pro_unabbrev("Atl")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})

test_that("pro-team abbreviation errors", {
  expect_error(pro_unabbrev("test"))
})

# stat --------------------------------------------------------------------

test_that("stat abbreviation", {
  x <- stat_abbrev(1)
  expect_length(x, 1)
  expect_equal(x, "PC")
})

test_that("stat un-abbreviation", {
  x <- stat_unabbrev("PC")
  expect_length(x, 1)
  expect_type(x, "integer")
  expect_equal(x, 1)
})

test_that("state abbreviation errors", {
  expect_error(stat_unabbrev("test"))
})
