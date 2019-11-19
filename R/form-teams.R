#' Form a table of league teams
#'
#' From an ESPN "members" API (via [fantasy_members()]), create a tidy tibble of
#' league members and their fantasy teams.
#'
#' @param data The list object returned by [fantasy_members()].
#' @return A tibble of teams and owners.
#' @examples
#' form_teams(data = fantasy_members(252353))
#' @importFrom purrr map_df
#' @importFrom dplyr rename right_join arrange select
#' @importFrom tidyr unnest_longer unite
#' @importFrom rlang .data
#' @export
form_teams <- function(data) {
  members <- data$members %>%
    purrr::map_df(tibble::as_tibble) %>%
    dplyr::rename(owners = .data$id)
  suppressMessages(
    teams <- data$teams %>%
      purrr::map_df(tibble::as_tibble) %>%
      tidyr::unnest_longer(col = .data$owners) %>%
      dplyr::right_join(y = members) %>%
      tidyr::unite(
        .data$location, .data$nickname,
        col = "teamName",
        sep = " "
      ) %>%
      dplyr::arrange(.data$id) %>%
      dplyr::select(
        .data$id,
        .data$abbrev,
        team_name = .data$teamName,
        owner_id = .data$owners,
        owner_name = .data$displayName,
        is_lm = .data$isLeagueManager
      )
  )
  return(teams)
}
