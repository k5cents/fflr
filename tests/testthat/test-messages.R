test_that("league messages", {
  m <- league_messages(leagueId = "42654852")
  expect_s3_class(m, "data.frame")
  expect_length(m, 7)
  expect_s3_class(m$date, "POSIXt")
})

test_that("league message errors", {
  expect_error(league_messages(leagueId = "42654852", leagueHistory = TRUE))
})
