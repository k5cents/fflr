# Replacement level: the waiver wire as a baseline -------------------------
#
# Shared by `evaluate_trade()`, `best_roster()`, and `waiver_upgrades()`. A
# "stand-in" is a real available player's row, shaped like `out_roster()`,
# that can start in a lineup without being rostered: tagged with a
# `replacement = TRUE` column so it's never counted as a roster player.

# single-position starting slots, which each get a stand-in; the flexible
# slots (FLEX, OP, ...) are filled by those same stand-ins
standin_slots <- function(do_slot) {
  single <- pos_ids$slot[!is.na(pos_ids$position)]
  do_slot[do_slot %in% single]
}

# the most-rostered available players at each slot, one row per player per
# week, from one request per slot covering every week
replacement_pool <- function(leagueId, seasonId, weeks, slots, limit, cookie) {
  bind_df(lapply(
    X = slots,
    FUN = function(slot) {
      filter <- list(players = list(
        filterStatus = list(value = list("FREEAGENT", "WAIVERS")),
        filterSlotIds = list(value = list(slot)),
        limit = limit,
        sortPercOwned = list(sortPriority = 1L, sortAsc = FALSE),
        filterStatsForSourceIds = list(value = list(0L, 1L)),
        filterStatsForSplitTypeIds = list(value = list(1L)),
        filterStatsForScoringPeriodIds = list(value = as.list(weeks))
      ))
      parsed <- try_json(
        url = "https://lm-api-reads.fantasy.espn.com",
        path = sprintf(
          "apis/v3/games/ffl/seasons/%i/segments/0/leagues/%s",
          seasonId, leagueId
        ),
        query = list(view = "kona_player_info"),
        cookie = cookie,
        headers = c(
          `X-Fantasy-Filter` = as.character(
            jsonlite::toJSON(filter, auto_unbox = TRUE)
          )
        ),
        simplifyVector = FALSE
      )
      rows <- lapply(weeks, function(wk) {
        lapply(parsed$players, out_lookup, wk = wk, yr = seasonId)
      })
      out <- bind_df(unlist(rows, recursive = FALSE))
      if (nrow(out) > 0) {
        status <- vapply(parsed$players, function(p) null_chr(p$status), "")
        out$status <- rep(status, times = length(weeks))
        out$standinSlot <- slot
      }
      out
    }
  ))
}

null_chr <- function(x) {
  if (is.null(x)) NA_character_ else as.character(x)
}

# the `rank`-th best scorer at each slot in week `wk`, one player per slot
pick_standins <- function(pool, wk, useScore, rank = 1) {
  if (is.null(pool) || nrow(pool) == 0) {
    return(NULL)
  }
  pool <- pool[pool$scoringPeriodId == wk & !is.na(pool[[useScore]]), ]
  picks <- lapply(
    X = split(pool, pool$standinSlot),
    FUN = function(x) {
      x <- x[order(x[[useScore]], decreasing = TRUE), ]
      x[rank, ][rank <= nrow(x), ]
    }
  )
  picks <- bind_df(unname(picks))
  if (nrow(picks) == 0) {
    return(NULL)
  }
  picks <- picks[!duplicated(picks$playerId), ]
  picks$standinSlot <- NULL
  picks
}

# add stand-ins to a team's roster `r`, on its bench, tagged as replacements
add_standins <- function(r, standins) {
  if (is.null(standins) || nrow(standins) == 0) {
    return(r)
  }
  r$replacement <- FALSE
  n <- nrow(standins)
  standins$teamId <- rep(r$teamId[1], n)
  standins$abbrev <- rep(r$abbrev[1], n)
  standins$lineupSlot <- rep(slot_abbrev(slot_unabbrev("BE")), n)
  standins$replacement <- TRUE
  rbind(r, standins[, names(r)])
}

is_standin <- function(r) {
  if (!"replacement" %in% names(r)) {
    return(rep(FALSE, nrow(r)))
  }
  r$replacement %in% TRUE
}

# each player's score minus the stand-in's at the same position; `NA` where
# the league has no stand-in for that position
over_replacement <- function(r, standins, useScore) {
  if (is.null(standins) || nrow(standins) == 0) {
    return(rep(NA_real_, nrow(r)))
  }
  base <- standins[[useScore]][match(
    as.character(r$position), as.character(standins$position)
  )]
  r[[useScore]] - base
}
