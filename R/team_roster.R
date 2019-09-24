#' @title Format a Team Roster
#' @description Take a team's list roster entries and applies [roster_entry()]
#'     to return a single tibble per team.
#' @param team The `team` index of [ffl_get()] response.
#' @return A tibble with a row for every roster entry.
#' @examples
#' data <- ffl_get(lid = 252353, view = "roster", scoringPeriodId = 3)
#' team <- data$teams[[5]]
#' team_roster(team)
#' @importFrom purrr map_df
#' @export
team_roster <- function(team) {
  map_df(team$roster$entries, roster_entry)
}
