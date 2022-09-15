test_that("get NFL game schedule times", {
  e <- pro_events()
  expect_s3_class(e, "data.frame")
  expect_type(e$competitors, "list")
})
