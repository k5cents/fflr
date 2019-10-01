#' @title Format a Weekly Matchup
#' @description Take a weekly matchup and return tidy tibble of scores.
#' @param entry An element of `schedule` list from a `mMatchup` view.
#' @return A two-row tibble fora matchup's `HOME` and `AWAY` scores.
#' @examples
#' data <- ffl_get(lid = 252353, view = "mMatchup")
#' matchup <- data$schedule[[5]]
#' weekly_matchup(matchup)
#' @importFrom tibble tibble
#' @export
weekly_matchup <- function(matchup) {
  tibble(
    game = matchup$id,
    week = matchup$matchupPeriodId,
    home = c(FALSE, TRUE),
    team = c(matchup$away$teamId, matchup$home$teamId),
    score = c(matchup$away$totalPoints, matchup$home$totalPoints)
  )
}

