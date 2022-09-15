test_that("player list by value with custom sort", {
  p <- list_players(
    leagueId = "42654852",
    sort = "CHANGE",
    position = "WR",
    status = "ALL",
    proTeam = "LAR",
    scoreType = "PPR",
    injured = FALSE,
    limit = 20
  )
  expect_true(all(p$proTeam == "LAR"))
  expect_true(all(p$defaultPosition == "WR"))
  if (!any(is.na(p$percentChange))) {
    x <- diff(p$percentChange[!is.na(p$percentChange)])
    expect_true(all(x <= 0))
  }
})

test_that("individual player bio info", {
  i <- player_info(playerId = 2977187)
  expect_s3_class(i, "data.frame")
  expect_length(i, 12)
  expect_s3_class(i$dateOfBirth, "Date")
})

test_that("player list API error", {
  expect_error(list_players(leagueId = "1", times = 1))
})
