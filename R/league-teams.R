#' Fantasy league teams
#'
#' The teams in a league and their owners.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league teams.
#' @examples
#' league_teams(lid = 252353)
#' @importFrom tibble as_tibble
#' @export
league_teams <- function(lid = getOption("lid"), old = FALSE, ...) {
  data <- ffl_api(lid, old, ...)
  if (old) {
    for (i in seq_along(data$teams)) {
      data$teams[[i]] <- parse_teams(data$teams[[i]])
      data$teams[[i]]$year <- data$seasonId[i]
      data$teams[[i]] <- data$teams[[i]][, c(5, 1:4)]
    }
  } else {
    data$teams <- parse_teams(data$teams)
    data$teams$year <- data$seasonId
    data$teams <- data$teams[, c(5, 1:4)]
  }
  return(data$teams)
}

parse_teams <- function(t) {
  t$name <- paste(t$location, t$nickname)
  names(t)[names(t) == "id"] <- "team"
  t$abbrev <- factor(t$abbrev, levels = t$abbrev)
  if ("owners" %in% names(t)) {
    tibble::as_tibble(t[, c("team", "abbrev", "owners", "name")])
  } else {
    tibble::as_tibble(t[, c("team", "abbrev", "name")])
  }
}

#' Convert team ID to abbreviation
#'
#' @param id A integer vector of team numbers to convert.
#' @param teams A table of teams from [league_teams()].
#' @return A factor vector of team abbreviations.
#' @examples
#' team_abbrev(id = 6, teams = league_teams(lid = 252353))
#' @export
team_abbrev <- function(id, teams = league_teams(lid = getOption("lid"))) {
  teams$abbrev[match(id, teams$team)]
}
