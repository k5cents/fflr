#' @title Format a Roster Entry
#' @description Take a team's roster entry list and return a single row tibble.
#' @param entry The `entry` index of `roster` list from a `team` list.
#' @return A single row tibble roster entry.
#' @examples
#' data <- fantasy_roster(lid = 252353, scoringPeriodId = 3)
#' entry <- data$teams[[5]]$roster$entries[[2]]
#' roster_entry(entry)
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom stringr str_which
#' @importFrom dplyr mutate recode
#' @importFrom magrittr "%>%" use_series
#' @export
roster_entry <- function(entry, weekId) {
  y <- entry$playerPoolEntry$player$stats
  weekCount = 0
  for (j in 1:length(y)) {
    if (y[[j]]$scoringPeriodId == weekId){
      type <- y[[j]]$statSourceId
      weekCount <- weekCount + 1
      if (type == 1) {
        proj <- y[[j]]$appliedTotal
      }
      else {
        points <- y[[j]]$appliedTotal
      }
      week <- y[[j]]$scoringPeriodId
      year <- y[[j]]$seasonId
    }
  }
  if (weekCount < 2) points <- NA
  stats <- entry$playerPoolEntry$player$stats
  roster <- tibble::tibble(
    year  = year,
    week  = week,
    owner = entry$playerPoolEntry$onTeamId,
    slot = factor(
      x = entry$lineupSlotId,
      levels = c("0", "2", "4", "6", "23", "16", "17", "20"),
      labels = c("QB", "RB", "WR", "TE", "FX", "DS", "KI", "BE")
    ),
    first = entry$playerPoolEntry$player$firstName,
    last  = entry$playerPoolEntry$player$lastName,
    team  = entry$playerPoolEntry$player$proTeamId,
    pos = factor(
      x = entry$playerPoolEntry$player$defaultPositionId,
      levels = c("1", "2", "3", "4", "5", "16"),
      labels = c("QB", "RB", "WR", "TE", "KI", "DS")
    ),
    score = points,
    proj  = proj,
    start = entry$playerPoolEntry$player$ownership$percentStarted/100,
    owned = entry$playerPoolEntry$player$ownership$percentOwned/100
  )
  aquired = entry$acquisitionType
  time = as.POSIXct(entry$acquisitionDate/1000, origin = "1970-01-01")
  if (!is.null(aquired) & !is.null(time)) {
    roster <- dplyr::mutate(roster, aquired, time)
  }
  return(roster)
}
