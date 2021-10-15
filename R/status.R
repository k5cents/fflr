#' League status
#'
#' Current information about a league: the date activated, current week,
#' starting week, final week, past seasons, teams joined, and waiver status.
#'
#' @inheritParams ffl_api
#' @return A data frame of league status by season.
#' @examples
#' league_status(leagueId = "42654852")
#' @importFrom tibble tibble
#' @family league functions
#' @export
league_status <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(leagueId, leagueHistory, view = "mStatus", ...)
  if (leagueHistory) {
    waiver_status <- rep(list(NA), nrow(dat$status$waiverProcessStatus))
    for (i in seq(nrow(dat$status$waiverProcessStatus))) {
      waiver_status[[i]] <- data.frame(
        date = as.POSIXct(names(dat$status$waiverProcessStatus[i, ])),
        status = unname(unlist(dat$status$waiverProcessStatus[i, ]))
      )
    }
  } else {
    waiver_status <- data.frame(
      date = as.POSIXct(names(dat$status$waiverProcessStatus)),
      status = unname(unlist(dat$status$waiverProcessStatus))
    )
  }
  tibble::tibble(
    year = dat$seasonId,
    isActive = dat$status$isActive,
    activatedDate = ffl_date(dat$status$activatedDate),
    scoringPeriodId = dat$scoringPeriodId,
    firstScoringPeriod = dat$status$firstScoringPeriod,
    finalScoringPeriod = dat$status$finalScoringPeriod,
    previousSeasons = list(dat$status$previousSeasons),
    standingsUpdateDate = ffl_date(dat$status$standingsUpdateDate),
    teamsJoined = dat$status$teamsJoined,
    waiverLastExecutionDate = ffl_date(dat$status$waiverLastExecutionDate),
    waiverNextExecutionDate = ffl_date(dat$status$waiverNextExecutionDate),
    waiverProcessStatus = list_ifnot(waiver_status)
  )
}
