#' League standings
#'
#' Return the current and projected standings, win streak, total wins, losses,
#' and points scored for and against each team.
#'
#' @inheritParams ffl_api
#' @return A data frame of team standings.
#' @examples
#' league_standings(leagueId = "42654852")
#' @importFrom tibble tibble
#' @export
league_standings <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId,
    leagueHistory,
    view = c("mTeam", "mStandings", "mSettings"),
    ...
  )
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$teams))
    for (i in seq_along(dat$members)) {
      out[[i]] <- parse_ranks(
        teams = dat$teams[[i]],
        y = dat$seasonId[i],
        w = dat$scoringPeriodId[i]
      )
    }
  } else {
    out <- parse_ranks(
      teams = dat$teams,
      y = dat$seasonId,
      w = dat$scoringPeriodId
    )
  }
  return(out)
}

parse_ranks <- function(teams, y = NULL, w = NULL) {
  tibble::tibble(
    seasonId = y,
    scoringPeriodId = w,
    teamId = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    draftDayProjectedRank = teams$draftDayProjectedRank,
    currentProjectedRank = teams$currentProjectedRank,
    playoffSeed = teams$playoffSeed,
    rankCalculatedFinal = teams$rankCalculatedFinal,
    teams$record$overall,
    playoffPct = teams$currentSimulationResults$playoffPct,
    divisionWinPct = teams$currentSimulationResults$divisionWinPct
  )
}

#' League standing simulation
#'
#' The ESPN algorithm simulates the entire season according to the projection
#' and matchup schedule to calculate the probability of a team winning their
#' division and making the playoffs.
#'
#' @inheritParams ffl_api
#' @return A data frame of simulated team standings.
#' @examples
#' league_simulation(leagueId = "42654852")
#' @importFrom tibble tibble
#' @export
league_simulation <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId,
    leagueHistory,
    view = c("mTeam", "mStandings"),
    ...
  )
  if (leagueHistory) {
    out <- rep(list(NA), length(dat$teams))
    for (i in seq_along(dat$members)) {
      out[[i]] <- parse_sim(
        teams = dat$teams[[i]],
        y = dat$seasonId[i],
        w = dat$scoringPeriodId[i]
      )
    }
  } else {
    out <- parse_sim(
      teams = dat$teams,
      y = dat$seasonId,
      w = dat$settings$scheduleSettings$matchupPeriodCount
    )
  }
  return(out)
}

parse_sim <- function(teams, y = NULL, w = NULL) {
  tibble::tibble(
    seasonId = y,
    scoringPeriodId = w,
    teamId = teams$id,
    abbrev = factor(teams$abbrev, levels = teams$abbrev),
    draftDayProjectedRank = teams$draftDayProjectedRank,
    currentProjectedRank = teams$currentProjectedRank,
    simulatedRank = teams$currentSimulationResults$rank,
    simulatedWins = teams$currentSimulationResults$modeRecord$wins,
    simulatedLosses = teams$currentSimulationResults$modeRecord$losses,
    simulatedTies = teams$currentSimulationResults$modeRecord$ties,
    playoffPct = teams$currentSimulationResults$playoffPct,
    divisionWinPct = teams$currentSimulationResults$divisionWinPct
  )
}
