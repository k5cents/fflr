options(fflr.leagueId = "42654852")

test_that("league ID can be found as option", {
  id <- ffl_id(leagueId = getOption("fflr.leagueId"))
  expect_equal(id, "42654852")
})

test_that("league ID can be supplied manually", {
  skip_if_not(nzchar(getOption("fflr.leagueId")))
  id <- ffl_id(leagueId = 42654852)
  expect_equal(id, "42654852")
})

test_that("league ID fails if none found or set", {
  skip_if(is.null(getOption("fflr.leagueId")))
  old_id <- getOption("fflr.leagueId")
  options(fflr.leagueId = NULL)
  expect_error(ffl_id())
  options(fflr.leagueId = old_id)
})

test_that("league ID can be extracted from URL", {
  id <- ffl_id("https://fantasy.espn.com/football/team?leagueId=42654852")
  expect_equal(id, "42654852")
})

test_that("league ID option can be set if one is provided", {
  old_id <- getOption("fflr.leagueId")
  options(fflr.leagueId = NULL)
  expect_message(ffl_id(leagueId = "123456"))
  expect_equal(getOption("fflr.leagueId"), "123456")
  options(fflr.leagueId = old_id)
})
