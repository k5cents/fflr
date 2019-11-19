#' Format a single weekly matchup
#'
#' Take a weekly matchup and return tidy tibble of scores for two teams.
#'
#' @param matchup A _single_ `schedule` element of the list object returned by
#'   [fantasy_matchup()].
#' @return A two-row tibble from matchup's `HOME` and `AWAY` scores.
#' @examples
#' data <- fantasy_matchup(lid = 252353)
#' form_matchup(data$schedule[[10]])
#' @importFrom tibble tibble
#' @importFrom forcats fct_rev as_factor
#' @importFrom rlang .data
#' @export
form_matchup <- function(matchup) {
  tibble(
    game = matchup$id,
    week = factor(matchup$matchupPeriodId, levels = 1:16),
    home = c(FALSE, TRUE),
    id = c(matchup$away$teamId, matchup$home$teamId),
    score = c(matchup$away$totalPoints, matchup$home$totalPoints),
    winner = .data$score == max(.data$score)
  )
}
