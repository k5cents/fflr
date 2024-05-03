test_that("historical data can be returned", {
  h <- league_standings(
    leagueId = "42654852",
    leagueHistory = TRUE
  )
  expect_type(h, "list")
  expect_length(h, ffl_year() - 2021)
  expect_s3_class(h[[1]], "data.frame")
})

test_that("historical data can be combined", {
  h <- combine_history(
    fun = league_simulation,
    leagueId = "42654852"
  )
  expect_s3_class(h, "data.frame")
  expect_length(h, 6)
})
