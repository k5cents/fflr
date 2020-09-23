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
league_teams <- function(lid, old = FALSE, ...) {
  data <- ffl_api(lid = lid, old = old, ...)
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
  tibble::as_tibble(t[, c(2, 1, 5, 6)])
}

#' Convert team ID to abbreviation
#'
#' @param lid ESPN League ID passed to [league_teams()] or the table itself.
#' @param id A integer vector of team IDs to convert.
#' @param ... Arguments passed to [league_teams()].
#' @return A character vector of team abbreviations.
#' @examples
#' id2abbrev(252353, id = 5)
id2abbrev <- function(lid = NULL, id, ...) {
  if (is.numeric(lid)) {
    lid <- league_teams(lid, ...)
  }
  id <- lid$abbrev[match(id, lid$team)]
  return(id)
}
