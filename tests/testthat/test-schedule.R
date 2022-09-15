test_that("obtain tidy fantasy schedule", {
  s <- tidy_schedule(leagueId = "42654852")
  expect_s3_class(s, "data.frame")
})

test_that("obtain tidy fantasy schedule history", {
  s <- tidy_schedule(leagueId = "42654852", leagueHistory = TRUE)
  expect_type(s, "list")
  expect_s3_class(s[[1]], "data.frame")
})

test_that("tidy matchups deprecated", {
  expect_warning(tidy_matchups(leagueId = "42654852"))
})
