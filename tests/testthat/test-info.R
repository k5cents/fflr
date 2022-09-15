test_that("current year", {
  y <- ffl_year()
  expect_length(y, 1)
  expect_type(y, "double")
})

test_that("current week", {
  w <- ffl_week()
  expect_length(w, 1)
  expect_type(w, "double")
})

test_that("fantasy seasons", {
  s <- ffl_seasons()
  expect_s3_class(s, "data.frame")
  expect_s3_class(s$startDate, "POSIXt")
})

test_that("fantasy seasons", {
  g <- espn_games()
  expect_s3_class(g, "data.frame")
  expect_length(unique(g$name), length(g$name))
})
