#' Fantasy league teams
#'
#' Return the fantasy team names and their owners.
#'
#' @inheritParams draft_picks
#' @return A tibble (or list) of league teams.
#' @examples
#' league_teams(lid = 252353)
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
league_teams <- function(lid, old = FALSE, ...) {
  b <- if (old) {
    "leagueHistory/"
  } else {
    sprintf("seasons/%s/segments/0/leagues/", format(Sys.Date(), "%Y"))
  }
  a <- paste0("https://fantasy.espn.com/apis/v3/games/ffl/", b, lid)
  data <- jsonlite::fromJSON(a)
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
