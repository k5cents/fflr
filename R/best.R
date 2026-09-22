#' Sort the optimal fantasy roster
#'
#' Uses the roster settings for each league to find the best possible
#' combinations of players to score the most fantasy points.
#'
#' If `scoringPeriodId` is the current week (the default), then actual scoring
#' might be incomplete (see `projectedScore` argument).
#'
#' With `replacement = TRUE`, each lineup can also start a replacement-level
#' stand-in from the waiver wire at each position, as in [evaluate_trade()]:
#' the `replacementRank`-th best score that week among today's most-rostered
#' available players at that position. A stand-in only appears where it
#' beats every eligible player on the roster, so it shows where a lineup is
#' below waiver level; [waiver_upgrades()] says who to drop for them.
#'
#' @inheritParams ffl_api
#' @param useScore One of "projectedScore" or "actualScore" (default).
#' @param replacement If `TRUE`, let each lineup start replacement-level
#'   stand-ins from the waiver wire, and add each player's score over
#'   replacement. Defaults to `FALSE`.
#' @param replacementRank Which available player at each position is the
#'   stand-in: `1` (default) is the best one that week.
#' @return A list of data frames with optimal rosters, one per team. With
#'   `replacement = TRUE`, stand-ins are rows with `replacement` set to `TRUE`,
#'   and `overReplacement` is each player's score minus the stand-in's at the
#'   same position (`NA` for positions without one).
#' @examples
#' best_roster(leagueId = "42654852", scoringPeriodId = 1)
#' @family roster functions
#' @export
best_roster <- function(leagueId = ffl_id(),
                        useScore = c("actualScore", "projectedScore"),
                        scoringPeriodId = NULL,
                        replacement = FALSE,
                        replacementRank = 1,
                        ...) {
  useScore <- match.arg(useScore, c("actualScore", "projectedScore"))
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mRoster", "mSettings", "mTeam"),
    scoringPeriodId = scoringPeriodId,
    ...
  )
  if (is_predraft(dat)) {
    return(data.frame())
  }
  slots <- lineup_slots(dat)
  slot_count <- slots$slot_count
  do_slot <- slots$do_slot
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
  if (!isTRUE(replacement)) {
    return(lapply(rosters, out_best, do_slot, slot_count, score_col = useScore))
  }
  cookie <- list(...)$cookie
  if (is.null(cookie)) cookie <- ffl_cookie()
  pool <- replacement_pool(
    leagueId = leagueId,
    seasonId = dat$seasonId,
    weeks = dat$scoringPeriodId,
    slots = standin_slots(do_slot),
    limit = 10L + as.integer(replacementRank),
    cookie = cookie
  )
  standins <- pick_standins(pool, dat$scoringPeriodId, useScore, replacementRank)
  lapply(rosters, function(r) {
    best <- out_best(add_standins(r, standins), do_slot, slot_count, useScore)
    if (!"replacement" %in% names(best)) {
      best$replacement <- rep(FALSE, nrow(best))
    }
    best$overReplacement <- over_replacement(best, standins, useScore)
    best
  })
}

out_best <- function(r,
                     do_slot,
                     slot_count,
                     score_col) {
  most_elig <- names(sort(table(unlist(r$eligibleSlots))))
  most_elig <- most_elig[most_elig %in% do_slot]
  most_elig <- most_elig[most_elig != "21" & most_elig != "25"]
  has_standins <- any(is_standin(r))
  best <- data.frame()
  for (s in most_elig) {
    n_max <- slot_count$limit[slot_count$position == s]
    is_elig <- sapply(r$eligibleSlots, has_slot, s)
    n_elig <- sum(is_elig)
    if (s == "20" && has_standins) {
      # a replacement stand-in either starts or isn't there at all, and the
      # real players whose starting slots they took all go to the bench
      is_elig <- is_elig & !is_standin(r) & r$lineupSlot != "IR"
      n_elig <- sum(is_elig)
      n_max <- max(n_max, n_elig)
    }
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
  r <- r[!is_standin(r), ]
  if (nrow(r) > 0 && has_standins) {
    # every real player is listed: on IR if they were, else on the bench
    r$actualSlot <- r$lineupSlot
    r$lineupSlot[r$lineupSlot != "IR"] <- "BE"
    best <- rbind(best, r)
  } else if (nrow(r) > 0) {
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

# the league's starting slots, in `out_best()`'s form, and the roster limit
lineup_slots <- function(dat) {
  slot_count <- out_roster_set(dat)$lineupSlotCounts[[1]]
  do_slot <- as.integer(slot_count$position[slot_count$limit > 0])
  do_slot <- pos_ids$slot[pos_ids$slot %in% do_slot]
  list(
    slot_count = slot_count,
    do_slot = do_slot,
    size_limit = sum(slot_count$limit[slot_count$position != 21])
  )
}

has_slot <- function(eligibleSlots, slot) {
  slot %in% eligibleSlots
}
