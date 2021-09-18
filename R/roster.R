#' Fantasy team rosters
#'
#' The roster of all teams in a league.
#'
#' @inheritParams ffl_api
#' @examples
#' team_roster(leagueId = "42654852", scoringPeriodId = 1)
#' @return A dataframe (or list) with league teams.
#' @export
team_roster <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = "mRoster",
    ...
  )
  if (leagueHistory) {
    lapply(dat$teams, function(x) lapply(x$roster$entries, out_roster))
  } else {
    stop_predraft(dat)
    lapply(dat$teams$roster$entries, out_roster)
  }
}

out_roster <- function(entry, t = NULL) {
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
    injury_status[is.na(injury_status)] <- "A"
  } else {
    injury_status <- abbreviate(entry$injuryStatus, minlength = 1)
  }
  x <- data.frame(
    seasonId  = year_int,
    scoringPeriodId  = week_int,
    teamId = entry$playerPoolEntry$onTeamId,
    lineupSlot = slot_abbrev(entry$lineupSlot),
    id = player$id,
    firstName = player$firstName,
    lastName = player$lastName,
    proTeam  = nfl_abb$abbrev[match(player$proTeamId, nfl_abb$id)],
    position = pos_abbrev(player$defaultPositionId),
    injuryStatus = injury_status,
    projectedScore  = proj_dbl,
    actualScore = score_dbl,
    percentStarted = player$ownership$percentStarted,
    percentOwned = player$ownership$percentOwned,
    percentChange = round(player$ownership$percentChange, digits = 3)
  )
  as_tibble(x[order(x$lineupSlot), ])
}

#' Starting roster
#'
#' The starting 9 man roster using standard roster slots. In the future this
#' function may be adapted to take roster slots from [roster_settings()].
#'
#' @param roster A roster data frame from [team_roster()].
#' @return A data frame of starters on a roster.
#' @examples
#' start_roster(team_roster(leagueId = "42654852")[[1]])
#' @export
start_roster <- function(roster) {
  roster[roster$lineupSlot != "BE" & roster$lineupSlot != "IR", ]
}

#' Sum of starting scores in a roster
#'
#' For a given roster tibble, sum the starting scores.
#'
#' @param roster A roster data frame from [team_roster()].
#' @return A starting score as double.
#' @examples
#' roster_score(team_roster(leagueId = "42654852")[[1]])
#' @export
roster_score <- function(roster) {
  sum(start_roster(roster)$actualScore)
}
