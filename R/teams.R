#' Bus Schedule at Stop
#'
#' Returns a set of buses scheduled at a stop for a given date.
#'
#' @format A tibble with 1 row per bus departure and 8 variables:
#' \describe{
#'   \item{abbrev}{Team name abbreviation}
#'   \item{id}{League team ID}
#'   \item{location}{Team location}
#'   \item{nickname}{Team nickname}
#'   \item{owners}{List of all team owner user IDs}
#' }
#' @inheritParams ffl_api
#' @examples
#' league_teams(leagueId = "42654852")
#' @return Data frame containing scheduled arrival information.
#' @family League information
#' @export
league_teams <- function(seasonId = 2021, leagueId = ffl_id(),
                         leagueHistory = FALSE) {
  x <- ffl_api(
    seasonId = seasonId,
    leagueId = leagueId,
    leagueHistory = leagueHistory
  )
  if (leagueHistory && is.list(x$teams)) {
    names(x$teams) <- x$seasonId
    lapply(x$teams, as_tibble)
  } else {
    as_tibble(x$teams)
  }
}
