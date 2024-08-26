test_that("state corrections", {
  skip_if(Sys.Date() < "2024-09-12")
  c <- stat_corrections(date = "2021-09-13")
  expect_s3_class(c, "data.frame")
  expect_s3_class(c$date, "Date")
  expect_length(c, 5)
})

test_that("state corrections errors", {
  skip_if(Sys.Date() < "2024-09-12")
  expect_error(stat_corrections(date = 1))
})
