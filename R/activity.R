#' Roster moves
#'
#' The individual proposed and executed transactions, trades, and waiver moves.
#'
#' As of November 2021, activity data related to trades coming from the API is
#' flawed. The `items` list column containing the players involved in a trade
#' will only contain data for _rejected_ trades (with an `executionType` of
#' "CANCEL"). For accepted and upheld trades, that `items` element is `NULL` or
#' an empty list. This flaw comes from the API itself, not processing done by
#' this package.
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
  # `expirationDate` and `acceptedDate` are only returned for signed-in
  # requests, so the columns present depend on whether a cookie was sent
  for (d in c("processDate", "proposedDate", "expirationDate", "acceptedDate")) {
    if (!is.null(t[[d]])) {
      t[[d]] <- ffl_date(t[[d]])
    }
  }
  t$rating <- NULL
  t$subOrder <- NULL
  as_tibble(t)
}
