#' Fantasy league teams
#'
#' The teams in a league and their owners.
#'
#' @inheritParams ffl_api
#' @examples
#' league_teams(leagueId = "42654852")
#' @return A dataframe (or list) with league teams.
#' @family League information
#' @export
league_teams <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  x <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory && is.list(x$teams)) {
    names(x$teams) <- x$seasonId
    lapply(x$teams, out_team)
  } else {
    out_team(x$teams)
  }
}

out_team <- function(z) {
  z$abbrev <- factor(z$id, labels = z$abbrev)
  as_tibble(z)
}

#' Convert team ID to abbreviation
#'
#' @param id A integer vector of team numbers to convert.
#' @param teams A table of teams from [league_teams()].
#' @return A factor vector of team abbreviations.
#' @examples
#' team_abbrev(id = 2, teams = league_teams(leagueId = "42654852"))
#' @export
team_abbrev <- function(id, teams = league_teams(leagueId = ffl_id())) {
  stopifnot(is.data.frame(teams))
  teams$abbrev[match(id, teams$id)]
}
