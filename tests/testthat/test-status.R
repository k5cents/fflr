test_that("league status", {
  s <- league_status(leagueId = "42654852")
  expect_s3_class(s, "data.frame")
  expect_length(s, 12)
  expect_s3_class(s$activatedDate, "POSIXt")
  expect_type(s$previousSeasons, "list")
})
