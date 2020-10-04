#' Fantasy match schedule
#'
#' The opponents each team faces every week in a fantasy regular season.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of match opponents.
#' @examples
#' match_schedule(lid = 252353)
#' @importFrom tibble tibble
#' @export
match_schedule <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = c("mMatchup", "mTeam"), ...)
  if (old) {
    out <- rep(list(NA), length(data$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- parse_sched(
        s = data$schedule[[i]],
        y = data$seasonId[i],
        t = data.frame(
          team = data$teams[[i]]$id,
          abbrev = factor(
            x = data$teams[[i]]$abbrev,
            levels = data$teams[[i]]$abbrev
          )
        )
      )
    }
  } else {
    out <- parse_sched(
      s = data$schedule,
      y = data$seasonId,
      t = data.frame(
        team = data$teams$id,
        abbrev = factor(
          x = data$teams$abbrev,
          levels = data$teams$abbrev
        )
      )
    )
  }
  return(out)
}

parse_sched <- function(s, y = NULL, t = NULL) {
  x <- tibble::tibble(
    year = as.integer(y),
    week = rep(s$matchupPeriodId, 2),
    match = rep(s$id, 2),
    team = team_abbrev(c(s$home$teamId, s$away$teamId), t),
    opp = team_abbrev(c(s$away$teamId, s$home$teamId), t),
    home = c(rep(TRUE, nrow(s)), rep(FALSE, nrow(s)))
  )
  x[order(x$match), ]
}


