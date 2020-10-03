library(testthat)
library(fflr)

test_that("multiplication works", {
  c <- stat_correct("2020-09-14")
  expect_s3_class(c, "tbl")
  expect_length(c, 6)
  expect_s3_class(c$date, "Date")
})

test_that("stat corrections warn and empty for future", {
  expect_warning(c <- stat_correct("2020-12-31"))
  expect_length(c, 6)
  expect_s3_class(c$date, "Date")
  expect_equal(nrow(c), 0)
})
