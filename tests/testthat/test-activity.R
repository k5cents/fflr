test_that("recent activity", {
  a <- recent_activity(
    leagueId = "42654852",
    seasonId = 2021,
    scoringPeriodId = 1
  )
  expect_s3_class(a, "data.frame")
  expect_length(a, 16)
  expect_type(a$items, "list")
})
