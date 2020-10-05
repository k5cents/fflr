library(testthat)
library(fflr)

test_that("single player info works", {
  p <- player_info(15847)
  expect_type(p, "list")
  expect_length(p, 12)
})

test_that("player info fails for defenses", {
  expect_error(player_info(-16015))
})
