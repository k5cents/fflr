#' Fantasy team roster
#'
#' List all available players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @param type Numeric data returned, either points average or rank.
#' @return A tibble (or list) of players on a roster.
#' @examples
#' opponent_rank()
#' @importFrom tibble as_tibble
#' @export
opponent_rank <- function(lid = getOption("lid"), type = c("avg", "rank")) {
  if (is.null(lid)) lid <- 252353
  data <- ffl_api(lid, view = "kona_player_info")
  p <- data$positionAgainstOpponent$positionalRatings
  oprk <- tibble::tibble(
    team = nfl_teams$team,
    name = nfl_teams$nfl,
    qb = NA, rb = NA, wr = NA,
    te = NA, ki = NA, ds = NA
  )
  type <- match.arg(type, c("avg", "rank"))
  for (s in 1:6) {
    for (t in 1:32) {
      oprk[[s + 2]][t] <- p[[s]][[2]][[t]][[match(type, c("avg", "rank"))]]
    }
  }
  return(oprk)
}
