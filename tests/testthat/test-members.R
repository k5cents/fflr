test_that("league members", {
  m <- league_members(leagueId = "42654852")
  expect_s3_class(m, "data.frame")
  expect_length(m, 6)
})

test_that("league members history with names", {
  m <- league_members(leagueId = "42654852", leagueHistory = TRUE)
  expect_type(m, "list")
  expect_named(m)
  expect_s3_class(m[[1]], "data.frame")
  expect_length(m[[1]], 6)
})
