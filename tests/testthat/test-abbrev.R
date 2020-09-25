library(testthat)
library(fflr)

test_that("team numbers are converted to abbreviations", {
  expect_equal(team_abbrev(team = 6, lid = 252353), "KIER")
})
