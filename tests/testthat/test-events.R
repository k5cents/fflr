test_that("get NFL game schedule times", {
  e <- pro_events()
  skip_empty(e)
  expect_s3_class(e, "data.frame")
  # expect_type(e$competitors, "list")
  expect_length(e, 7)
})

test_that("get NFL game scores", {
  s <- pro_scores()
  skip_empty(s)
  expect_s3_class(s, "data.frame")
  expect_type(s$lineup, "list")
  expect_length(s, 9)
})
