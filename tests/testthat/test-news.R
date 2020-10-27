library(testthat)
library(fflr)

n <- player_news(15847)
test_that("news returns for a single player", {
  expect_s3_class(n, "tbl")
  expect_length(n, 6)
  expect_type(n$premium, "logical")
  expect_s3_class(n$published, "POSIXlt")
  expect_equal(length(unique(n$id)), 1)
})

test_that("news returns for multiple players", {
  n2 <- player_news(c(15847, 15795))
  expect_s3_class(n2, "tbl")
  expect_length(n2, 6)
  expect_type(n2$premium, "logical")
  expect_s3_class(n2$published, "POSIXlt")
  expect_gt(length(unique(n2$id)), 1)
})

test_that("news warns when limit is reached", {
  expect_warning(player_news(nfl_players$id[1:10]))
})

test_that("news body can be parsed as an HTML document", {
  skip_if_not(any(grepl("^<", n$body)), "no HTML found for this player")
  n <- player_news(15847, parse = TRUE)
  types <- unlist(lapply(lapply(n$body, class), `[[`, 1))
  expect_true("xml_document" %in% types)
  expect_true("character" %in% types)
})
