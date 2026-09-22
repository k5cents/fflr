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
    scoringPeriodId = 1, seasonId = 2026L, proTeam = NULL,
    scoreType = "STANDARD", limit = 1
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

test_that("stat keys ask for the requested season, not a fixed one", {
  f <- filter_json(seasonId = 2031L, scoringPeriodId = 4, sort = "PROJ")
  expect_equal(
    unlist(f$players$filterStatsForTopScoringPeriodIds$additionalValue),
    c("002031", "102031", "002030", "1120314", "022031")
  )
  expect_equal(f$players$sortAppliedStatTotal$value, "1120314")
  f <- filter_json(seasonId = 2031L, sort = "FPTS")
  expect_equal(f$players$sortAppliedStatTotal$value, "002031")
})

test_that("list_players requests its own season", {
  # offline: record the URL asked for, then stop before any parsing
  asked <- NULL
  local_mocked_bindings(
    RETRY = function(verb, url, ...) {
      asked <<- url
      stop("mocked")
    },
    .package = "httr"
  )
  local_mocked_bindings(ffl_year = function(...) 2031L, ffl_week = function(...) 1L)
  expect_error(list_players(leagueId = "1"), "mocked")
  expect_match(asked, "/seasons/2031/", fixed = TRUE)
  expect_error(list_players(leagueId = "1", seasonId = 2024), "mocked")
  expect_match(asked, "/seasons/2024/", fixed = TRUE)
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
