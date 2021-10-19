test_that("scores by matchup period", {
  s <- tidy_scores(
    leagueId = "42654852",
    leagueHistory = FALSE,
    useMatchup = TRUE
  )
  expect_length(unique(s$matchupPeriodId), 17)
})

test_that("scores by scoring period", {
  s <- tidy_scores(
    leagueId = "42654852",
    leagueHistory = FALSE,
    useMatchup = FALSE
  )
  expect_equal(length(unique(s$scoringPeriodId)), nrow(s)/4)
})
