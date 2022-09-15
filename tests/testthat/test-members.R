test_that("league members", {
  m <- league_members(leagueId = "42654852")
  expect_s3_class(m, "data.frame")
  expect_length(m, 3)
})
