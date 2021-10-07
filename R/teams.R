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
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory && is.list(dat$teams)) {
    names(dat$teams) <- dat$seasonId
    lapply(dat$teams, out_team)
  } else {
    out_team(dat$teams)
  }
}

out_team <- function(z, trim = FALSE) {
  z <- change_names(z, "id", "teamId")
  z$abbrev <- factor(z$teamId, labels = z$abbrev)
  if (trim) {
    z <- z[, c("teamId", "abbrev")]
  }
  as_tibble(z)
}
