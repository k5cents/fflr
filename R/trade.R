#' Evaluate a proposed trade
#'
#' Score both teams' optimal starting lineups before and after swapping the
#' given `give`/`receive` players, using the league's own lineup optimizer
#' (see [best_roster()]) rather than an external trade value chart -- so the
#' answer reflects this league's actual roster settings and ESPN's own
#' per-week projections, not a generic consensus ranking.
#'
#' Every `receive` player must be on another team's roster: the team that
#' rosters them is the trade partner, and is scored with the same swap in
#' reverse. If `receive` players come from more than one team, the partner
#' side can't be split up and only `teamId` is scored, with a warning. A free
#' agent or player on waivers is an error -- that's a pickup, not a trade.
#'
#' Passing more than one `scoringPeriodId` scores the same swap at each week
#' separately (rosters, byes, and matchups all change week to week). Use
#' `scoringPeriodId = "rest"` to score every week from the current one through
#' the end of the regular season. That makes one API request per week, so it
#' takes a few seconds; sum `delta` by `teamId` for a rest-of-season total.
#'
#' If a team ends up with more players than the league's roster limit (not
#' counting players on IR), its lowest-scoring non-starters are listed in
#' `dropped`. Dropping non-starters never changes the starting score, so this
#' says who you'd have to cut rather than changing the result. A warning is
#' given if the league's trade deadline has passed.
#'
#' @inheritParams ffl_api
#' @param teamId The team ID evaluating the trade (see [league_teams()]).
#' @param give Integer vector of player IDs leaving `teamId`'s roster. Every
#'   ID must currently be on that roster.
#' @param receive Integer vector of player IDs arriving on `teamId`'s roster,
#'   all currently rostered by other teams.
#' @param seasonId Integer year of the NFL season. Defaults to the current
#'   season (see [ffl_year()]) rather than [ffl_api()]'s fixed default, which
#'   is only right for the year of the fflr release.
#' @param scoringPeriodId Integer vector of one or more weeks to score, or
#'   "rest" for the rest of the regular season. Defaults to the current week
#'   (see [ffl_week()]).
#' @param useScore One of "projectedScore" (default) or "actualScore".
#' @return A tibble with one row per team per `scoringPeriodId`: the optimal
#'   starting score with the current roster (`scoreBefore`), with the trade
#'   applied (`scoreAfter`), and their difference (`delta`); the players who
#'   move into (`startersIn`) and out of (`startersOut`) the optimal starting
#'   lineup; the bench players the team would have to drop to get back under
#'   the roster limit (`dropped`); and which traded players, on either side,
#'   are on bye that week (`byes`), from [nfl_teams] -- `NA` for seasons other
#'   than the one that data covers. Player lists are comma-separated names, `NA`
#'   when empty.
#' @examples
#' \dontrun{
#' evaluate_trade(teamId = 6, give = 4427366, receive = 4362628)
#' evaluate_trade(teamId = 6, give = 4427366, receive = 4362628,
#'                scoringPeriodId = "rest")
#' }
#' @family roster functions
#' @export
evaluate_trade <- function(leagueId = ffl_id(),
                           teamId,
                           give = integer(),
                           receive = integer(),
                           seasonId = ffl_year(),
                           scoringPeriodId = ffl_week(),
                           useScore = c("projectedScore", "actualScore"),
                           cookie = ffl_cookie()) {
  useScore <- match.arg(useScore, c("projectedScore", "actualScore"))
  teamId <- as.integer(teamId)
  seasonId <- as.integer(seasonId)
  give <- as.integer(give)
  receive <- as.integer(receive)
  if (length(give) > 0 && length(receive) > 0 && any(give %in% receive)) {
    stop("a player cannot be in both `give` and `receive`", call. = FALSE)
  }

  # the league as it is now: who rosters whom, the deadline, the schedule
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
  partner <- trade_partner(now, teamId, give, receive)
  trade_deadline_check(now)

  if (identical(scoringPeriodId, "rest")) {
    scoringPeriodId <- seq(now$scoringPeriodId, last_regular_week(now))
  }
  scoringPeriodId <- as.integer(scoringPeriodId)

  bind_df(lapply(
    X = scoringPeriodId,
    FUN = function(wk) {
      dat <- if (wk == now$scoringPeriodId) now else fetch(wk)
      trade_at_week(
        dat = dat,
        teamId = teamId,
        partner = partner,
        give = give,
        receive = receive,
        useScore = useScore,
        leagueId = leagueId,
        cookie = cookie
      )
    }
  ))
}

# which team `receive` comes from; NA if none (give-only) or several
trade_partner <- function(dat, teamId, give, receive) {
  owner <- roster_owners(dat)
  missing_give <- give[!give %in% owner$playerId[owner$teamId == teamId]]
  if (length(missing_give) > 0) {
    stop(
      sprintf(
        "player(s) %s are not on team %s's roster",
        paste(missing_give, collapse = ", "), teamId
      ),
      call. = FALSE
    )
  }
  from <- owner$teamId[match(receive, owner$playerId)]
  if (any(is.na(from))) {
    stop(
      sprintf(
        "player(s) %s are not on any team's roster; evaluate_trade() only scores trades between teams",
        paste(receive[is.na(from)], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  if (any(from == teamId)) {
    stop(
      sprintf(
        "player(s) %s are already on team %s's roster",
        paste(receive[from == teamId], collapse = ", "), teamId
      ),
      call. = FALSE
    )
  }
  from <- unique(from)
  if (length(from) > 1) {
    warning(
      sprintf(
        "`receive` players come from teams %s; only team %s is scored",
        paste(from, collapse = ", "), teamId
      ),
      call. = FALSE
    )
    return(NA_integer_)
  }
  if (length(from) == 0) NA_integer_ else from
}

roster_owners <- function(dat) {
  bind_df(lapply(
    X = seq_along(dat$teams$id),
    FUN = function(i) {
      data.frame(
        teamId = dat$teams$id[i],
        playerId = dat$teams$roster$entries[[i]]$playerPoolEntry$player$id
      )
    }
  ))
}

trade_deadline_check <- function(dat) {
  deadline <- ffl_date(dat$settings$tradeSettings$deadlineDate)
  if (!is.na(deadline) && deadline < Sys.time()) {
    warning(
      sprintf("the league's trade deadline passed on %s", format(deadline, "%b %d, %Y")),
      call. = FALSE
    )
  }
}

last_regular_week <- function(dat) {
  sched <- dat$settings$scheduleSettings
  last <- max(unlist(sched$matchupPeriods[[as.character(sched$matchupPeriodCount)]]))
  # already in the playoffs, so score through the end of the season
  if (dat$scoringPeriodId > last) {
    last <- dat$status$finalScoringPeriod
  }
  last
}

trade_at_week <- function(dat, teamId, partner, give, receive, useScore,
                          leagueId, cookie) {
  wk <- dat$scoringPeriodId
  slot_count <- out_roster_set(dat)$lineupSlotCounts[[1]]
  do_slot <- as.integer(slot_count$position[slot_count$limit > 0])
  do_slot <- pos_ids$slot[pos_ids$slot %in% do_slot]
  size_limit <- sum(slot_count$limit[slot_count$position != 21])

  tm <- out_team(dat$teams, trim = TRUE)
  team_rost <- function(tid) {
    i <- match(tid, dat$teams$id)
    out_roster(
      entry = dat$teams$roster$entries[[i]],
      tid = tid,
      wk = wk,
      yr = dat$seasonId,
      tm = tm,
      es = TRUE
    )
  }
  mine <- team_rost(teamId)
  missing_give <- setdiff(give, mine$playerId)
  if (length(missing_give) > 0) {
    stop(
      sprintf(
        "player(s) %s are not on team %s's week %s roster",
        paste(missing_give, collapse = ", "), teamId, wk
      ),
      call. = FALSE
    )
  }

  # find `receive` wherever they were rostered that week, else look them up
  everyone <- bind_df(lapply(dat$teams$id, team_rost))
  incoming <- everyone[everyone$playerId %in% receive, ]
  unrostered <- setdiff(receive, incoming$playerId)
  if (length(unrostered) > 0) {
    looked_up <- player_lookup(
      playerId = unrostered,
      leagueId = leagueId,
      seasonId = dat$seasonId,
      scoringPeriodId = wk,
      cookie = cookie
    )
    looked_up$teamId <- NA_integer_
    looked_up$abbrev <- NA
    looked_up$lineupSlot <- NA
    incoming <- rbind(incoming, looked_up[, names(incoming)])
  }
  outgoing <- mine[mine$playerId %in% give, ]
  byes <- traded_byes(rbind(outgoing, incoming), wk = wk, yr = dat$seasonId)

  sides <- list(trade_side(
    r = mine, out_id = give, arrive = incoming, tm = tm,
    do_slot = do_slot, slot_count = slot_count, size_limit = size_limit,
    useScore = useScore, byes = byes
  ))
  if (!is.na(partner)) {
    sides[[2]] <- trade_side(
      r = team_rost(partner), out_id = receive, arrive = outgoing, tm = tm,
      do_slot = do_slot, slot_count = slot_count, size_limit = size_limit,
      useScore = useScore, byes = byes
    )
  }
  bind_df(sides)
}

trade_side <- function(r, out_id, arrive, tm, do_slot, slot_count, size_limit,
                       useScore, byes) {
  tid <- r$teamId[1]
  arrive$teamId <- tid
  arrive$abbrev <- team_abbrev(tid, teams = tm)
  arrive$lineupSlot <- slot_abbrev(slot_unabbrev("BE"))
  hypo <- rbind(r[!r$playerId %in% out_id, ], arrive[, names(r)])

  before <- start_roster(out_best(r, do_slot, slot_count, score_col = useScore))
  after <- start_roster(out_best(hypo, do_slot, slot_count, score_col = useScore))

  n_over <- sum(hypo$lineupSlot != "IR") - size_limit
  dropped <- NA_character_
  if (n_over > 0) {
    bench <- hypo[!hypo$playerId %in% after$playerId & hypo$lineupSlot != "IR", ]
    bench <- bench[order(bench[[useScore]], na.last = FALSE), ]
    dropped <- player_names(bench[seq_len(n_over), ])
  }

  score_before <- sum(before[[useScore]])
  score_after <- sum(after[[useScore]])
  data.frame(
    scoringPeriodId = r$scoringPeriodId[1],
    teamId = tid,
    abbrev = team_abbrev(tid, teams = tm),
    scoreBefore = score_before,
    scoreAfter = score_after,
    delta = score_after - score_before,
    startersIn = player_names(after[!after$playerId %in% before$playerId, ]),
    startersOut = player_names(before[!before$playerId %in% after$playerId, ]),
    dropped = dropped,
    byes = byes
  )
}

# traded players whose NFL team is on bye, from the bundled `nfl_teams` data,
# which only describes one season
traded_byes <- function(traded, wk, yr) {
  if (!yr %in% fflr::nfl_schedule$seasonId) {
    return(NA_character_)
  }
  bye <- fflr::nfl_teams$byeWeek[
    match(as.character(traded$proTeam), as.character(fflr::nfl_teams$abbrev))
  ]
  player_names(traded[bye %in% wk, ])
}

player_names <- function(r) {
  if (nrow(r) == 0) {
    return(NA_character_)
  }
  paste(r$firstName, r$lastName, collapse = ", ")
}
