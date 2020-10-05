#' Optimal fantasy roster
#'
#' The highest scoring 9 man roster using standard roster slots. In the future
#' this function may be adapted to take roster slots from [roster_settings()].
#'
#' @param roster A roster tibble from [team_roster()].
#' @return A tibble of players on a roster.
#' @examples
#' best_roster(team_roster(lid = 252353, week = 1)[[7]])
#' @export
best_roster <- function(roster) {
  if (sum(is.na(roster$score)) > 3) {
    use_proj <- TRUE
    roster$score <- roster$proj
    roster$proj <- NULL
  } else {
    use_proj <- FALSE
  }
  n <- ncol(roster)
  y <- roster[roster$slot != "BE" & roster$slot != "IR", ]
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
  ki <- sort(roster$score[roster$pos == "PK"], decreasing = T)[1]
  ki <- which(roster$score == ki & roster$pos == "PK")
  y[which(y$slot == "PK"), 5:n] <- roster[ki, 5:n]
  fx <- sort(roster$score[roster$pos %in% c("RB", "WR", "TE")], decreasing = T)
  fx <- fx[which(!(fx %in% c(rb, wr, te)))][1]
  y[which(y$slot == "FX"), 5:n] <- roster[match(fx, roster$score), 5:n]
  return(y)
}

#' Starting roster
#'
#' The starting 9 man roster using standard roster slots. In the future this
#' function may be adapted to take roster slots from [roster_settings()].
#'
#' @param roster A roster tibble from [team_roster()].
#' @return A tibble of starters on a roster.
#' @examples
#' start_roster(team_roster(lid = 252353, week = 1)[[7]])
#' @export
start_roster <- function(roster) {
  roster[roster$slot != "BE" & roster$slot != "IR", ]
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
#' best <- best_roster(start)
#' roster_score(start)/roster_score(best)
#' @export
roster_score <- function(roster) {
  sum(roster$score[roster$slot != "BE" & roster$slot != "IR"], na.rm = TRUE)
}
