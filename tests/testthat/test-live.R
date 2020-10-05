library(testthat)
library(fflr)

test_that("live scoreboard works if gameday", {
  s <- live_scoring(252353)
  if (all(s$score == 0) | any(is.na(s$score) | nrow(s) < 8)) {
    skip("no live scoring until gameday")
  } else {
    expect_length(s, 5)
    expect_equal(nrow(s), 8)
    expect_error(live_scoring(252353, old = TRUE))
  }
})

test_that("live scoreboard can add yet-to-play", {
  s <- live_scoring(252353, yet = TRUE)
  if (all(s$score == 0) | any(is.na(s$score) | nrow(s) < 8)) {
    skip("no live scoring until gameday")
  } else {
    expect_length(s, 6)
    expect_equal(nrow(s), 8)
  }
})
