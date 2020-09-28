#' Fantasy team roster
#'
#' The players on a team roster with position, injury status, and playing stats.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of players on a roster.
#' @examples
#' team_roster(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
team_roster <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mRoster", ...)
  if (old) {
    out <- rep(list(NA), length(data$teams))
    for (y in seq_along(out)) {
      out[[y]] <- lapply(data$teams[[y]]$roster$entries, parse_roster)
    }
  } else {
    out <- lapply(data$teams$roster$entries, parse_roster)
  }
  return(out)
}

parse_roster <- function(entry) {
  if (is.null(entry)) {
    return(entry)
  }
  player <- entry$playerPoolEntry$player
  stats <- player$stats
  proj_dbl <- score_dbl <- rep(NA, length(player$stats))
  for (i in seq_along(player$stats)) {
    s <- player$stats[[i]]
    week_int <- max(s$scoringPeriodId)
    year_int <- max(s$seasonId)
    if (year_int >= 2018) {
      is_split <- s$statSplitTypeId == 1
      is_week <- s$scoringPeriodId == week_int
      which_score <- which(s$statSourceId == 0 & is_split & is_week)
      if (length(which_score) == 0) {
        score_dbl[i] <- NA_real_
      } else {
        score_dbl[i] <- s$appliedTotal[which_score]
      }
      which_proj <- which(s$statSourceId == 1 & is_split & is_week)
      proj_dbl[i] <- s$appliedTotal[which_proj]
    } else {
      score_dbl[i] <- s$appliedTotal
      proj_dbl[i] <- NA_real_
    }
  }
  if (year_int >= 2018) {
    injury_status <- abbreviate(player$injuryStatus, minlength = 1)
  } else {
    injury_status <- abbreviate(entry$injuryStatus, minlength = 1)
  }
  x <- tibble::tibble(
    year  = year_int,
    week  = week_int,
    team = entry$playerPoolEntry$onTeamId,
    slot = slot_abbrev(entry$lineupSlotId),
    id = player$id,
    first = player$firstName,
    last = player$lastName,
    pro  = fflr::nfl_teams$abbrev[match(player$proTeamId, fflr::nfl_teams$team)],
    pos = pos_abbrev(player$defaultPositionId),
    status = injury_status,
    proj  = proj_dbl,
    score = score_dbl,
    start = player$ownership$percentStarted,
    rost = player$ownership$percentOwned,
    change = round(player$ownership$percentChange, digits = 3),
    acq_type = entry$acquisitionType,
    acq_date = ffl_date(entry$acquisitionDate)
  )
  return(x[order(x$slot), ])
}

# c(
#   QB = "0", TQ = "1", RB = "2", RW = "3", WR = "4", WT = "5", TE = "6",
#   FX = "7", OP = "8", DT = "9", DE = "10", LB = "11", ER = "12", DL = "13",
#   CB = "14", SF = "15", DB = "16", DP = "17", DS = "18", KI = "19", PU = "20",
#   HC = "21", BE = "22", IR = "23"
# )

slot_abbrev <- function(slot) {
  factor(
    x = slot,
    levels = c("0",  "2",  "4",  "6",  "23", "16", "17", "20", "21"),
    labels = c("QB", "RB", "WR", "TE", "FX", "DS", "KI", "BE", "IR")
  )
}

pos_abbrev <- function(pos) {
  factor(
    x = pos,
    levels = c("1",  "2",  "3",  "4",  "5",  "16"),
    labels = c("QB", "RB", "WR", "TE", "KI", "DS")
  )
}
