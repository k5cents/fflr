test_that("date utility", {
  expect_s3_class(ffl_date(NULL), "POSIXt")
})

test_that("coerce into a list", {
  expect_type(list_ifnot(state.abb), "list")
  expect_type(list_ifnot(mtcars), "list")
  expect_type(list_ifnot(list("one")), "list")
})

test_that("ordering a data frame", {
  o <- order_df(mtcars, mtcars$mpg)
  expect_true(all(diff(o$mpg) <= 0))
})

test_that("bind two data frames", {
  a <- mtcars[1:10, ]
  z <- mtcars[-(1:10), ]
  b <- bind_df(list(a = a, z = z), .id = "half")
  expect_equal(nrow(b), nrow(mtcars))
  expect_gt(ncol(b), ncol(mtcars))
})
