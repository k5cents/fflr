test_that("calculate best possible past roster", {
  b <- best_roster(
    leagueId = "42654852",
    useScore = "actualScore",
    scoringPeriodId = 1
  )
  b1 <- b[[1]]
  expect_s3_class(b1, "data.frame")
  expect_length(b1, 17)

  start_rb <- b1$actualScore[b1$lineupSlot == "RB"]
  bench_rb <- b1$actualScore[b1$lineupSlot == "BE" & b1$position == "RB"]
  expect_gt(min(start_rb), max(bench_rb))
})

test_that("calculate best possible future roster", {
  b <- best_roster(
    leagueId = "42654852",
    useScore = "projectedScore",
    scoringPeriodId = ffl_week()
  )
  b2 <- b[[2]]
  expect_s3_class(b2, "data.frame")
  expect_length(b2, 17)

  start_wr <- b2$projectedScore[b2$lineupSlot == "WR"]
  bench_wr <- b2$projectedScore[b2$lineupSlot == "BE" & b2$position == "WR"]
  expect_gt(min(start_wr), max(bench_wr))
})
