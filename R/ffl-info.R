#' Get fantasy football info
#'
#' Information on the current fantasy football season.
#'
#' @return A list of season information.
#' @examples
#' str(ffl_info())
#' @export
ffl_info <- function() {
  f <- try_api("https://fantasy.espn.com/apis/v3/games/ffl")
  list(
    game = f$abbrev,
    active = f$active,
    year = f$currentSeason$id,
    week = f$currentSeason$currentScoringPeriod$id,
    start_date = ffl_date(f$currentSeason$startDate),
    end_date = ffl_date(f$currentSeason$endDate)
  )
}

#' Current fantasy season
#'
#' @param offset Add negative or positive values.
#' @examples
#' Sys.time()
#' ffl_year()
#' @export
ffl_year <- function(offset = 0) {
  x <- ffl_info()
  x$year + offset
}

#' Current fantasy scoring period
#'
#' @inheritParams ffl_year
#' @examples
#' Sys.time()
#' ffl_week(-1)
#' @export
ffl_week <- function(offset = 0) {
  x <- ffl_info()
  x$week + offset
}

#' List past fantasy seasons
#'
#' @return A tibble fantasy football seasons.
#' @examples
#' ffl_seasons()
#' @importFrom tibble as_tibble
#' @export
ffl_seasons <- function() {
  s <- try_api("https://fantasy.espn.com/apis/v3/games/ffl/seasons")
  s$week <- s$currentScoringPeriod$id
  s$currentScoringPeriod <- NULL
  s$pro_league <- "NFL"
  s$game <- "FFL"
  s <- s[, c(12, 7, 10, 11, 9, 5)]
  names(s)[c(2, 5:6)] <- c("year", "start_date", "end_date")
  s$start_date <- ffl_date(s$start_date)
  s$end_date <- ffl_date(s$end_date)
  tibble::as_tibble(s)
}

#' List all fantasy games
#'
#' @return A tibble fantasy games.
#' @examples
#' espn_games()
#' @importFrom tibble as_tibble
#' @export
espn_games <- function() {
  g <- try_api("https://fantasy.espn.com/apis/v3/games")
  g$start_date <- ffl_date(g$currentSeason$startDate)
  g$end_date <- ffl_date(g$currentSeason$endDate)
  g$currentSeason <- NULL
  g <- g[, c(1:3, 8:11)]
  names(g)[1:5] <- c("game", "active", "year", "pro_league", "pro_sport")
  tibble::as_tibble(g)
}
