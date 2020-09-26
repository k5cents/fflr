library(testthat)
library(fflr)

test_that("live scoreboard works if gameday", {
  wday <- weekdays(Sys.Date(), abbreviate = TRUE)
  if (wday %in% c("Mon", "Tue", "Wed", "Thur")) {
    skip("no live scoring until gameday")
  } else {
    s <- live_scoring(252353)
    expect_length(s, 5)
    expect_equal(nrow(s), 8)
  }
  expect_error(live_scoring(252353, old = TRUE))
})
