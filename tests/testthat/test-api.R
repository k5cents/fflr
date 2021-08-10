test_that("empty API call returns fantasy league info", {
  x <- ffl_api()
  expect_type(x, "list")
  expect_length(x, 9)
})
