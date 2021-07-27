test_that("league ID can be found in environment", {
  id <- fflr_id(leagueId = Sys.getenv("ESPN_LEAGUE_ID"))
  expect_equal(id, "252353")
})

test_that("league ID can be supplied manually", {
  skip_if_not(nzchar(Sys.getenv("ESPN_LEAGUE_ID")))
  id <- fflr_id(leagueId = 252353)
  expect_equal(id, "252353")
})

test_that("league ID returns empty if not found", {
  skip_if_not(nzchar(Sys.getenv("ESPN_LEAGUE_ID")))
  old_id <- Sys.getenv("ESPN_LEAGUE_ID")
  Sys.unsetenv("ESPN_LEAGUE_ID")
  expect_warning(nzchar(fflr_id()))
  Sys.setenv("ESPN_LEAGUE_ID" = old_id)
})

test_that("league ID can be extracted from URL", {
  id <- fflr_id("https://fantasy.espn.com/football/team?leagueId=252353")
  expect_equal(id, "252353")
})
