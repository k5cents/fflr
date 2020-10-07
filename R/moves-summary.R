#' League transactions
#'
#' Summary of transactions and roster changes made during a season.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league members.
#' @examples
#' moves_summary(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
moves_summary <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mTeam", ...)
  member_cols <- c("user", "owners", "lm")
  if (old) {
    out <- rep(list(NA), length(data$teams))
    for (i in seq_along(data$members)) {
      out[[i]] <- parse_trans(
        teams = data$teams[[i]],
        y = data$seasonId[i],
        w = data$scoringPeriodId[i]
      )
    }
  } else {
    out <- parse_trans(
      teams = data$teams,
      y = data$seasonId,
      w = data$scoringPeriodId
    )
  }
  return(out)
}

parse_trans <- function(teams, y = NULL, w = NULL) {
  teams$transactionCounter$matchupAcquisitionTotals <- NULL
  counter <- teams$transactionCounter[, c(1:3, 5:6, 9)]
  names(counter)[c(1, 4:5)] <- c("spent", "activated", "reserved")
  x <- tibble::tibble(
    year = y,
    week = w,
    team = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    waiver = teams$waiverRank,
    counter
  )
  return(x)
}
