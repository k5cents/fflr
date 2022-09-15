test_that("obtain draft data", {
  d <- draft_recap(
    leagueId = "42654852"
  )
  expect_s3_class(d, "data.frame")
  expect_length(d, 15)
})

test_that("obtain draft data history", {
  d <- draft_recap(
    leagueId = "42654852",
    leagueHistory = TRUE
  )
  expect_type(d, "list")
  expect_s3_class(d[[1]], "data.frame")
})

