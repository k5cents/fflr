#' Fantasy matchup scores
#'
#' The score of each team in a matchup or scoring period and the match outcome.
#'
#' `expectedWins` are calculated by comparing a team score against all _other_
#' scores for a given matchup period. This statistic expresses how a team would
#' fair if the schedule was random The highest scoring team is thus expected to
#' earn 1 win and the lowest scoring team would expect to win 0 matchups.
#'
#' @inheritParams ffl_api
#' @param useMatchup logical; Whether scoring should be summarized by
#'   `matchupPeriodId` (default) or `scoringPeriodId`. The later always relates
#'   to a single week of the NFL season, while fantasy matchups might span
#'   several scoring periods, especially in the playoffs.
#' @return A tidy data frame of scores by team and matchup/scoring period.
#' @examples
#' tidy_scores(leagueId = "42654852", useMatchup = FALSE)
#' @family scoring functions
#' @export
tidy_scores <- function(leagueId = ffl_id(), leagueHistory = FALSE,
                        useMatchup = TRUE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mMatchup", "mTeam"),
    leagueHistory = leagueHistory,
    ...
  )
  parse_fun <- ifelse(useMatchup, parse_match, parse_scores)
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- parse_fun(
        s = dat$schedule[[i]],
        y = dat$seasonId[i],
        t = out_team(dat$teams[[i]], trim = TRUE)
      )
    }
  } else {
    out <- parse_fun(
      s = dat$schedule,
      y = dat$seasonId,
      t = out_team(dat$teams, trim = TRUE)
    )
  }
  return(out)
}

parse_match <- function(s, y = NULL, t = NULL) {
  n <- length(s$winner)
  n_opp <- nrow(t) - 1
  is_home <- c(rep(TRUE, n), rep(FALSE, n))
  winners <- rep(s$winner, 2)
  winners[winners == "UNDECIDED"] <- NA
  x <- data.frame(
    seasonId = y,
    matchupPeriodId = rep(s$matchupPeriodId, 2),
    matchupId = rep(s$id, 2),
    teamId = c(s$home$teamId, s$away$teamId),
    abbrev = team_abbrev(c(s$home$teamId, s$away$teamId), teams = t),
    isHome = is_home,
    totalPoints = c(s$home$totalPoints, s$away$totalPoints),
    isWinner = (rep(s$winner, 2) == "HOME") == is_home
  )
  x <- x[order(x$matchupId), ]
  x <- x[!is.na(x$matchupPeriodId), ]
  x$expectedWins <- NA_integer_
  for (w in unique(x$matchupPeriodId)) {
    y <- x$totalPoints[x$matchupPeriodId == w]
    x$expectedWins[x$matchupPeriodId == w] <- (match(y, sort(y)) - 1) / n_opp
  }
  as_tibble(x)
}

parse_scores <- function(s, y = NULL, t = NULL) {
  n_opp <- nrow(t) - 1
  top <- rep(list(NA), 2)
  for (k in 2:1) {
    x <- s[[k]]$pointsByScoringPeriod
    out <- rep(list(NA), length(x))
    wks <- names(x)
    names(out) <- wks
    x$team <- s[[k]]$teamId
    for (i in seq_along(out)) {
      z <- which(!is.na(x[[wks[i]]]))
      n <- length(z)
      is_home <- rep(as.logical(k - 1), n)
      out[[i]] <- data.frame(
        seasonId = rep(y, n),
        scoringPeriodId = rep(as.numeric(wks[i]), n),
        matchupId = seq(nrow(x))[z],
        teamId = x$team[z],
        abbrev = team_abbrev(x$team[z], teams = t),
        isHome = is_home,
        points = x[[wks[i]]][z]
      )
    }
    top[[k]] <- bind_df(out)
  }

  x <- bind_df(top)
  x <- x[order(x$matchupId, !x$isHome), ]
  x$expectedWins <- NA_integer_
  for (w in unique(x$scoringPeriodId)) {
    y <- x$points[x$scoringPeriodId == w]
    x$expectedWins[x$scoringPeriodId == w] <- (match(y, sort(y)) - 1) / n_opp
  }
  as_tibble(x)
}
