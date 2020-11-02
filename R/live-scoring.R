#' Live matchup scoreboard
#'
#' The current and projected score for each ongoing match.
#'
#' @param lid ESPN League ID, defaults to `getOption("lid")`. Use
#'   `options(lid = <League ID>)` to set your league ID; put that line in your
#'   `.Rprofile` file to set the option at start up.
#' @param yet If `TRUE`, [pro_schedule()] and the "mRoster" view are called to
#'   determine how many starting players have _yet_ started playing.
#' @return A tibble of scores.
#' @examples
#' live_scoring(252353)
#' @importFrom tibble tibble
#' @export
live_scoring <- function(lid = getOption("lid"), yet = FALSE) {
  v <- "mScoreboard"
  if (yet) {
    v <- list(v, "mRoster")
  }
  d <- ffl_api(lid, view = v)
  s <- tibble::tibble(
    week = d$status$currentMatchupPeriod,
    match = c(d$schedule$id, d$schedule$id),
    team = c(d$schedule$home$teamId, d$schedule$away$teamId),
    score = c(d$schedule$home$totalPointsLive, d$schedule$away$totalPointsLive),
    proj = c(
      d$schedule$home$totalProjectedPointsLive,
      d$schedule$away$totalProjectedPointsLive
    )
  )
  s <- s[!is.na(s$proj), ]
  s <- s[order(s$match), ]
  t <- parse_teams(d$teams)
  s$team <- team_abbrev(s$team, teams = t)
  x <- split(s, s$match)
  for (i in seq_along(x)) {
    x[[i]]$line <- x[[i]]$proj - (sum(x[[i]]$proj) - x[[i]]$proj)
  }
  s <- do.call("rbind", x)
  if (yet) {
    r <- do.call("rbind", lapply(d$teams$roster$entries, parse_roster))
    r <- start_roster(r)
    r <- merge(r, pro_schedule())
    r$team <- team_abbrev(r$team, teams = t)
    y <- by(
      data = r,
      INDICES = r$team,
      FUN = function(data) sum(data$future, na.rm = TRUE)
    )
    y <- data.frame(
      team = names(y),
      yet = as.vector(y)
    )
    s <- ffl_merge(y, s)[, c(3:4, 1:2, 5:7)]
    s <- s[order(s$match), ]
  }
  return(s)
}


