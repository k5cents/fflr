#' Roster acquisition history
#'
#' The date and method of each player's acquisition onto a fantasy roster.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of players on a roster.
#' @examples
#' player_acquire(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
player_acquire <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = list("mRoster", "mTeam"))
  if (old | length(list(...) > 0)) {
    stop("acqusition data is only available for current season and period")
  }
  t <- parse_teams(data$teams)
  e <- data$teams$roster$entries
  out <- rep(list(NA), length(e))
  names(out) <- t$abbrev
  for (i in seq_along(e)) {
    out[[i]] <- parse_acquire(
      entry = e[[i]],
      t = t,
      y = data$seasonId,
      w = data$scoringPeriodId
    )
    out[[i]]$team <- t$abbrev[i]
  }
  return(out)
}

parse_acquire <- function(entry, t, y, w) {
  player <- entry$playerPoolEntry$player
  x <- tibble::tibble(
    year  = y,
    week  = w,
    team = entry$playerPoolEntry$onTeamId,
    slot = slot_abbrev(entry$lineupSlotId),
    id = player$id,
    first = player$firstName,
    last = player$lastName,
    pro  = fflr::nfl_teams$abbrev[match(player$proTeamId, fflr::nfl_teams$team)],
    pos = pos_abbrev(player$defaultPositionId),
    method = entry$acquisitionType,
    date = ffl_date(entry$acquisitionDate)
  )
  x[order(x$slot), ]
}
