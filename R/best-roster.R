#' Fantasy optimal roster
#'
#' The highest scoring 9 man roster using standard roster slots.
#'
#' @param roster A roster tibble from [team_roster()].
#' @return A tibble of players on a roster.
#' @examples
#' best_roster(team_roster(lid = 252353)[[7]])
#' @export
best_roster <- function(roster) {
  if (all(is.na(roster$score))) {
    stop("The score column is empty, the period is likely the future")
  }
  n <- ncol(roster)
  y <- roster[roster$slot != "BE", ]
  qb <- sort(roster$score[roster$pos == "QB"], decreasing = T)[1]
  y[which(y$slot == "QB"), 5:n] <- roster[match(qb, roster$score), 5:n]
  rb <- sort(roster$score[roster$pos == "RB"], decreasing = T)[1:2]
  y[which(y$slot == "RB"), 5:n] <- roster[match(rb, roster$score), 5:n]
  wr <- sort(roster$score[roster$pos == "WR"], decreasing = T)[1:2]
  y[which(y$slot == "WR"), 5:n] <- roster[match(wr, roster$score), 5:n]
  te <- sort(roster$score[roster$pos == "TE"], decreasing = T)[1]
  y[which(y$slot == "TE"), 5:n] <- roster[match(te, roster$score), 5:n]
  ds <- sort(roster$score[roster$pos == "DS"], decreasing = T)[1]
  y[which(y$slot == "DS"), 5:n] <- roster[match(ds, roster$score), 5:n]
  ki <- sort(roster$score[roster$pos == "KI"], decreasing = T)[1]
  ki <- which(roster$score == ki & roster$pos == "KI")
  y[which(y$slot == "KI"), 5:n] <- roster[ki, 5:n]
  fx <- sort(roster$score[roster$pos %in% c("RB", "WR", "TE")], decreasing = T)
  fx <- fx[which(!(fx %in% c(rb, wr, te)))][1]
  y[which(y$slot == "FX"), 5:n] <- roster[match(fx, roster$score), 5:n]
  return(y)
}

#' Sum a roster score
#'
#' For a given roster tibble, sum the starting scores.
#'
#' @param roster A roster tibble from [team_roster()] or [best_roster()].
#' @return A score as double.
#' @examples
#' # asses performance compared to optimal
#' start <- team_roster(lid = 252353, week = 1)[[5]]
#' best <- best_roster(start_roster)
#' roster_score(start_roster)/roster_score(best_roster)
#' @export
roster_score <- function(roster) {
  sum(roster$score[roster$slot != "BE"], na.rm = TRUE)
}
