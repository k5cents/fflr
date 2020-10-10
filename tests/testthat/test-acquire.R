library(testthat)
library(fflr)

test_that("acquisition data returns for current rosters", {
  a <- player_acquire(252353)
  expect_type(a, "list")
  expect_s3_class(a[[1]], "tbl")
  expect_length(a, 8)
  expect_length(a[[1]], 11)
  expect_s3_class(a[[1]]$date, "POSIXt")
})

test_that("acquisition data errors for past years and week", {
  expect_error(player_acquire(252353, old = TRUE))
  expect_error(player_acquire(252353, week = 1))
})
