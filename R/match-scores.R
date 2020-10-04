#' Fantasy matchup scores
#'
#' The score of each team in a matchup period, the match outcome, and the number
#' of league teams outscored (power wins).
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of draft picks.
#' @examples
#' match_scores(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
match_scores <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = c("mMatchup", "mTeam"), ...)
  if (old) {
    out <- rep(list(NA), length(data$schedule))
    for (i in seq_along(out)) {
      t <- data.frame(
        team = data$teams[[i]]$id,
        abbrev = factor(data$teams[[i]]$abbrev, levels = data$teams[[i]]$abbrev)
      )
      out[[i]] <- parse_matchup(
        s = data$schedule[[i]],
        y = data$seasonId[i],
        t = t
      )
    }
  } else {
    t <- data.frame(
      team = data$teams$id,
      abbrev = factor(data$teams$abbrev, levels = data$teams$abbrev)
    )
    out <- parse_matchup(
      s = data$schedule,
      y = data$seasonId,
      t = t
    )
  }
  return(out)
}

parse_matchup <- function(s, y = NULL, t = NULL) {
  n <- length(s$winner)
  is_home <- c(rep(TRUE, n), rep(FALSE, n))
  winners <- rep(s$winner, 2)
  winners[winners == "UNDECIDED"] <- NA
  x <- tibble::tibble(
    year = y,
    match = rep(s$id, 2),
    week = factor(rep(s$matchupPeriodId, 2), levels = 1:16),
    team = c(s$home$teamId, s$away$teamId),
    abbrev = team_abbrev(c(s$home$teamId, s$away$teamId), teams = t),
    home = is_home,
    score = c(s$home$totalPoints, s$away$totalPoints),
    winner = (rep(s$winner, 2) == "HOME") == is_home
  )
  x <- x[order(x$match), ]
  x$score[x$score == 0] <- NA
  x$power = NA_integer_
  for (w in unique(x$week)) {
    y <- x$score[x$week == w]
    x$power[x$week == w] <- match(y, sort(y)) - 1
  }
  return(x[!is.na(x$score), ])
}
