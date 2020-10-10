library(testthat)
library(fflr)

test_that("fantasy tables can be merged", {
  x <- team_roster(252353)[[5]]
  y <- pro_schedule()
  s <- ffl_merge(x, y)
  n <- length(intersect(names(x), names(y)))
  expect_equal(ncol(s), ncol(x) + ncol(y) - n)
})
