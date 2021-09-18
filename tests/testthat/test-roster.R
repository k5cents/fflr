test_that("All current team rosters as list", {
  r <- team_roster(leagueId = "42654852", scoringPeriodId = 1)
  expect_type(r, "list")
  expect_length(r, 4)
  expect_s3_class(r[[1]], "data.frame")
  expect_length(r[[1]], 15)
  expect_s3_class(r[[1]]$lineupSlot, "factor")
})

test_that("All final period team rosters as list of list", {
  rh <- team_roster(leagueId = "252353", leagueHistory = TRUE)
  expect_gt(length(rh), 4)
  expect_length(rh[[1]], 8)
  expect_length(rh[[2]], 10)
  expect_type(rh, "list")
  expect_type(rh[[1]], "list")
  expect_s3_class(rh[[1]][[1]], "data.frame")
})
