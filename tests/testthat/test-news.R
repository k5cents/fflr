test_that("player news", {
  n <- player_news(playerId = "2977187")
  expect_s3_class(n, "data.frame")
  expect_length(n, 6)
  expect_s3_class(n$published, "POSIXt")
  expect_type(n$body, "character")
})

test_that("player news with parsing", {
  skip_if_not_installed("rvest")
  n <- player_news(playerId = "2977187", parseHTML = TRUE)
  expect_s3_class(n, "data.frame")
  expect_length(n, 6)
  expect_type(n$body, "list")
  if (any(sapply(n$body, typeof) != "character")) {
    expect_s3_class(
      object = n$body[which(sapply(n$body, typeof) != "character")][[1]],
      class = "xml_document"
    )
  }
})
