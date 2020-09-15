library(testthat)
library(fflr)

expect_height <- function(object, n) {
  expect_equal(object = nrow(object), n)
}

test_that("can calculate single best roster", {
  r <- team_roster(252353, old = FALSE, week = 1)
  b <- best_roster(r[[1]])
  expect_s3_class(b, "tbl")
  expect_length(b, 15)
  expect_height(b, 9)
  expect_type(roster_score(b), "double")
})

test_that("scores stop if pre-game", {
  s <- ffl_api(252353, old = FALSE)
  r <- team_roster(252353, old = FALSE, week = s$status$currentMatchupPeriod)
  expect_error(best_roster(r[[1]]))
})
