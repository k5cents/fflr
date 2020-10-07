#' League information
#'
#' Basic information on a ESPN fantasy football league, like the name, size,
#' and season length.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of season settings.
#' @examples
#' league_info(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
league_info <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  x <- list(
    year = d$seasonId,
    name = unique(d$settings$name),
    id = unique(d$id),
    public = d$settings$isPublic,
    size = d$settings$size,
    length = d$status$finalScoringPeriod
  )
  if (old) {
    tibble::as_tibble(x)
  } else {
    return(x)
  }
}

#' League team size
#'
#' @inheritParams draft_picks
#' @return A named integer vector.
#' @examples
#' league_size(252353, old = TRUE)
#' @export
league_size <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  x <- d$settings$size
  names(x) <- d$seasonId
  return(x)
}

#' League name
#'
#' @inheritParams draft_picks
#' @return A character vector.
#' @examples
#' league_name(252353)
#' @export
league_name <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, ...)
  unique(d$settings$name)
}

#' League draft settings
#'
#' The type, date, and pick order of a league draft.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of draft settings.
#' @examples
#' draft_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
draft_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$draftSettings[c(12, 1:2, 4:5, 10:11)]
  names(s) <- c("type", "budget", "date", "trading", "keepers", "order", "time")
  s$date <- ffl_date(s$date)
  s$budget[s$type == "SNAKE"] <- NA_character_
  s$year <- d$seasonId
  s <- s[c(length(s), 1:length(s) - 1)]
  if (old) {
    tibble::as_tibble(s)
  } else {
    return(s)
  }
}

#' League waiver settings
#'
#' The type, days, and details of a league waiver process.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of waiver settings.
#' @examples
#' waiver_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
waiver_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$acquisitionSettings[c(-5, -6)]
  names(s) <- c(
    "budget", "limit", "type", "is_auction", "min_bid",
    "waiver_hours", "order_reset", "process_days", "process_hour"
  )
  s$year <- d$seasonId
  s <- s[c(length(s), 1:length(s) - 1)]
  if (old) {
    tibble::as_tibble(s)
  } else {
    return(s)
  }
}

#' League finance settings
#'
#' The off-site fees assigned to various roster movies and transactions.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of finance settings.
#' @examples
#' fee_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
fee_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$financeSettings
  names(s) <- c(
    "entry", "misc", "loss", "trade", "add", "drop", "active", "reserve"
  )
  s$year <- d$seasonId
  s <- s[c(length(s), 1:length(s) - 1)]
  if (old) {
    tibble::as_tibble(s)
  } else {
    return(s)
  }
}

#' League roster settings
#'
#' The number of players and positions on a fantasy football roster.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of roster settings.
#' @examples
#' roster_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble
#' @export
roster_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$rosterSettings
  if (old) {
    slot_limit <- pos_limit <- rep(list(NA), nrow(s$positionLimits))
    for (i in seq(nrow(s$positionLimits))) {
      pos_used <- s$positionLimits[i, ] != 0 & !is.na( s$positionLimits[i, ])
      pos_limit[[i]] <- tibble::tibble(
        slot = pos_abbrev(names(s$positionLimits[i, ])[pos_used]),
        limit = unname(s$positionLimits[i, ])[pos_used]
      )
      slot_used <- s$lineupSlotCounts[i,] != 0 & !is.na( s$lineupSlotCounts[i,])
      slot_limit[[i]] <- tibble::tibble(
        slot = slot_abbrev(names(s$lineupSlotCounts[i, ])[slot_used]),
        limit = unname(s$lineupSlotCounts[i, ])[slot_used]
      )
    }
  } else {
    pos_used <- unlist(s$positionLimits) != 0
    pos_limit <- unlist(s$positionLimits[pos_used])
    names(pos_limit) <- pos_abbrev(names(pos_limit))
    slot_used <- unlist(s$lineupSlotCounts) != 0
    slot_limit <- unlist(s$lineupSlotCounts[slot_used])
    names(slot_limit) <- slot_abbrev(names(slot_limit))
  }
  x <- list(
    use_undrop = s$isUsingUndroppableList,
    lineup_lock = s$lineupLocktimeType,
    roster_lock = s$rosterLocktimeType,
    move_limit = s$moveLimit,
    slot_count = slot_limit,
    pos_count = pos_limit
  )
  x$year <- d$seasonId
  x <- x[c(length(x), 1:length(x) - 1)]
  if (old) {
    tibble::as_tibble(x)
  } else {
    return(x)
  }
}

#' League schedule settings
#'
#' The length of a fantasy season and the match periods for each week.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of schedule settings.
#' @examples
#' schedule_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble tibble
#' @export
schedule_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$scheduleSettings[-8]
  names(s) <- c(
    "divisions",
    "match_count",
    "match_length",
    "match_sched",
    "period_type",
    "playoff_length",
    "seed_rule",
    "playoff_size"
  )
  if (old) {
    for (i in seq_along(s$divisions)) {
      s$divisions[[i]] <- tibble::as_tibble(s$divisions[[i]])
    }
  } else {
    s$divisions <- tibble::as_tibble(s$divisions)
  }
  s$year <- d$seasonId
  s <- s[c(length(s), 1:length(s) - 1)]
  if (old) {
    sched <- rep(list(NA), nrow(s$match_sched))
    for (i in seq(nrow(s$match_sched))) {
      sched[[i]] <- tibble::tibble(
        week = unlist(s$match_sched[i, ]),
        period = substr(names(unlist(s$match_sched[i, ])), 1, 2)
      )
    }
    s$match_sched <- sched
    tibble::as_tibble(s)
  } else {
    s$match_sched <- tibble::tibble(
      week = unlist(s$match_sched),
      period = substr(names(unlist(s$match_sched)), 1, 2)
    )
    return(s)
  }
}

#' League scoring settings
#'
#' The scoring system used and points awarded for various actions.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of scoring settings.
#' @examples
#' score_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble tibble
#' @export
score_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$scoringSettings
  if (old) {
    for (i in seq_along(s$scoringItems)) {
      s$scoringItems[[i]]$pointsOverrides <- s$scoringItems[[i]]$pointsOverrides$`16`
      s$scoringItems[[i]] <- s$scoringItems[[i]][, c(6, 4, 5)]
      names(s$scoringItems[[i]]) <- c("stat", "points", "overrides")
      s$scoringItems[[i]] <- tibble::as_tibble(s$scoringItems[[i]])
    }
  } else {
    s$scoringItems$pointsOverrides <- s$scoringItems$pointsOverrides$`16`
    s$scoringItems <- s$scoringItems[, c(6, 4, 5)]
    names(s$scoringItems) <- c("stat", "points", "overrides")
    s$scoringItems <- tibble::as_tibble(s$scoringItems)
  }
  x <- list(
    score_type = s$scoringType,
    rank_type = s$playerRankType,
    home_bonus = s$homeTeamBonus,
    playoff_bonus = s$playoffHomeTeamBonus,
    playoff_tie = s$playoffMatchupTieRule,
    scoring = s$scoringItems
  )
  x$year <- d$seasonId
  x <- x[c(length(x), 1:length(x) - 1)]
  if (old) {
    tibble::as_tibble(x)
  } else {
    return(x)
  }
}

#' League trade settings
#'
#' The time each trade can stand, votes needed to veto, and season deadline.
#'
#' @inheritParams draft_picks
#' @return A list or tibble of trade settings.
#' @examples
#' trade_settings(252353, old = TRUE)
#' @importFrom tibble as_tibble tibble
#' @export
trade_settings <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, old, view = "mSettings", ...)
  s <- d$settings$tradeSettings
  s$deadlineDate <- ffl_date(s$deadlineDate)
  s$year <- d$seasonId
  s <- s[c(length(s), 1:length(s) - 1)]
  if (old) {
    names(s)[-1] <- c("out_universe", "max", "hours", "veto", "deadline")
    tibble::as_tibble(s)
  } else {
    names(s)[-1] <- c("out_universe", "deadline", "max", "hours", "veto")
    return(s)
  }
}
