library(testthat)
library(fflr)

test_that("stat corrections work for a good week", {
  c <- stat_correct("2020-09-14")
  expect_s3_class(c, "tbl")
  expect_length(c, 6)
  expect_s3_class(c$date, "Date")
})

test_that("stat corrections warn and empty for future", {
  skip("season over")
  expect_warning(c <- stat_correct("2099-01-01"))
  expect_length(c, 6)
  expect_s3_class(c$date, "Date")
  expect_equal(nrow(c), 0)
})

test_that("stat corrections error without proper date", {
  expect_error(stat_correct("Sep 14 2020"))
  expect_error(stat_correct(1))
})
