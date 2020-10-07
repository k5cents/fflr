#' League standings
#'
#' Return the current and projected standings, win streak, total wins, losses,
#' and points scored for and against each team.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league members.
#' @examples
#' score_summary(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
score_summary <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, view = "mTeam", ...)
  member_cols <- c("user", "owners", "lm")
  if (old) {
    out <- rep(list(NA), length(data$teams))
    for (i in seq_along(data$members)) {
      out[[i]] <- parse_ranks(
        teams = data$teams[[i]],
        y = data$seasonId[i],
        w = data$scoringPeriodId[i]
      )
    }
  } else {
    out <- parse_ranks(
      teams = data$teams,
      y = data$seasonId,
      w = data$scoringPeriodId
    )
  }
  return(out)
}

parse_ranks <- function(teams, y = NULL, w = NULL) {
  record <- teams$record$overall[, c(1, 2, 8:9, 3:7)]
  record_nms <- c("back", "against", "points", "streak", "type")
  names(record)[c(1, 6:9)] <- record_nms
  x <- tibble::tibble(
    year = y,
    week = w,
    team = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    draft = teams$draftDayProjectedRank,
    current = teams$currentProjectedRank,
    seed = teams$playoffSeed,
    final = teams$rankCalculatedFinal,
    record
  )
  x$percentage <- round(x$percentage, 3)
  for (j in seq_along(x)[-11]) {
    if (!is.numeric(x[[j]]) | all(is.na(x[[j]]))) {
      next()
    } else if(all(x[[j]] == 0)) {
      x[[j]] <- NA_integer_
    }
  }
  x$streak[x$type == "LOSS"] <- -1 * x$streak[x$type == "LOSS"]
  x$type <- NULL
  return(x)
}
