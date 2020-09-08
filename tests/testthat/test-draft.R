library(testthat)
library(fflr)

test_that("draft history returns multiple years", {
  expect_type(draft_history(252353, TRUE), "list")
})
