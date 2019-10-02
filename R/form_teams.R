#' @title Create ESPN Teams Tibble
#' @description From an ESPN "members" API (via [fantasy_members()]), create a
#'   tidy tibble of league members and their fantasy teams.
#' @param data The list object returned by [fantasy_members()].
#' @return A tibble of teams and owners.
#' @examples
#' form_teams(data = fantasy_members(252353))
#' @importFrom purrr map_df
#' @importFrom dplyr rename right_join arrange select
#' @importFrom tidyr unnest_longer unite
#' @export
form_teams <- function(data) {
  members <- data$members %>%
    purrr:::map_df(tibble::as_tibble) %>%
    dplyr::rename(owners = id)
  suppressMessages(
    teams <- data$teams %>%
      purrr:::map_df(tibble::as_tibble) %>%
      tidyr::unnest_longer(col = owners) %>%
      dplyr::right_join(y = members) %>%
      tidyr::unite(
        location, nickname,
        col = "teamName",
        sep = " "
      ) %>%
      dplyr::arrange(id) %>%
      dplyr::select(
        id,
        abbrev,
        team_name = teamName,
        owner_id = owners,
        owner_name = displayName,
        is_lm = isLeagueManager
      )
  )
  return(teams)
}
