#' NFL team performance against positions
#'
#' The average opposition team point differential by position.
#'
#' @inheritParams ffl_api
#' @return A data frame of team performance against position.
#' @examples
#' opponent_ranks()
#' @export
opponent_ranks <- function(leagueId = ffl_id()) {
  if (is.null(leagueId)) leagueId <- "42654852"
  dat <- ffl_api(leagueId, view = "kona_player_info")
  p <- dat$positionAgainstOpponent$positionalRatings
  oprk <- rep(
    times = 32,
    x = list(list(
      position = factor(
        x = names(p),
        levels = c("1",  "2",  "3",  "4",  "5",  "16"),
        labels = c("QB", "RB", "WR", "TE", "KI", "DS")
      ),
      opponentProTeam = NA_character_,
      rank = rep(NA_integer_, 6),
      average = rep(NA_real_, 6)
    ))
  )
  names(oprk) <- names(p[[1]]$ratingsByOpponent)
  for (i in names(oprk)) {
    for (s in 1:6) {
      oprk[[i]]$opponentProTeam <- i
      oprk[[i]]$rank[s] <- p[[s]]$ratingsByOpponent[i][[1]]$rank
      oprk[[i]]$average[s] <- p[[s]]$ratingsByOpponent[i][[1]]$average
    }
  }
  oprk <- do.call("rbind", lapply(oprk, as.data.frame))
  oprk$opponentProTeam <- pro_abbrev(oprk$opponentProTeam)
  as_tibble(oprk)
}
