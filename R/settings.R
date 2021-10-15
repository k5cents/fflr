#' League information
#'
#' Basic information on a ESPN fantasy football league, like the name, size,
#' and season length.
#'
#' @inheritParams ffl_api
#' @return A data frame of league information by season.
#' @examples
#' league_info(leagueId = "42654852")
#' @family league settings functions
#' @export
league_info <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  out <- list(
    id = unique(dat$id),
    seasonId = dat$seasonId,
    name = unique(dat$settings$name),
    isPublic = dat$settings$isPublic,
    size = dat$settings$size,
    finalScoringPeriod = dat$status$finalScoringPeriod
  )
  as_tibble(out)
}

#' League size
#'
#' @inheritParams ffl_api
#' @return A data frame of league size by season.
#' @examples
#' league_size(leagueId = "42654852")
#' @family league settings functions
#' @export
league_size <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  out <- data.frame(
    seasonId = dat$seasonId,
    size =  dat$settings$size,
    stringsAsFactors = FALSE
  )
  as_tibble(out)
}

#' League name
#'
#' @inheritParams ffl_api
#' @return A character vector.
#' @examples
#' league_name(leagueId = "42654852")
#' @family league settings functions
#' @export
league_name <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    ...
  )
  unique(dat$settings$name)
}

#' League waiver settings
#'
#' The type, days, and details of a league waiver process.
#'
#' @inheritParams ffl_api
#' @return A data frame of waiver settings by season.
#' @examples
#' acquisition_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
acquisition_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE,
                                 ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    simplifyDataFrame = TRUE,
    simplifyVector = FALSE,
    ...
  )
  out <- dat$settings$acquisitionSettings[c(-5, -6)]
  if (isFALSE(leagueHistory)) {
    out$waiverProcessDays <- list(unlist(out$waiverProcessDays))
  }
  out$year <- dat$seasonId
  out <- out[c(length(out), seq(out) - 1)]
  as_tibble(out)
}

#' League draft settings
#'
#' The type, date, and pick order of a league draft.
#'
#' @inheritParams ffl_api
#' @return A data frame of league draft settings by season.
#' @examples
#' draft_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
draft_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    simplifyDataFrame = TRUE,
    simplifyVector = FALSE,
    ...
  )
  out <- dat$settings$draftSettings
  if (isFALSE(leagueHistory)) {
    out$pickOrder <- list(unlist(out$pickOrder))
  }
  out$availableDate <- ffl_date(out$availableDate)
  out$date <- ffl_date(out$date)
  out$auctionBudget[out$type == "SNAKE"] <- NA_character_
  out$seasonId <- dat$seasonId
  # TODO: improve dimensions to work for both leagueHistory
  if (isFALSE(leagueHistory)) {
    out <- out[c(length(out), seq(length(out) - 1))]
  } else {
    out <- out[, c(length(out), seq(length(out) - 1))]
  }
  as_tibble(out)
}

#' League finance settings
#'
#' The off-site fees assigned to various roster movies and transactions.
#'
#' @inheritParams ffl_api
#' @return A data frame of finance settings by season.
#' @examples
#' finance_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
finance_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    simplifyDataFrame = TRUE,
    simplifyVector = FALSE,
    ...
  )
  out <- dat$settings$financeSettings
  out$year <- dat$seasonId
  out <- out[c(length(out), seq(out) - 1)]
  as_tibble(out)
}

#' League roster settings
#'
#' The number of players and positions on a fantasy football roster.
#'
#' @inheritParams ffl_api
#' @return A data frame of league roster settings by season.
#' @examples
#' roster_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
roster_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  out_roster_set(dat, leagueHistory = leagueHistory)
}

out_roster_set <- function(dat, leagueHistory = FALSE) {
  slot_limit <- out_slot(dat, leagueHistory = leagueHistory)
  pos_limit <- out_pos(dat, leagueHistory = leagueHistory)
  out <- list(
    seasonId = dat$seasonId,
    isBenchUnlimited = dat$settings$rosterSettings$isBenchUnlimited,
    isUsingUndroppableList = dat$settings$rosterSettings$isUsingUndroppableList,
    lineupLocktimeType = dat$settings$rosterSettings$lineupLocktimeType,
    lineupSlotCounts = slot_limit,
    moveLimit = dat$settings$rosterSettings$moveLimit,
    positionLimits = pos_limit,
    rosterLocktimeType = dat$settings$rosterSettings$rosterLocktimeType
  )
  as_tibble(out)
}

out_slot <- function(l, leagueHistory) {
  s <- l$settings$rosterSettings$lineupSlotCounts
  if (leagueHistory) {
    out <- rep(list(NA), nrow(s))
    for (i in seq(nrow(s))) {
      out[[i]] <- data.frame(
        position = names(s),
        limit = unlist(s[i, ])
      )
    }
  } else {
    out <- list(
      data.frame(
        position = names(s),
        limit = unlist(unname(s))
      )
    )
  }
  return(out)
}

out_pos <- function(l, leagueHistory) {
  p <- l$settings$rosterSettings$positionLimits
  if (leagueHistory) {
    out <- rep(list(NA), nrow(p))
    for (i in seq(nrow(p))) {
      out[[i]] <- data.frame(
        position = names(p),
        limit = unlist(p[i, ])
      )
    }
  } else {
    out <- list(
      data.frame(
        position = names(p),
        limit = unlist(unname(p))
      )
    )
  }
  return(out)
}

#' League schedule settings
#'
#' The length of a fantasy season and the match periods for each week.
#'
#' @inheritParams ffl_api
#' @return A data frame of league schedule settings by season.
#' @examples
#' schedule_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
schedule_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  s <- dat$settings$scheduleSettings
  s$seasonId <- dat$seasonId
  s <- s[c(length(s), seq(s) - 1)]
  if (leagueHistory) {
    sched <- rep(list(NA), nrow(s$matchupPeriods))
    for (i in seq(nrow(s$matchupPeriods))) {
      sched[[i]] <- data.frame(
        matchupPeriod = unlist(s$matchupPeriods[i, ]),
        scoringPeriod = substr(names(unlist(s$matchupPeriods[i, ])), 1, 2)
      )

    }
    s$matchupPeriods <- sched
  } else {
    s$divisions <- list(s$divisions)
    s$matchupPeriods <- list(
      data.frame(
        matchupPeriod = unlist(s$matchupPeriods),
        scoringPeriod = substr(names(unlist(s$matchupPeriods)), 1, 2)
      )
    )
  }
  as_tibble(s)
}

#' League scoring settings
#'
#' The scoring system used and points awarded for various actions.
#'
#' @inheritParams ffl_api
#' @return A data frame of league scoring settings by season.
#' @examples
#' scoring_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
scoring_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  s <- dat$settings$scoringSettings
  x <- list(
    seasonId = dat$seasonId,
    scoringType = s$scoringType,
    playerRankType = s$playerRankType,
    homeTeamBonus = s$homeTeamBonus,
    playoffHomeTeamBonus = s$playoffHomeTeamBonus,
    playoffMatchupTieRule = s$playoffMatchupTieRule,
    scoringItems = ifelse(leagueHistory, s$scoringItems, list(s$scoringItems))
  )
  as_tibble(x)
}

#' League trade settings
#'
#' The time each trade can stand, votes needed to veto, and season deadline.
#'
#' @inheritParams ffl_api
#' @return A data frame of league trade settings by season.
#' @examples
#' trade_settings(leagueId = "42654852")
#' @family league settings functions
#' @export
trade_settings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = "mSettings",
    leagueHistory = leagueHistory,
    ...
  )
  s <- dat$settings$tradeSettings
  s$deadlineDate <- ffl_date(s$deadlineDate)
  s$seasonId <- dat$seasonId
  s <- s[c(length(s), seq(s) - 1)]
  as_tibble(s)
}
