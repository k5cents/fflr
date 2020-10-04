#' Live matchup scoreboard
#'
#' The current and projected score for each ongoing match.
#'
#' @inheritParams draft_picks
#' @return A tibble of scores.
#' @examples
#' live_scoring(252353)
#' @importFrom tibble tibble
#' @export
live_scoring <- function(lid = getOption("lid"), old = FALSE, ...) {
  if (old) {
    stop("live scoring for past seasons?")
  }
  d <- ffl_api(lid, view = "mScoreboard", ...)
  s <- tibble::tibble(
    week = d$status$currentMatchupPeriod,
    match = c(d$schedule$id, d$schedule$id),
    team = c(d$schedule$home$teamId, d$schedule$away$teamId),
    score = c(d$schedule$home$totalPointsLive, d$schedule$away$totalPointsLive),
    proj = c(
      d$schedule$home$totalProjectedPointsLive,
      d$schedule$away$totalProjectedPointsLive
    )
  )
  s <- s[!is.na(s$proj), ]
  s <- s[order(s$match), ]
  return(s)
}
