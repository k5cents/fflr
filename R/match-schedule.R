#' Match schedule
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of draft picks.
#' @examples
#' match_schedule(lid = 252353)
#' @importFrom tibble as_tibble
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
    year = y,
    week = s$matchupPeriodId,
    match = s$id,
    home = team_abbrev(s$home$teamId, t),
    away = team_abbrev(s$away$teamId, t)
  )
  return(x)
}


