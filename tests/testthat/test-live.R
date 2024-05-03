test_that("live scoring returns 1 row per team", {
  l <- live_scoring(leagueId = "42654852", yetToPlay = TRUE, bonusWin = TRUE)
  skip_empty(l)
  expect_s3_class(l, "data.frame")
  # expect_true("toPlay" %in% names(l))
  expect_length(l, 7)
  expect_equal(nrow(l), 4)
})
