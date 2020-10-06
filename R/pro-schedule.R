#' Professional NFL schedule
#'
#' The opponents each team faces every week in an NFL regular season.
#'
#' @param year Season schedule (2004-present), defaults to [ffl_year()].
#' @return Tibble of NFL team opponents by week.
#' @examples
#' pro_schedule(year = ffl_year(-2))
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @export
pro_schedule <- function(year = ffl_year()) {
  d <- jsonlite::fromJSON(
    txt = paste0(
      "https://fantasy.espn.com/apis/v3/games/ffl/seasons/", year,
      "?view=proTeamSchedules_wl"
    )
  )
  p <- d$settings$proTeams$proGamesByScoringPeriod
  t <- data.frame(
    team = d$settings$proTeams$id,
    abbrev = d$settings$proTeams$abbrev
  )
  sched <- rep(list(NA), length(p))
  for (i in seq_along(p)) {
    x <- unique(do.call("rbind", p[[i]]))
    x <- tibble::tibble(
      year = as.integer(year),
      week = unique(x$scoringPeriodId),
      pro = c(x$homeProTeamId, x$awayProTeamId),
      opp = c(x$awayProTeamId, x$homeProTeamId),
      home = c(rep(TRUE, nrow(x)), rep(FALSE, nrow(x))),
      kickoff = ffl_date(rep(x$date, 2))
    )
    sched[[i]] <- x[order(x$pro), ]
  }
  sched <- do.call("rbind", sched)
  sched$pro <- team_abbrev(sched$pro, fflr::nfl_teams)
  sched$opp <- team_abbrev(sched$opp, fflr::nfl_teams)
  sched$future <- sched$kickoff > Sys.time()
  return(sched)
}
