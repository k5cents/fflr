test_that("get individual player outlook", {
  o <- player_outlook(
    leagueId = NULL,
    limit = 1
  )
  expect_s3_class(o, "data.frame")
  expect_length(o, 6)
})
