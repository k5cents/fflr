#' Fantasy league teams
#'
#' The teams in a league and their owners.
#'
#' @inheritParams ffl_api
#' @examples
#' league_members(leagueId = "42654852")
#' @return A dataframe (or list) with league members.
#' @family league functions
#' @export
league_members <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory && is.list(dat$teams)) {
    names(dat$teams) <- dat$seasonId
    lapply(dat$members, out_member)
  } else {
    out_member(dat$members)
  }
}

out_member <- function(x) {
  x <- change_names(x, "id", "memberId")
  as_tibble(x)
}
