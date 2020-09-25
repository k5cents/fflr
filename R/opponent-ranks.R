#' Fantasy team roster
#'
#' List all available players.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @param type Numeric data returned, either points average or rank.
#' @return A tibble (or list) of players on a roster.
#' @examples
#' opponent_ranks()
#' @importFrom tibble as_tibble
#' @export
opponent_ranks <- function(lid = getOption("lid")) {
  if (is.null(lid)) lid <- 252353
  data <- ffl_api(lid, view = "kona_player_info")
  p <- data$positionAgainstOpponent$positionalRatings
  oprk <- rep(
    times = 32,
    x = list(list(
      pro = NA_character_,
      pos = factor(
        x = names(p),
        levels = c("1",  "2",  "3",  "4",  "5",  "16"),
        labels = c("QB", "RB", "WR", "TE", "KI", "DS")
      ),
      rank = rep(NA_integer_, 6),
      avg = rep(NA_real_, 6)
    ))
  )
  for (i in seq_along(oprk)) {
    for (s in 1:6) {
      oprk[[i]]$pro <- nfl_teams$nfl[i]
      oprk[[i]]$rank[s] <- p[[s]]$ratingsByOpponent[i][[1]]$rank
      oprk[[i]]$avg[s] <- p[[s]]$ratingsByOpponent[i][[1]]$average
    }
  }
  oprk <- do.call("rbind", lapply(oprk, as.data.frame))
  tibble::as_tibble(oprk)
}



