#' Fantasy weekly scores
#'
#' Weekly scores differ from [match_scores[]] in that matchups (especially
#' during the playoffs) often last multiple weeks.
#'
#' @inheritParams draft_picks
#' @return A tibble of scores by week.
#' @examples
#' week_scores(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
week_scores <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = c("mMatchup", "mTeam"), ...)
  if (old) {
    out <- rep(list(NA), length(data$schedule))
    for (i in seq_along(out)) {
      out[[i]] <- parse_week(
        s = data$schedule[[i]],
        y = data$seasonId[i],
        t = data.frame(
          stringsAsFactors = FALSE,
          team = data$teams[[i]]$id,
          abbrev = factor(
            x = data$teams[[i]]$abbrev,
            levels = data$teams[[i]]$abbrev
          )
        )
      )
    }
  } else {
    out <- parse_week(
      s = data$schedule,
      y = data$seasonId,
      t = data.frame(
        stringsAsFactors = FALSE,
        team = data$teams$id,
        abbrev = factor(
          x = data$teams$abbrev,
          levels = data$teams$abbrev
        )
      )
    )
  }
  return(out)
}

parse_week <- function(s, y = NULL, t = NULL) {
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
      out[[i]] <- data.frame(
        year = rep(y, n),
        match = seq(nrow(x))[z],
        week = rep(as.numeric(wks[i]), n),
        team = x$team[z],
        abbrev = team_abbrev(x$team[z], teams = t),
        home = rep(as.logical(k - 1), n),
        score = x[[wks[i]]][z]
      )
    }
    top[[k]] <- tibble::as_tibble(do.call("rbind", out))
  }

  x <- do.call("rbind", top)
  x <- x[order(x$match, !x$home), ]
  x$power = NA_integer_
  for (w in unique(x$week)) {
    y <- x$score[x$week == w]
    x$power[x$week == w] <- match(y, sort(y)) - 1
  }
  return(x)
}
