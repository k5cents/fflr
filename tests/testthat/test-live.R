test_that("multiplication works", {
  l <- live_scoring(leagueId = "42654852", yetToPlay = TRUE)
  expect_s3_class(l, "data.frame")
  expect_true("toPlay" %in% names(l))
  expect_length(l, 8)
})
