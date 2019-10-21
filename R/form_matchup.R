#' @title Format a Weekly Matchup
#' @description Take a weekly matchup and return tidy tibble of scores.
#' @param data The list object returned by [fantasy_roster()].
#' @return A two-row tibble fora matchup's `HOME` and `AWAY` scores.
#' @examples
#' data <- fantasy_data(lid = 252353, view = "mMatchup")
#' form_matchup(data)
#' @importFrom tibble tibble
#' @importFrom forcats fct_rev as_factor
#' @importFrom rlang .data
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
  mups$week <- as.factor(mups$week)
  mups <- dplyr::filter(mups, .data$score != 0)
  return(mups)
}
