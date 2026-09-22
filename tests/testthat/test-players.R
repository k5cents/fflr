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
  expect_error(list_players(leagueId = "1"), "ESPN Fantasy API request failed")
})

filter_json <- function(...) {
  args <- list(
    sort = "ROST", position = NULL, status = "AVAILABLE", injured = NULL,
    scoringPeriodId = 1, proTeam = NULL, scoreType = "STANDARD", limit = 1
  )
  args[names(list(...))] <- list(...)
  jsonlite::fromJSON(do.call(fantasy_filter, args), simplifyVector = FALSE)
}

test_that("single filter values are sent as JSON arrays", {
  f <- filter_json(status = "FREEAGENT", position = "QB", proTeam = "MIA")
  expect_equal(f$players$filterStatus$value, list("FREEAGENT"))
  expect_equal(f$players$filterSlotIds$value, list(0L))
  expect_equal(f$players$filterProTeamIds$value, list(15L))
  expect_equal(f$players$filterRanksForScoringPeriodIds$value, list(1L))
})

test_that("multiple and expanded statuses build the filter", {
  expect_equal(
    filter_json(status = "AVAILABLE")$players$filterStatus$value,
    list("FREEAGENT", "WAIVERS")
  )
  expect_equal(
    filter_json(status = c("FREEAGENT", "WAIVERS"))$players$filterStatus$value,
    list("FREEAGENT", "WAIVERS")
  )
  expect_equal(
    filter_json(status = c("AVAILABLE", "ONTEAM"))$players$filterStatus$value,
    list("ONTEAM", "FREEAGENT", "WAIVERS")
  )
  expect_null(filter_json(status = "ALL")$players$filterStatus)
})

test_that("player list with a single status", {
  for (s in c("WAIVERS", "ONTEAM")) {
    p <- list_players("42654852", status = s, limit = 1)
    expect_equal(nrow(p), 1)
  }
  # all unrostered players are on waivers between game day and waiver run,
  # so free agents can legitimately be empty
  p <- list_players("42654852", status = "FREEAGENT", limit = 1)
  expect_s3_class(p, "tbl_df")
  expect_lte(nrow(p), 1)
})

test_that("empty player list keeps the same columns and types", {
  full <- list_players("42654852", status = "ALL", limit = 1)
  empty <- empty_players(full$scoringPeriodId[1])
  expect_equal(nrow(empty), 0)
  expect_identical(lapply(empty, class), lapply(full, class))
  expect_identical(levels(empty$proTeam), levels(full$proTeam))
  expect_identical(levels(empty$defaultPosition), levels(full$defaultPosition))
})

test_that("player list with a single position", {
  p <- list_players("42654852", position = "QB", status = "ALL", limit = 5)
  expect_equal(nrow(p), 5)
  expect_true(all(p$defaultPosition == "QB"))
})
