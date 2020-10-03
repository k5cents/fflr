library(testthat)
library(fflr)

test_that("news returns for a single player", {
  n <- player_news(15847)
  expect_s3_class(n, "tbl")
  expect_length(n, 6)
  expect_type(n$premium, "logical")
  expect_s3_class(n$published, "POSIXlt")
  expect_equal(length(unique(n$id)), 1)
})

test_that("news returns for multiple players", {
  n <- player_news(c(15847, 15795))
  expect_s3_class(n, "tbl")
  expect_length(n, 6)
  expect_type(n$premium, "logical")
  expect_s3_class(n$published, "POSIXlt")
  expect_gt(length(unique(n$id)), 1)
})

test_that("news warns when limit is reached", {
  expect_warning(player_news(nfl_players$id[1:10]))
})

test_that("news body can be parsed as an HTML document", {
  n <- player_news(15795, parse = TRUE)
  types <- unlist(lapply(lapply(n$body, class), `[[`, 1))
  expect_true("xml_document" %in% types)
  expect_true("character" %in% types)
})
