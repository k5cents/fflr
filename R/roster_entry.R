#' @title Format a Roster Entry
#' @description Take a team's roster entry list and return a single row tibble.
#'   This function is used in [form_roster()] to combine the entries from an
#'   entire team into a single tibble.
#' @param entry The `entry` element of `roster` list from a `team` list.
#' @return A single row tibble roster entry.
#' @examples
#' data <- fantasy_roster(lid = 252353, scoringPeriodId = 3)
#' roster_entry(entry = data$teams[[5]]$roster$entries[[2]])
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom stringr str_which
#' @importFrom dplyr mutate recode
#' @importFrom magrittr "%>%" use_series
#' @export
roster_entry <- function(entry) {
  stats <- entry$playerPoolEntry$player$stats
  s <- purrr::transpose(entry$playerPoolEntry$player$stats)
  week_int <- max(unlist(s$scoringPeriodId))
  year_int <- max(unlist(s$seasonId))
  which_score <- which(s$statSourceId == 0 & s$statSplitTypeId == 1 & s$scoringPeriodId == week_int)
  if (length(which_score) == 0) {
    score_dbl <- NA_real_
  } else {
    score_dbl <- unlist(s$appliedTotal[which_score])
  }
  which_proj <- which(s$statSourceId == 1 & s$statSplitTypeId == 1 & s$scoringPeriodId == week_int)
  proj_dbl <- unlist(s$appliedTotal[which_proj])
  roster <- tibble::tibble(
    year  = year_int,
    week  = week_int,
    owner = entry$playerPoolEntry$onTeamId,
    slot = factor(
      x = entry$lineupSlotId,
      levels = c("0",  "2",  "4",  "6",  "23", "16", "17", "20"),
      labels = c("QB", "RB", "WR", "TE", "FX", "DS", "KI", "BE")
    ),
    first = entry$playerPoolEntry$player$firstName,
    last  = entry$playerPoolEntry$player$lastName,
    team  = pro_teams$pro[match(entry$playerPoolEntry$player$proTeamId, pro_teams$team)],
    pos = factor(
      x = entry$playerPoolEntry$player$defaultPositionId,
      levels = c("1",  "2",  "3",  "4",  "5",  "16"),
      labels = c("QB", "RB", "WR", "TE", "KI", "DS")
    ),
    proj  = proj_dbl,
    score = score_dbl,
    start = entry$playerPoolEntry$player$ownership$percentStarted/100,
    rost = entry$playerPoolEntry$player$ownership$percentOwned/100
  )
  aquired = entry$acquisitionType
  time = as.POSIXct(entry$acquisitionDate/1000, origin = "1970-01-01")
  if (!is.null(aquired) & !is.null(time)) {
    roster <- dplyr::mutate(roster, aquired, time)
  }
  return(roster)
}
