#' Live matchup scoreboard
#'
#' The current and projected score for each ongoing match.
#'
#' @inheritParams ffl_api
#' @param yetToPlay If `TRUE`, [pro_schedule()] and the "mRoster" view are
#'   called to determine how many starting players have _yet_ to start playing.
#' @param bonusWin If `TRUE`, a logical column `bonusWin` will be added
#'   containing `TRUE` values for teams who are projected to score in the top
#'   half of points this week. This is a way to project the "bonus win" optional
#'   setting added in 2022.
#' @return A data frame of scores by period.
#' @examples
#' live_scoring(leagueId = "42654852", yetToPlay = FALSE)
#' @importFrom tibble tibble
#' @importFrom stats median
#' @family scoring functions
#' @export
live_scoring <- function(leagueId = ffl_id(), yetToPlay = FALSE,
                         bonusWin = FALSE, ...) {
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
  if (all(is.na(s$totalProjectedPointsLive))) {
    message("No live scoring available")
    return(data.frame())
  }
  s <- s[!is.na(s$totalProjectedPointsLive), ]
  s <- s[order(s$matchupId), ]
  tm <- out_team(dat$teams, trim = TRUE)
  s$abbrev <- team_abbrev(s$teamId, teams = tm)
  s <- move_col(s, "abbrev", 4)
  if (bonusWin) {
    middle_point <- median(s$totalProjectedPointsLive)
    s$bonusWin <- s$totalProjectedPointsLive > middle_point
  }
  if (yetToPlay) {
    pro <- tryCatch(
      expr = pro_schedule(),
      error = function(e) {
        return(NULL)
      }
    )
    if (is.null(pro)) {
      message("No pro schedule available to compare start times")
      return(s)
    }
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
      abbrev = names(y),
      toPlay = as.vector(y)
    )
    s <- ffl_merge(y, s)
    s <- s[order(s$matchupId), ]
  }
  return(s)
}
