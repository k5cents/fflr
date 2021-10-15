#' Fantasy league teams
#'
#' The teams in a league and their owners.
#'
#' If any team has multiple owners, the `memberId` column will be a list of
#' unique owner member ID strings per team (see [league_members()]).
#'
#' @inheritParams ffl_api
#' @examples
#' league_teams(leagueId = "42654852")
#' @return A dataframe (or list) with league teams.
#' @family league functions
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
  z <- change_names(z, "owners", "memberId")
  z$abbrev <- factor(z$teamId, labels = z$abbrev)
  if (trim) {
    z <- z[, c("teamId", "abbrev")]
    return(as_tibble(z))
  }
  n_member <- sapply(z$memberId, length)
  if (all(n_member < 2)) {
    if (any(n_member == 0)) {
      z$memberId[n_member == 0] <- list(NA_character_)
    }
    z$memberId <- unlist(z$memberId)
  }
  as_tibble(z)
}
