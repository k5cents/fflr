#' Find waiver wire upgrades
#'
#' Score every add/drop a team could make from the waiver wire: for each of
#' the most-rostered available players at each starting position, the best
#' player to drop for them and how much the team's optimal starting lineup
#' gains, week by week, using the league's own lineup optimizer (see
#' [best_roster()]) and ESPN's per-week projections. The pickup counterpart to
#' [evaluate_trade()].
#'
#' The pool is today's free agents and players on waivers (see `status` in
#' the output), the top `limit` at each single-position starting slot by
#' percent rostered -- the same pool [evaluate_trade()] and [best_roster()]
#' take their replacement-level stand-ins from. It's today's pool, not a
#' forecast of who will be available in later weeks.
#'
#' If the roster has an open spot (not counting IR), nobody is dropped.
#' Otherwise each add is paired with the drop that costs the least: a player
#' who wouldn't start in any scored week after the add costs nothing, and of
#' those, the one with the lowest total score is chosen; if every player
#' would start at some point, each is tried. Players on IR are never
#' dropped, since dropping them frees no roster spot.
#'
#' @inheritParams evaluate_trade
#' @param teamId The team ID looking for upgrades (see [league_teams()]).
#' @param limit The number of available players to consider at each
#'   position, most rostered first. Defaults to 10.
#' @return A tibble with one row per add that improves the lineup, best
#'   first: the player to add and their `status` ("FREEAGENT" or "WAIVERS"),
#'   the player to drop (`NA` with an open roster spot), the optimal starting
#'   score summed over the scored weeks without the move (`scoreBefore`) and
#'   with it (`scoreAfter`), their difference (`delta`), the number of weeks
#'   the move helps (`weeksImproved`), and the players the add takes a
#'   starting spot from in any of those weeks (`startersOut`). Player lists
#'   are comma-separated names, `NA` when empty; no rows if nothing helps.
#' @examples
#' \dontrun{
#' waiver_upgrades(teamId = 6)
#' waiver_upgrades(teamId = 6, scoringPeriodId = "rest")
#' }
#' @family roster functions
#' @export
waiver_upgrades <- function(leagueId = ffl_id(),
                            teamId,
                            seasonId = ffl_year(),
                            scoringPeriodId = ffl_week(),
                            useScore = c("projectedScore", "actualScore"),
                            limit = 10,
                            cookie = ffl_cookie()) {
  useScore <- match.arg(useScore, c("projectedScore", "actualScore"))
  teamId <- as.integer(teamId)
  seasonId <- as.integer(seasonId)
  fetch <- function(wk = NULL) {
    ffl_api(
      leagueId = leagueId,
      view = c("mRoster", "mSettings", "mTeam"),
      seasonId = seasonId,
      scoringPeriodId = wk,
      cookie = cookie
    )
  }
  now <- fetch()
  if (!teamId %in% now$teams$id) {
    stop(sprintf("team %s not found in league %s", teamId, leagueId), call. = FALSE)
  }
  if (identical(scoringPeriodId, "rest")) {
    scoringPeriodId <- seq(now$scoringPeriodId, last_regular_week(now))
  }
  scoringPeriodId <- as.integer(scoringPeriodId)
  slots <- lineup_slots(now)

  tm <- out_team(now$teams, trim = TRUE)
  rosters <- lapply(scoringPeriodId, function(wk) {
    dat <- if (wk == now$scoringPeriodId) now else fetch(wk)
    out_roster(
      entry = dat$teams$roster$entries[[match(teamId, dat$teams$id)]],
      tid = teamId,
      wk = wk,
      yr = seasonId,
      tm = tm,
      es = TRUE
    )
  })
  pool <- replacement_pool(
    leagueId = leagueId,
    seasonId = seasonId,
    weeks = scoringPeriodId,
    slots = standin_slots(slots$do_slot),
    limit = as.integer(limit),
    cookie = cookie
  )

  current <- rosters[[match(now$scoringPeriodId, scoringPeriodId, nomatch = 1)]]
  droppable <- current$playerId[current$lineupSlot != "IR"]
  if (length(droppable) < slots$size_limit) {
    droppable <- integer()
  }
  before <- lapply(rosters, function(r) {
    start_roster(out_best(r, slots$do_slot, slots$slot_count, useScore))
  })
  upgrades <- lapply(
    X = unique(pool$playerId),
    FUN = function(id) {
      best_upgrade(
        rosters = rosters,
        before = before,
        add = pool[pool$playerId == id, ],
        droppable = droppable,
        do_slot = slots$do_slot,
        slot_count = slots$slot_count,
        useScore = useScore
      )
    }
  )
  out <- bind_df(upgrades)
  if (nrow(out) == 0) {
    return(empty_upgrades())
  }
  out <- out[out$delta > 0, ]
  as_tibble(out[order(out$delta, decreasing = TRUE), ])
}

# the lineup gain from adding `add` (its rows, one per week) to each week's
# roster in `rosters`, paired with the `droppable` player that costs least
best_upgrade <- function(rosters, before, add, droppable, do_slot, slot_count,
                         useScore) {
  lineup <- function(r) {
    suppressWarnings(start_roster(out_best(r, do_slot, slot_count, useScore)))
  }
  weeks <- vapply(rosters, function(r) r$scoringPeriodId[1], integer(1))
  added <- lapply(seq_along(rosters), function(i) {
    r <- rosters[[i]]
    a <- add[add$scoringPeriodId == weeks[i] & !is.na(add[[useScore]]), ]
    if (nrow(a) == 0) {
      return(r)
    }
    a <- a[1, ]
    a$teamId <- r$teamId[1]
    a$abbrev <- r$abbrev[1]
    a$lineupSlot <- slot_abbrev(slot_unabbrev("BE"))
    rbind(r, a[, names(r)])
  })
  score <- function(l) vapply(l, function(x) sum(x[[useScore]]), double(1))
  score_before <- score(before)

  # the best a drop can do is cost nothing, which dropping a player who
  # never starts after the add does
  after_drop <- function(d) {
    lapply(added, function(r) lineup(r[r$playerId != d, ]))
  }
  # an add that can't outscore any starter in a slot they fit leaves that
  # week's lineup as it was, without running the optimizer
  after <- lapply(seq_along(added), function(i) {
    a <- added[[i]][nrow(added[[i]]), ]
    if (nrow(added[[i]]) == nrow(rosters[[i]])) {
      return(before[[i]])
    }
    fits <- before[[i]][
      pos_ids$slot[match(before[[i]]$lineupSlot, pos_ids$abbrev)] %in% a$eligibleSlots[[1]],
    ]
    if (nrow(fits) > 0 && all(a[[useScore]] <= fits[[useScore]])) {
      return(before[[i]])
    }
    lineup(added[[i]])
  })
  # adding without dropping is the most an add can gain
  if (!isTRUE(sum(score(after)) > sum(score_before))) {
    return(NULL)
  }
  drop <- NA_integer_
  if (length(droppable) > 0) {
    starts <- unique(unlist(lapply(after, `[[`, "playerId")))
    bench <- setdiff(droppable, starts)
    if (length(bench) > 0) {
      total <- vapply(bench, function(d) {
        sum(unlist(lapply(rosters, function(r) r[[useScore]][r$playerId == d])), na.rm = TRUE)
      }, double(1))
      drop <- bench[which.min(total)]
      after <- after_drop(drop)
    } else {
      tries <- lapply(droppable, after_drop)
      pick <- which.max(vapply(tries, function(l) sum(score(l)), double(1)))
      drop <- droppable[pick]
      after <- tries[[pick]]
    }
  }
  score_after <- score(after)

  first <- add[1, ]
  dropped <- rosters[[1]][rosters[[1]]$playerId %in% drop, ]
  benched <- unlist(lapply(seq_along(after), function(i) {
    if (score_after[i] <= score_before[i]) {
      return(integer())
    }
    setdiff(before[[i]]$playerId, after[[i]]$playerId)
  }))
  everyone <- do.call(rbind, rosters)
  benched <- everyone[match(unique(benched), everyone$playerId), ]
  data.frame(
    teamId = rosters[[1]]$teamId[1],
    abbrev = rosters[[1]]$abbrev[1],
    addId = first$playerId,
    add = player_names(first),
    position = first$position,
    proTeam = first$proTeam,
    status = first$status,
    dropId = if (is.na(drop)) NA_integer_ else drop,
    drop = if (nrow(dropped) == 0) NA_character_ else player_names(dropped[1, ]),
    scoreBefore = sum(score_before),
    scoreAfter = sum(score_after),
    delta = sum(score_after) - sum(score_before),
    weeksImproved = sum(score_after > score_before),
    startersOut = player_names(benched)
  )
}

empty_upgrades <- function() {
  as_tibble(data.frame(
    stringsAsFactors = FALSE,
    teamId = integer(),
    abbrev = character(),
    addId = integer(),
    add = character(),
    position = character(),
    proTeam = character(),
    status = character(),
    dropId = integer(),
    drop = character(),
    scoreBefore = double(),
    scoreAfter = double(),
    delta = double(),
    weeksImproved = integer(),
    startersOut = character()
  ))
}
