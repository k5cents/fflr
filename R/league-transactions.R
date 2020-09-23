#' League transactions
#'
#' Summary of transactions and roster changes made during a season.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league members.
#' @examples
#' league_transactions(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
league_transactions <- function(lid, old = FALSE, ...) {
  data <- ffl_api(lid, old = old, view = "mTeam", ...)
  member_cols <- c("user", "owners", "lm")
  if (old) {
    out <- rep(list(NA), length(data$teams))
    for (i in seq_along(data$members)) {
      out[[i]] <- parse_trans(data$teams[[i]], year = data$seasonId[i])
    }
  } else {
    out <- parse_trans(data$teams, year = data$seasonId)
  }
  return(out)
}

parse_trans <- function(teams, year = NULL, week = NULL) {
  teams$transactionCounter$matchupAcquisitionTotals <- NULL
  counter <- teams$transactionCounter[, c(1:3, 5:6, 9)]
  names(counter)[c(1, 4:5)] <- c("spent", "activated", "reserved")
  x <- tibble::tibble(
    year = year,
    team = teams$id,
    abbrev = teams$abbrev,
    waiver = teams$waiverRank,
    counter
  )
  return(x)
}
