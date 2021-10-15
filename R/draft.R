#' Fantasy draft history
#'
#' Return the sequential result of a fantasy draft pick, whether snake or
#' salary cap format.
#'
#' @inheritParams ffl_api
#' @return A data frame(s) of draft picks.
#' @examples
#' draft_recap(leagueId = "42654852")
#' @family league functions
#' @export
draft_recap <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    view = c("mDraftDetail", "mTeam"),
    leagueHistory = leagueHistory,
    ...
  )
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$seasonId))
    for (i in seq_along(out)) {
      tm <- out_team(dat$teams[[i]], trim = TRUE)
      out[[i]] <- out_draft(
        picks = dat$draftDetail$picks[[i]],
        tm = out_team(dat$teams[[i]]),
        y = dat$seasonId[i]
      )
    }
    return(out)
  } else {
    tm <- out_team(dat$teams, trim = TRUE)
    out_draft(dat$draftDetail$picks, tm, dat$seasonId)
  }
}

out_draft <- function(picks, tm, y) {
  x <- as_tibble(cbind(seasonId = y, picks))
  x$bidAmount[x$bidAmount == 0] <- NA_integer_
  x <- col_abbrev(x, "lineupSlotId", slot_abbrev(x$lineupSlotId))
  x <- change_names(x, "id", "pickId")
  x$nominatingTeamId <- team_abbrev(x$nominatingTeamId, teams = tm)
  x$abbrev <- team_abbrev(x$teamId, teams = tm)
  x <- move_col(x, "abbrev", match("teamId", names(x)) + 1)
  as_tibble(x)
}

