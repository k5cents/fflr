test_that("state corrections", {
  c <- stat_corrections(date = "2021-09-13")
  expect_s3_class(c, "data.frame")
  expect_s3_class(c$date, "Date")
  expect_length(c, 5)
})

test_that("state corrections errors", {
  expect_error(stat_corrections(date = 1))
})
