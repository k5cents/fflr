test_that("opponent ranks", {
  o <- opponent_ranks(leagueId = "42654852")
  expect_s3_class(o, "data.frame")
  expect_length(o, 4)
  expect_length(unique(o$opponentProTeam), 32)
})
