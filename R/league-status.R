#' League status
#'
#' Current information about a league: the date activated, current week,
#' starting week, final week, past seasons, teams joined, and waiver status.
#'
#' @inheritParams draft_picks
#' @return A tibble or list of league status.
#' @examples
#' league_status(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
league_status <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mStatus", ...)
  if (old) {
    waiver_status <- rep(list(NA), nrow(d$status$waiverProcessStatus))
    for (i in seq(nrow(d$status$waiverProcessStatus))) {
      waiver_status[[i]] <- tibble::tibble(
        date = as.POSIXct(names(d$status$waiverProcessStatus[i, ])),
        status = unname(unlist(d$status$waiverProcessStatus[i, ]))
      )
    }
  } else {
    waiver_status <- tibble::tibble(
      date = as.POSIXct(names(d$status$waiverProcessStatus)),
      status = unname(unlist(d$status$waiverProcessStatus))
    )
  }
  x <- list(
    year = d$seasonId,
    is_active = d$status$isActive,
    activated = ffl_date(d$status$activatedDate),
    this_week = d$scoringPeriodId,
    first_week = d$status$firstScoringPeriod,
    last_week = d$status$finalScoringPeriod,
    past_years = d$status$previousSeasons,
    updated = ffl_date(d$status$standingsUpdateDate),
    teams_joined = d$status$teamsJoined,
    waiver_last = ffl_date(d$status$waiverLastExecutionDate),
    waiver_next = ffl_date(d$status$waiverNextExecutionDate),
    waiver_status = waiver_status
  )
  if (old) {
    tibble::as_tibble(x)
  } else {
    return(x)
  }
}
