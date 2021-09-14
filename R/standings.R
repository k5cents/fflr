#' League standings
#'
#' Return the current and projected standings, win streak, total wins, losses,
#' and points scored for and against each team.
#'
#' @inheritParams ffl_api
#' @return A data frame of team standings.
#' @examples
#' league_standings(leagueId = "42654852")
#' @importFrom tibble tibble
#' @export
league_standings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(leagueId, leagueHistory, view = "mTeam", ...)
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$teams))
    for (i in seq_along(dat$members)) {
      out[[i]] <- parse_ranks(
        teams = dat$teams[[i]],
        y = dat$seasonId[i],
        w = dat$scoringPeriodId[i]
      )
    }
  } else {
    out <- parse_ranks(
      teams = dat$teams,
      y = dat$seasonId,
      w = dat$scoringPeriodId
    )
  }
  return(out)
}

parse_ranks <- function(teams, y = NULL, w = NULL) {
  tibble::tibble(
    year = y,
    week = w,
    team = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    draftDayProjectedRank = teams$draftDayProjectedRank,
    currentProjectedRank = teams$currentProjectedRank,
    playoffSeed = teams$playoffSeed,
    rankCalculatedFinal = teams$rankCalculatedFinal,
    teams$record$overall
  )
}
