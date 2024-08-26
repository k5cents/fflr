test_that("get simulated season projections", {
  s <- league_simulation(
    leagueId = "42654852"
  )
  expect_s3_class(s, "data.frame")
  expect_length(s, 11)
})
