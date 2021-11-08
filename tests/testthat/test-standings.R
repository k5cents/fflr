test_that("standings returns data frame", {
  s <- league_standings("42654852")
  expect_s3_class(s, "data.frame")
  expect_length(s, 17)
})

test_that("combine all historical standings", {
  s <- combine_history(league_standings, "252353")
  expect_s3_class(s, "data.frame")
  expect_gt(nrow(s), 10)
  expect_gt(length(unique(s$seasonId)), 1)
})

test_that("simulations returns data frame", {
  s <- league_simulation("42654852")
  expect_s3_class(s, "data.frame")
  expect_length(s, 11)
  expect_true("playoffPct" %in% names(s))
})
