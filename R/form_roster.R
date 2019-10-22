#' @title Format a Team Roster
#' @description Take a team's list roster entries and applies [roster_entry()]
#'     to return a single tibble per team.
#' @param team The list object returned by [fantasy_roster()].
#' @return A tibble with a row for every roster entry.
#' @examples
#' data <- fantasy_roster(lid = 252353, scoringPeriodId = 3)
#' team <- data$teams[[5]]
#' form_roster(team)
#' @importFrom purrr map_df
#' @importFrom dplyr arrange
#' @importFrom rlang .data
#' @export
form_roster <- function(data, teamNumber) {
  weekId <- data$scoringPeriodId
  data$teams[[teamNumber]]$roster$entries %>%
    purrr::map_df(roster_entry, weekId) %>%
    dplyr::arrange(.data$slot)
 
}
