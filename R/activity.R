#' Roster moves
#'
#' The individual proposed and executed transactions, trades, and waiver moves.
#'
#' @inheritParams ffl_api
#' @return A data frame of transactions and roster moves.
#' @examples
#' recent_activity(leagueId = "42654852", scoringPeriodId = 2)
#' @family player functions
#' @export
recent_activity <- function(leagueId = ffl_id(), leagueHistory = FALSE,
                            scoringPeriodId = NULL, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = c("mTransactions2", "mTeam"),
    scoringPeriodId = scoringPeriodId,
    ...
  )
  tm <- out_team(dat$teams, trim = TRUE)
  if (leagueHistory) {
    stop("not currently supported for past seasons")
  } else if (is.null(dat$transactions)) {
    message("no roster moves for current period")
    return(data.frame())
  } else {
    t <- dat$transactions
    for (i in seq_along(t$items)) {
      if (!is.null(t$items[[i]]) & length(t$items[[i]]) > 0) {
        t$items[[i]] <- cbind(id = t$id[i], t$items[[i]])
      }
    }
    i <- do.call("rbind", t$items)[, -c(4, 5)]
    i$fromLineupSlotId[i$fromLineupSlotId == -1L] <- NA_integer_
    i$fromLineupSlotId <- slot_abbrev(i$fromLineupSlotId)
    i$toLineupSlotId <- slot_abbrev(i$toLineupSlotId)
    i$fromTeamId[i$fromTeamId == 0] <- NA_integer_
    i$toLineupSlotId[i$toLineupSlotId == -1L] <- NA_integer_
    i$toLineupSlotId[i$toLineupSlotId == 0] <- NA_integer_
    t$bidAmount[t$bidAmount == 0] <- NA_integer_
    t$proposedDate <- ffl_date(t$proposedDate)
    t$processDate <- ffl_date(t$processDate)
    t$seaonId <- dat$seasonId
    t <- t[, c("seaonId", "scoringPeriodId", "proposedDate", "processDate",
               "bidAmount", "status", "id")]
    t <- merge(t, i, by = "id")
    t$id <- substr(t$id, start = 1, stop = 8)
    t$bidAmount[t$type == "DROP"] <- NA
    t$toTeamId[t$toTeamId == 0] <- NA
    t$fromTeamId[t$fromTeamId == 0] <- NA
    t$abbrev <- team_abbrev(t$toTeamId, teams = tm)
    t <- move_col(t, "abbrev", 13)
    as_tibble(t[order(t$proposedDate), ])
  }
}
