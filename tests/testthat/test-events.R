test_that("get NFL game schedule times", {
  e <- pro_events()
  expect_s3_class(e, "data.frame")
  expect_type(e$competitors, "list")
  expect_length(e, 13)
})

test_that("get NFL game scores", {
  s <- pro_scores()
  expect_s3_class(s, "data.frame")
  expect_type(s$lineup, "list")
  expect_length(s, 9)
})
