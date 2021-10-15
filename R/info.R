#' Get fantasy football information
#'
#' Information on the current fantasy football season, with functions to quickly
#' access and modify certain information (like the current `seasonId` or
#' `scoringPeriodId`).
#'
#' @return A list of season information.
#' @param offset Add negative or positive values.
#' @examples
#' str(ffl_info())
#' Sys.time()
#' ffl_year()
#' ffl_week(-1)
#' @family Game information
#' @export
ffl_info <- function() {
  x <- try_json("https://fantasy.espn.com/apis/v3/games/ffl")
  list(
    abbrev = x$abbrev,
    active = x$active,
    currentSeason = x$currentSeason$id,
    currentScoringPeriod = x$currentSeason$currentScoringPeriod$id,
    startDate = ffl_date(x$currentSeason$startDate),
    endDate = ffl_date(x$currentSeason$endDate)
  )
}

#' @rdname ffl_info
#' @export
ffl_year <- function(offset = 0) {
  x <- ffl_info()
  x$currentSeason + offset
}

#' @rdname ffl_info
#' @export
ffl_week <- function(offset = 0) {
  x <- ffl_info()
  x$currentScoringPeriod + offset
}

#' List past fantasy football seasons
#'
#' @return A tibble of fantasy football seasons.
#' @examples
#' ffl_seasons()
#' @family Game information
#' @export
ffl_seasons <- function() {
  s <- try_json("https://fantasy.espn.com/apis/v3/games/ffl/seasons")
  s$startDate <- ffl_date(s$startDate)
  s$endDate <- ffl_date(s$endDate)
  s$currentScoringPeriod <- s$currentScoringPeriod$id
  names(s)[3] <- "currentScoringPeriodId"
  as_tibble(s)
}

#' List all fantasy games
#'
#' @return A tibble of fantasy games.
#' @examples
#' espn_games()
#' @family Game information
#' @export
espn_games <- function() {
  g <- try_json("https://fantasy.espn.com/apis/v3/games")
  g$currentSeason$startDate <- ffl_date(g$currentSeason$startDate)
  g$currentSeason$endDate <- ffl_date(g$currentSeason$endDate)
  g$currentSeason <- NULL
  as_tibble(g)
}
