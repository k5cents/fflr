test_that("team transactions", {
  t <- transaction_counter(leagueId = "42654852")
  expect_s3_class(t, "data.frame")
  expect_length(t, 14)
})

test_that("team budget summary", {
  b <- budget_summary(leagueId = "42654852")
  expect_s3_class(b, "data.frame")
  expect_length(b, 6)
  expect_true("acquisitionBudgetSpent" %in% names(b))
})
