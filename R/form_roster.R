#' @title Format a Team Roster
#' @description Take a team's list roster entries and applies [roster_entry()]
#'     to return a single tibble per team.
#' @param data The list object returned by [fantasy_roster()].
#' @return A tibble with a row for every roster entry.
#' @examples
#' data <- ffl_get(lid = 252353, view = "roster", scoringPeriodId = 3)
#' team <- data$teams[[5]]
#' team_roster(team)
#' @importFrom purrr map_df
#' @importFrom dplyr arrange
#' @export
form_roster <- function(data) {
  team$roster$entries %>%
    purrr::map_df(roster_entry) %>%
    dplyr::arrange(slot)
}
