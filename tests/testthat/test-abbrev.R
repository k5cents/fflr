library(testthat)
library(fflr)

test_that("team numbers are converted to abbreviations", {
  expect_equal(
    object = as.character(team_abbrev(id = 6, teams = league_teams(252353))),
    expected = "KIER"
  )
})
