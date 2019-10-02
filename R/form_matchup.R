#' @title Format a Weekly Matchup
#' @description Take a weekly matchup and return tidy tibble of scores.
#' @param data The list object returned by [fantasy_roster()].
#' @return A two-row tibble fora matchup's `HOME` and `AWAY` scores.
#' @examples
#' data <- ffl_get(lid = 252353, view = "mMatchup")
#' matchup <- data$schedule[[5]]
#' weekly_matchup(matchup)
#' @importFrom tibble tibble
#' @export
form_matchup <- function(data) {
  sched <- data$schedule
  ind_matchup <- function(matchup) {
    tibble(
      game = matchup$id,
      week = matchup$matchupPeriodId,
      home = c(FALSE, TRUE),
      id = c(matchup$away$teamId, matchup$home$teamId),
      score = c(matchup$away$totalPoints, matchup$home$totalPoints)
    )
  }
  mups <- purrr::map_df(sched, ind_matchup)
  mups$week <- forcats::fct_rev(forcats::as_factor(mups$week))
  mups <- dplyr::filter(mups, score != 0)
  return(mups)
}
