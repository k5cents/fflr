test_that("look up players by id, including a defense", {
  p <- player_lookup(playerId = c(4429160, -16026), leagueId = "42654852")
  skip_empty(p)
  expect_s3_class(p, "data.frame")
  expect_length(p, 14)
  expect_setequal(p$playerId, c(4429160, -16026))
  expect_true("D/ST" %in% p$position)
})

test_that("player lookup errors on an id nothing matches", {
  expect_error(player_lookup(playerId = 1, leagueId = "42654852"), "ID\\(s\\) 1")
})

test_that("player lookup errors if any one id is missing", {
  expect_error(
    player_lookup(playerId = c(4429160, 1), leagueId = "42654852"),
    "ID\\(s\\) 1$"
  )
})

test_that("player lookup returns rows in the order given", {
  ids <- c(-16026, 4429160, 4426348)
  p <- player_lookup(playerId = ids, leagueId = "42654852")
  skip_empty(p)
  expect_equal(p$playerId, ids)
})

test_that("looked up defense on bye scores zero, like team_roster()", {
  p <- list(player = list(
    id = -16026L, firstName = "Dolphins", lastName = "D/ST",
    proTeamId = 15L, defaultPositionId = 16L, eligibleSlots = list(16L, 20L),
    stats = list(list(
      scoringPeriodId = 2L, statSplitTypeId = 1L, statSourceId = 1L,
      appliedTotal = 6.5
    ))
  ))
  x <- out_lookup(p, wk = 5, yr = 2026)
  expect_equal(x$projectedScore, 0)
  expect_equal(x$actualScore, 0)
})

test_that("looked up player without ownership data still returns a row", {
  p <- list(player = list(
    id = 1L, firstName = "No", lastName = "Owner",
    proTeamId = 15L, defaultPositionId = 2L, eligibleSlots = list(2L, 23L),
    stats = list()
  ))
  x <- out_lookup(p, wk = 5, yr = 2026)
  expect_equal(nrow(x), 1)
  expect_length(x, 14)
  expect_true(is.na(x$percentOwned))
  expect_true(is.na(x$projectedScore))
})

test_that("player lookup returns projections for a past week", {
  p <- player_lookup(
    playerId = 4429160, leagueId = "42654852", scoringPeriodId = 1
  )
  skip_empty(p)
  expect_equal(p$scoringPeriodId, 1)
  expect_false(is.na(p$projectedScore))
})

test_that("evaluate a trade for both sides", {
  r <- team_roster(leagueId = "42654852")
  skip_empty(r[[1]])
  mine <- r[[1]]
  other <- r[[2]]
  # my worst RB for their best: the better RB can only help, the worse hurt
  my_rb <- mine[mine$position == "RB" & mine$lineupSlot != "IR", ]
  my_rb <- my_rb[which.min(my_rb$projectedScore), ]
  their_rb <- other[other$position == "RB" & other$lineupSlot != "IR", ]
  their_rb <- their_rb[which.max(their_rb$projectedScore), ]
  skip_if(nrow(my_rb) == 0 || nrow(their_rb) == 0)
  skip_if(their_rb$projectedScore <= my_rb$projectedScore)

  e <- evaluate_trade(
    leagueId = "42654852",
    teamId = unique(mine$teamId),
    give = my_rb$playerId,
    receive = their_rb$playerId,
    scoringPeriodId = ffl_week()
  )
  expect_s3_class(e, "data.frame")
  expect_length(e, 10)
  expect_equal(e$teamId, c(unique(mine$teamId), unique(other$teamId)))
  expect_false(anyNA(e$delta))
  expect_equal(e$delta, e$scoreAfter - e$scoreBefore)
  expect_gte(e$delta[1], 0)
  expect_lte(e$delta[2], 0)
  # a 1-for-1 trade never pushes either team over the roster limit
  expect_true(all(is.na(e$dropped)))
})

test_that("evaluate_trade explains lineup changes and roster drops", {
  r <- team_roster(leagueId = "42654852")
  skip_empty(r[[1]])
  mine <- r[[1]]
  other <- r[[2]]
  bench <- mine$playerId[mine$lineupSlot == "BE"][1]
  their_two <- other$playerId[other$lineupSlot %in% c("RB", "WR")][1:2]
  slots <- roster_settings("42654852")$lineupSlotCounts[[1]]
  limit <- sum(slots$limit[slots$position != 21])
  skip_if(anyNA(c(bench, their_two)) || sum(mine$lineupSlot != "IR") < limit)

  e <- evaluate_trade(
    leagueId = "42654852",
    teamId = unique(mine$teamId),
    give = bench,
    receive = their_two,
    scoringPeriodId = ffl_week()
  )
  # a 2-for-1 on a full roster leaves exactly one player to cut
  expect_length(strsplit(e$dropped[1], ", ")[[1]], 1)
  expect_true(is.na(e$dropped[2]))
  # whoever the incoming starters are, they came from `receive`
  their_names <- paste(other$firstName, other$lastName)[other$playerId %in% their_two]
  ins <- strsplit(e$startersIn[1], ", ")[[1]]
  expect_true(all(is.na(ins) | ins %in% their_names))
})

test_that("evaluate_trade scores each scoringPeriodId separately", {
  r <- team_roster(leagueId = "42654852")
  skip_empty(r[[1]])
  mine <- r[[1]]
  starter <- mine$playerId[mine$lineupSlot != "BE" & mine$lineupSlot != "IR"][1]
  skip_if(is.na(starter))

  wk <- ffl_week() + 0:1
  e <- evaluate_trade(
    leagueId = "42654852",
    teamId = unique(mine$teamId),
    give = starter,
    scoringPeriodId = wk
  )
  expect_equal(nrow(e), 2)
  expect_setequal(e$scoringPeriodId, wk)
  # giving away a starter for nothing can only hold even or lose value
  expect_true(all(e$scoreAfter <= e$scoreBefore))
})

test_that("evaluate_trade scores the rest of the regular season", {
  r <- team_roster(leagueId = "42654852")
  skip_empty(r[[1]])
  mine <- r[[1]]
  e <- evaluate_trade(
    leagueId = "42654852",
    teamId = unique(mine$teamId),
    give = mine$playerId[1],
    scoringPeriodId = "rest"
  )
  s <- ffl_api("42654852", view = "mSettings")$settings$scheduleSettings
  last <- max(unlist(s$matchupPeriods[[as.character(s$matchupPeriodCount)]]))
  expect_equal(min(e$scoringPeriodId), unique(mine$scoringPeriodId))
  expect_equal(max(e$scoringPeriodId), last)
})

test_that("evaluate_trade rejects receiving a free agent", {
  fa <- list_players("42654852", limit = 1)
  skip_empty(fa)
  expect_error(
    evaluate_trade(leagueId = "42654852", teamId = 1, receive = fa$id[1]),
    "not on any team"
  )
})

test_that("evaluate_trade warns once the trade deadline has passed", {
  past <- as.numeric(Sys.time() - 86400) * 1000
  dat <- list(settings = list(tradeSettings = list(deadlineDate = past)))
  expect_warning(trade_deadline_check(dat), "deadline passed")
  dat$settings$tradeSettings$deadlineDate <- past + 2 * 86400 * 1000
  expect_silent(trade_deadline_check(dat))
})

test_that("rest of season ends with the regular season, or the playoffs", {
  dat <- list(
    scoringPeriodId = 1,
    status = list(finalScoringPeriod = 4),
    settings = list(scheduleSettings = list(
      matchupPeriodCount = 2,
      matchupPeriods = list(`1` = 1L, `2` = 2L, `3` = 3:4)
    ))
  )
  expect_equal(last_regular_week(dat), 2)
  dat$scoringPeriodId <- 3
  expect_equal(last_regular_week(dat), 4)
})

test_that("evaluate_trade rejects a give not on the roster", {
  expect_error(
    evaluate_trade(
      leagueId = "42654852", teamId = 1, give = 1, receive = integer()
    ),
    "not on team"
  )
})

test_that("evaluate_trade rejects receiving a player already rostered", {
  r <- team_roster(leagueId = "42654852")
  skip_empty(r[[1]])
  aus <- r[[1]]
  expect_error(
    evaluate_trade(
      leagueId = "42654852", teamId = unique(aus$teamId),
      receive = aus$playerId[1]
    ),
    "already on team"
  )
})

test_that("evaluate_trade rejects a player in both give and receive", {
  expect_error(
    evaluate_trade(
      leagueId = "42654852", teamId = 1, give = 4429160, receive = 4429160,
      scoringPeriodId = 1
    )
  )
})

test_that("traded players on bye are listed from the NFL schedule", {
  tb <- fflr::nfl_teams$byeWeek[fflr::nfl_teams$abbrev == "TB"]
  gb <- fflr::nfl_teams$byeWeek[fflr::nfl_teams$abbrev == "GB"]
  yr <- unique(fflr::nfl_schedule$seasonId)
  traded <- data.frame(
    firstName = c("Bucky", "Christian"),
    lastName = c("Irving", "Watson"),
    proTeam = factor(c("TB", "GB"))
  )
  expect_equal(traded_byes(traded, wk = tb, yr = yr), "Bucky Irving")
  expect_equal(traded_byes(traded, wk = gb, yr = yr), "Christian Watson")
  expect_true(is.na(traded_byes(traded, wk = 1, yr = yr)))
  # the bundled bye weeks only describe one season
  expect_true(is.na(traded_byes(traded, wk = tb, yr = yr - 1)))
})

test_that("evaluate_trade asks ESPN for its own season, not ffl_api()'s", {
  # ffl_api()'s seasonId default is fixed at the release year, so a request
  # that doesn't pass one silently reads the wrong season the next year.
  # Offline: record the season asked for, then stop before any parsing.
  asked <- NULL
  local_mocked_bindings(
    ffl_api = function(..., seasonId) {
      asked <<- seasonId
      stop("mocked")
    },
    ffl_year = function(...) 2031L
  )
  expect_error(
    evaluate_trade(leagueId = "1", teamId = 1, give = 1, scoringPeriodId = 1),
    "mocked"
  )
  expect_identical(asked, 2031L)
  expect_error(
    evaluate_trade(
      leagueId = "1", teamId = 1, give = 1, seasonId = 2024, scoringPeriodId = 1
    ),
    "mocked"
  )
  expect_identical(asked, 2024L)
})
