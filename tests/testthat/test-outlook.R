test_that("get individual player outlook", {
  o <- player_outlook(
    leagueId = NULL,
    limit = 1
  )
  expect_s3_class(o, "data.frame")
  if (all(is.na(o$outlook))) {
    expect_length(o, 5)
  } else {
    expect_length(o, 6)
    expect_equal(anyDuplicated(o[, c("id", "scoringPeriodId")]), 0)
    # weekly outlooks usually name the week they describe
    wk <- o[o$scoringPeriodId > 0, ]
    names_week <- mapply(grepl, paste("Week", wk$scoringPeriodId), wk$outlook)
    expect_gt(mean(names_week), 0.5)
  }
})

test_that("player outlooks keep their week across multiple players", {
  o <- player_outlook(leagueId = NULL, limit = 5)
  skip_if(all(is.na(o$outlook)))
  expect_gt(length(unique(o$id)), 1)
  expect_equal(anyDuplicated(o[, c("id", "scoringPeriodId")]), 0)
})
