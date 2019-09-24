#' @title Find Optimal Roster
#' @description Take a team's tibble (via [team_roster()] and return the roster
#'   lineup which would have scored the maximum number of points that week.
#' @param roster A roster tibble, as returned by [team_roster()].
#' @return A tibble with the best roster, excluding bench.
#' @examples
#' data <- ffl_get(lid = 252353, view = "roster", scoringPeriodId = 2)
#' team <- data$teams[[5]]
#' roster <- team_roster(team)
#' best_roster(roster)
#' @importFrom dplyr filter
#' @export
best_roster <- function(roster) {
  y <- dplyr::filter(roster, slot != "BE")
  y[, 5:12] <- NA
  qb <- sort(roster$score[roster$pos == "QB"], decreasing = T)[1]
  y[which(y$slot == "QB"), 5:12] <- roster[which(roster$score == qb), 5:12]
  rb <- sort(roster$score[roster$pos == "RB"], decreasing = T)[1:2]
  y[which(y$slot == "RB"), 5:12] <- roster[which(roster$score %in% rb), 5:12]
  wr <- sort(roster$score[roster$pos == "WR"], decreasing = T)[1:2]
  y[which(y$slot == "WR"), 5:12] <- roster[which(roster$score %in% wr), 5:12]
  te <- sort(roster$score[roster$pos == "TE"], decreasing = T)[1]
  y[which(y$slot == "TE"), 5:12] <- roster[which(roster$score == te), 5:12]
  ds <- sort(roster$score[roster$pos == "DS"], decreasing = T)[1]
  y[which(y$slot == "DS"), 5:12] <- roster[which(roster$score == ds), 5:12]
  ki <- sort(roster$score[roster$pos == "KI"], decreasing = T)[1]
  y[which(y$slot == "KI"), 5:12] <- roster[which(roster$score == ki), 5:12]
  fx <- sort(roster$score[roster$pos %in% c("RB", "WR", "TE")], decreasing = T)
  fx <- fx[which(!(fx %in% c(rb, wr, te)))][1]
  y[which(y$slot == "FX"), 5:12] <- roster[which(roster$score %in% fx), 5:12]
  return(y)
}
