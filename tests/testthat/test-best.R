library(testthat)
library(fflr)

expect_height <- function(object, n) {
  expect_equal(object = nrow(object), n)
}

test_that("scores stop if pre-game", {
  r <- team_roster(252353, week = ffl_week())[[5]]
  b <- best_roster(r)
  expect_s3_class(b, "tbl")
  if (sum(is.na(r$score)) > 3) {
    expect_length(b, 14)
    expect_height(b, 9)
    expect_gt(roster_score(b), roster_score(r))
  } else {
    expect_length(b, 15)
  }
})
