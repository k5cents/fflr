library(testthat)
library(fflr)

test_that("single player info works", {
  p <- player_info(15847)
  expect_type(p, "list")
  expect_length(p, 12)
  expect_s3_class(p$birth_date, "Date")
})

test_that("single player row works", {
  p <- player_info(15847, row = TRUE)
  expect_s3_class(p, "tbl")
  expect_length(p, 12)
})

test_that("single player row works", {
  p <- player_info(3884368, row = FALSE)
  expect_type(p, "list")
  expect_length(p, 8)
})

test_that("player info fails for defenses", {
  expect_error(player_info(-16015))
})
