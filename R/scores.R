#' Fantasy matchup scores
#'
#' The score of each team in a matchup period and the match outcome.
#'
#' `powerWins` are added by comparing a team score versus every other team
#' during that matchup period; the highest score would have won against all
#' teams and the lowest score would have zero wins.
#'
#' @inheritParams ffl_api
#' @return A tidy data frame of scores by team and matchup period.
#' @examples
#' tidy_scores(leagueId = "42654852")
#' tidy_scores(leagueId = "252353", leagueHistory = TRUE)
#' @export
tidy_scores <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mMatchup", "mTeam"),
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- parse_matchup(
        s = dat$schedule[[i]],
        y = dat$seasonId[i],
        t = out_team(dat$teams[[i]])
      )
    }
  } else {
    out <- parse_matchup(
      s = dat$schedule,
      y = dat$seasonId,
      t = out_team(dat$teams)
    )
  }
  return(out)
}

parse_matchup <- function(s, y = NULL, t = NULL) {
  n <- length(s$winner)
  is_home <- c(rep(TRUE, n), rep(FALSE, n))
  winners <- rep(s$winner, 2)
  winners[winners == "UNDECIDED"] <- NA
  x <- data.frame(
    seasonId = y,
    id = rep(s$id, 2),
    matchupPeriodId = factor(rep(s$matchupPeriodId, 2), levels = 1:16),
    teamId = c(s$home$teamId, s$away$teamId),
    abbrev = team_abbrev(c(s$home$teamId, s$away$teamId), teams = t),
    isHome = is_home,
    totalPoints = c(s$home$totalPoints, s$away$totalPoints),
    isWinner = (rep(s$winner, 2) == "HOME") == is_home
  )
  x <- x[order(x$id), ]
  x <- x[!is.na(x$matchupPeriodId), ]
  x$powerWins <- NA_integer_
  for (w in unique(x$matchupPeriodId)) {
    y <- x$totalPoints[x$matchupPeriodId == w]
    x$powerWins[x$matchupPeriodId == w] <- match(y, sort(y)) - 1
  }
  as_tibble(x)
}
