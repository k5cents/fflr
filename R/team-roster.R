#' Fantasy team roster
#'
#' The players on a team roster with position, injury status, and playing stats.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of players on a roster.
#' @examples
#' team_roster(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
team_roster <- function(lid, old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mRoster", ...)
  if (old) {
    out <- rep(list(NA), length(data$teams))
    for (y in seq_along(out)) {
      out[[y]] <- lapply(data$teams[[y]]$roster$entries, parse_roster)
    }
  } else {
    out <- lapply(data$teams$roster$entries, parse_roster)
  }
  return(out)
}

#' Return list data from API JSON
#' @inheritParams draft_picks
#' @param view The API "view" for data to be returned.
#' @importFrom jsonlite fromJSON
ffl_api <- function(lid = NULL, old = FALSE, view = NULL, ...) {
  a <- "https://fantasy.espn.com/apis/v3/games/ffl/"
  b <- if (old) {
    "leagueHistory/"
  } else {
    sprintf("seasons/%s/segments/0/leagues/", format(Sys.Date(), "%Y"))
  }
  x <- list(view = view, ...)
  names(x)[names(x) == "week"] <- "scoringPeriodId"
  c <- paste(paste(names(x), x, sep = "="), collapse = "&")
  data <- jsonlite::fromJSON(paste0(a, b, lid, "?", c))
  return(data)
}

parse_roster <- function(entry) {
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
  } else {
    injury_status <- abbreviate(entry$injuryStatus, minlength = 1)
  }
  x <- tibble::tibble(
    year  = year_int,
    week  = week_int,
    team = entry$playerPoolEntry$onTeamId,
    slot = factor(
      x = entry$lineupSlotId,
      levels = c("0",  "2",  "4",  "6",  "23", "16", "17", "20"),
      labels = c("QB", "RB", "WR", "TE", "FX", "DS", "KI", "BE")
    ),
    id = player$id,
    first = player$firstName,
    last = player$lastName,
    pro  = nfl_teams$nfl[match(player$proTeamId, nfl_teams$team)],
    pos = factor(
      x = player$defaultPositionId,
      levels = c("1",  "2",  "3",  "4",  "5",  "16"),
      labels = c("QB", "RB", "WR", "TE", "KI", "DS")
    ),
    status = injury_status,
    proj  = proj_dbl,
    score = score_dbl,
    start = player$ownership$percentStarted/100,
    rost = player$ownership$percentOwned/100,
    change = round(player$ownership$percentChange, digits = 3)
  )
  return(x[order(x$slot), ])
}
