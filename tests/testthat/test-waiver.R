# a made-up full roster: one QB and one RB slot, one bench spot, one IR
fake_week <- function(wk, nix = 15) {
  r <- rbind(
    fake_player(1L, "Bo", "Nix", "QB", nix, "QB"),
    fake_player(2L, "Run", "Ningback", "RB", 10, "RB"),
    fake_player(3L, "Back", "Up", "RB", 5),
    fake_player(4L, "Hurt", "Guy", "RB", 0, "IR")
  )
  r$scoringPeriodId <- wk
  r
}

fake_add <- function(proj, pos = "QB", id = 90L, weeks = c(9L, 10L)) {
  a <- do.call(rbind, lapply(seq_along(weeks), function(i) {
    x <- fake_player(id, "Tyler", "Shough", pos, proj[i])
    x$scoringPeriodId <- weeks[i]
    x
  }))
  a$status <- "WAIVERS"
  a
}

fake_upgrade <- function(add, rosters, droppable = 1:3) {
  slot_count <- data.frame(
    position = c("0", "2", "20", "21"),
    limit = c(1L, 1L, 1L, 1L)
  )
  do_slot <- c(0L, 2L, 20L)
  before <- lapply(rosters, function(r) {
    start_roster(out_best(r, do_slot, slot_count, "projectedScore"))
  })
  best_upgrade(
    rosters = rosters, before = before, add = add, droppable = droppable,
    do_slot = do_slot, slot_count = slot_count, useScore = "projectedScore"
  )
}

test_that("an add that never starts is not an upgrade", {
  rosters <- list(fake_week(9L), fake_week(10L))
  expect_null(fake_upgrade(fake_add(c(12, 14)), rosters))
})

test_that("an upgrade pairs the add with the drop that costs nothing", {
  # Nix is on bye in week 10: the add starts there only
  rosters <- list(fake_week(9L), fake_week(10L, nix = 0))
  u <- fake_upgrade(fake_add(c(12, 19)), rosters)
  expect_equal(u$delta, 19)
  expect_equal(u$weeksImproved, 1)
  expect_equal(u$startersOut, "Bo Nix")
  # Nix still starts week 9, so the bench RB is the free drop, not Nix
  expect_equal(u$drop, "Back Up")
  expect_equal(u$dropId, 3L)
  expect_equal(u$status, "WAIVERS")
})

test_that("with an open roster spot nobody is dropped", {
  rosters <- list(fake_week(9L), fake_week(10L, nix = 0))
  u <- fake_upgrade(fake_add(c(12, 19)), rosters, droppable = integer())
  expect_true(is.na(u$drop))
  expect_true(is.na(u$dropId))
  expect_equal(u$delta, 19)
})

test_that("of several free drops, the lowest scorer goes", {
  # a better QB every week: neither Nix nor the backup RB starts again
  rosters <- list(fake_week(9L), fake_week(10L))
  u <- fake_upgrade(fake_add(c(20, 20)), rosters)
  expect_equal(u$delta, 10)
  expect_equal(u$drop, "Back Up")
})

test_that("when everyone starts, each drop is tried", {
  # the add starts week 9 only, Ningback week 10, the backup week 11 on
  # Ningback's bye: every drop costs something, the backup least
  wk <- function(w, ningback, backup) {
    r <- fake_week(w)
    r$projectedScore[2:3] <- c(ningback, backup)
    r
  }
  rosters <- list(wk(9L, 10, 5), wk(10L, 10, 5), wk(11L, 0, 4))
  u <- fake_upgrade(fake_add(c(11, 0, 0), "RB", weeks = 9:11), rosters)
  expect_equal(u$drop, "Back Up")
  # +1 in week 9, -4 in week 11 without the backup: a net loss
  expect_equal(u$delta, -3)
})

test_that("waiver upgrades for a live team", {
  teams <- league_teams(leagueId = "42654852")
  skip_empty(teams)
  u <- waiver_upgrades(leagueId = "42654852", teamId = teams$teamId[1])
  expect_s3_class(u, "tbl_df")
  expect_named(u, names(empty_upgrades()))
  expect_true(all(u$delta > 0))
  expect_false(is.unsorted(rev(u$delta)))
  expect_equal(u$delta, u$scoreAfter - u$scoreBefore)
})
