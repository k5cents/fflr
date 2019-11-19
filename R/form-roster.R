#' Format a team roster
#'
#' Take a team's list of roster entries and use [purrr::map_df()] to apply
#' [roster_entry()] and return a single tibble per team list.
#'
#' @param team The a single element of the `teams` list found in the list
#'   returned by [fantasy_roster()]. That is, for an entire [fantasy_roster()]
#'   data frame, [form_roster()] would be applied to every top level list.
#' @return A tibble with a row for every roster entry.
#' @examples
#' data <- fantasy_roster(lid = 252353)
#' form_roster(team = data$teams[[5]])
#' @importFrom purrr map_df
#' @importFrom dplyr arrange mutate
#' @importFrom rlang .data
#' @export
form_roster <- function(team) {
  abbrev <- team$abbrev
  team$roster$entries %>%
    purrr::map_df(roster_entry) %>%
    dplyr::arrange(.data$slot) %>%
    dplyr::mutate(owner = abbrev)
}
