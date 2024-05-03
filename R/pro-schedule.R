#' Professional schedule
#'
#' The opponents each team faces every week in a regular season.
#'
#' @param seasonId Season schedule (2004-present), defaults to [ffl_year()].
#' @return Data frame of team opponents by week.
#' @examples
#' pro_schedule(seasonId = ffl_year(-2))
#' @importFrom tibble tibble
#' @family professional football functions
#' @export
pro_schedule <- function(seasonId = ffl_year()) {
  dat <- try_json(
    url = sprintf(
      fmt = "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/%i", seasonId
    ),
    query = list(view = "proTeamSchedules_wl")
  )
  p <- dat$settings$proTeams$proGamesByScoringPeriod
  tm <- data.frame(
    stringsAsFactors = FALSE,
    team = dat$settings$proTeams$id,
    abbrev = dat$settings$proTeams$abbrev
  )
  sched <- rep(list(NA), length(p))
  for (i in seq_along(p)) {
    x <- unique(do.call("rbind", p[[i]]))
    x <- data.frame(
      seasonId = as.integer(seasonId),
      scoringPeriodId = unique(x$scoringPeriodId),
      matchupId = x$id,
      proTeam = pro_abbrev(c(x$homeProTeamId, x$awayProTeamId)),
      opponent = pro_abbrev(c(x$awayProTeamId, x$homeProTeamId)),
      isHome = c(rep(TRUE, nrow(x)), rep(FALSE, nrow(x))),
      date = ffl_date(rep(x$date, 2))
    )
    sched[[i]] <- x[order(x$proTeam), ]
  }
  sched <- do.call("rbind", sched)
  as_tibble(sched[order(sched$date, sched$matchupId), ])
}
