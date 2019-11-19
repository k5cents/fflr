#' @title Find Optimal Roster
#' @description Take a team's tibble (via [form_roster()] and return the roster
#'   lineup which would have scored the maximum number of points that week.
#' @param roster A roster tibble, as returned by [form_roster()].
#' @return A tibble with the best roster, excluding bench.
#' @examples
#' data <- fantasy_roster(lid = 252353, scoringPeriodId = 9)
#' team <- data$teams[[5]]
#' roster <- form_roster(team)
#' best_roster(roster)
#' @importFrom dplyr filter
#' @importFrom rlang .data
#' @export
best_roster <- function(roster) {
  if (all(is.na(roster$score))) {
    stop("The score column is empty, the period is likely the future")
  }
  n <- ncol(roster)
  y <- dplyr::filter(roster, .data$slot != "BE")
  y[, 5:ncol(y)] <- NA
  qb <- sort(roster$score[roster$pos == "QB"], decreasing = T)[1]
  y[which(y$slot == "QB"), 5:n] <- roster[which(roster$score == qb), 5:n]
  rb <- sort(roster$score[roster$pos == "RB"], decreasing = T)[1:2]
  y[which(y$slot == "RB"), 5:n] <- roster[which(roster$score %in% rb), 5:n]
  wr <- sort(roster$score[roster$pos == "WR"], decreasing = T)[1:2]
  y[which(y$slot == "WR"), 5:n] <- roster[which(roster$score %in% wr), 5:n]
  te <- sort(roster$score[roster$pos == "TE"], decreasing = T)[1]
  y[which(y$slot == "TE"), 5:n] <- roster[which(roster$score == te), 5:n]
  ds <- sort(roster$score[roster$pos == "DS"], decreasing = T)[1]
  y[which(y$slot == "DS"), 5:n] <- roster[which(roster$score == ds), 5:n]
  ki <- sort(roster$score[roster$pos == "KI"], decreasing = T)[1]
  y[which(y$slot == "KI"), 5:n] <- roster[which(roster$score == ki), 5:n]
  fx <- sort(roster$score[roster$pos %in% c("RB", "WR", "TE")], decreasing = T)
  fx <- fx[which(!(fx %in% c(rb, wr, te)))][1]
  y[which(y$slot == "FX"), 5:n] <- roster[which(roster$score %in% fx), 5:n]
  return(y)
}

#' @title Sum Roster Score
#' @description For a given roster tibble, sum the starting scores.
#' @param roster A roster tibble, as returned by [form_roster()] or
#'   [best_roster()].
#' @return A double.
#' @examples
#' data <- fantasy_roster(lid = 252353, scoringPeriodId = 2)
#' start_roster <- form_roster(data$teams[[5]])
#' best_roster <- best_roster(start_roster)
#' start_score <- roster_score(start_roster)
#' best_score <- roster_score(best_roster)
#' start_score/best_score
#' @export
roster_score <- function(roster) {
  sum(roster$score[roster$slot != "BE"], na.rm = TRUE)
}
