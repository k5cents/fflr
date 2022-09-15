test_that("historical data can be returned", {
  h <- league_standings(
    leagueId = "42654852",
    leagueHistory = TRUE
  )
  expect_type(h, "list")
  expect_length(h, 1)
  expect_s3_class(h[[1]], "data.frame")
})
