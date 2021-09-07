#' Fantasy league teams
#'
#' The teams in a league and their owners.
#'
#' @inheritParams ffl_api
#' @examples
#' league_members(leagueId = "42654852")
#' @return A dataframe (or list) with league teams.
#' @family League information
#' @export
league_members <- function(leagueId = ffl_id(), seasonId = 2021,
                           leagueHistory = FALSE) {
  dat <- ffl_api(
    leagueId = leagueId,
    seasonId = seasonId,
    leagueHistory = leagueHistory
  )
  if (leagueHistory && is.list(dat$teams)) {
    names(dat$teams) <- dat$seasonId
    lapply(dat$teams, out_member)
  } else {
    out_team(dat$teams)
  }
}

out_member <- function(z) {
  z$abbrev <- factor(z$id, labels = z$abbrev)
  as_tibble(z)
}
