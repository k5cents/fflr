#' NFL team performance against positions
#'
#' The average opposition team point differential by position.
#'
#' @param lid ESPN League ID, defaulted because all return the same data.
#' @return A tibble of performance stats.
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
  names(oprk) <- names(p[[1]]$ratingsByOpponent)
  for (i in names(oprk)) {
    for (s in 1:6) {
      oprk[[i]]$pro <- i
      oprk[[i]]$rank[s] <- abs(p[[s]]$ratingsByOpponent[i][[1]]$rank - 33L)
      oprk[[i]]$avg[s] <- p[[s]]$ratingsByOpponent[i][[1]]$average
    }
  }
  oprk <- do.call("rbind", lapply(oprk, as.data.frame))
  oprk$pro <- team_abbrev(oprk$pro, fflr::nfl_teams)
  tibble::as_tibble(oprk)
}
