test_that("calculate best possible past roster", {
  b <- best_roster(
    leagueId = "42654852",
    useScore = "actualScore",
    scoringPeriodId = 1
  )
  skip_empty(b)
  b1 <- b[[1]]
  expect_s3_class(b1, "data.frame")
  expect_length(b1, 17)
  skip_if(all(is.na(b1$actualScore)))

  start_rb <- b1$actualScore[b1$lineupSlot == "RB"]
  bench_rb <- b1$actualScore[b1$lineupSlot == "BE" & b1$position == "RB"]
  expect_gt(min(start_rb), max(bench_rb))
})

test_that("calculate best possible future roster", {
  b <- best_roster(
    leagueId = "42654852",
    useScore = "projectedScore",
    scoringPeriodId = 1
  )
  skip_empty(b)
  b2 <- b[[2]]
  expect_s3_class(b2, "data.frame")
  expect_length(b2, 17)
  skip_if(all(is.na(b2$actualScore)))

  start_wr <- b2$projectedScore[b2$lineupSlot == "WR"]
  bench_wr <- b2$projectedScore[b2$lineupSlot == "BE" & b2$position == "WR"]
  if (sum(start_wr) > 0) {
    expect_gt(min(start_wr), max(bench_wr))
  }
})

test_that("stand-ins start only above the roster and never crowd it out", {
  r <- rbind(
    fake_player(1L, "Bo", "Nix", "QB", 0, "QB"),
    fake_player(2L, "Run", "Ningback", "RB", 10, "RB"),
    fake_player(3L, "Back", "Up", "RB", 5),
    fake_player(4L, "Also", "Benched", "RB", 4, "IR")
  )
  standins <- rbind(
    fake_player(90L, "Tyler", "Shough", "QB", 19.3),
    fake_player(91L, "Deep", "Sleeper", "RB", 3)
  )
  slot_count <- data.frame(
    position = c("0", "2", "20", "21"),
    limit = c(1L, 1L, 1L, 1L)
  )
  b <- out_best(add_standins(r, standins), c(0L, 2L, 20L), slot_count, "projectedScore")
  # the better stand-in starts, the worse one is gone, and the one bench
  # spot holds both real players the stand-in displaced; IR stays on IR
  expect_equal(b$playerId[b$replacement], 90L)
  expect_setequal(b$playerId[!b$replacement], 1:4)
  expect_equal(as.character(b$lineupSlot[match(c(1L, 4L), b$playerId)]), c("BE", "IR"))
  expect_equal(
    over_replacement(b, standins, "projectedScore")[match(c(1L, 2L), b$playerId)],
    c(-19.3, 7)
  )
  # without stand-ins, nothing changes
  expect_false("replacement" %in% names(out_best(r, c(0L, 2L, 20L), slot_count, "projectedScore")))
})

test_that("best roster with replacement stand-ins", {
  b0 <- best_roster(leagueId = "42654852", useScore = "projectedScore")
  skip_empty(b0)
  b <- best_roster(
    leagueId = "42654852", useScore = "projectedScore", replacement = TRUE
  )
  for (i in seq_along(b)) {
    # every real player is still listed, and stand-ins are at replacement
    expect_setequal(b[[i]]$playerId[!b[[i]]$replacement], b0[[i]]$playerId)
    expect_true(all(b[[i]]$overReplacement[b[[i]]$replacement] == 0))
    expect_false(any(b[[i]]$replacement & b[[i]]$lineupSlot == "BE"))
  }
})
