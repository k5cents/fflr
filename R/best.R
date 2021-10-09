#' Sort the optimal fantasy roster
#'
#' Uses the roster settings for each league to find the best possible
#' combinations of players to score the most fantasy points.
#'
#' @inheritParams ffl_api
#' @param scoringPeriodId The scoring period for which rosters will be
#'   optimized. If `scoringPeriodId` is the current week (the default), then
#'   actual scoring might be incomplete (see `projectedScore` below).
#' @param projectedScore logical; Should rosters be sorted using the ESPN
#'   `projectedScore`? If any players are missing an `actualScore` value, then
#'   `projectedScore` will be used regardless of this argument.
#' @examples
#' best_roster(leagueId = "42654852", scoringPeriodId = 1)
#' @return A dataframe (or list) with optimal rosters.
#' @export
best_roster <- function(leagueId = ffl_id(), scoringPeriodId = ffl_week(),
                        projectedScore = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mRoster", "mSettings", "mTeam"),
    scoringPeriodId = scoringPeriodId
  )
  set <- out_roster_set(dat)
  slot_count <- set$lineupSlotCounts[[1]]
  do_slot <- as.integer(slot_count$position[slot_count$limit > 0])
  do_slot <- pos_ids$slot[pos_ids$slot %in% do_slot]
  rosters <- lapply(
    X = seq_along(dat$teams$roster$entries),
    FUN = function(i) {
      out_roster(
        entry = dat$teams$roster$entries[[i]],
        tid = dat$teams$id[i],
        tm = out_team(dat$teams, trim = TRUE),
        es = TRUE
      )
    }
  )
  names(rosters) <- dat$teams$abbrev
  proj <- any(is.na(unlist(sapply(rosters, `[[`, "actualScore"))))
  score_col <- ifelse(projectedScore || proj, "projectedScore", "actualScore")
  lapply(rosters, out_best, do_slot, slot_count, score_col)
}

out_best <- function(r,
                     do_slot = c(0, 2, 4, 6, 23, 16, 17, 20),
                     slot_count = roster_settings()$lineupSlotCounts[[1]],
                     score_col = "projectedScore") {
  best <- data.frame()
  for (s in do_slot[do_slot != 21]) {
    n_slot <- slot_count$limit[slot_count$position == s]
    is_eligable <- sapply(r$eligibleSlots, has_slot, s)
    n_eligable <- sum(is_eligable)
    if (n_eligable < n_slot) {
      warning(paste("Insufficient number of eligable players for slot", s))
      n_slot <- n_eligable
    }
    can_slot <- r[is_eligable, ]
    if (n_eligable > 1) {
      can_slot <- can_slot[order(can_slot[[score_col]], decreasing = TRUE), ]
    }
    can_slot <- can_slot[seq(n_slot), ]
    can_slot$actualSlot <- can_slot$lineupSlot
    can_slot$lineupSlot <- slot_abbrev(s)
    best <- rbind(best, can_slot)
    r <- r[!(r$playerId %in% best$playerId), ]
  }
  if (nrow(r) > 0) {
    n_ir <- slot_count$limit[slot_count$position == 23]
    if (nrow(r) == n_ir & all(r$lineupSlot == "IR")) {
      r$actualSlot <- r$lineupSlot
      best <- rbind(best, r)
    }
  }
  best <- move_col(best, "actualSlot", 6)
  best$eligibleSlots <- NULL
  return(best)
}

has_slot <- function(eligibleSlots, slot) {
  slot %in% eligibleSlots
}
