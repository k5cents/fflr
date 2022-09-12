#' Live matchup scoreboard
#'
#' The current and projected score for each ongoing match.
#'
#' @inheritParams ffl_api
#' @param yetToPlay If `TRUE`, [pro_schedule()] and the "mRoster" view are
#'   called to determine how many starting players have _yet_ started playing.
#' @return A data frame of scores by period.
#' @examples
#' live_scoring(leagueId = "42654852", yetToPlay = FALSE)
#' @importFrom tibble tibble
#' @family scoring functions
#' @export
live_scoring <- function(leagueId = ffl_id(), yetToPlay = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mScoreboard", "mRoster"),
    ...
  )
  if (is_predraft(dat)) {
    return(data.frame())
  }
  s <- tibble::tibble(
    currentMatchupPeriod = dat$status$currentMatchupPeriod,
    matchupId = c(
      dat$schedule$id,
      dat$schedule$id
    ),
    teamId = c(
      dat$schedule$home$teamId,
      dat$schedule$away$teamId
    ),
    totalPointsLive = c(
      dat$schedule$home$totalPointsLive,
      dat$schedule$away$totalPointsLive
      ),
    totalProjectedPointsLive = c(
      dat$schedule$home$totalProjectedPointsLive,
      dat$schedule$away$totalProjectedPointsLive
    )
  )
  s <- s[!is.na(s$totalProjectedPointsLive), ]
  s <- s[order(s$matchupId), ]
  tm <- out_team(dat$teams, trim = TRUE)
  s$abbrev <- team_abbrev(s$teamId, teams = tm)
  s <- move_col(s, "abbrev", 4)
  if (yetToPlay) {
    r <- do.call(
      "rbind",
      lapply(
        X = seq_along(dat$teams$roster$entries),
        FUN = function(i) {
          out_roster(
            entry = dat$teams$roster$entries[[i]],
            tid = dat$teams$id[i],
            wk = dat$scoringPeriodId,
            yr = dat$seasonId,
            tm = tm
          )
        }
      )
    )
    r <- start_roster(r)
    r <- merge(r, pro_schedule())
    r$team <- team_abbrev(r$team, teams = tm)
    y <- by(
      data = r,
      INDICES = r$team,
      FUN = function(data) sum(data$date > Sys.time(), na.rm = TRUE)
    )
    y <- data.frame(
      stringsAsFactors = FALSE,
      team = names(y),
      toPlay = as.vector(y)
    )
    s <- ffl_merge(y, s)
    s <- s[order(s$matchupId), ]
  }
  return(s)
}
