#' Fantasy matchups
#'
#' The weekly matchups between home and away teams, with score and winner.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of draft picks.
#' @examples
#' weekly_matchups(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
weekly_matchups <- function(lid, old = FALSE, ...) {
  data <- ffl_api(lid = lid, old = old, view = "mMatchup", ...)
  if (old) {
    out <- rep(list(NA), length(data$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- parse_matchup(data$schedule[[i]], y = data$seasonId[i])
    }
  } else {
    out <- parse_matchup(data$schedule, y = data$seasonId)
  }
  return(out)
}

parse_matchup <- function(s, y = NULL) {
  n <- length(s$winner)
  is_home <- c(rep(TRUE, n), rep(FALSE, n))
  winners <- rep(s$winner, 2)
  winners[winners == "UNDECIDED"] <- NA
  x <- tibble::tibble(
    year = y,
    id = rep(s$id, 2),
    week = factor(rep(s$matchupPeriodId, 2), levels = 1:16),
    team = c(s$home$teamId, s$away$teamId),
    home = is_home,
    score = c(s$home$totalPoints, s$away$totalPoints),
    winner = (rep(s$winner, 2) == "HOME") == is_home
  )
  return(x[order(x$id),])
}
