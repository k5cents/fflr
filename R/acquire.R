#' Roster acquisition history
#'
#' The date and method of each player's acquisition onto a fantasy roster.
#'
#' @inheritParams ffl_api
#' @return A data frame of roster players with acquisition method and date.
#' @examples
#' player_acquire(leagueId = "42654852")
#' @importFrom tibble tibble
#' @export
player_acquire <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(leagueId, leagueHistory, view = c("mRoster", "mTeam"), ...)
  if (leagueHistory | length(list(...) > 0)) {
    stop("Acqusition data is only available for current season and period")
  }
  tm <- out_team(dat$teams)
  e <- dat$teams$roster$entries
  out <- rep(list(NA), length(e))
  names(out) <- tm$abbrev
  for (i in seq_along(e)) {
    out[[i]] <- parse_acquire(
      entry = e[[i]],
      t = tm,
      y = dat$seasonId,
      w = dat$scoringPeriodId
    )
    out[[i]]$onTeamId <- tm$abbrev[i]
  }
  return(out)
}

parse_acquire <- function(entry, t, y, w) {
  player <- entry$playerPoolEntry$player
  x <- tibble::tibble(
    seasonId  = y,
    scoringPeriodId  = w,
    onTeamId = entry$playerPoolEntry$onTeamId,
    lineupSlotId = slot_abbrev(entry$lineupSlotId),
    id = player$id,
    firstName = player$firstName,
    lastName = player$lastName,
    proTeamId  = pro_abbrev(player$proTeamId),
    defaultPositionId = pos_abbrev(player$defaultPositionId),
    acquisitionType = entry$acquisitionType,
    acquisitionDate = ffl_date(entry$acquisitionDate)
  )
  x[order(x$lineupSlotId), ]
}
