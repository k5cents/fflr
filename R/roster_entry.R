#' @title Format a Roster Entry
#' @description Take a team's roster entry list and return a single row tibble.
#' @param entry The `entry` index of `roster` list from a `team` list.
#' @return A single row tibble roster entry.
#' @examples
#' data <- ffl_get(lid = 252353, view = "roster", scoringPeriodId = 3)
#' entry <- data$teams[[5]]$roster$entries[[2]]
#' roster_entry(entry)
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom stringr str_which
#' @importFrom dplyr mutate recode
#' @importFrom magrittr "%>%" use_series
#' @export
roster_entry <- function(entry) {
  stats <- entry$playerPoolEntry$player$stats
  names(stats) <- purrr::map(stats, magrittr::use_series, "id")
  names <- names(stats)
  names(stats)[names == max(names[stringr::str_which(names, "112019")])] <- "proj"
  names(stats)[names == max(names[stringr::str_which(names, "014011")])] <- "score"
  tibble::tibble(
    year  = stats$score$seasonId,
    week  = stats$score$scoringPeriodId,
    owner = entry$playerPoolEntry$onTeamId,
    slot = factor(
      x = entry$lineupSlotId,
      levels = c("0", "2", "4", "6", "16", "17", "20", "23"),
      labels = c("QB", "RB", "WR", "TE", "DS", "KI", "BE", "FX")
    ),
    id    = as.character(abs(entry$playerId)),
    first = entry$playerPoolEntry$player$firstName,
    last  = entry$playerPoolEntry$player$lastName,
    team  = entry$playerPoolEntry$player$proTeamId,
    pos = factor(
      x = entry$playerPoolEntry$player$defaultPositionId,
      levels = c("1", "2", "3", "4", "5", "16"),
      labels = c("QB", "RB", "WR", "TE", "KI", "DS")
    ),
    score = stats$score$appliedTotal,
    proj  = stats$proj$appliedTotal,
    start = entry$playerPoolEntry$player$ownership$percentStarted/100,
    owned = entry$playerPoolEntry$player$ownership$percentOwned/100
  )
}
