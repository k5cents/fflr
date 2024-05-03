test_that("get individual player outlook", {
  o <- player_outlook(
    leagueId = NULL,
    limit = 1
  )
  expect_s3_class(o, "data.frame")
  if (is.na(o$outlook)) {
    expect_length(o, 5)
  } else {
    expect_length(o, 6)
  }
})
