#' League transactions
#'
#' Summary of transactions and roster changes made during a season by team.
#'
#' @inheritParams ffl_api
#' @return A data frame of transaction counts by team.
#' @examples
#' transaction_counter(leagueId = "42654852")
#' @importFrom tibble as_tibble
#' @export
transaction_counter <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(leagueId, leagueHistory, view = "mTeam", ...)
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$teams))
    for (i in seq_along(dat$members)) {
      out[[i]] <- out_trans(
        teams = dat$teams[[i]],
        y = dat$seasonId[i],
        w = dat$scoringPeriodId[i]
      )
    }
  } else {
    out <- out_trans(
      teams = dat$teams,
      y = dat$seasonId,
      w = dat$scoringPeriodId
    )
  }
  return(out)
}

out_trans <- function(teams, y = NULL, w = NULL) {
  teams$transactionCounter$matchupAcquisitionTotals <- NULL
  x <- data.frame(
    seasonId = y,
    scoringPeriodId = w,
    teamId = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    waiverRank = teams$waiverRank,
    teams$transactionCounter
  )
  as_tibble(x)
}
