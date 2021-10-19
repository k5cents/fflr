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
  expect_true(all(diff(p$percentChange) < 0))
})
