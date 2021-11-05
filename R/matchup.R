#' Fantasy match schedule
#'
#' The opponents each team faces every week in a fantasy regular season.
#' Returned in a tidy format where each row is a single team with an indication
#' of home-away status. There are two rows per matchup, one for each team.
#'
#' @inheritParams ffl_api
#' @return A data frame(s) of match opponents.
#' @examples
#' tidy_schedule(leagueId = "42654852")
#' @family league functions
#' @export
tidy_schedule <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mMatchup", "mTeam"),
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- out_sched(
        s = dat$schedule[[i]],
        y = dat$seasonId[i],
        team = out_team(dat$teams[[i]], trim = TRUE)
      )
    }
    return(out)
  } else {
    out <- out_sched(
      s = dat$schedule,
      y = dat$seasonId,
      team = out_team(dat$teams, trim = TRUE)
    )
    as_tibble(out)
  }
}

out_sched <- function(s, y = NULL, team = NULL) {
  out <- data.frame(
    seasonId = as.integer(y),
    matchupPeriodId = rep(s$matchupPeriodId, 2),
    matchupId = rep(s$id, 2),
    teamId = c(s$home$teamId, s$away$teamId),
    abbrev = team_abbrev(c(s$home$teamId, s$away$teamId), team),
    opponent = team_abbrev(c(s$away$teamId, s$home$teamId), team),
    isHome = c(rep(TRUE, nrow(s)), rep(FALSE, nrow(s)))
  )
  as_tibble(out[order(out$matchupId), ])
}

#' @rdname tidy_schedule
#' @export
tidy_matchups <- function(...) {
  .Deprecated("tidy_schedule")
  tidy_schedule(...)
}
