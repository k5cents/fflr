#' Fantasy draft history
#'
#' Return the sequential result of a fantasy draft pick, whether snake or
#' salary cap format.
#'
#' @inheritParams ffl_api
#' @return A data frame(s) of draft picks.
#' @examples
#' draft_recap(leagueId = "42654852")
#' draft_recap(leagueId = "252353", leagueHistory = TRUE)
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
      tm <- data.frame(
        stringsAsFactors = FALSE,
        id = dat$teams[[i]]$id,
        abbrev = factor(
          x = dat$teams[[i]]$abbrev,
          levels = dat$teams[[i]]$abbrev
        )
      )
      x <- dat$draftDetail$picks[[i]]
      x$autoDraftTypeId <- as.logical(x$autoDraftTypeId)
      x$nominatingTeamId <- team_abbrev(x$nominatingTeamId, teams = tm)
      x$teamId <- team_abbrev(x$teamId, teams = tm)
      x$seasonId <- dat$seasonId[i]
      x <- x[c(length(x), seq(x) - 1)]
      x$bidAmount[x$bidAmount == 0] <- NA_integer_
      out[[i]] <- as_tibble(x)
    }
    return(out)
  } else {
    x <- dat$draftDetail$picks
    x$autoDraftTypeId <- as.logical(x$autoDraftTypeId)
    tm <- data.frame(
      stringsAsFactors = FALSE,
      id = dat$teams$id,
      abbrev = factor(
        x = dat$teams$abbrev,
        levels = dat$teams$abbrev
      )
    )
    x <- dat$draftDetail$picks
    x$autoDraftTypeId <- as.logical(x$autoDraftTypeId)
    x$nominatingTeamId <- team_abbrev(x$nominatingTeamId, teams = tm)
    x$teamId <- team_abbrev(x$teamId, teams = tm)
    x$seasonId <- dat$seasonId
    x <- x[c(length(x), seq(x) - 1)]
    x$bidAmount[x$bidAmount == 0] <- NA_integer_
    as_tibble(x)
  }
}
