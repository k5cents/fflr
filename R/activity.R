#' Roster moves
#'
#' The individual proposed and executed transactions, trades, and waiver moves.
#'
#' @inheritParams ffl_api
#' @return A data frame of transactions and roster moves.
#' @examples
#' recent_activity(leagueId = "42654852", scoringPeriodId = 2)
#' @family player functions
#' @export
recent_activity <- function(leagueId = ffl_id(), leagueHistory = FALSE,
                            scoringPeriodId = NULL, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = c("mTransactions2", "mTeam"),
    scoringPeriodId = scoringPeriodId,
    ...
  )
  tm <- out_team(dat$teams, trim = TRUE)
  if (leagueHistory) {
    stop("not currently supported for past seasons")
  } else if (is.null(dat$transactions)) {
    message("no roster moves for current period")
    return(data.frame())
  }
  t <- dat$transactions
  t$processDate <- ffl_date(t$processDate)
  t$proposedDate <- ffl_date(t$proposedDate)
  t$rating <- NULL
  t$subOrder <- NULL
  as_tibble(t)
}
