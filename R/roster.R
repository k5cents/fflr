#' Fantasy team rosters
#'
#' The roster of all teams in a league.
#'
#' @inheritParams ffl_api
#' @examples
#' team_roster(leagueId = "42654852", scoringPeriodId = 1)
#' @return A dataframe (or list) with league teams.
#' @family roster functions
#' @export
team_roster <- function(leagueId = ffl_id(), leagueHistory = FALSE,
                        scoringPeriodId = NULL, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = c("mRoster", "mTeam"),
    scoringPeriodId = scoringPeriodId,
    ...
  )
  if (leagueHistory) {
    out <- lapply(
      X = seq_along(dat$teams),
      FUN = function(i) {
        tm <- out_team(dat$teams[[i]], trim = TRUE)
        out <- lapply(
          X = seq_along(dat$teams[[i]]$roster$entries),
          FUN = function(j) {
            out_roster(
              entry = dat$teams[[i]]$roster$entries[[j]],
              tid = dat$teams[[i]]$id[j],
              wk = dat$scoringPeriodId[i],
              yr = dat$seasonId[i],
              tm = tm
            )
          }
        )
        names(out) <- dat$teams[[i]]$abbrev
        return(out)
      }
    )
    names(out) <- dat$seasonId
    return(out)
  } else {
    if (is_predraft(dat)) {
      return(data.frame())
    }
    tm <- out_team(dat$teams, trim = TRUE)
    out <- lapply(
      X = seq_along(dat$teams$roster$entries),
      FUN = function(i) {
        out_roster(
          entry = dat$teams$roster$entries[[i]],
          tid = dat$teams$id[i],
          wk = dat$scoringPeriodId,
          yr = dat$seasonId,
          tm = tm
        )
      }
    )
    names(out) <- dat$teams$abbrev
    return(out)
  }
}

out_roster <- function(entry, tid, tm, wk, yr, es = FALSE) {
  if (is.null(entry)) {
    return(entry)
  }
  player <- entry$playerPoolEntry$player
  proj_dbl <- score_dbl <- rep(NA, length(player$stats))
  for (i in seq_along(player$stats)) {
    s <- player$stats[[i]]
    week_int <- wk
    # week_int <- max(s$scoringPeriodId)
    year_int <- yr
    # year_int <- max(s$seasonId)
    if (year_int >= 2018) {
      is_split <- s$statSplitTypeId == 1
      is_week <- s$scoringPeriodId == week_int
      if (!any(is_week)) {
        if (player$defaultPositionId[i] == 16) {
          proj_dbl[i] <- 0
          score_dbl[i] <- 0
          next
        } else {
          next
        }
      }
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
    teamId = tid,
    abbrev = team_abbrev(tid, teams = tm),
    lineupSlot = slot_abbrev(entry$lineupSlot),
    playerId = player$id,
    firstName = player$firstName,
    lastName = player$lastName,
    proTeam  = pro_abbrev(player$proTeamId),
    position = pos_abbrev(player$defaultPositionId),
    injuryStatus = injury_status,
    projectedScore  = proj_dbl,
    actualScore = score_dbl,
    percentStarted = player$ownership$percentStarted,
    percentOwned = player$ownership$percentOwned,
    percentChange = round(player$ownership$percentChange, digits = 3)
  )
  if (isTRUE(es)) {
    x$eligibleSlots <- player$eligibleSlots
  }
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
#' rost <- team_roster(leagueId = "42654852", leagueHistory = TRUE)[[1]][[1]]
#' start_roster(rost)
#' @family roster functions
#' @export
start_roster <- function(roster) {
  roster[roster$lineupSlot != "BE" & roster$lineupSlot != "IR", ]
}

#' Sum of starting scores in a roster
#'
#' For a given roster tibble, sum the starting scores.
#'
#' @param roster A roster data frame from [team_roster()].
#' @param useScore One of "projectedScore" or "actualScore" (default).
#' @return A starting score as double.
#' @examples
#' rost <- team_roster(leagueId = "42654852", leagueHistory = TRUE)[[1]][[1]]
#' roster_score(rost)
#' @family roster functions
#' @export
roster_score <- function(roster,
                         useScore = c("actualScore", "projectedScore")) {
  useScore <- match.arg(useScore, c("actualScore", "projectedScore"))
  sum(start_roster(roster)[[useScore]])
}
