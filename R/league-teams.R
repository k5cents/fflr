#' Fantasy league teams
#'
#' Return the fantasy team names and their owners.
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
    }
  } else {
    data$teams <- parse_teams(data$teams)
    data$teams$year <- data$seasonId
  }
  return(data$teams)
}

parse_teams <- function(t) {
  t$name <- paste(t$location, t$nickname)
  if (max(unlist(lapply(t$owners, length))) == 1) {
    empty <- which(!unlist(lapply(t$owners, length)))
    if (length(empty) > 0) {
      t$owners[empty] <- NA_character_
    }
    t$owners <- unlist(t$owners)
  }
  names(t)[2] <- "team"
  t$abbrev <- factor(t$abbrev, levels = t$abbrev)
  tibble::as_tibble(t[, c(2, 1, 5, 6)])
}

#' Convert team ID to abbreviation
#'
#' @param id A integer vector of team numbers to convert.
#' @param teams A table of teams from [league_teams()].
#' @return A factor vector of team abbreviations.
#' @examples
#' team_abbrev(id = 6)
#' @export
team_abbrev <- function(id, teams = league_teams(getOption("lid"))) {
  teams$abbrev[match(id, teams$team)]
}
