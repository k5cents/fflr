#' Fantasy match schedule
#'
#' The opponents each team faces every week in a fantasy regular season.
#' Returned in a tidy format where each row is a single team with an indication
#' of home-away status. There are two rows per matchup, one for each team.
#'
#' @inheritParams ffl_api
#' @return A data frame(s) of match opponents.
#' @examples
#' tidy_matchups(leagueId = "42654852")
#' tidy_matchups(leagueId = "252353", leagueHistory = TRUE)
#' @export
tidy_matchups <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
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
        team = data.frame(
          stringsAsFactors = FALSE,
          id = dat$teams[[i]]$id,
          abbrev = factor(
            x = dat$teams[[i]]$abbrev,
            levels = dat$teams[[i]]$abbrev
          )
        )
      )
    }
    return(out)
  } else {
    out <- out_sched(
      s = dat$schedule,
      y = dat$seasonId,
      team = data.frame(
        stringsAsFactors = FALSE,
        id = dat$teams$id,
        abbrev = factor(
          x = dat$teams$abbrev,
          levels = dat$teams$abbrev
        )
      )
    )
    as_tibble(out)
  }
}

out_sched <- function(s, y = NULL, team = NULL) {
  out <- data.frame(
    seasonId = as.integer(y),
    matchupPeriodId = rep(s$matchupPeriodId, 2),
    id = rep(s$id, 2),
    teamId = team_abbrev(c(s$home$teamId, s$away$teamId), team),
    opponent = team_abbrev(c(s$away$teamId, s$home$teamId), team),
    home = c(rep(TRUE, nrow(s)), rep(FALSE, nrow(s)))
  )
  as_tibble(out[order(out$id), ])
}


