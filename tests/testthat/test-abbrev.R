library(testthat)
library(fflr)

test_that("team numbers are converted to abbreviations", {
  expect_equal(team_abbrev(252353, id = 6), "KIER")
})
