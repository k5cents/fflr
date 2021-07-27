test_that("empty API call returns fantasy league info", {
  x <- fflr_api()
  expect_type(x, "list")
  expect_length(x, 10)
})
