#' @title Format a Roster Entry
#' @description Take a team's roster entry list and return a single row tibble.
#' @param entry The `entry` index of `roster` list from a `team` list.
#' @return A single row tibble roster entry.
#' @examples
#' data <- ffl_get(lid = 252353, view = "roster")
#' entry <- data$teams[[5]]$roster$entries[[2]]
#' roster_entry(entry)
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom stringr str_which
#' @importFrom dplyr mutate recode
#' @importFrom magrittr "%>%"
#' @export
roster_entry <- function(entry) {
  stats <- entry$playerPoolEntry$player$stats
  names(stats) <- purrr::map(stats, `$`, "id")
  names <- names(stats)
  names(stats)[names == max(names[stringr::str_which(names, "112019")])] <- "proj"
  names(stats)[names == max(names[stringr::str_which(names, "014011")])] <- "score"
  tibble::tibble(
    year    = stats$score$seasonId,
    week    = stats$score$scoringPeriodId,
    player  = as.character(abs(entry$playerId)),
    first   = entry$playerPoolEntry$player$firstName,
    last    = entry$playerPoolEntry$player$lastName,
    pos     = entry$playerPoolEntry$player$defaultPositionId,
    team    = entry$playerPoolEntry$player$proTeamId,
    owned   = entry$playerPoolEntry$player$ownership$percentOwned/100,
    start   = entry$playerPoolEntry$player$ownership$percentStarted/100,
    slot    = entry$lineupSlotId,
    proj    = stats$proj$appliedTotal,
    score   = stats$score$appliedTotal
  ) %>% dplyr::mutate(
    slot = slot %>%
      dplyr::recode(
        "0"  = "QB",
        "2"  = "RB",
        "4"  = "WR",
        "6"  = "TE",
        "16" = "DF",
        "17" = "K",
        "20" = "BE",
        "23" = "FX"
      ),
    pos = pos %>%
      dplyr::recode(
        "1"  = "QB",
        "2"  = "RB",
        "3"  = "WR",
        "4"  = "TE",
        "5"  = "K",
        "16" = "D"
      )
  )
}
