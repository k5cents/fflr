library(testthat)
library(fflr)

test_that("live scoreboard works if gameday", {
  skip("no live scoring until gameday")
  s <- live_scoring(252353)
  expect_length(s, 5)
  expect_equal(nrow(s), 8)
  expect_error(live_scoring(252353, old = TRUE))
})
