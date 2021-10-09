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
    scoringPeriodId = scoringPeriodId,
    ...
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
                     do_slot,
                     slot_count,
                     score_col = "projectedScore") {
  most_elig <- names(sort(table(unlist(r$eligibleSlots))))
  most_elig <- most_elig[most_elig %in% do_slot]
  most_elig <- most_elig[most_elig != "21" & most_elig != "25"]
  best <- data.frame()
  for (s in most_elig) {
    n_max <- slot_count$limit[slot_count$position == s]
    is_elig <- sapply(r$eligibleSlots, has_slot, s)
    n_elig <- sum(is_elig)
    if (n_elig < n_max) {
      warning(
        sprintf("Slot %s has %i maximum but %i eligible", s, n_max, n_elig)
      )
      if (n_elig == 0) {
        next
      }
      n_max <- n_elig
    }
    can_max <- r[is_elig, ]
    if (n_elig > 1) {
      can_max <- can_max[order(can_max[[score_col]], decreasing = TRUE), ]
    }
    can_max <- can_max[seq(n_max), ]
    can_max$actualSlot <- can_max$lineupSlot
    can_max$lineupSlot <- slot_abbrev(s)
    best <- rbind(best, can_max)
    r <- r[!(r$playerId %in% best$playerId), ]
  }
  if (nrow(r) > 0) {
    n_ir <- slot_count$limit[slot_count$position == 21]
    if (nrow(r) == n_ir & all(r$lineupSlot == "IR")) {
      r$actualSlot <- r$lineupSlot
      best <- rbind(best, r)
    }
  }
  best <- move_col(best, "actualSlot", 6)
  best$eligibleSlots <- NULL
  best[order(best$lineupSlot), ]
}

has_slot <- function(eligibleSlots, slot) {
  slot %in% eligibleSlots
}
