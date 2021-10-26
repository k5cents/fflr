#' Sort the optimal fantasy roster
#'
#' Uses the roster settings for each league to find the best possible
#' combinations of players to score the most fantasy points.
#'
#' If `scoringPeriodId` is the current week (the default), then actual scoring
#' might be incomplete (see `projectedScore` argument).
#'
#' @inheritParams ffl_api
#' @param useScore One of "projectedScore" or "actualScore" (default).
#' @return A dataframe (or list) with optimal rosters.
#' @examples
#' best_roster(leagueId = "42654852", scoringPeriodId = 1)
#' @family roster functions
#' @export
best_roster <- function(leagueId = ffl_id(),
                        useScore = c("actualScore", "projectedScore"),
                        scoringPeriodId = NULL, ...) {
  useScore <- match.arg(useScore, c("actualScore", "projectedScore"))
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
        wk = dat$scoringPeriodId,
        yr = dat$seasonId,
        tm = out_team(dat$teams, trim = TRUE),
        es = TRUE
      )
    }
  )
  names(rosters) <- dat$teams$abbrev
  # proj <- any(is.na(unlist(sapply(rosters, `[[`, "actualScore"))))
  lapply(rosters, out_best, do_slot, slot_count, score_col = useScore)
}

out_best <- function(r,
                     do_slot,
                     slot_count,
                     score_col) {
  most_elig <- names(sort(table(unlist(r$eligibleSlots))))
  most_elig <- most_elig[most_elig %in% do_slot]
  most_elig <- most_elig[most_elig != "21" & most_elig != "25"]
  best <- data.frame()
  for (s in most_elig) {
    n_max <- slot_count$limit[slot_count$position == s]
    is_elig <- sapply(r$eligibleSlots, has_slot, s)
    n_elig <- sum(is_elig)
    if (n_elig < n_max) {
      if (s != "20") {
        warning(
          sprintf("Slot %s has %i maximum but %i eligible", s, n_max, n_elig),
          call. = FALSE
        )
      }
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
